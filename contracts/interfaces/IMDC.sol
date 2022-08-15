//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IMDC {
    function mint(address to) external returns (uint256);
}