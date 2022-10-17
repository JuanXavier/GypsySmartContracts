//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract SimpleBank {
    mapping(address => uint256) private balances;
    address public owner;
    event LogDepositMade(address, uint256);

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable returns (uint256) {
        balances[msg.sender] += msg.value;
        emit LogDepositMade(msg.sender, msg.value);
        return balances[msg.sender];
    }

    function withdraw(uint256 withdrawAmount) public returns (uint256) {
        require(withdrawAmount <= balances[msg.sender]);
        balances[msg.sender] -= withdrawAmount;
        payable(msg.sender).transfer(withdrawAmount);
        return balances[msg.sender];
    }

    function balance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
