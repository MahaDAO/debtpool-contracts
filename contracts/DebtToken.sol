//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {IDebtToken} from "./interfaces/IDebtToken.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControlEnumerable} from "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract DebtToken is AccessControlEnumerable, ERC20, IDebtToken {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public mintedSupply;
    uint256 public burntSupply;

    constructor() ERC20("ARTH Debt Token", "ARTH-DP") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function mint(address to, uint256 amount)
        external
        virtual
        override
        onlyRole(MINTER_ROLE)
    {
        _mint(to, amount);
        mintedSupply += amount;
    }

    function grantMintRole(address to) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setupRole(MINTER_ROLE, to);
    }

    function burn(uint256 amount) external virtual override {
        _burn(_msgSender(), amount);
        burntSupply += amount;
    }

    function burnAll() external virtual override {
        burntSupply += balanceOf(_msgSender());
        _burn(_msgSender(), balanceOf(_msgSender()));
    }

    function burnFrom(address who, uint256 amount)
        external
        virtual
        override
        onlyRole(MINTER_ROLE)
    {
        _burn(who, amount);
        burntSupply += amount;
    }
}
