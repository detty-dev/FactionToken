// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import { FractionalNFTMarketplace} from "../src/FractionalNFT.sol";
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../FractionalNFTMarketplace.sol";

contract FractionalNFTMarketplaceTest is Test {

    FractionalNFTMarketplace fractionalNFTMarketplace;

    function setUp() public {
        fractionalNFTMarketplace = new FractionalNFTMarketplace();
    }

    function testCreateFractionalNFTToken() public {
        // Create a new NFT contract.
        ERC721 nftContract = new ERC721();

        nftContract.mint(msg.sender, 1);

        fractionalNFTMarketplace.createFractionalNFTToken(1);

        assert(fractionalNFTMarketplace.fractionalNFTTokenIds(1) > 0);
    }

    function testCreatePaymentPlan() public {
        fractionalNFTMarketplace.createFractionalNFTToken(1);
        fractionalNFTMarketplace.createPaymentPlan(1, 3, 1 ether;

        // Check that the payment plan exists.
        assert(fractionalNFTMarketplace.paymentPlans(1).installments == 3);
        assert(fractionalNFTMarketplace.paymentPlans(1).installmentAmount == 1 ETH);
    }

    function testMakePayment() public {
          fractionalNFTMarketplace.createFractionalNFTToken(1);

         fractionalNFTMarketplace.createPaymentPlan(1, 3, 1 ETH);

        fractionalNFTMarketplace.makePayment{value: 1 ETH}(1);

        assert(fractionalNFTMarketplace.paymentPlans(1).nextInstallmentDue > block.timestamp);
    }
}
