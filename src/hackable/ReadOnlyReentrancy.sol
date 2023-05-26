//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract ReadOnlyReentrancy {
    address public owner;
    mapping(address => uint) public balances;

    constructor() public {
        owner = msg.sender;
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit value must be greater than 0");
        balances[msg.sender] += msg.value;
    }

    function getTotalBalance() public view returns (uint) {
        uint total = 0;
        for (address user in balances) {
            total += balances[user];
        }
        return total;
    }

    function transfer(address payable _to, uint _value) public {
        require(balances[msg.sender] >= _value, "Insufficient balance");
        require(_to != address(0), "Invalid address");
        require(_value > 0, "Transfer value must be greater than 0");

        // VULNERABILITY: Calling a non-view function from within a view function
        _to.transfer(_value); // Transfer the value to the recipient

        balances[msg.sender] -= _value;
        balances[_to] += _value;
    }
}
