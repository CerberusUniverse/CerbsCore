// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/interfaces/IERC721.sol";

interface IMillionDogeClub is IERC721 {
    function mint(address player) external returns (uint256);

    function burn(uint256 tokenId) external;
}
