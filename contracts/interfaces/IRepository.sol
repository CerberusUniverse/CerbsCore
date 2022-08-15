// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../LevelEnum.sol";

interface IRepository {
    function getProperty(uint256 _tokenId)
        external
        view
        returns (Property memory);

    function setProperty(uint256 _tokenId) external;

    function updateCdoge(uint256 _tokenId, uint256 _amount) external;

    function tokenHashRate(uint256 _tokenId) external view returns (uint256);
}
