// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract MagoMintPayment is Ownable {
    uint256 private constant MAX_SUPPLY = 300;
    uint256 private constant PRIVATE_PRICE = 0.55 ether;
    uint256 private publicPrice;

    bool public presale = true;
    mapping(address => bool) public whitelist;
    mapping(address => uint256) public purchasedQuantity;

    constructor() {}

    event PaymentCompleted(string _puchaseType, address _from, uint256 _amount);

    function publicPurchase(uint256 amount) public payable {
        require(!presale, "presale is active");
        require(msg.value >= amount * publicPrice, "not enough funds");
        purchasedQuantity[msg.sender] += amount;
        emit PaymentCompleted("PUBLIC", msg.sender, amount);
    }

    function prePurchase(uint256 amount) public payable {
        require(presale, "presale is not active");
        require(msg.value >= amount * PRIVATE_PRICE, "not enough funds");
        purchasedQuantity[msg.sender] += amount;
        emit PaymentCompleted("PRIVATE", msg.sender, amount);
    }

    function freePurchase() public {
        require(whitelist[msg.sender], "Already claimed max");
        whitelist[msg.sender] = false;
        purchasedQuantity[msg.sender] += 1;
        emit PaymentCompleted("FREE", msg.sender, 1);
    }

    function setPublicPrice(uint256 newPublicPrice) public onlyOwner {
        publicPrice = newPublicPrice;
    }

    function withdraw() external onlyOwner {
        Address.sendValue(payable(0xeC2C16A4aBD441ef48e1b48D644330302F010923), address(this).balance);
    }

    function setWhitelist(address[] calldata addresses) public onlyOwner {
        for(uint index=0; index<addresses.length; index++) {
            whitelist[addresses[index]] = true;
        }
    }
}