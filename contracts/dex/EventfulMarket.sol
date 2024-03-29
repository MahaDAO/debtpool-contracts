// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

import {ERC20} from "./ERC20.sol";

contract EventfulMarket {
    event LogItemUpdate(uint256 id); // event is used for offer, cancel and buy functions

    // event used in buy function
    event LogTrade(
        uint256 pay_amt,
        address indexed pay_gem,
        uint256 buy_amt,
        address indexed buy_gem
    );

    // event used in offer function
    event LogMake(
        bytes32 indexed id,
        bytes32 indexed pair,
        address indexed maker,
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt,
        uint64 timestamp
    );

    // used for bump function
    event LogBump(
        bytes32 indexed id,
        bytes32 indexed pair,
        address indexed maker,
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt,
        uint64 timestamp
    );

    // event used in buy function
    event LogTake(
        bytes32 id,
        bytes32 indexed pair,
        address indexed maker,
        ERC20 pay_gem,
        ERC20 buy_gem,
        address indexed taker,
        uint128 take_amt,
        uint128 give_amt,
        uint64 timestamp
    );

    // event is used for cancel function
    event LogKill(
        bytes32 indexed id,
        bytes32 indexed pair,
        address indexed maker,
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt,
        uint64 timestamp
    );
}
