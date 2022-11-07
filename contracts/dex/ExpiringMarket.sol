// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

import {DSAuth} from "./DSAuth.sol";
import {SimpleMarket} from "./SimpleMarket.sol";

contract ExpiringMarket is DSAuth, SimpleMarket {
    uint64 public close_time;
    bool public stopped;

    // after close_time has been reached, no new offers are allowed
    modifier can_offer {
        require(!isClosed(), "after close_time has been reached, no new offers are allowed");
        _;
    }

    // after close, no new buys are allowed
    modifier can_buy(uint id) {
        require(isActive(id), "after close can_buy - id is not active");
        require(!isClosed(), "after close no new buys are allowed");
        _;
    }

    // after close, anyone can cancel an offer
    modifier can_cancel(uint id) {
        require(isActive(id), "can_cancel offer - id is not active");
        require(isClosed() || (msg.sender == getOwner(id)), "can_cancel offer");
        _;
    }

    function ExpiringMarket(uint64 _close_time)
        public
    {
        close_time = _close_time;
    }

    function isClosed() public constant returns (bool closed) {
        return stopped || getTime() > close_time;
    }

    function getTime() public constant returns (uint64) {
        return uint64(now);
    }

    function stop() public auth {
        stopped = true;
    }
}
