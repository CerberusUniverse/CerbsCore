//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IMDCPropertyStruct.sol";
import "./interfaces/IMDC.sol";

contract CerberusMDCReferralV3 {

    event e_setParent(address msgsender, address parent);
    event e_Purchase(address msgsender);
    event e_updateReferral(address seller, uint256 amount);
    event e_updateStake(address staker, IMDCPropertyStruct.Level level, bool stake);
    event e_shareWithdraw(address withdrawer);
    event e_withdraw(uint256 amount);
    event e_setOwner(address owner);
    event e_setMarket(address market);
    event e_setStake(address stake);
    event e_setPurchaseShutdown(bool should);
    event e_setShareWithdrawShutdown(bool should);
    event e_setMaster(address _master);
    event e_setPaytype(address paytype);
    event e_setPrice(uint256 price);
    event e_setMDC(address mdc);
    event e_setDefaultReferer(uint256 defaultreferer);
    event e_setMaxDepth(uint256 maxdepth);
    event e_setLevelShouldShared(uint256 level, uint256 percent);
    event e_setUserDefaultReferer(address user, uint256 defaultreferer);
    using SafeMath for uint256;

    address private Owner;
    modifier onlyOwner {
        require(msg.sender == Owner, 'The caller is not owner');
        _;
    }

    bool private lock;
    modifier Lock {
        require(!lock, 'This is a reentry attack');
        lock = true;
        _;
        lock = false;
    }

    bool private shouldPurchaseShutdown;
    modifier purchaseShutdown {
        require(!shouldPurchaseShutdown, 'The purchase shutdown');
        _;
    }

    bool private shouldShareWithdrawShutdown;
    modifier shareWithdrawShutdown {
        require(!shouldShareWithdrawShutdown, 'The shareWithdraw shutdown');
        _;
    }

    address private Market;
    modifier onlyMarket {
        require(msg.sender == Market, 'The caller is not market');
        _;
    }

    address private Stake;
    modifier onlyStake {
        require(msg.sender == Stake, 'The caller is not stake');
        _;
    }

    struct userData {
        address Parent;
        uint256 defaultReferer;
        uint256 Refererd;
        bool Stake;
        IMDCPropertyStruct.Level Level;
        uint256 Share;
    }
    mapping(address => userData) private User;

    address private Master;
    address private Paytype;
    uint256 private Price;
    address private MDC;
    uint256 private defaultReferer;
    uint256 private maxDepth;

    mapping(uint256 => uint256) private levelShouldShared;

    constructor() {
        Initialize();
    }

    function Initialize() internal {
        Owner = msg.sender;
    }

    function fetchOwner() external view returns (address) {
        return Owner;
    }

    function fetchPurchaseShutdown() external view returns (bool) {
        return shouldPurchaseShutdown;
    }

    function fetchShareWithdrawShutdown() external view returns (bool) {
        return shouldShareWithdrawShutdown;
    }

    function fetchMarket() external view returns (address) {
        return Market;
    }

    function fetchStake() external view returns (address) {
        return Stake;
    }

    function fetchMaster() external view returns (address) {
        return Master;
    }

    function fetchPaytype() external view returns (address) {
        return Paytype;
    }
    
    function fetchPrice() external view returns (uint256) {
        return Price;
    }

    function fetchMDC() external view returns (address) {
        return MDC;
    }

    function fetchDefaultReferer() external view returns (uint256) {
        return defaultReferer;
    }

    function fetchMaxDepth() external view returns (uint256) {
        return maxDepth;
    }

    function fetchUserData(address user) external view returns (userData memory) {
        return User[user];
    }

    function fetchLevelShouldShared(uint256 level) external view returns (uint256) {
        return levelShouldShared[level];
    }

    function fetchLevelShouldShared(IMDCPropertyStruct.Level level) internal view returns (uint256) {
        if(level == IMDCPropertyStruct.Level.Soldier) return levelShouldShared[0];
        if(level == IMDCPropertyStruct.Level.General) return levelShouldShared[1];
        if(level == IMDCPropertyStruct.Level.Chieftain) return levelShouldShared[2];
        if(level == IMDCPropertyStruct.Level.King) return levelShouldShared[3];
        if(level == IMDCPropertyStruct.Level.Astronaut) return levelShouldShared[4];
        if(level == IMDCPropertyStruct.Level.Alien) return levelShouldShared[5];
        if(level == IMDCPropertyStruct.Level.Martian) return levelShouldShared[6];
        if(level == IMDCPropertyStruct.Level.Collector) return levelShouldShared[7];
        return 0;
    }

    function Max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    function setParent(address _parent) external returns (bool) {
        require(msg.sender != Master, 'The master can not set parent');
        require(_parent != msg.sender, 'The referrer can not be yourself');
        require(User[msg.sender].Parent == address(0), 'You already set parent');
        require(User[_parent].defaultReferer != 0, 'The referer defaultReferer can not be zero');

        userData storage parent = User[_parent];
        uint256 maxReferer = Max(parent.defaultReferer, defaultReferer);
        require(parent.Refererd < maxReferer, 'The refererd is full');

        parent.Refererd ++;

        User[msg.sender].Parent = _parent;

        emit e_setParent(msg.sender, _parent);

        return true;
    }

    function Purchase() external purchaseShutdown() Lock() returns (bool) {
        require(msg.sender != Master, 'The master can not purchase');
        require(User[msg.sender].Parent != address(0), 'You can not purchase without parent');

        userData storage msgsender = User[msg.sender];
        if(msgsender.defaultReferer == 0) msgsender.defaultReferer = defaultReferer;

        IERC20(Paytype).transferFrom(msg.sender, address(this), Price);
        IMDC(MDC).mint(msg.sender);

        emit e_Purchase(msg.sender);

        return true;
    }

    function updateReferral(address seller, uint256 amount) external onlyMarket() Lock() returns (bool) {

        uint256 Loop = 0;
        address loopParent = User[seller].Parent;
        uint256 alreadyShared = 0;

        while(Loop < maxDepth) {
            Loop = Loop.add(1);

            userData storage user = User[loopParent];
            
            if(!user.Stake) continue;

            uint256 _levelShouldShared = fetchLevelShouldShared(user.Level);
            if(alreadyShared < _levelShouldShared) {
                user.Share += _levelShouldShared.sub(alreadyShared).mul(amount).div(10000);
                alreadyShared = _levelShouldShared;
            }

            if(alreadyShared == fetchLevelShouldShared(IMDCPropertyStruct.Level.Collector)) break;
            if(user.Parent == address(0)) break;
            loopParent = user.Parent;
        }

        User[Master].Share += uint256(10000).sub(alreadyShared).mul(amount).div(10000);

        emit e_updateReferral(seller, amount);

        return true;
    }

    function updateStake(address staker, IMDCPropertyStruct.Level level, bool stake) external onlyStake() Lock() returns (bool) {
        userData storage user = User[staker];
        user.Stake = stake;
        user.Level = level;

        emit e_updateStake(staker, level, stake);

        return true;
    }

    function shareWithdraw() external shareWithdrawShutdown() Lock() returns (bool) {
        userData storage user = User[msg.sender];
        IERC20(Paytype).transfer(msg.sender, user.Share);
        user.Share = 0;

        emit e_shareWithdraw(msg.sender);

        return true;
    }

    function withdraw(uint256 amount) external onlyOwner() returns (bool) {
        require(IERC20(Paytype).balanceOf(address(this)) >= amount, 'The withdraw amount is wrong');
        IERC20(Paytype).transfer(msg.sender, amount);

        emit e_withdraw(amount);

        return true;
    }

    function setOwner(address owner) external onlyOwner() returns (bool) {
        Owner = owner;

        emit e_setOwner(owner);

        return true;
    }

    function setMarket(address market) external onlyOwner() returns (bool) {
        Market = market;

        emit e_setMarket(market);

        return true;
    }

    function setStake(address stake) external onlyOwner() returns (bool) {
        Stake = stake;

        emit e_setStake(stake);

        return true;
    }

    function setPurchaseShutdown(bool should) external onlyOwner() returns (bool) {
        shouldPurchaseShutdown = should;

        emit e_setPurchaseShutdown(should);

        return true;
    }

    function setShareWithdrawShutdown(bool should) external onlyOwner() returns (bool) {
        shouldShareWithdrawShutdown = should;

        emit e_setShareWithdrawShutdown(should);

        return true;
    }

    function setMaster(address _master) external onlyOwner() returns (bool) {
        if(Master != address(0)) {
            User[Master].Level = IMDCPropertyStruct.Level.Soldier;
            User[Master].Stake = false;
        }

        Master = _master;
        userData storage master = User[_master];
        master.Stake = true;
        master.Level = IMDCPropertyStruct.Level.Collector;
        master.defaultReferer = 100;

        emit e_setMaster(_master);

        return true;
    }

    function setPaytype(address paytype) external onlyOwner() returns (bool) {
        Paytype = paytype;

        emit e_setPaytype(paytype);

        return true;
    }

    function setPrice(uint256 price) external onlyOwner() returns (bool) {
        Price = price;

        emit e_setPrice(price);

        return true;
    }

    function setMDC(address mdc) external onlyOwner() returns (bool) {
        MDC = mdc;

        emit e_setMDC(mdc);

        return true;
    }

    function setDefaultReferer(uint256 defaultreferer) external onlyOwner() returns (bool) {
        defaultReferer = defaultreferer;

        emit e_setDefaultReferer(defaultreferer);

        return true;
    }

    function setMaxDepth(uint256 maxdepth) external onlyOwner() returns (bool) {
        maxDepth = maxdepth;

        emit e_setMaxDepth(maxdepth);

        return true;
    }

    function setLevelShouldShared(uint256 level, uint256 percent) external onlyOwner() returns (bool) {
        levelShouldShared[level] = percent;

        emit e_setLevelShouldShared(level, percent);

        return true;
    }

    function setUserDefaultReferer(address user, uint256 defaultreferer) external onlyOwner() returns (bool) {
        User[user].defaultReferer = defaultreferer;

        emit e_setUserDefaultReferer(user, defaultreferer);

        return true;
    }
}