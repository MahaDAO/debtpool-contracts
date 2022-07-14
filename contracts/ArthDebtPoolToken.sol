// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControlEnumerable} from "@openzeppelin/contracts/access/AccessControlEnumerable.sol"; 
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol"; 

contract ArthDebtPoolToken is AccessControlEnumerable, ERC20 {
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  uint256 private _totalCiculatingSupply;

  constructor() ERC20("ARTH Debt Pool", "ARTH-DP"){
    _setupRole(MINTER_ROLE, _msgSender());
  }

  function mintDPToken(address to, uint256 amount) public virtual {
    require(hasRole(MINTER_ROLE, _msgSender()), "must have minter role to mint");
    _mint(to, amount);
    _totalCiculatingSupply += amount;
  }

  function mintMultiple(address[] memory to, uint256[] memory amount) public virtual {
    require(hasRole(MINTER_ROLE, _msgSender()), "must have minter role to mint");
    for (uint256 i = 0; i < to.length; i++) {
        _mint(to[i], amount[i]);
        _totalCiculatingSupply += amount[i];
    }
  }

  function burnDPToken(uint256 amount) public virtual {
    _burn(msg.sender, amount);
  }

  function getTotalCirculatingSupply() public view returns (uint256){
    return _totalCiculatingSupply;
  }
}
