//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

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
    uint256 cdoge;
    uint256 berus;
    Level level;
}

struct History {
    address seller;
    Level level;
}
