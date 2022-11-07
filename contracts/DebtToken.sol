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
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    modifier onlyMinter() {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "must have minter role to mint"
        );
        _;
    }

    function mint(address to, uint256 amount)
        external
        virtual
        override
        onlyMinter
    {
        _mint(to, amount);
        mintedSupply += amount;
    }

    function mintMultiple(address[] memory to, uint256[] memory amount)
        external
        virtual
        override
        onlyMinter
    {
        for (uint256 i = 0; i < to.length; i++) {
            _mint(to[i], amount[i]);
            mintedSupply += amount[i];
        }
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
        onlyMinter
    {
        _burn(who, amount);
        burntSupply += amount;
    }
}
