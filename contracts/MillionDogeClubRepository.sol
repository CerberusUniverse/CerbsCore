//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interface/IMillionDogeClub.sol";
import "./interface/ILevel.sol";
import "./interface/IBerus.sol";
import "./owner/Manage.sol";
import "./LevelEnum.sol";

contract MillionDogeClubRepository is Manage, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;

    IERC20 public cdogeToken;
    IBerus public berusToken;
    IMillionDogeClub public mdc;
    ILevel public levelInterface;

    uint256 public baseDivider = 1000;

    uint256 public baseDoge;
    uint256 public baseBerus;
    mapping(uint256 => Property) private property;
    mapping(uint256 => History[]) private sellRecored;
    mapping(uint256 => EnumerableSet.UintSet) private _ownedTokens;

    event SetDogeToken(address manage, address _token);
    event SetBerusToken(address manage, address _token);
    event SetMdc(address manage, address _mdc);
    event SetLevel(address manage, address _level);
    event SetBaseDivider(address manage, uint256 _base);
    event SetBaseDoge(address manage, uint256 _base);
    event SetBaseBerus(address manage, uint256 _base);
    event SetProperty(address _manage, uint256 _tokenId);
    event UpdateProperty(address _manage, uint256 _tokenId);
    event DepositBerus(address _owner, uint256 _tokenId, uint256 _amount);
    event UpdateCdoge(uint256 _tokenId, uint256 _amount);
    event TacKBack(address recipient, uint256 amount, uint256 blocktime);

    constructor(
        address _cdoge,
        address _berus,
        address _mdc,
        address _level
    ) {
        cdogeToken = IERC20(_cdoge);
        berusToken = IBerus(_berus);
        mdc = IMillionDogeClub(_mdc);
        levelInterface = ILevel(_level);
    }

    function baseRepos() private view returns (Property memory) {
        Property memory pro = Property(baseDoge, baseBerus, Level.Soldier);
        return pro;
    }

    /**
     * set nft property
     */
    function setProperty(uint256 _tokenId) external onlyManage nonReentrant {
        emit SetProperty(msg.sender, _tokenId);
        property[_tokenId] = baseRepos();
    }

    /**
     * update nft property
     */
    function updateProperty(uint256 _tokenId, Property calldata _pro)
        external
        onlyManage
        nonReentrant
    {
        emit UpdateProperty(msg.sender, _tokenId);
        property[_tokenId] = _pro;
    }

    /**
     * return nft property
     */
    function getProperty(uint256 _tokenId)
        external
        view
        returns (Property memory)
    {
        return property[_tokenId];
    }

    /**
     * update cdoge
     */
    function updateCdoge(uint256 _tokenId, uint256 _amount)
        external
        onlyManage
        nonReentrant
    {
        Property storage pro = property[_tokenId];
        pro.cdoge += _amount;
        pro.level = levelInterface.checkLevel(pro.cdoge, pro.berus);
        emit UpdateCdoge(_tokenId, _amount);
    }

    /**
     * deposit berus
     */
    function depositBerus(uint256 _tokenId, uint256 _amount)
        external
        nonReentrant
    {
        berusToken.transferFrom(msg.sender, address(this), _amount);
        Property storage pro = property[_tokenId];
        pro.berus += _amount;
        pro.level = levelInterface.checkLevel(pro.cdoge, pro.berus);
        emit DepositBerus(msg.sender, _tokenId, _amount);
    }

    /**
     * burn cnft get cdoge
     */
    function burn(uint256 _tokenId) external nonReentrant {
        Property memory pro = property[_tokenId];
        cdogeToken.transfer(msg.sender, pro.cdoge);
        mdc.burn(_tokenId);
        berusToken.burn(pro.berus);
        delete property[_tokenId];
    }

    function tokenHashRate(uint256 _tokenId) external view returns (uint256) {
        Property memory pro = property[_tokenId];
        // get token level
        uint256 lv = levelInterface.checkBonus(pro.level);
        // calc current rate
        return pro.cdoge.mul(lv).div(baseDivider).add(pro.cdoge);
    }

    function setBaseDoge(uint256 _base) external onlyManage {
        require(_base >= 0, "base is zero");
        baseDoge = _base;
        emit SetBaseDoge(msg.sender, _base);
    }

    function setBaseBerus(uint256 _base) external onlyManage {
        require(_base >= 0, "base is zero");
        baseBerus = _base;
        emit SetBaseBerus(msg.sender, _base);
    }

    function setDogeToken(address _token) external onlyManage {
        require(_token != address(0), "token address is zero");
        cdogeToken = IERC20(_token);
        emit SetDogeToken(msg.sender, _token);
    }

    function setBerusToken(address _token) external onlyManage {
        require(_token != address(0), "token address is zero");
        berusToken = IBerus(_token);
        emit SetBerusToken(msg.sender, _token);
    }

    function setMdc(address _token) external onlyManage {
        require(_token != address(0), "token address is zero");
        mdc = IMillionDogeClub(_token);
        emit SetMdc(msg.sender, _token);
    }

    function setLevel(address _level) external onlyManage {
        require(_level != address(0), "level address is zero");
        levelInterface = ILevel(_level);
        emit SetLevel(msg.sender, _level);
    }

    function setBaseDivider(uint256 _base) external onlyManage {
        require(_base > 0, "_base divider is zero");
        baseDivider = _base;
        emit SetBaseDivider(msg.sender, _base);
    }

    function takeBackBerus(address recipient) external onlyManage {
        uint256 amount = berusToken.balanceOf(address(this));
        berusToken.transfer(recipient, amount);
        emit TacKBack(recipient, amount, block.timestamp);
    }

    function takeBackDoge(address recipient) external onlyManage {
        uint256 amount = cdogeToken.balanceOf(address(this));
        cdogeToken.transfer(recipient, amount);
        emit TacKBack(recipient, amount, block.timestamp);
    }
}
