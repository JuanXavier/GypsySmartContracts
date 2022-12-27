// SPDX-License-Identifier:MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

interface A {
    function transfer(uint256 amount, address to) external;
}

contract Calldata {
    function encodeFunction(uint256 amount, address to) external pure returns (bytes memory) {
        return abi.encodeWithSelector(A.transfer.selector, amount, to);
    }

    function encodeString(string memory str) external pure returns (bytes memory) {
        return abi.encode(str);
    }

    function decodeString(bytes memory _data) external pure returns (string memory) {
        return abi.decode(_data, (string));
    }

    function decodeFunction(bytes memory _data) external pure returns (uint256 a, uint256 b) {
        (a, b) = abi.decode(_data, (uint256, uint256));
    }
}

contract CalldataTest is Test {
    address public alice = 0x00000000000000000000000000000000DeaDBeef;
    Calldata calldataContract = new Calldata();

    function testEncodeFunction() public {
        vm.startPrank(alice);
        bytes memory encodedData = calldataContract.encodeFunction(100, alice);
        console.logBytes(encodedData);
    }

    function testDecodeString() public {
        bytes memory encodedString = calldataContract.encodeString("Hello World");
        string memory str = abi.decode(encodedString, (string));
        console.logString(str);
    }
}
