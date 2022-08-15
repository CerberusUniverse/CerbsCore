//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IMDCPropertyStruct.sol";

interface ICerberusReferralV3 {
    function fetchUserData(address user) external view returns (IMDCPropertyStruct.userData memory);
    function updateReferral(address seller, uint256 amount) external returns (bool);
    function updateStake(address staker, IMDCPropertyStruct.Level level, bool stake) external returns (bool);
}