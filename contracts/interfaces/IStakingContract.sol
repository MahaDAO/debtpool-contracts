// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IStakingContract {
    function notifyRewardAmount(uint256 reward) external;

    function getRewardFor(address who) external;

    function updateReward(address who) external;

    function lastTimeRewardApplicable() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);

    function earned(address who) external view returns (uint256);

    function getRewardForDuration() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function refundTokens(address token) external;

    /* ========== EVENTS ========== */
    event DefaultInitialization();
    event RewardAdded(uint256 reward);
    event RewardPaid(address indexed user, uint256 reward);
    event Recovered(
        address indexed tokenAddress,
        address indexed to,
        uint256 amount
    );
}
