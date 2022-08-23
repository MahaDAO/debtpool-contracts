// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IStakingContract} from "./interfaces/IStakingContract.sol";
import {ISnapshot} from "./interfaces/ISnapshot.sol";
import {BasicRewardsDistributionRecipient} from "./interfaces/BasicRewardsDistributionRecipient.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract StakingContract is Ownable, IStakingContract, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */
    ISnapshot public snapshot;
    IERC20 public rewardsToken;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    constructor(
        address _rewardsToken,
        address _snapshot,
        uint256 _rewardsDuration
    ) {
        snapshot = ISnapshot(_snapshot);
        rewardsToken = IERC20(_rewardsToken);
        rewardsDuration = _rewardsDuration;

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
    }

    /* ========== VIEWS ========== */

    function totalSupply() public view override returns (uint256) {
        return snapshot.totalDebtSupply();
    }

    function balanceOf(address account) public view override returns (uint256) {
        return snapshot.debtOf(account);
    }

    function lastTimeRewardApplicable() public view override returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view override returns (uint256) {
        if (totalSupply() == 0) return rewardPerTokenStored;
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address who) public view override returns (uint256) {
        return
            balanceOf(who)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[who]))
                .div(1e18)
                .add(rewards[who]);
    }

    function getRewardForDuration() external view override returns (uint256) {
        return rewardRate.mul(rewardsDuration);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function getRewardFor(address who) public override {
        _updateReward(who);
        uint256 reward = rewards[who];
        if (reward > 0) {
            rewards[who] = 0;
            rewardsToken.safeTransfer(who, reward);
            emit RewardPaid(who, reward);
        }
    }

    function _updateReward(address who) internal {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (who != address(0)) {
            rewards[who] = earned(who);
            userRewardPerTokenPaid[who] = rewardPerTokenStored;
        }
    }

    function updateReward(address who) external override {
        require(msg.sender == address(snapshot), "not snapshot");
        _updateReward(who);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function notifyRewardAmount(uint256 reward) external override {
        require(_msgSender() == address(snapshot), "not snapshot");
        _updateReward(address(0));

        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(rewardsDuration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(rewardsDuration);
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = rewardsToken.balanceOf(address(this));
        require(
            rewardRate <= balance.div(rewardsDuration),
            "Provided reward too high"
        );

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(reward);
    }

    function refundTokens(address token) external override onlyOwner {
        IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
    }
}
