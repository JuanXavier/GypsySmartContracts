// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract UnsafeMath {
    function testUnderflow() public pure returns (uint256) {
        uint256 x;
        return x--;
    }

    //this function avoid safemath and return big amount
    function testUncheckedUnderflow() public pure returns (uint256) {
        uint256 x;
        unchecked {
            return x--;
        }
    }
}
