// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "../LevelEnum.sol";

interface IReferral {
    function updateStake(
        address staker,
        Level level,
        bool stake
    ) external returns (bool);
}
