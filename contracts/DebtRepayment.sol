// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {ISnapshot} from "./interfaces/ISnapshot.sol";

interface IStakingContract {
    function notifyRewardAmount(uint256 amount) external;

    function updateReward(address who) external;
}

// user -> debt in fragments -> debtx in fragments -> gons
// fragments = 1000
// gonsPerFragment = 1000

contract DebtRepayment is Initializable, AccessControl, ISnapshot {
    using SafeMath for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public totalFragments;
    mapping(address => uint256) public fragmentsOf;

    mapping(address => uint256) public userDebtxFactor;

    IStakingContract public rewards;

    uint256 public constant MAX_FACTOR = 1e18; // 100%
    uint256 public constant MIN_FACTOR = 1e16; // 1%
    uint256 public constant GONS_PERCISION = 1e18;
    uint256 public gonsPerFragment = 1e18;

    function initialize(address _rewards) external initializer {
        rewards = IStakingContract(_rewards);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function register(uint256 amount, address who) external override {
        require(fragmentsOf[who] == 0, "already minted");
        _checkRole(MINTER_ROLE, _msgSender());

        userDebtxFactor[who] = MAX_FACTOR;
        uint256 debtx = convertFragmentToValues(
            convertDebtToDebtX(amount, userDebtxFactor[who])
        );
        fragmentsOf[who] = convertValueToFragments(debtx);

        totalFragments += fragmentsOf[who];
        rewards.updateReward(who);
    }

    function balanceOf(address who) public view override returns (uint256) {
        return convertFragmentToValues(fragmentsOf[who]);
    }

    function debtOf(address who) public view override returns (uint256) {
        return convertDebtXToDebt(balanceOf(who), userDebtxFactor[who]);
    }

    function totalSupply() public view override returns (uint256) {
        return convertFragmentToValues(totalFragments);
    }

    function rebaseDebt(uint256 newDebtxFactor) external {
        address who = _msgSender();
        require(fragmentsOf[who] > 0, "balance = 0");

        totalFragments -= fragmentsOf[who];

        uint256 debt = convertDebtXToDebt(balanceOf(who), userDebtxFactor[who]);
        uint256 newdebt = convertDebtToDebtX(debt, newDebtxFactor);
        fragmentsOf[who] = convertValueToFragments(newdebt);
        userDebtxFactor[who] = newDebtxFactor;

        totalFragments += fragmentsOf[who];

        rewards.updateReward(who);
    }

    function distribute(uint256 amount) external {
        // todo: find out how much to reduce the gons by
        uint256 gonsToReduceBy = 1e17; // 10%?
        gonsPerFragment = gonsPerFragment.sub(gonsToReduceBy);
        rewards.notifyRewardAmount(amount);
    }

    // @dev spits out a range between 100 - 1% in e18
    function factorMultiplierE18(uint256 factor) public pure returns (uint256) {
        require(factor <= MAX_FACTOR, "above MAX_FACTOR");
        return Math.max(MIN_FACTOR, ((MAX_FACTOR - factor)**2) / 1e18);
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

    function convertFragmentToValues(uint256 fragments)
        public
        view
        returns (uint256 gons)
    {
        gons = fragments.mul(GONS_PERCISION).div(gonsPerFragment);
    }

    function convertValueToFragments(uint256 gons)
        public
        view
        returns (uint256 fragments)
    {
        fragments = gons.mul(gonsPerFragment).div(GONS_PERCISION);
    }
}
