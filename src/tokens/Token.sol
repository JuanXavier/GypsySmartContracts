// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Token {
    address internal immutable owner;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor() {
        owner = msg.sender;
    }

    function mint(address user, uint256 amount) external {
        require(msg.sender == owner, "Only owner is allowed to mint");
        balanceOf[user] += amount;
    }
}
