// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract ERC20Events {
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
}
