// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract StakingPayback is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20[] public rewardsToken;
    IERC20 public stakingToken;
    mapping(address => uint256) public periodFinish;
    mapping(address => uint256) public rewardRate;
    mapping(address => uint256) public lastUpdateTime;
    uint256 public rewardsDuration;
    address public rewardsDistribution;

    mapping(address => uint256) public rewardPerTokenStored;
    mapping(address => mapping(address => uint256))
        public userRewardPerTokenPaid;
    mapping(address => mapping(address => uint256)) public rewards; // who -> token -> amount

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _rewardsDistribution,
        IERC20[] memory _rewardsToken,
        address _stakingToken,
        uint256 _rewardsDuration
    ) {
        rewardsToken = _rewardsToken;
        stakingToken = IERC20(_stakingToken);
        rewardsDistribution = _rewardsDistribution;
        rewardsDuration = _rewardsDuration;
    }

    /* ========== VIEWS ========== */

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable(address token)
        public
        view
        returns (uint256)
    {
        return Math.min(block.timestamp, periodFinish[token]);
    }

    function rewardPerToken(address token) public view returns (uint256) {
        if (_totalSupply == 0) return rewardPerTokenStored[token];
        return
            rewardPerTokenStored[token].add(
                lastTimeRewardApplicable(token)
                    .sub(lastUpdateTime[token])
                    .mul(rewardRate[token])
                    .mul(1e18)
                    .div(_totalSupply)
            );
    }

    function earned(address token, address account)
        public
        view
        returns (uint256)
    {
        return
            _balances[account]
                .mul(
                    rewardPerToken(token).sub(
                        userRewardPerTokenPaid[account][token]
                    )
                )
                .div(1e18)
                .add(rewards[token][account]);
    }

    function getRewardForDuration(address token)
        external
        view
        returns (uint256)
    {
        return rewardRate[token].mul(rewardsDuration);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(uint256 amount)
        external
        nonReentrant
        updateReward(msg.sender)
    {
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount)
        public
        nonReentrant
        updateReward(msg.sender)
    {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getReward(address token)
        public
        nonReentrant
        updateReward(msg.sender)
    {
        uint256 reward = rewards[msg.sender][token];
        if (reward > 0) {
            rewards[msg.sender][token] = 0;
            IERC20(token).safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function exit() external {
        withdraw(_balances[msg.sender]);

        for (uint256 index = 0; index < rewardsToken.length; index++) {
            getReward(address(rewardsToken[index]));
        }
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function notifyRewardAmount(address token, uint256 reward)
        external
        onlyRewardsDistribution
        updateReward(address(0))
    {
        if (block.timestamp >= periodFinish[token]) {
            rewardRate[token] = reward.div(rewardsDuration);
        } else {
            uint256 remaining = periodFinish[token].sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate[token]);
            rewardRate[token] = reward.add(leftover).div(rewardsDuration);
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(
            rewardRate[token] <= balance.div(rewardsDuration),
            "Provided reward too high"
        );

        lastUpdateTime[token] = block.timestamp;
        periodFinish[token] = block.timestamp.add(rewardsDuration);
        emit RewardAdded(reward);
    }

    /* ========== MODIFIERS ========== */

    function _updateRewardToken(address token, address account) internal {
        rewardPerTokenStored[token] = rewardPerToken(token);
        lastUpdateTime[token] = lastTimeRewardApplicable(token);
        if (account != address(0)) {
            rewards[account][token] = earned(token, account);
            userRewardPerTokenPaid[account][token] = rewardPerTokenStored[
                token
            ];
        }
    }

    modifier updateReward(address account) {
        for (uint256 index = 0; index < rewardsToken.length; index++) {
            _updateRewardToken(address(rewardsToken[index]), account);
        }
        _;
    }

    modifier onlyRewardsDistribution() {
        require(
            msg.sender == rewardsDistribution,
            "Caller is not RewardsDistribution contract"
        );
        _;
    }
    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
}
