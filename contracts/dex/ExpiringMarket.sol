// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

import {DSAuth} from "./DSAuth.sol";
import {SimpleMarket} from "./SimpleMarket.sol";

contract ExpiringMarket is DSAuth, SimpleMarket {
    // // after close_time has been reached, no new offers are allowed
    // // after close, no new buys are allowed
    // modifier can_buy(uint256 id) {
    //     require(isActive(id), "after close can_buy - id is not active");
    //     _;
    // }
    // // after close, anyone can cancel an offer
    // modifier can_cancel(uint256 id) {
    //     require(isActive(id), "can_cancel offer - id is not active");
    //     _;
    // }
}
