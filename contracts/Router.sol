//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {Epoch} from "./utils/Epoch.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStakingCollector} from "./interfaces/IStakingCollector.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Router is Epoch {
  using SafeMath for uint256;

  IStakingCollector public arthCollector;
  IStakingCollector public arthxCollector;
  IERC20[] public tokens;

  event TokenAdded(address indexed token);
  event TokenReplaced(address indexed token, uint256 index);

  constructor(
    address _arthBoardroom,
    address _arthxBoardroom,
    IERC20[] memory _tokens,
    uint256 _period
  ) Epoch(_period, block.timestamp, 0) {
    arthCollector = IStakingCollector(_arthBoardroom);
    arthxCollector = IStakingCollector(_arthxBoardroom);
    tokens = _tokens;
  }

  function getToken(uint256 index) external view returns (IERC20) {
    return tokens[index];
  }

  function getTokenCount() external view returns (uint256) {
    return tokens.length;
  }

  function addPoolToken(IERC20 token) external onlyOwner {
    tokens.push(token);
    emit TokenAdded(address(token));
  }

  function replacePoolToken(uint256 index, IERC20 token) external onlyOwner {
    tokens[index] = token;
    emit TokenReplaced(address(token), index);
  }

  function step() external checkEpoch {
    // TODO: capture totalValuePresent18 and totalValueAccumulated18 properly

    // send all tokens to the various collector contracts
    for (uint256 i = 0; i < tokens.length; i++) {
      if (address(tokens[i]) == address(0)) continue;
      uint256 balance = tokens[i].balanceOf(address(this));
      if (balance > 0) {
        tokens[i].transfer(address(arthCollector), balance.div(2));
        tokens[i].transfer(address(arthxCollector), balance.div(2));
      }
    }

    arthCollector.step();
    arthxCollector.step();
  }

  function refundTokens(IERC20 token) external onlyOwner {
    uint256 balance = token.balanceOf(address(this));
    token.transfer(_msgSender(), balance);
  }
}
