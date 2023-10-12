// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./FractionalNFT.sol";
import "./PaymentHandling.sol";
import "./marketPlace.sol";

contract NFTFactory is Ownable {
    // Addresses of deployed contract instances
    address public fractionalNFTContract;
    address public paymentHandlingContract;
    address public fractionalNFTMarketplaceContract;

    event FractionalNFTContractCreated(address indexed contractAddress);
    event PaymentHandlingContractCreated(address indexed contractAddress);
    event FractionalNFTMarketplaceContractCreated(address indexed contractAddress);

    function createFractionalNFTContract(
        string memory _name,
        string memory _symbol,
        address _paymentToken
    ) external onlyOwner {
        FractionalNFT fractionalNFT = new FractionalNFT(_name, _symbol, _paymentToken);
        fractionalNFTContract = address(fractionalNFT);
        emit FractionalNFTContractCreated(fractionalNFTContract);
    }

    function createPaymentHandlingContract(address _paymentToken) external onlyOwner {
        PaymentHandling paymentHandling = new PaymentHandling(_paymentToken);
        paymentHandlingContract = address(paymentHandling);
        emit PaymentHandlingContractCreated(paymentHandlingContract);
    }

    function createFractionalNFTMarketplaceContract(address _nftContract, address _paymentToken) external onlyOwner {
        FractionalNFTMarketplace marketplace = new FractionalNFTMarketplace(_nftContract, _paymentToken);
        fractionalNFTMarketplaceContract = address(marketplace);
        emit FractionalNFTMarketplaceContractCreated(fractionalNFTMarketplaceContract);
    }
}
