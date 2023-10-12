// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FractionalNFTMarketplace is Ownable {
    IERC721 public nftContract; // The NFT contract
    IERC20 public paymentToken; // The token used for payments

    struct Listing {
        uint256 tokenId;
        uint256 fractionsAvailable;
        uint256 fractionalPrice;
        address seller;
    }

    Listing[] public listings;
    uint256 public nextListingId;

    mapping(uint256 => address[]) public buyers;
    mapping(uint256 => mapping(address => uint256)) public purchasedFractions;

    event ListingCreated(
        uint256 indexed listingId,
        uint256 tokenId,
        uint256 fractionsAvailable,
        uint256 fractionalPrice,
        address seller
    );

    event Purchase(
        uint256 indexed listingId,
        address indexed buyer,
        uint256 fractionsPurchased,
        uint256 totalPrice
    );

    constructor(address _nftContract, address _paymentToken) {
        nftContract = IERC721(_nftContract);
        paymentToken = IERC20(_paymentToken);
    }

    function createListing(
        uint256 _tokenId,
        uint256 _fractionsAvailable,
        uint256 _fractionalPrice
    ) external {
        require(nftContract.ownerOf(_tokenId) == msg.sender, "Only the NFT owner can create a listing");
        listings.push(Listing(_tokenId, _fractionsAvailable, _fractionalPrice, msg.sender));
        nextListingId++;

        emit ListingCreated(nextListingId, _tokenId, _fractionsAvailable, _fractionalPrice, msg.sender);
    }

    function purchaseFractions(uint256 _listingId, uint256 _fractionsToBuy) external {
        require(_listingId > 0 && _listingId <= nextListingId, "Invalid listing ID");
        Listing storage listing = listings[_listingId - 1];
        require(listing.fractionsAvailable >= _fractionsToBuy, "Not enough fractions available");

        uint256 cost = _fractionsToBuy * listing.fractionalPrice;
        require(paymentToken.transferFrom(msg.sender, listing.seller, cost), "Payment failed");

        for (uint256 i = 0; i < _fractionsToBuy; i++) {
            buyers[_listingId].push(msg.sender);
            purchasedFractions[_listingId][msg.sender]++;
            listing.fractionsAvailable--;
        }

        emit Purchase(_listingId, msg.sender, _fractionsToBuy, cost);
    }

    function getBuyers(uint256 _listingId) external view returns (address[] memory) {
        return buyers[_listingId];
    }
}
