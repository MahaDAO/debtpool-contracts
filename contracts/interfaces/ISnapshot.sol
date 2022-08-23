// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ISnapshot {
    function totalSupply() external view returns (uint256);

    function totalSupplyDebtx() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function balanceOfDebtx(address account) external view returns (uint256);

    function register(uint256 amount, address who) external;
}
