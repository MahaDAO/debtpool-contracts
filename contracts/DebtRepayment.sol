// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {ISnapshot} from "./interfaces/ISnapshot.sol";

interface IStakingContract {
    function notifyRewardAmount(uint256 amount) external;

    function updateReward(address who) external;
}

contract DebtRepayment is AccessControl, ISnapshot {
    using SafeMath for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 totalFragments;
    mapping(address => uint256) public fragmentBalances;
    mapping(address => uint256) private _userFactor;

    IStakingContract public rewards;

    uint256 public constant MAX_FACTOR = 1e18; // 100%
    uint256 public constant MIN_FACTOR = 1e16; // 1%
    uint256 public gonsPerFragment = 1e8;

    constructor(address _rewards) {
        rewards = IStakingContract(_rewards);
    }

    function register(uint256 amount, address who) external override {
        require(fragmentBalances[who] == 0, "already minted");
        _checkRole(MINTER_ROLE, _msgSender());

        fragmentBalances[who] = convertDebtToDebtX(amount, MAX_FACTOR);
        _userFactor[who] = MAX_FACTOR;

        totalFragments += balanceOf(who);
        rewards.updateReward(who);
    }

    function balanceOf(address who) public view override returns (uint256) {
        return fragmentBalances[who] * gonsPerFragment;
    }

    function totalSupply() public view override returns (uint256) {
        return totalFragments * gonsPerFragment;
    }

    function debtOf(address who) external view returns (uint256) {
        return convertDebtXToDebt(fragmentBalances[who], _userFactor[who]);
    }

    function rebase(uint256 factor) external {
        address who = _msgSender();
        require(fragmentBalances[who] >= 0, "balance = 0");

        totalFragments -= balanceOf(who);

        // update debt values
        uint256 debt = convertDebtXToDebt(
            fragmentBalances[who],
            _userFactor[who]
        );
        fragmentBalances[who] = convertDebtToDebtX(debt, factor);

        totalFragments += balanceOf(who);
        rewards.updateReward(who);
    }

    function distribute(uint256 amount) external {
        // todo: find out how much to reduce the gons by
        uint256 gonsToReduceBy = 100;
        gonsPerFragment = gonsPerFragment.sub(gonsToReduceBy);
        rewards.notifyRewardAmount(amount);
    }

    // @dev spits out a range between 100 - 1% in e18
    function factorMultiplierE18(uint256 factor) public pure returns (uint256) {
        return Math.max(MIN_FACTOR, (MAX_FACTOR - factor)**2 / 1e18);
    }

    function convertDebtToDebtX(uint256 debt, uint256 factor)
        public
        pure
        returns (uint256 debtx)
    {
        debtx = (debt * factorMultiplierE18(factor)) / 1e18;
    }

    function convertDebtXToDebt(uint256 debtx, uint256 factor)
        public
        pure
        returns (uint256 debt)
    {
        debt = (debtx * 1e18) / factorMultiplierE18(factor);
    }
}
