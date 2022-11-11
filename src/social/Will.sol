// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Will {
    address public owner;
    uint256 public fortune;
    bool public deceased;
    address payable[] public familyWallets;
    mapping(address => uint256) public inheritance;

    constructor(uint256 _fortune) payable {
        owner = msg.sender;
        deceased = false;
        fortune = _fortune;
    }

    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }

    modifier isDeceased() {
        require(deceased);
        _;
    }

    function addInheritor(address payable _inheritor, uint256 value) public ownerOnly {
        require(msg.sender != tx.origin);
        familyWallets.push(_inheritor);
        inheritance[_inheritor] = value;
    }

    function payout() public ownerOnly isDeceased {
        for (uint256 i = 0; i < familyWallets.length; i++) {
            familyWallets[i].call{ value: inheritance[familyWallets[i]] }("");
            fortune = fortune - inheritance[familyWallets[i]];
        }
    }

    function declareDeath() public ownerOnly {
        deceased = true;
        payout();
    }

    receive() external payable {}
}
