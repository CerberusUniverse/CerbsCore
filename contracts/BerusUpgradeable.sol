// contracts/BerusUpgradeable.sol
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

pragma solidity ^0.8.2;

contract BerusUpgradeable is Initializable, OwnableUpgradeable, ERC20Upgradeable {
    uint constant Precision = 1 ether;
    function initialize(uint totalSupply) external initializer {
        __Ownable_init();
        __ERC20_init("Cerberus Berus Token", "BERUS");
        _mint(_msgSender(), totalSupply * Precision);
    }
}