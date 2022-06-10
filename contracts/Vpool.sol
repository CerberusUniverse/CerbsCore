// contracts/Vpool.sol
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "../libs/Math.sol";

pragma solidity ^0.8.2;

contract Vpool is Context {
    // current level of Vpool
    uint256 private _curLevel;

    // left token amount on the current level
    uint256 private _leftToken;

    // total amount of token in Vpool
    uint256 private _totalToken;

    // max anchor token amount to deposit on each level
    uint256 private _maxAnchor;

    IERC20 private _anchor;
    IERC20 private _token;
    uint constant Precision = 1 ether;

    constructor(uint256 maxAnchor, address anchor, address token) {
        _curLevel = 1;
        _leftToken = 0;
        _totalToken = 0;
        _maxAnchor = maxAnchor;
        _anchor = IERC20(anchor);
        _token = IERC20(token);
    }

    // deposit token to Vpool
    function insertToken(uint256 amount) external {
        amount = amount / Precision;
        require(amount > 0, "have to insert more than 1");

        _token.transferFrom(_msgSender(), address(this), amount * Precision);
        _totalToken += amount;
        // get Vpool full level
        uint256 fullLevel = getLevelByTotalToken(_totalToken);
        uint256 fullLevelToken = getTokenByFullLevel(fullLevel);
        _leftToken = _totalToken - fullLevelToken;

        // token fills the full level perfectly
        if (_leftToken == 0) {
            _curLevel = fullLevel;
        } else {
            // put left token to current level
            _curLevel = fullLevel + 1;
        }
    }

    // deposit anchor to Vpool to exchange token
    function depositAnchor(uint256 amount) external {
        amount = amount / Precision;
        require(amount > 0, "have to insert more than 1");

        _anchor.transferFrom(_msgSender(), address(this), amount * Precision);
        // anchor required to clean the current level
        uint256 anchorRequired = _leftToken / _curLevel;
        if (_leftToken % _curLevel > 0) anchorRequired++;

        // exchange anchor for token
        if (amount < anchorRequired) {
            uint256 exchangedToken = amount * _curLevel;
            _leftToken -= exchangedToken;
            _totalToken -= exchangedToken;
            _token.transfer(_msgSender(), exchangedToken * Precision);
        } else if (amount == anchorRequired) {
            uint256 exchangedToken = _leftToken;
            _curLevel--;
            _leftToken = _curLevel * _maxAnchor;
            _totalToken -= exchangedToken;
            _token.transfer(_msgSender(), exchangedToken * Precision);
        } else {
            uint256 totalTokenBefore = _totalToken;
            uint256 belowAmount = amount - anchorRequired;
            uint256 levelsDeposited = belowAmount / _maxAnchor;
            uint256 curAnchorDeposited = belowAmount % _maxAnchor;
            _curLevel = _curLevel - 1 - levelsDeposited;
            _leftToken = _curLevel * (_maxAnchor - curAnchorDeposited);
            _totalToken = getTokenByFullLevel(_curLevel-1) + _leftToken;
            _token.transfer(_msgSender(), (totalTokenBefore - _totalToken) * Precision);
        }
    }

    function getLevelByTotalToken(uint256 totalToken) public view returns (uint256) {
        // Sn=(_maxAnchor + levels * _maxAnchor)*levels/2
        // (levels * levels + levels) * _maxAnchor / 2 = Sn
        // levels^2 + levels = 2*Sn/_maxAnchor
        uint256 n = 2 * totalToken / _maxAnchor;
        return (Math.floorSqrt(4 * n + 1) - 1) / 2;
    }

    function getTokenByFullLevel(uint256 levels) public view returns (uint256) {
        // Sn=(_maxAnchor + levels * _maxAnchor)*levels/2
        return (levels + levels * levels) * _maxAnchor / 2;
    }

    function getCurLevel() external view returns (uint256) {
        return _curLevel;
    }

    function getLeftToken() external view returns (uint256) {
        return _leftToken;
    }

    function getTotalToken() external view returns (uint256) {
        return _totalToken;
    }

    function getMaxAnchor() external view returns (uint256) {
        return _maxAnchor;
    }
}