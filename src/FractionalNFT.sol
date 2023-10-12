// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FractionalNFT is ERC721, Ownable {
    IERC20 public paymentToken;

    struct FractionalNFT {
        uint256 tokenId;
        uint256 totalFractions;
        uint256 fractionalPrice;
    }

    FractionalNFT[] public fractionalNFTs;

    mapping(uint256 => address[]) public fractionalOwners;
    mapping(uint256 => mapping(address => uint256)) public fractionalBalances;

    event FractionPurchased(address indexed buyer, uint256 tokenId, uint256 fractions);

    constructor(
        string memory _name,
        string memory _symbol,
        address _paymentToken
    ) ERC721("DettyToken", "DEV") {
        paymentToken = IERC20(_paymentToken);
    }

    function createFractionalNFT(
        string memory _tokenURI,
        uint256 _totalFractions,
        uint256 _fractionalPrice
    ) external onlyOwner {
        uint256 tokenId = totalSupply() + 1;
        _mint(owner(), tokenId);
        _setTokenURI(tokenId, _tokenURI);
        fractionalNFTs.push(FractionalNFT(tokenId, _totalFractions, _fractionalPrice));
    }

    function purchaseFractions(uint256 _nftIndex, uint256 _fractionsToBuy) external {
        FractionalNFT storage fractionalNFT = fractionalNFTs[_nftIndex];
        require(fractionalNFT.totalFractions >= _fractionsToBuy, "Not enough fractions available");

        uint256 cost = _fractionsToBuy * fractionalNFT.fractionalPrice;
        require(paymentToken.transferFrom(msg.sender, owner(), cost), "Payment failed");

        for (uint256 i = 0; i < _fractionsToBuy; i++) {
            fractionalOwners[_nftIndex].push(msg.sender);
            fractionalBalances[_nftIndex][msg.sender]++;
            fractionalNFT.totalFractions--;
        }

        emit FractionPurchased(msg.sender, fractionalNFT.tokenId, _fractionsToBuy);
    }

    function fractionalBalanceOf(uint256 _nftIndex, address _owner) external view returns (uint256) {
        return fractionalBalances[_nftIndex][_owner];
    }
}

