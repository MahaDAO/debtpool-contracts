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

// user -> debt in fragments -> debtx in fragments -> gons
// fragments = 1000
// gonsPerFragment = 1000

contract DebtRepayment is AccessControl, ISnapshot {
    using SafeMath for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public totalFragments;
    uint256 public totalDebtxFragments;
    mapping(address => uint256) public debtFragmentBalances;
    mapping(address => uint256) private _userFactor;

    IStakingContract public rewards;

    uint256 public constant MAX_FACTOR = 1e18; // 100%
    uint256 public constant MIN_FACTOR = 1e16; // 1%
    uint256 public constant GONS_PERCISION = 1e18;

    uint256 public gonsPerFragment = 1e18;

    constructor(address _rewards) {
        rewards = IStakingContract(_rewards);
    }

    function register(uint256 amount, address who) external override {
        require(debtFragmentBalances[who] == 0, "already minted");
        _checkRole(MINTER_ROLE, _msgSender());

        debtFragmentBalances[who] = amount;
        _userFactor[who] = MAX_FACTOR;

        totalFragments += amount;
        totalDebtxFragments += balanceOfDebtx(who);
        rewards.updateReward(who);
    }

    function balanceOf(address who) public view override returns (uint256) {
        return convertFragmentToGons(balanceOfDebtx(who));
    }

    function totalSupply() public view override returns (uint256) {
        return convertFragmentToGons(totalFragments);
    }

    function totalSupplyDebtx() public view override returns (uint256) {
        return convertFragmentToGons(totalDebtxFragments);
    }

    function balanceOfDebtx(address who)
        public
        view
        override
        returns (uint256)
    {
        return convertDebtXToDebt(debtFragmentBalances[who], _userFactor[who]);
    }

    function rebaseDebt(uint256 debtxFactor) external {
        address who = _msgSender();
        require(debtFragmentBalances[who] >= 0, "balance = 0");

        totalDebtxFragments -= balanceOfDebtx(who);
        _userFactor[who] = debtxFactor;

        totalDebtxFragments += balanceOfDebtx(who);
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
        require(factor <= MAX_FACTOR, "above MAX_FACTOR");
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

    function convertFragmentToGons(uint256 fragments)
        public
        view
        returns (uint256 gons)
    {
        gons = fragments.mul(GONS_PERCISION).div(gonsPerFragment);
    }

    function convertFragmentToValues(uint256 gons)
        public
        view
        returns (uint256 fragments)
    {
        fragments = gons.mul(gonsPerFragment).div(GONS_PERCISION);
    }
}
