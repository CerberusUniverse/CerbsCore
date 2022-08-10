//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IMDCPropertyStruct {
    enum Level {
        Soldier,
        General,
        Chieftain,
        King,
        Astronaut,
        Alien,
        Martian,
        Collector
    }
    struct Property {
        uint256 Cdoge;
        uint256 Berus;
        IMDCPropertyStruct.Level level;
    }
    struct History {
        address Seller;
        IMDCPropertyStruct.Level Level;
    }
    struct userData {
        address Parent;
        uint256 defaultReferer;
        uint256 Refererd;
        bool Stake;
        IMDCPropertyStruct.Level Level;
        uint256 Share;
    }
}