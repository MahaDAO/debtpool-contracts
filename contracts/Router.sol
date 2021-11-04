//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IPoolToken.sol";
import "./interfaces/ISnapshotBoardroom.sol";

contract Router is AccessControl {
    using SafeMath for uint256;

    IPoolToken public poolToken;
    ISnapshotBoardroom public arthBoardroom;
    ISnapshotBoardroom public arthxBoardroom;

    constructor(address _arthBoardroom, address _arthxBoardroom) {
        arthBoardroom = ISnapshotBoardroom(_arthBoardroom);
        arthxBoardroom = ISnapshotBoardroom(_arthxBoardroom);
    }

    function sendRewards () external {
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
        poolToken.mint(address(arthBoardroom), 100 * 1e18 / 2);
        poolToken.mint(address(arthxBoardroom), 100 * 1e18 / 2);
    }
}