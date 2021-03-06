// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IStakingChild} from "./interfaces/IStakingChild.sol";
import {IStakingMaster} from "./interfaces/IStakingMaster.sol";
import {ISnapshot} from "./interfaces/ISnapshot.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * The staking master contract is the high level contract responsible
 * for interfacing with the end user. It takes into account, account balances,
 * withdrawing rewards and updating staking balances.
 */
contract StakingMaster is AccessControl, ReentrancyGuard, IStakingMaster {
    using SafeERC20 for IERC20;

    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");
    bytes32 public constant POOL_MAINTAINER_ROLE =
        keccak256("POOL_MAINTAINER_ROLE");

    ISnapshot public snapshot;
    address[] public pools;
    mapping(address => bool) public isPoolValid;

    event PoolAdded(address indexed pool);
    event SnapshotChanged(address indexed pool);

    constructor(address _governance, address _snapshot) {
        _setupRole(DEFAULT_ADMIN_ROLE, _governance);
        _setupRole(UPDATER_ROLE, _governance);

        _setupRole(UPDATER_ROLE, _msgSender());
        _setupRole(POOL_MAINTAINER_ROLE, _msgSender());

        snapshot = ISnapshot(_snapshot);
    }

    function totalSupply() external view override returns (uint256) {
        return snapshot.totalSupply();
    }

    function balanceOf(address who) external view override returns (uint256) {
        return snapshot.balanceOf(who);
    }

    function getReward() external override nonReentrant {
        for (uint256 index = 0; index < pools.length; index++) {
            IStakingChild pool = IStakingChild(pools[index]);
            pool.updateReward(_msgSender());
            pool.getRewardFor(_msgSender());
        }
    }

    function _addPool(address pool) internal {
        require(!isPoolValid[pool], "pool already added");
        pools.push(pool);
        isPoolValid[pool] = true;
        emit PoolAdded(pool);
    }

    function addPool(address pool)
        external
        override
        onlyRole(POOL_MAINTAINER_ROLE)
    {
        _addPool(pool);
    }

    function addPools(address[] memory _pools)
        external
        override
        onlyRole(POOL_MAINTAINER_ROLE)
    {
        for (uint256 index = 0; index < _pools.length; index++) {
            _addPool(_pools[index]);
        }
    }

    function updateRewardFor(address who)
        external
        override
        onlyRole(UPDATER_ROLE)
    {
        for (uint256 index = 0; index < pools.length; index++) {
            IStakingChild pool = IStakingChild(pools[index]);
            pool.updateReward(who);
        }
    }

    function updateRewardForMultiple(address[] memory whom)
        external
        override
        onlyRole(UPDATER_ROLE)
    {
        for (uint256 index1 = 0; index1 < whom.length; index1++) {
            address who = whom[index1];
            for (uint256 index = 0; index < pools.length; index++) {
                IStakingChild pool = IStakingChild(pools[index]);
                pool.updateReward(who);
            }
        }
    }

    function refundTokens(address token)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        IERC20(token).transfer(
            _msgSender(),
            IERC20(token).balanceOf(address(this))
        );
    }

    function setSnapshot(address _escrow)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        snapshot = ISnapshot(_escrow);
        emit SnapshotChanged(_escrow);
    }
}
