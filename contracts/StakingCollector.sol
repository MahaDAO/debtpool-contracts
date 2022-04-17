// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStakingChild} from "./interfaces/IStakingChild.sol";
import {IStakingCollector} from "./interfaces/IStakingCollector.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * The staking collector is an automated distribution contract, that distributes rewards in the contract's
 * balance at every step.
 */
contract StakingCollector is Ownable, IStakingCollector {
  using SafeMath for uint256;

  address[] public tokens;
  address router;

  mapping(address => address) public tokenStakingPool;

  event TokenRegistered(address indexed token, address stakingPool);
  event TokenUpdated(address indexed token, address stakingPool);
  event RouterChanged(address indexed who, address old, address _router);

  function registerToken(address token, address stakingPool)
    external
    onlyOwner
  {
    require(tokenStakingPool[token] == address(0), "token already exists");

    tokenStakingPool[token] = stakingPool;
    emit TokenRegistered(token, stakingPool);

    tokens.push(token);
  }

  function setRouter(address _router) external onlyOwner {
    emit RouterChanged(_msgSender(), router, _router);
    router = _router;
  }

  function updateToken(address token, address stakingPool) external onlyOwner {
    require(tokenStakingPool[token] != address(0), "token doesn't exists");
    tokenStakingPool[token] = stakingPool;
    emit TokenUpdated(token, stakingPool);
  }

  function step() external override {
    require(_msgSender() == router, "not router");

    for (uint256 index = 0; index < tokens.length; index++) {
      IERC20 token = IERC20(tokens[index]);

      // figure out how much tokens to send
      uint256 balanceToSend = token.balanceOf(address(this));

      if (balanceToSend > 0) {
        // send token and notify the staking contract
        IStakingChild stakingPool = IStakingChild(
          tokenStakingPool[tokens[index]]
        );
        token.transfer(address(stakingPool), balanceToSend);
        stakingPool.notifyRewardAmount(balanceToSend);
      }
    }
  }

  function refundTokens(address token) external onlyOwner {
    IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
  }
}
