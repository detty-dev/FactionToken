// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FractionalNFTMarketplace {

    ERC721 public nftContract;
    ERC20 public fractionalNFTToken;

    mapping(uint256 => uint256) public fractionalNFTTokenIds; 
    mapping(uint256 => PaymentPlan) public paymentPlans;

    struct PaymentPlan {
        uint256 installments;
        uint256 installmentAmount;
        uint256 nextInstallmentDue;
    }

    constructor(ERC721 _nftContract, ERC20 _fractionalNFTToken) {
        nftContract = _nftContract;
        fractionalNFTToken = _fractionalNFTToken;
    }

   
    function createFractionalNFTToken(uint256 _tokenId) public {
        require(nftContract.ownerOf(_tokenId) == msg.sender, "Only the owner of the NFT can create a fractional NFT token");
       uint256 fractionalNFTTokenId = fractionalNFTToken.totalSupply() + 1;

        fractionalNFTToken.mint(msg.sender, fractionalNFTTokenId);

       fractionalNFTTokenIds[_tokenId] = fractionalNFTTokenId;
    }

    function createPaymentPlan(uint256 _fractionalNFTTokenId, uint256 _installments, uint256 _installmentAmount) public {
        require(fractionalNFTToken.balanceOf(msg.sender) >= _fractionalNFTTokenId, "Only the owner of the fractional NFT token can create a payment plan");

        PaymentPlan memory paymentPlan = PaymentPlan({
            installments: _installments,
            installmentAmount: _installmentAmount,
            nextInstallmentDue: block.timestamp + 7 days;
        });

        paymentPlans[_fractionalNFTTokenId] = paymentPlan;
    }

    function makePayment(uint256 _fractionalNFTTokenId) public payable {
        require(paymentPlans[_fractionalNFTTokenId].installments > 0, "The caller does not have a valid payment plan for the given fractional NFT token ID");
        require(msg.value >= paymentPlans[_fractionalNFTTokenId].installmentAmount, "The payment is not sufficient to cover the next installment");
        paymentPlans[_fractionalNFTTokenId].nextInstallmentDue += 7 days;
        paymentPlans[_fractionalNFTTokenId].installments -= 1;

        // Send 0.1% of the payment to the seller and the platform
        fractionalNFTToken.transferFrom(msg.sender, fractionalNFTToken.ownerOf(_fractionalNFTTokenId), msg.value * 0.1 / 100);
        fractionalNFTToken.transferFrom(msg.sender, address(this), msg.value * 0.1 / 100);

        // Transfer the remaining amount to the fractional NFT token owner
        fractionalNFTToken.transferFrom(msg.sender, fractionalNFTToken.ownerOf(_fractionalNFTTokenId), msg.value - msg.value * 0.1 / 100 * 2);
    }

}  