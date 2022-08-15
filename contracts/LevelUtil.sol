//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;
import "./LevelEnum.sol";
import "./owner/Manage.sol";

contract LevelUtil is Manage {
    uint256 public soldierBonus;
    uint256 public generalBonus;
    uint256 public chieftainBonus;
    uint256 public kingBonus;
    uint256 public astronautBonus;
    uint256 public alienBonus;
    uint256 public martianBonus;
    uint256 public collectorBonus;

    uint256[2] public levelSoldier;
    uint256[2] public levelGeneral;
    uint256[2] public levelChieftain;
    uint256[2] public levelKing;
    uint256[2] public levelAstronaut;
    uint256[2] public levelAlien;
    uint256[2] public levelMartian;
    uint256[2] public levelCollector;

    constructor() {
        soldierBonus = 10;
        generalBonus = 20;
        chieftainBonus = 30;
        kingBonus = 69;
        astronautBonus = 80;
        alienBonus = 90;
        martianBonus = 100;
        collectorBonus = 169;
        levelSoldier = [1e21, 1e22];
        levelGeneral = [2e21, 2e22];
        levelChieftain = [1e22, 1e23];
        levelKing = [5e22, 5e23];
        levelAstronaut = [1e23, 1e24];
        levelAlien = [2e23, 2e24];
        levelMartian = [1e24, 1e25];
        levelCollector = [1e24, 1e25];
    }

    function setSoldierBonus(uint256 _bonus) external onlyManage {
        require(_bonus > 0, "bonus is zero");
        soldierBonus = _bonus;
    }

    function setGeneralBonus(uint256 _bonus) external onlyManage {
        require(_bonus > 0, "bonus is zero");
        generalBonus = _bonus;
    }

    function setChieftainBonus(uint256 _bonus) external onlyManage {
        require(_bonus > 0, "bonus is zero");
        chieftainBonus = _bonus;
    }

    function setKingBonus(uint256 _bonus) external onlyManage {
        require(_bonus > 0, "bonus is zero");
        kingBonus = _bonus;
    }

    function setAstronautBonus(uint256 _bonus) external onlyManage {
        require(_bonus > 0, "bonus is zero");
        astronautBonus = _bonus;
    }

    function setAlienBonus(uint256 _bonus) external onlyManage {
        require(_bonus > 0, "bonus is zero");
        alienBonus = _bonus;
    }

    function setMartianBonus(uint256 _bonus) external onlyManage {
        require(_bonus > 0, "bonus is zero");
        martianBonus = _bonus;
    }

    function setCollectorBonus(uint256 _bonus) external onlyManage {
        require(_bonus > 0, "bonus is zero");
        collectorBonus = _bonus;
    }

    function setLevelSoldier(uint256[2] calldata _limit) external onlyManage {
        levelSoldier = _limit;
    }

    function setLevelGeneral(uint256[2] calldata _limit) external onlyManage {
        levelGeneral = _limit;
    }

    function setLevelChieftains(uint256[2] calldata _limit)
        external
        onlyManage
    {
        levelChieftain = _limit;
    }

    function setLevelKing(uint256[2] calldata _limit) external onlyManage {
        levelKing = _limit;
    }

    function setLevelAstronaut(uint256[2] calldata _limit) external onlyManage {
        levelAstronaut = _limit;
    }

    function setLevelAlien(uint256[2] calldata _limit) external onlyManage {
        levelAlien = _limit;
    }

    function setLevelMartian(uint256[2] calldata _limit) external onlyManage {
        levelMartian = _limit;
    }

    function setLevelCollector(uint256[2] calldata _limit) external onlyManage {
        levelCollector = _limit;
    }

    /**
     * Doge Soldier 1-1,000 ,1k-10k
     * Doge General 1,001-2,000 ,10k-20k
     * Doge Chieftain 2,001-10,000 ,20k-100k
     * Doge King 10,001-50,000 ,100k-500k
     * Doge Astronaut 50,001-100,000 ,500k-1M
     * Doge Alien 100,001-200,000, 1M-2M
     * Doge Martian 200,001-1,000,000 ,2M-10M
     * Doge Collector 1,000,001+ ,10M+
     */
    function checkLevel(uint256 _cdoge, uint256 _berus)
        external
        view
        returns (Level lv)
    {
        // Soldier 1-1,000 ,1k-10k
        if (_cdoge <= levelSoldier[0] || _berus <= levelSoldier[1]) {
            return Level.Soldier;
        }
        // General 1,001-2,000 ,10k-20k
        if (_cdoge <= levelGeneral[0] || _berus <= levelGeneral[1]) {
            return Level.General;
        }
        // Chieftain 2,001-10,000 ,20k-100k
        if (_cdoge <= levelChieftain[0] || _berus <= levelChieftain[1]) {
            return Level.Chieftain;
        }
        // King 10,001-50,000 ,100k-500k
        if (_cdoge <= levelKing[0] || _berus <= levelKing[1]) {
            return Level.King;
        }
        // Astronaut 50,001-100,000 ,500k-1M
        if (_cdoge <= levelAstronaut[0] || _berus <= levelAstronaut[1]) {
            return Level.Astronaut;
        }
        // Alien 100,001-200,000, 1M-2M
        if (_cdoge <= levelAlien[0] || _berus <= levelAlien[1]) {
            return Level.Alien;
        }
        // Martian 200,001-1,000,000 ,2M-10M
        if (_cdoge <= levelMartian[0] || _berus <= levelMartian[1]) {
            return Level.Martian;
        }
        //  Collector 1,000,001+ ,10M+
        if (_cdoge > levelCollector[0] || _berus > levelCollector[1]) {
            return Level.Collector;
        }
    }

    /**
     * Doge Soldier 1%
     * Doge General 2%
     * Doge Chieftain 3%
     * Doge King 6.9%
     * Doge Astronaut 8%
     * Doge Alien 9%
     * Doge Martian 10%
     * Doge Collector 16.9%
     */
    function checkBonus(Level lv) external view returns (uint256 bonus) {
        if (lv == Level.Soldier) {
            return soldierBonus;
        }
        if (lv == Level.General) {
            return generalBonus;
        }
        if (lv == Level.Chieftain) {
            return chieftainBonus;
        }
        if (lv == Level.King) {
            return kingBonus;
        }
        if (lv == Level.Astronaut) {
            return astronautBonus;
        }
        if (lv == Level.Alien) {
            return alienBonus;
        }
        if (lv == Level.Martian) {
            return martianBonus;
        }
        if (lv == Level.Collector) {
            return collectorBonus;
        }
    }
}
