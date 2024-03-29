// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

import {EventfulMarket} from "./EventfulMarket.sol";
import {DSMath} from "./DSMath.sol";
import {ERC20} from "./ERC20.sol";

contract SimpleMarket is EventfulMarket, DSMath {
    uint256 public last_offer_id;

    mapping(uint256 => OfferInfo) public offers;

    bool locked;

    struct OfferInfo {
        uint256 pay_amt;
        ERC20 pay_gem;
        uint256 buy_amt;
        ERC20 buy_gem;
        address owner;
        uint64 timestamp;
    }

    modifier can_buy(uint256 id) {
        require(isActive(id), "SM can_buy id inctive");
        _;
    }

    modifier can_cancel(uint256 id) {
        require(isActive(id), "can_cancel id inactive");
        require(getOwner(id) == msg.sender, "can_cancel getOwner");
        _;
    }

    modifier can_offer() {
        _;
    }

    modifier synchronized() {
        require(!locked, "synchro-shouldn't be locked");
        locked = true;
        _;
        locked = false;
    }

    function isActive(uint256 id) public constant returns (bool active) {
        return offers[id].timestamp > 0;
    }

    function getOwner(uint256 id) public constant returns (address owner) {
        return offers[id].owner;
    }

    function getOffer(uint256 id)
        public
        constant
        returns (
            uint256,
            ERC20,
            uint256,
            ERC20
        )
    {
        OfferInfo offer = offers[id];
        return (offer.pay_amt, offer.pay_gem, offer.buy_amt, offer.buy_gem);
    }

    // ---- Public entrypoints ---- //

    function bump(bytes32 id_) public can_buy(uint256(id_)) {
        uint256 id = uint256(id_);
        emit LogBump(
            id_,
            keccak256(offers[id].pay_gem, offers[id].buy_gem),
            offers[id].owner,
            offers[id].pay_gem,
            offers[id].buy_gem,
            uint128(offers[id].pay_amt),
            uint128(offers[id].buy_amt),
            offers[id].timestamp
        );
    }

    // Accept given `quantity` of an offer. Transfers funds from caller to
    // offer maker, and from market to caller.
    function buy(uint256 id, uint256 quantity)
        public
        can_buy(id)
        synchronized
        returns (bool)
    {
        OfferInfo memory offer = offers[id];
        uint256 spend = mul(quantity, offer.buy_amt) / offer.pay_amt;

        require(uint128(spend) == spend, "buy-spend not equal");
        require(uint128(quantity) == quantity, "buy-quantity not equal");

        // For backwards semantic compatibility.
        if (
            quantity == 0 ||
            spend == 0 ||
            quantity > offer.pay_amt ||
            spend > offer.buy_amt
        ) {
            return false;
        }

        offers[id].pay_amt = sub(offer.pay_amt, quantity);
        offers[id].buy_amt = sub(offer.buy_amt, spend);
        require(
            offer.buy_gem.transferFrom(msg.sender, offer.owner, spend),
            "buy-transferFrom failed"
        );
        require(
            offer.pay_gem.transfer(msg.sender, quantity),
            "buy-transfer failed"
        );

        emit LogItemUpdate(id);
        emit LogTake(
            bytes32(id),
            keccak256(offer.pay_gem, offer.buy_gem),
            offer.owner,
            offer.pay_gem,
            offer.buy_gem,
            msg.sender,
            uint128(quantity),
            uint128(spend),
            uint64(now)
        );
        emit LogTrade(quantity, offer.pay_gem, spend, offer.buy_gem);

        if (offers[id].pay_amt == 0) {
            delete offers[id];
        }

        return true;
    }

    // Cancel an offer. Refunds offer maker.
    function cancel(uint256 id)
        public
        can_cancel(id)
        synchronized
        returns (bool success)
    {
        // read-only offer. Modify an offer by directly accessing offers[id]
        OfferInfo memory offer = offers[id];
        delete offers[id];

        require(
            offer.pay_gem.transfer(offer.owner, offer.pay_amt),
            "cancel-transfer failed"
        );

        emit LogItemUpdate(id);
        emit LogKill(
            bytes32(id),
            keccak256(offer.pay_gem, offer.buy_gem),
            offer.owner,
            offer.pay_gem,
            offer.buy_gem,
            uint128(offer.pay_amt),
            uint128(offer.buy_amt),
            uint64(now)
        );

        success = true;
    }

    function kill(bytes32 id) public {
        require(cancel(uint256(id)), "kill-cancel failed");
    }

    function make(
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt
    ) public returns (bytes32 id) {
        return bytes32(offer(pay_amt, pay_gem, buy_amt, buy_gem));
    }

    // Make a new offer. Takes funds from the caller into market escrow.
    function offer(
        uint256 pay_amt,
        ERC20 pay_gem,
        uint256 buy_amt,
        ERC20 buy_gem
    ) public can_offer synchronized returns (uint256 id) {
        require(uint128(pay_amt) == pay_amt, "offer-pay_amt should be equal");
        require(uint128(buy_amt) == buy_amt, "offer-buy_amt should be equal");
        require(pay_amt > 0, "offer-pay_amt should be >0");
        require(
            pay_gem != ERC20(0x0),
            "offer-pay_gem shouldn't be = ERC20(0x0)"
        );
        require(buy_amt > 0, "offer-buy_amt should be >0");
        require(
            buy_gem != ERC20(0x0),
            "offer-buy_gem shouldn't be = ERC20(0x0)"
        );
        require(pay_gem != buy_gem, "offer-pay_gem shouldn't be = buy_gem");

        OfferInfo memory info;
        info.pay_amt = pay_amt;
        info.pay_gem = pay_gem;
        info.buy_amt = buy_amt;
        info.buy_gem = buy_gem;
        info.owner = msg.sender;
        info.timestamp = uint64(now);
        id = _next_id();
        offers[id] = info;

        require(
            pay_gem.transferFrom(msg.sender, this, pay_amt),
            "new-transferFrom failed"
        );

        emit LogItemUpdate(id);
        emit LogMake(
            bytes32(id),
            keccak256(pay_gem, buy_gem),
            msg.sender,
            pay_gem,
            buy_gem,
            uint128(pay_amt),
            uint128(buy_amt),
            uint64(now)
        );
    }

    function take(bytes32 id, uint128 maxTakeAmount) public {
        require(
            buy(uint256(id), maxTakeAmount),
            "take fn - calling buy function failed"
        );
    }

    function _next_id() internal returns (uint256) {
        last_offer_id++;
        return last_offer_id;
    }
}
