// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import "src/FractionalNFT.sol";

contract FractionalNFTMarketplaceTest is Test {

    FractionalNFTMarketplace fractionalNFTMarketplace;

    function setUp() public {
        fractionalNFTMarketplace = new FractionalNFTMarketplace();
    }

    function testCreateFractionalNFTToken() public {
        ERC721 nftContract = new ERC721();
        nftContract.mint(msg.sender, 1);
        fractionalNFTMarketplace.createFractionalNFTToken(1);        
        assert(fractionalNFTMarketplace.fractionalNFTTokenIds(1) > 0);
    }

    function testCreatePaymentPlan() public {
        fractionalNFTMarketplace.createFractionalNFTToken(1);
        fractionalNFTMarketplace.createPaymentPlan(1, 3, 1 ether);

        // Check that the payment plan exists.
        assert(fractionalNFTMarketplace.paymentPlans(1).installments == 3);
        assert(fractionalNFTMarketplace.paymentPlans(1).installmentAmount == 1 ether);
    }

    function testMakePayment() public {
          fractionalNFTMarketplace.createFractionalNFTToken(1);
         fractionalNFTMarketplace.createPaymentPlan(1, 3, 1 ether);
        fractionalNFTMarketplace.makePayment{value: 1 ether}(1);
        assert(fractionalNFTMarketplace.paymentPlans(1).nextInstallmentDue > block.timestamp);
    }
}
