//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IPoolToken.sol";
import "./interfaces/ISnapshotBoardroom.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Router is AccessControl, ReentrancyGuard {
    using SafeMath for uint256;

    IPoolToken public poolToken;
    ISnapshotBoardroom public arthBoardroom;
    ISnapshotBoardroom public arthxBoardroom;
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");

    modifier onlyAdmin {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "not admin");
        _;
    }

    modifier onlyOracle() {
        require(hasRole(ORACLE_ROLE, _msgSender()), "not oracle");
        _;
    }

    constructor(address _arthBoardroom, address _arthxBoardroom) {
        arthBoardroom = ISnapshotBoardroom(_arthBoardroom);
        arthxBoardroom = ISnapshotBoardroom(_arthxBoardroom);

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ORACLE_ROLE, _msgSender());
    }

    function sendRewards () external onlyOracle {
        uint256 totalValueAccumulated18 = 0;
        uint256 totalValuePresent18 = 0;

        // TODO: capture totalValuePresent18 and totalValueAccumulated18 properly

        // send all tokens to the pool token contract
        for (uint256 i = 0; i < poolToken.getTokenCount(); i++) {
            if (address(poolToken.getToken(i)) == address(0)) continue;
            uint256 balance = poolToken.getToken(i).balanceOf(address(this));
            if (balance > 0) poolToken.getToken(i).transfer(address(poolToken), balance);
        }

        // TODO: calculate the value created and mint new pool tokens and register with the boardroom contracts
        // understand how much value is being transferred and mint accordingly.
        uint256 amountToMint = 100 * 1e18;
        uint256 arthShare = amountToMint.div(2);
        uint256 arthxShare = amountToMint.div(2);

        // once calculated; we mint the pool tokens over to the boardrooms
        poolToken.mint(address(this), amountToMint);
        poolToken.approve(address(arthBoardroom), arthShare);
        poolToken.approve(address(arthxBoardroom), arthxShare);
        arthBoardroom.allocateSeigniorage(arthShare);
        arthxBoardroom.allocateSeigniorage(arthxShare);
    }

    function refundTokens(IERC20 token) external onlyAdmin {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(_msgSender(), balance);
    }
}