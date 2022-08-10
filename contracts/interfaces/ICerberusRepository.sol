//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IMDCPropertyStruct.sol";

interface ICerberusRepository {
    function getProperty(uint256 _tokenId)
        external
        view
        returns (IMDCPropertyStruct.Property memory);

    function updateCdoge(uint256 _tokenId, uint256 _amount) external;
}