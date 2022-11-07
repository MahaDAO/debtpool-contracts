// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

import {ERC20Events} from "./ERC20Events.sol";

contract ERC20 is ERC20Events {
    function totalSupply() public view returns (uint256);

    function balanceOf(address guy) public view returns (uint256);

    function allowance(address src, address guy) public view returns (uint256);

    function approve(address guy, uint256 wad) public returns (bool);

    function transfer(address dst, uint256 wad) public returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) public returns (bool);
}
