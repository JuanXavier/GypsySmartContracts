// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract RandomToken is ERC20 {
    constructor() ERC20("", "") {}

    function freeMint(uint256 amount) external {
        _mint(msg.sender, amount);
    }
}

contract TokenSender {
    using ECDSA for bytes32;

    function transfer(
        address sender,
        uint256 amount,
        address recipient,
        address token,
        bytes memory signature
    ) external {
        // Get hashed message
        bytes32 messageHash = getHash(sender, amount, recipient, token);
        bytes32 signedMessageHash = messageHash.toEthSignedMessageHash();

        // Check for signer
        address signer = signedMessageHash.recover(signature);
        if (signer != sender) revert();

        // Transfer
        bool sent = ERC20(token).transferFrom(sender, recipient, amount);
        if (!sent) revert();
    }

    function getHash(
        address sender,
        uint256 amount,
        address recipient,
        address token
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(sender, amount, recipient, token));
    }
}