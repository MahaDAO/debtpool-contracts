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
  uint256[] public tokenRates;

  event TokenAdded(address indexed token);
  event TokenReplaced(address indexed token, uint256 index);

  constructor(
    address _arthCollector,
    address _arthxCollector,
    IERC20[] memory _tokens,
    uint256[] memory _tokenRates,
    uint256 _period
  ) Epoch(_period, block.timestamp, 0) {
    arthCollector = IStakingCollector(_arthCollector);
    arthxCollector = IStakingCollector(_arthxCollector);
    tokens = _tokens;
    tokenRates = _tokenRates;
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

  function setCollectors(
    IStakingCollector _arthCollector,
    IStakingCollector _arthxCollector
  ) external onlyOwner {
    arthCollector = _arthCollector;
    arthxCollector = _arthxCollector;
  }

  function replacePoolToken(uint256 index, IERC20 token) external onlyOwner {
    tokens[index] = token;
    emit TokenReplaced(address(token), index);
  }

  function step() external {
    // TODO: capture totalValuePresent18 and totalValueAccumulated18 properly

    // send all tokens to the various collector contracts
    for (uint256 i = 0; i < tokens.length; i++) {
      if (address(tokens[i]) == address(0)) continue;

      uint256 tokenBalance = tokens[i].balanceOf(address(this));
      uint256 ratePerEpoch = tokenRates[i];
      uint256 balanceToSend;

      // if a rate was not set, then we send everything in the contract
      if (ratePerEpoch == 0) balanceToSend = tokenBalance;
      else {
        require(tokenBalance > ratePerEpoch, "not enough tokens");
        balanceToSend = ratePerEpoch;
      }

      if (balanceToSend > 0) {
        tokens[i].transfer(address(arthCollector), balanceToSend.div(2));
        tokens[i].transfer(address(arthxCollector), balanceToSend.div(2));
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
