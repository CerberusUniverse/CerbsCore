// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../LevelEnum.sol";

interface ILevel {
    function checkLevel(uint256 _cdoge, uint256 _berus)
        external
        view
        returns (Level lv);

    function checkBonus(Level lv) external view returns (uint256 bonus);
}
