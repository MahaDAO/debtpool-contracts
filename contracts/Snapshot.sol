// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {ISnapshot} from "./interfaces/ISnapshot.sol";
import {Operator} from "./Operator.sol";

contract Snapshot is Operator, ISnapshot {
  using Address for address;
  using SafeMath for uint256;

  mapping(address => uint256) private _balances;
  uint256 private _totalSupply;

  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return _balances[account];
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

  function _register(uint256 amount, address who) internal virtual {
    require(amount > 0, "Snapshot: Cannot stake 0");

    _totalSupply = _totalSupply.add(amount);
    _balances[who] = _balances[who].add(amount);
    emit Staked(who, amount);
  }

  event Staked(address indexed user, uint256 amount);
}
