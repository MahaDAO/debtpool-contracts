// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Context, Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {Operator} from "./Operator.sol";
import {ITokenStore} from "./interfaces/ITokenStore.sol";
import {IERC20Burnable} from "./interfaces/IERC20Burnable.sol";

contract TokenStore is ITokenStore, Operator {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== EVENTS ========== */

    event StakeEnableChanged(bool newFlag, bool oldFlag);

    event TokenChanged(
        address indexed operator,
        address oldToken,
        address newToken
    );

    /* ========== STATE VARIABLES ========== */

    address public token;

    bool public stakeEnabled = true;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    /* ========== Modifier ============== */

    modifier ensureStakeIsEnabled() {
        require(stakeEnabled, "Store: stake is disabled");
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(IERC20 _token) {
        token = address(_token);
    }

    /* ========== VIEW FUNCTIONS ========== */

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function toggleStakeEnabled(bool flag) public onlyOwner {
        stakeEnabled = flag;
        emit StakeEnableChanged(flag, !flag);
    }

    // gov
    function setToken(address newToken) public onlyOwner {
        address oldToken = token;
        token = newToken;
        emit TokenChanged(msg.sender, oldToken, newToken);
    }

    // logic
    function stake(uint256 amount)
        public
        virtual
        override
        ensureStakeIsEnabled
    {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        IERC20Burnable(token).burnFrom(msg.sender, amount);
    }
}
