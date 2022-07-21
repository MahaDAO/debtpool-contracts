// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {ISnapshot} from "./interfaces/ISnapshot.sol";
import {IERC20BurnerMinter} from "./interfaces/IERC20BurnerMinter.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Snapshot is Ownable, ISnapshot {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20BurnerMinter public token;
    mapping(address => uint256) private _balances;
    uint256 private gonsTotalSupply;

    uint256 private _totalSupply;
    uint256 public gonsPerFragment = 1e6;
    uint256 public gonsDecimals = 6;
 
    /* ========== CONSTRUCTOR ========== */

    constructor(address _dptoken) public {
        token = IERC20BurnerMinter(_dptoken);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply.mul(gonsPerFragment).div(gonsPercision());
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account].mul(gonsPerFragment).div(gonsPercision());
    }

    function gonsPercision() public view virtual returns (uint256) {
        return 10**gonsDecimals;
    }

    function register(uint256 amount, address who) external override onlyOwner {
        _register(amount, who);
    }

    function registerMultiple(uint256[] memory amount, address[] memory who)
        external
        override
        onlyOwner
    {
        for (uint256 index = 0; index < amount.length; index++) {
            _register(amount[index], who[index]);
        }
    }

    function deposit(uint256 amount) external {
        _deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        _withdraw(msg.sender, amount);
    }

    // consider some amount paid back
    function payback(uint256 amount) external onlyOwner {
        uint256 percentageToRemove18 = amount.mul(1e18).div(_totalSupply);
        uint256 percentageToKeep18 = uint256(1e18).sub(percentageToRemove18);
        gonsDecimals = percentageToKeep18.mul(gonsDecimals).div(1e18);

        token.burn(amount);
    }

    function _register(uint256 amount, address who) internal virtual {
        require(amount > 0, "Snapshot: Cannot stake 0");
        _mint(who, amount);
    }

    function _deposit(address account, uint256 amount) internal {
        require(account != address(0), "deposit to the zero address");

        uint256 gonValues = amount.mul(gonsPercision()).div(gonsPerFragment);
        _totalSupply = _totalSupply.add(gonValues);
        _balances[account] = _balances[account].add(gonValues);

        token.transferFrom(account, address(this), amount);
        emit Deposited(account, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "mint to the zero address");

        uint256 gonValues = amount.mul(gonsPercision()).div(gonsPerFragment);
        _totalSupply = _totalSupply.add(gonValues);
        _balances[account] = _balances[account].add(gonValues);

        token.mint(address(this), amount);
        emit Minted(account, amount);
    }

    function _withdraw(address account, uint256 amount) internal {
        require(account != address(0), "ARTH: burn from the zero address");

        uint256 gonValues = amount.mul(gonsPercision()).div(gonsPerFragment);

        _balances[account] = _balances[account].sub(
            gonValues,
            "ARTH: burn amount exceeds balance"
        );

        _totalSupply = _totalSupply.sub(gonValues);
        token.transfer(account, amount);
        emit Withdraw(account, amount);
    }

    event Deposited(address indexed user, uint256 amount);
    event Minted(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
}
