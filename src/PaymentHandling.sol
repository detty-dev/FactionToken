// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PaymentHandling is Ownable {
    IERC20 public paymentToken;
    uint256 public escrowBalance;

    mapping(address => uint256) public escrowedAmount;

    event PaymentReceived(address payer, uint256 amount);
    event EscrowFundsReleased(address beneficiary, uint256 amount);

    constructor(address _paymentToken) {
        paymentToken = IERC20(_paymentToken);
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(paymentToken.transferFrom(msg.sender, address(this), amount), "Payment failed");

        escrowBalance += amount;
        escrowedAmount[msg.sender] += amount;

        emit PaymentReceived(msg.sender, amount);
    }

    function releaseEscrow(address beneficiary, uint256 amount) external onlyOwner {
        require(escrowedAmount[beneficiary] >= amount, "Insufficient escrowed funds");
        require(escrowBalance >= amount, "Insufficient escrow balance");

        escrowedAmount[beneficiary] -= amount;
        escrowBalance -= amount;

        require(paymentToken.transfer(beneficiary, amount), "Escrow release failed");

        emit EscrowFundsReleased(beneficiary, amount);
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(escrowBalance >= amount, "Insufficient escrow balance");

        escrowBalance -= amount;
        require(paymentToken.transfer(owner(), amount), "Withdrawal failed");
    }
}
