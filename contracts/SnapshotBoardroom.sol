// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {ISnapshotBoardroom} from "./interfaces/ISnapshotBoardroom.sol";
import {Operator} from "./Operator.sol";
import {IPoolToken} from "./interfaces/IPoolToken.sol";

contract SnapshotBoardroom is ReentrancyGuard, Operator, ISnapshotBoardroom {
    using Address for address;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ========== DATA STRUCTURES ========== */
    struct Boardseat {
        uint256 lastSnapshotIndex;
        uint256 rewardEarned;
    }

    struct BoardSnapshot {
        uint256 rewardPerShare;
        uint256 rewardReceived;
        uint256 time;
    }

    /* ========== STATE VARIABLES ========== */
    IPoolToken public rewardToken;
    BoardSnapshot[] public boardHistory;
    mapping(address => Boardseat) public directors;
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;

    /* ========== CONSTRUCTOR ========== */
    constructor(IPoolToken _pooltoken) {
        rewardToken = _pooltoken;
        BoardSnapshot memory genesisSnapshot = BoardSnapshot({
            time: block.number,
            rewardReceived: 0,
            rewardPerShare: 0
        });
        boardHistory.push(genesisSnapshot);
    }

    /* ========== Modifiers =============== */
    modifier directorExists() {
        require(
            balanceOf(msg.sender) > 0,
            "Boardroom: The director does not exist"
        );
        _;
    }

    modifier updateReward(address director) {
        if (director != address(0)) {
            Boardseat memory seat = directors[director];
            seat.rewardEarned = earned(director);
            seat.lastSnapshotIndex = latestSnapshotIndex();
            directors[director] = seat;
        }
        _;
    }

    /* ========== VIEW FUNCTIONS ========== */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function latestSnapshotIndex() public view returns (uint256) {
        return boardHistory.length.sub(1);
    }

    function getLatestSnapshot() internal view returns (BoardSnapshot memory) {
        return boardHistory[latestSnapshotIndex()];
    }

    function getLastSnapshotIndexOf(address director)
        public
        view
        returns (uint256)
    {
        return directors[director].lastSnapshotIndex;
    }

    function getLastSnapshotOf(address director)
        internal
        view
        returns (BoardSnapshot memory)
    {
        return boardHistory[getLastSnapshotIndexOf(director)];
    }

    function rewardPerShare() public view returns (uint256) {
        return getLatestSnapshot().rewardPerShare;
    }

    function earned(address director) public view returns (uint256) {
        uint256 latestRPS = getLatestSnapshot().rewardPerShare;
        uint256 storedRPS = getLastSnapshotOf(director).rewardPerShare;

        return
            balanceOf(director).mul(latestRPS.sub(storedRPS)).div(1e18).add(
                directors[director].rewardEarned
            );
    }

    /* ========== MUTATIVE FUNCTIONS ========== */
    function setRewardToken(address _poolToken) public onlyOwner {
        emit TokenChanged(msg.sender, address(rewardToken), _poolToken);
        rewardToken = IPoolToken(_poolToken);
    }

    function register(uint256 amount, address who) public onlyOwner {
        _register(amount, who);
    }

    function registerMultiple(uint256[] memory amount, address[] memory who)
        public
        onlyOwner
    {
        for (uint256 index = 0; index < amount.length; index++) {
            _register(amount[index], who[index]);
        }
    }

    function _register(uint256 amount, address who)
        internal
        virtual
        updateReward(who)
    {
        require(amount > 0, "Boardroom: Cannot stake 0");

        _totalSupply = _totalSupply.add(amount);
        _balances[who] = _balances[who].add(amount);
        emit Staked(who, amount);
    }


    function claimReward() public updateReward(msg.sender) {
        uint256 reward = directors[msg.sender].rewardEarned;
        if (reward > 0) {
            directors[msg.sender].rewardEarned = 0;
            rewardToken.withdrawTo(reward, msg.sender);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function allocateSeigniorage(uint256 amount) external override onlyOperator {
        require(amount > 0, "Boardroom: Cannot allocate 0");
        require(
            totalSupply() > 0,
            "Boardroom: Cannot allocate when totalSupply is 0"
        );

        uint256 prevRPS = getLatestSnapshot().rewardPerShare;
        uint256 nextRPS = prevRPS.add(amount.mul(1e18).div(totalSupply()));

        BoardSnapshot memory newSnapshot = BoardSnapshot({
            time: block.number,
            rewardReceived: amount,
            rewardPerShare: nextRPS
        });
        boardHistory.push(newSnapshot);

        rewardToken.transferFrom(msg.sender, address(this), amount);
        emit RewardAdded(msg.sender, amount);
    }

    function withdrawERC20(IERC20 _token, uint256 amount) external onlyOwner {
        _token.transfer(msg.sender, amount);
    }

    event RewardAdded(address indexed user, uint256 reward);
    event RewardPaid(address indexed user, uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event TokenChanged(
        address indexed operator,
        address oldToken,
        address newToken
    );
    event Withdrawn(address indexed user, uint256 amount);
}