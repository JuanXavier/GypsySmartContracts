// SPDX-License-Identifier:MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

interface A {
    function transferOne(uint256 amount, address to) external;

    function transferTwo(uint256[] memory ids, address to) external;
}

contract Calldata {
    uint256[] ids;

    function encodeFunctionA(uint256 amount, address to) external pure returns (bytes memory) {
        return abi.encodeWithSelector(A.transferOne.selector, amount, to);
    }

    function encodeFunctionB(uint256[] memory ids, address to) external pure returns (bytes memory) {
        return abi.encodeWithSelector(A.transferTwo.selector, ids, to);
    }

    function encodeString(string memory str) external pure returns (bytes memory) {
        return abi.encode(str);
    }

    function decodeString(bytes memory _data) external pure returns (string memory) {
        return abi.decode(_data, (string));
    }

    function decodeFunctionA(bytes memory _data) external pure returns (uint256 a, uint256 b) {
        (a, b) = abi.decode(_data, (uint256, uint256));
    }

    function decodeFunctionB(bytes memory _data) external returns (uint256[] memory a, address b) {
        ids.push(1234);
        ids.push(4567);
        ids.push(8910);
        (a, b) = abi.decode(_data, (uint256[], address));
    }
}

contract CalldataTest is Test {
    address public alice = 0x00000000000000000000000000000000DeaDBeef;
    Calldata public calldataContract = new Calldata();
    uint256[] ids;

    function testEncodeFunctionA() public {
        vm.startPrank(alice);
        bytes memory encodedData = calldataContract.encodeFunctionA(100, alice);
        console.logBytes(encodedData);
    }

    function testEncodeFunctionB() public {
        vm.startPrank(alice);
        ids.push(1234);
        ids.push(4567);
        ids.push(8910);
        bytes memory encodedData = calldataContract.encodeFunctionB(ids, alice);
        console.logBytes(encodedData);
        /**
        '0x  0xd9c50289', selector
        '0x0000000000000000000000000000000000000000000000000000000000000040', offset of input array  
        '0x00000000000000000000000000000000000000000000000000000000deadbeef',  to
        '0x0000000000000000000000000000000000000000000000000000000000000003',  length
        '0x00000000000000000000000000000000000000000000000000000000000004d2',  1234
        '0x00000000000000000000000000000000000000000000000000000000000011d7',  4567
        '0x00000000000000000000000000000000000000000000000000000000000022ce'   8910
        */
    }

    function testDecodeString() public {
        vm.startPrank(alice);
        bytes memory encodedString = calldataContract.encodeString("Hello World!");
        console.logBytes(encodedString);
        string memory str = abi.decode(encodedString, (string));
        console.logString(str);
        assertEq(str, "Hello World!");
    }
}
