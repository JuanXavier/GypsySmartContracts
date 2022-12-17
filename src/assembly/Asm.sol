//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Asm {
    fallback() external payable {
        assembly {
            return(0, calldatasize())
        }
    }
}
