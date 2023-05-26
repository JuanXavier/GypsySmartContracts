//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Asm {
    fallback() external payable {
        assembly {
            return(0, calldatasize())
        }
    }
}

contract Ass {
    function add(uint256 a, uint256 b) external pure returns (uint256) {
        assembly {
            mstore(0, add(a, b)) // On SLOT 0, store the VALUE  of a + b
            return(0, 32) // Return from SLOT 0 in memory, a value of 32 bytes in SIZE
        }
    }

    function div(int256 a, int256 b) external pure returns (int256 result) {
        assembly {
            mstore(0, div(a, b))
            return(0, 0x20)
        }
    }

    function f(uint256 a) external pure returns (uint256[] memory) {
        uint256[] memory arr = new uint256[](3);
        arr[0] = a;
        arr[1] = 0x24;
        assembly {
            let len := mload(arr) // Load the length of array at first address.
            let arr0 := mload(add(arr, 32)) // Read first element.
            let arr1 := mload(add(arr, 64)) // Read second element.
            mstore(add(arr, 96), 7) // Write to element 3
        }
        return arr;
    }

    function f(uint256 a, uint256 b) external view returns (uint256[] memory) {
        assembly {
            // Create an dynamic sized array manually.
            let memOffset := mload(0x40) // 0x40 is the address where next free memory slot is stored in Solidity.
            mstore(memOffset, 0x20) // single dimensional array, data offset is 0x20
            mstore(add(memOffset, 32), 2) // Set size to 2
            mstore(add(memOffset, 64), a) // array[0] = a
            mstore(add(memOffset, 96), b) // array[1] = b
            return(memOffset, 128)
        }
    }
}
