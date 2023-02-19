
// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";
import {MatchingMarket} from "./MatchingMarket.sol";
import {ERC20} from "./ERC20.sol";

contract UIHelper { 

    struct Orders {
        uint256 pay_amt;
        address pay_gem;
        uint256 buy_amt;
        address buy_gem;
        address owner;
        uint64 timestamp;
        uint256 id;
    }

    function getBestBuyOrders(MatchingMarket market, address baseAsset, address quoteAsset, uint256 limit) external view returns (Orders[] memory ret) {
        Orders[] memory buyOrders = new Orders[](limit);
        uint256 limitIndex = 0;

        for (uint256 index = 0; (index < market.last_offer_id() || index == market.last_offer_id()) && limitIndex < limit; index++) {
            if(market.isActive(index)){
                (uint256 pay_amt, address pay_gem, uint256 buy_amt, address buy_gem, address owner, uint64 timestamp) = market.offers(index);
                if(buy_gem == baseAsset && pay_gem == quoteAsset){

                    buyOrders[limitIndex].pay_amt = pay_amt;
                    buyOrders[limitIndex].pay_gem = pay_gem;
                    buyOrders[limitIndex].buy_amt = buy_amt;
                    buyOrders[limitIndex].buy_gem = buy_gem;
                    buyOrders[limitIndex].owner = owner;
                    buyOrders[limitIndex].timestamp = timestamp;
                    buyOrders[limitIndex].id = index;

                    limitIndex++;
                }
            }
        }
        return buyOrders;
    }

    function getBestSellOrders(MatchingMarket market, address baseAsset, address quoteAsset, uint256 limit) external view returns (Orders[] memory ret) {
        Orders[] memory sellOrders = new Orders[](limit);
        uint256 limitIndexSell = 0;
        address testquoteAsset = quoteAsset;
        address testbaseAsset = baseAsset;
        for (uint256 index = 0; (index < market.last_offer_id() || index == market.last_offer_id())&& limitIndexSell < limit; index++) {
            if(market.isActive(index)){
                (uint256 pay_amt, address pay_gem, uint256 buy_amt, address buy_gem, address owner, uint64 timestamp) = market.offers(index);
                if(buy_gem == quoteAsset && pay_gem == baseAsset){

                    sellOrders[limitIndexSell].pay_amt = pay_amt;
                    sellOrders[limitIndexSell].pay_gem = pay_gem;
                    sellOrders[limitIndexSell].buy_amt = buy_amt;
                    sellOrders[limitIndexSell].buy_gem = buy_gem;
                    sellOrders[limitIndexSell].owner = owner;
                    sellOrders[limitIndexSell].timestamp = timestamp;
                    sellOrders[limitIndexSell].id = index;

                    limitIndexSell++;

                }
            }
        }
        return sellOrders;

    }

}