// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenFaucet is ERC20 {
    uint256 public amount = 1_000;
    mapping(address => uint256) public lockTime;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 50_000_000 * (10**18));
    }

    function requestTokens(address requestor) external {
        require(block.timestamp > lockTime[msg.sender], "lock time has not expired.");
        _mint(requestor, amount);
        lockTime[msg.sender] = block.timestamp + 1 days;
    }
}
