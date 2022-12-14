// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract YourContract is Ownable {
    using ECDSA for bytes32;

    uint256 public nonce = 0;

    function getHash(
        uint256 _nonce,
        address to,
        uint256 value
    ) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), _nonce, to, value));
    }

    function metaSendValue(
        address payable to,
        uint256 value,
        bytes memory signature
    ) public {
        bytes32 hash = getHash(nonce, to, value);
        address signer = recover(hash, signature);
        require(signer == owner(), "SIGNER MUST BE OWNER");
        nonce++;
        (
            bool success, /* bytes memory data */

        ) = to.call{ value: value }("");
        require(success, "TX FAILED");
    }

    function recover(bytes32 hash, bytes memory signature) public pure returns (address) {
        return hash.toEthSignedMessageHash().recover(signature);
    }

    receive() external payable {
        /* allow deposits */
    }
}
