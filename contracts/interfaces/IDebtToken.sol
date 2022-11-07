// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDebtToken is IERC20 {
    function mint(address to, uint256 amount) external virtual;

    function mintMultiple(address[] memory to, uint256[] memory amount)
        external
        virtual;

    function burn(uint256 amount) external virtual;

    function burnAll() external virtual;

    function burnFrom(address who, uint256 amount) external virtual;
}
