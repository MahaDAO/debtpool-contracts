// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract DSAuthority {
    function canCall(
        address src,
        address dst,
        bytes4 sig
    ) public view returns (bool);
}
