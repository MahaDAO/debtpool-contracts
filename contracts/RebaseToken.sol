// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Rebase} from "./ERC20Rebase.sol";

contract RebaseToken is ERC20Rebase, Ownable{

  IERC20 public arthdp = IERC20(0x2057d85f2eA34a3ff78E4fE092979DBF4dd32766);

  /**
  * @dev Allow a user to burn a number of wrapped tokens and withdraw the corresponding number of underlying tokens.
  */
  function withdrawTo(address account, uint256 amount) public virtual returns (bool) {
      _burn(_msgSender(), amount);
      SafeERC20.safeTransfer(arthdp, account, amount);
      // emit Withdraw(account, amount);
      return true;
  }

  function withdraw(uint256 amount) public virtual returns (bool) {
      return withdrawTo(_msgSender(), amount);
  }
}
