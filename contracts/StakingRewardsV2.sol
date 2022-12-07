// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IDebtToken} from "./interfaces/IDebtToken.sol";
import {AccessControlEnumerable} from "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

// NOTE: V2 allows setting of rewardsDuration in constructor
contract StakingRewardsV2 is AccessControlEnumerable, ReentrancyGuard {
    using SafeMath for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant NOTIFIER_ROLE = keccak256("NOTIFIER_ROLE");

    /* ========== STATE VARIABLES ========== */

    IERC20 public rewardsToken;
    IDebtToken public debtToken;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public burnRate;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _rewardsToken,
        address _debtToken,
        uint256 _burnRate // the rate at which tokens are burn
    ) {
        rewardsToken = IERC20(_rewardsToken);
        debtToken = IDebtToken(_debtToken);
        burnRate = _burnRate;
        rewardsDuration = 1;

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(NOTIFIER_ROLE, _msgSender());
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /* ========== VIEWS ========== */

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(_totalSupply)
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            _balances[account]
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function getRewardForDuration() external view returns (uint256) {
        return rewardRate.mul(rewardsDuration);
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
        debtToken.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function mintMultiple(address[] memory who, uint256[] memory amount)
        external
        virtual
        onlyRole(MINTER_ROLE)
    {
        uint256 mintedSupply;

        for (uint256 i = 0; i < who.length; i++) {
            mintedSupply += amount[i];

            _totalSupply = _totalSupply.add(amount[i]);
            _balances[who[i]] = _balances[who[i]].add(amount[i]);
            emit Staked(who[i], amount[i]);
        }

        debtToken.mint(address(this), mintedSupply);
    }

    function exit() public nonReentrant updateReward(msg.sender) {
        getReward();
        _withdraw(msg.sender, _balances[msg.sender]);
    }

    function getReward() public nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
            _burnBalance(msg.sender, reward);
        }
    }

    function _withdraw(address who, uint256 amount) internal {
        _totalSupply = _totalSupply.sub(amount);
        _balances[who] = _balances[who].sub(amount);
        debtToken.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function _burnBalance(address who, uint256 rewardAmount) internal {
        uint256 burnAmount = rewardAmount.mul(burnRate).div(1e18);
        _totalSupply = _totalSupply.sub(burnAmount);
        _balances[who] = _balances[who].sub(burnAmount);
        debtToken.burn(burnAmount);
        emit Burnt(msg.sender, burnAmount);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function notifyRewardAmount(uint256 reward)
        external
        onlyRole(NOTIFIER_ROLE)
        updateReward(address(0))
    {
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

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Burnt(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
}
