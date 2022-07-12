//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Payments{
     address owner;
    uint public val;
    struct Payment{
        uint amount;
        uint timestamp;
        address from;
        string message;
    }

    struct Balance{
        uint32 totalPayments;
        mapping (uint=>Payment) payments;
    }

    mapping (address=>Balance) public balances;

    constructor(){
        owner = msg.sender;
    }

    function currentBalance() public view returns(uint){
        return address(this).balance;
    }

    function getPayment(address _adr, uint _index) view public returns(Payment memory){
        return balances[_adr].payments[_index];
    }

    function pay(string memory _message) public payable{
        Payment memory newPayment=Payment(msg.value, block.timestamp, msg.sender, _message);
        uint paymentNumber = balances[msg.sender].totalPayments;
        balances[msg.sender].totalPayments++;
        balances[msg.sender].payments[paymentNumber]=newPayment;
    }
}