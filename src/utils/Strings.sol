// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Strings {
    function getLength(string calldata str) external pure returns (uint256) {
        return bytes(str).length;
    }

    function concatenateStr(string calldata a, string calldata b) external pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }

    function reverseStr(string calldata _str) external pure returns (string memory) {
        bytes memory str = bytes(_str);
        string memory tmp = new string(str.length); //create new string in the same length
        bytes memory _reverse = bytes(tmp);

        for (uint256 i; i < str.length; ++i) {
            _reverse[str.length - i - 1] = str[i];
        }
        return string(_reverse);
    }

    function compareStr(string calldata a, string calldata b) external pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}
