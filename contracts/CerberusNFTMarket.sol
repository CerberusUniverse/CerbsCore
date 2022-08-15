// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./interfaces/ICerberusReferralV3.sol";
import "./interfaces/ICerberusRepository.sol";
import "./interfaces/IMDCPropertyStruct.sol";

contract CerberusNFTMarket is IERC721Receiver {
    event e_addCollection(address ERC721ADDRESS, address paytype, bool cerberusecology);
    event e_openCollection(address ERC721ADDRESS);
    event e_closeCollection(address ERC721ADDRESS);
    event e_Sell(address ERC721ADDRESS, uint256 tokenid, uint256 amount);
    event e_Unsell(address ERC721ADDRESS, uint256 tokenid);
    event e_Purchase(address ERC721ADDRESS, uint256 tokenid, uint256 amount);
    event e_setReferral(address ERC721ADDRESS);
    event e_setRepository(address ERC721ADDRESS);
    event e_setDepositePercent(uint256 percent);
    event e_setSellPercent(uint256 percent);
    event e_setReferralPercent(uint256 percent);
    event e_setFeeToAndFeePercent(address feeTo, uint256 percent);
    event e_setShutdown(bool should);
    event e_setOwner(address _owner);

    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    address private Owner;
    modifier onlyOwner {
        require(msg.sender == Owner, 'The caller is not owner');
        _;
    }
    
    bool private Should;
    modifier Shutdown {
        require(!Should, 'Market already shutdown');
        _;
    }
    
    bool private lock;
    modifier Lock {
        require(!lock, 'This is a reentry attack');
        lock = true;
        _;
        lock = false;
    }

    enum CollectionStatus {
        open,
        close
    }

    struct Collection {
        CollectionStatus status;
        address nft;
        address paytype;
        bool cerberusecology;
    }

    struct sellDetail {
        address seller;
        uint256 price;
    }

    mapping(address => bool) private isCollectionListed;
    mapping(address => Collection) private Collections;
    mapping(address => EnumerableSet.UintSet) private totalTokenIdOfCollection;
    mapping(address => EnumerableSet.AddressSet) private totalSellerOfCollection;
    mapping(address => mapping(address => EnumerableSet.UintSet)) private totalTokenIdOfSeller;
    mapping(address => mapping(uint256 => sellDetail)) private getSellDetail;

    EnumerableSet.AddressSet totalCollection;
    address private Referral;
    address private Repository;
    uint256 private depositePercent;
    uint256 private sellPercent;
    uint256 private referralPercent;
    uint256 private feePercent;
    address private feeTo;

    constructor() {
        Initialize();
    }

    function Initialize() internal {
        Owner = msg.sender;
    }

    function fetchOwner() external view returns (address) {
        return Owner;
    }

    function fetchShutdown() external view returns (bool) {
        return Should;
    }
    
    function fetchReferral() external view returns (address) {
        return Referral;
    }

    function fetchRepository() external view returns (address) {
        return Repository;
    }
    
    function fetchDepositePercent() external view returns (uint256) {
        return depositePercent;
    }
    
    function fetchSellPercent() external view returns (uint256) {
        return sellPercent;
    }
    
    function fetchReferralPercent() external view returns (uint256) {
        return referralPercent;
    }

    function fetchFeeToAndFeePercent() external view returns (address, uint256) {
        return (feeTo, feePercent);
    }

    function fetchTotalCollection() external view returns(address[] memory) {
        return totalCollection.values();
    }

    function fetchDetailOfCollection(address ERC721ADDRESS) external view returns (Collection memory) {
        return Collections[ERC721ADDRESS];
    }

    function fetchTotalTokenIdOfCollection(address ERC721ADDRESS) external view returns (uint256[] memory) {
        return totalTokenIdOfCollection[ERC721ADDRESS].values();
    }

    function fetchTotalSellerOfCollection(address ERC721ADDRESS) external view returns (address[] memory) {
        return totalSellerOfCollection[ERC721ADDRESS].values();
    }

    function fetchTotalTokenIdOfSeller(address ERC721ADDRESS, address seller) external view returns (uint256[] memory) {
        return totalTokenIdOfSeller[ERC721ADDRESS][seller].values();
    }

    function fetchNFTDetailOfTokenId(address ERC721ADDRESS, uint256 tokenid) external view returns (sellDetail memory) {
        return getSellDetail[ERC721ADDRESS][tokenid];
    }

    function addCollection(address ERC721ADDRESS, address paytype, bool cerberusecology) external onlyOwner() returns (bool) {
        require(isCollectionListed[ERC721ADDRESS] == false, 'Already collected');
        require(ERC721ADDRESS != address(0), 'The NFT address can not be 0');
        require(paytype != address(0), 'The paytype can not be 0');

        isCollectionListed[ERC721ADDRESS] = true;
        totalCollection.add(ERC721ADDRESS);
        Collections[ERC721ADDRESS] = Collection({
            status: CollectionStatus.open,
            nft: ERC721ADDRESS,
            paytype: paytype,
            cerberusecology: cerberusecology
        });

        emit e_addCollection(ERC721ADDRESS, paytype, cerberusecology);

        return true;
    }

    function openCollection(address ERC721ADDRESS) external onlyOwner() returns (bool) {
        require(isCollectionListed[ERC721ADDRESS] == true, "The NFT market does not support your NFT");
        require(Collections[ERC721ADDRESS].status == CollectionStatus.close, "The NFT market does not close");

        Collections[ERC721ADDRESS].status = CollectionStatus.open;
        totalCollection.add(ERC721ADDRESS);

        emit e_openCollection(ERC721ADDRESS);

        return true;
    }

    function closeCollection(address ERC721ADDRESS) external onlyOwner() returns (bool) {
        require(isCollectionListed[ERC721ADDRESS] == true, "The NFT market does not support your NFT");
        require(Collections[ERC721ADDRESS].status == CollectionStatus.open, "The NFT market does not open");

        Collections[ERC721ADDRESS].status = CollectionStatus.close;
        totalCollection.remove(ERC721ADDRESS);

        emit e_closeCollection(ERC721ADDRESS);

        return true;
    }

    function Sell(address ERC721ADDRESS, uint256 tokenid, uint256 amount) external Shutdown() returns (bool) {
        require(amount >= 0, "Error sell Price");
        require(isCollectionListed[ERC721ADDRESS] == true, "The NFT market does not support your NFT");
        require(Collections[ERC721ADDRESS].status == CollectionStatus.open, "The NFT market does not open");

        IERC721(ERC721ADDRESS).safeTransferFrom(msg.sender, address(this), tokenid);
        totalTokenIdOfCollection[ERC721ADDRESS].add(tokenid);
        totalSellerOfCollection[ERC721ADDRESS].add(msg.sender);
        totalTokenIdOfSeller[ERC721ADDRESS][msg.sender].add(tokenid);
        getSellDetail[ERC721ADDRESS][tokenid] = sellDetail({
            seller: msg.sender,
            price: amount
        });

        emit e_Sell(ERC721ADDRESS, tokenid, amount);

        return true;
    }

    function Unsell(address ERC721ADDRESS, uint256 tokenid) external returns (bool) {
        require(isCollectionListed[ERC721ADDRESS] == true, "The NFT market does not support your NFT");

        sellDetail memory detail = getSellDetail[ERC721ADDRESS][tokenid];
        require(detail.seller == msg.sender, 'Not your NFT');

        IERC721(ERC721ADDRESS).safeTransferFrom(address(this), msg.sender, tokenid);

        totalTokenIdOfCollection[ERC721ADDRESS].remove(tokenid);
        totalTokenIdOfSeller[ERC721ADDRESS][detail.seller].remove(tokenid);
        delete getSellDetail[ERC721ADDRESS][tokenid];

        uint256 length = totalTokenIdOfSeller[ERC721ADDRESS][detail.seller].length();
        if(length == 0) totalSellerOfCollection[ERC721ADDRESS].remove(detail.seller);

        emit e_Unsell(ERC721ADDRESS, tokenid);

        return true;
    }

    function Purchase(address ERC721ADDRESS, uint256 tokenid) external Shutdown() returns (bool) {
        require(isCollectionListed[ERC721ADDRESS] == true, "The NFT market does not support your NFT");

        Collection memory collection = Collections[ERC721ADDRESS];
        require(collection.status == CollectionStatus.open, "The NFT market does not open");

        sellDetail memory detail = getSellDetail[ERC721ADDRESS][tokenid];
        require(IERC20(collection.paytype).allowance(msg.sender, address(this)) >= detail.price, 'The allowance is not enough');

        {
            IMDCPropertyStruct.userData memory msgsender = ICerberusReferralV3(Referral).fetchUserData(msg.sender);
            require(msgsender.defaultReferer != 0, 'You can not purchase without mdc');
        }
        
        if(collection.cerberusecology) {
            require(Referral != address(0), 'Please set referral');
            require(Repository != address(0), 'Please set repository');
            require(feeTo != address(0), 'Please set feeTo');

            IMDCPropertyStruct.Property memory property = ICerberusRepository(Repository).getProperty(tokenid);
            uint256 Cdoge = property.Cdoge;

            if(detail.price <= Cdoge) {
                uint256 fee = detail.price.mul(feePercent).div(10000);
                IERC20(collection.paytype).transferFrom(msg.sender, feeTo, fee);
                IERC20(collection.paytype).transferFrom(msg.sender, detail.seller, detail.price.sub(fee));
                ICerberusRepository(Repository).updateCdoge(tokenid, 0);
                IERC721(collection.nft).safeTransferFrom(address(this), msg.sender, tokenid);
            } else {
                uint256 overflowCdoge = detail.price.sub(Cdoge);
                uint256 fee = overflowCdoge.mul(feePercent).div(10000);
                uint256 adjustedCdoge = overflowCdoge.sub(fee);
                uint256 sellAmount = adjustedCdoge.mul(sellPercent).div(10000);
                uint256 depositeAmount = adjustedCdoge.mul(depositePercent).div(10000);
                uint256 referralAmount = adjustedCdoge.mul(referralPercent).div(10000);

                IERC20(collection.paytype).transferFrom(msg.sender, feeTo, fee);

                IERC20(collection.paytype).transferFrom(msg.sender, detail.seller, Cdoge.add(sellAmount));

                IERC20(collection.paytype).transferFrom(msg.sender, Referral, referralAmount);
                ICerberusReferralV3(Referral).updateReferral(detail.seller, referralAmount);

                IERC20(collection.paytype).transferFrom(msg.sender, Repository, depositeAmount);
                ICerberusRepository(Repository).updateCdoge(tokenid, depositeAmount);

                IERC721(collection.nft).safeTransferFrom(address(this), msg.sender, tokenid);
            }
        } else {
            uint256 fee = detail.price.mul(feePercent).div(10000);
            IERC20(collection.paytype).transferFrom(msg.sender, feeTo, fee);
            IERC20(collection.paytype).transferFrom(msg.sender, detail.seller, detail.price.sub(fee));
            IERC721(collection.nft).safeTransferFrom(address(this), msg.sender, tokenid);
        }
        
        totalTokenIdOfCollection[collection.nft].remove(tokenid);
        totalTokenIdOfSeller[collection.nft][detail.seller].remove(tokenid);
        delete getSellDetail[ERC721ADDRESS][tokenid];

        uint256 length = totalTokenIdOfSeller[collection.nft][detail.seller].length();
        if(length == 0) totalSellerOfCollection[collection.nft].remove(detail.seller);

        emit e_Purchase(ERC721ADDRESS, tokenid, detail.price);

        return true;
    }

    function setReferral(address ERC721ADDRESS) external onlyOwner() returns (bool) {
        Referral = ERC721ADDRESS;

        emit e_setReferral(ERC721ADDRESS);

        return true;
    }

    function setRepository(address ERC721ADDRESS) external onlyOwner() returns (bool) {
        Repository = ERC721ADDRESS;

        emit e_setRepository(ERC721ADDRESS);

        return true;
    }
    
    function setDepositePercent(uint256 percent) external onlyOwner() returns (bool) {
        depositePercent = percent;

        emit e_setDepositePercent(percent);

        return true;
    }

    function setSellPercent(uint256 percent) external onlyOwner() returns (bool) {
        sellPercent = percent;

        emit e_setSellPercent(percent);

        return true;
    }

    function setReferralPercent(uint256 percent) external onlyOwner() returns (bool) {
        referralPercent = percent;

        emit e_setReferralPercent(percent);

        return true;
    }

    function setFeeToAndFeePercent(address _feeTo, uint256 percent) external onlyOwner() returns (bool) {
        feeTo = _feeTo;
        feePercent = percent;

        emit e_setFeeToAndFeePercent(_feeTo, percent);

        return true;
    }

    function setShutdown(bool should) external onlyOwner() returns (bool) {
        Should = should ? true : false;

        emit e_setShutdown(should);

        return true;
    }

    function setOwner(address _owner) external onlyOwner() returns (bool) {
        Owner = _owner;

        emit e_setOwner(_owner);

        return true;
    }

    function onERC721Received(address, address, uint256, bytes memory) external virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}