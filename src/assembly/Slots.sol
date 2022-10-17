// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

/// @dev Educational contract to learn about reading and writing in storage
///            and memory using low-level assembly.

contract Slots {
    uint256 public number;
    address public myAdd;
    string public secretWord;

    constructor() {
        myAdd = msg.sender;
        number = block.timestamp**1 ether;
    }

    function changeAddSlot(uint256 _newSlot) external {
        assembly {
            let slot := myAdd.slot // read slot from addr
            let content := sload(slot) // load content from Addr
            sstore(_newSlot, content) // copy content to new spot
            sstore(1, 0x0) // delete content from original slot
        }
    }

    function hashStringStorage(string calldata) external {
        assembly {
            // the calldata represents the entire data passed to a contract when calling a function
            // the first 4 bytes always represent the signature of the function, and the rest are the parameters
            // here we can skip the signature because we are already in the function, so the signature
            //obviously represent the current function
            // we can use CALLDATALOAD to load 32 bytes from the calldata.
            // we use calldataload(4) to skip the signature bytes. This will therefore load the 1st parameter
            // when using non-value types (array, mapping, bytes, string) the first parameter is going to be
            // the offset where the parameter starts
            // at that offset, we'll find the length of the parameter, and then the value
            // this is the offset in `calldata` where our string starts
            // here we use calldataload(4) -> loads the offset where the string starts
            // -> we add 4 to that offset to take into account the signature bytes
            // <https://www.evm.codes/#35>
            let strOffset := add(4, calldataload(4))

            // we use calldataload() again with the offset we just computed, this gives us the length of the
            // string (the value stored at the offset)
            let strSize := calldataload(strOffset)

            // we load the free memory pointer
            let pointer := mload(0x40)

            // we copy the value of our string into that free memory
            // the string starts at the next memory slot, so we add 0x20 to it
            calldatacopy(pointer, add(strOffset, 0x20), strSize)

            // then we compute the hash of that string
            // remember, the string is now stored at `pointer`
            let hashed := keccak256(pointer, strSize)

            // and we store it to storage
            sstore(secretWord.slot, hashed)
        }
    }

    function readSlot(uint256 _slot) external view returns (bytes memory) {
        assembly {
            let content := sload(_slot) // load content from slot and store it in variable
            mstore(0, content) // store content on slot 0 of memory
            return(0, 0x20) // return value in slot 0 of memory with size 32bytes(0x20=32 in decimal)
        }
    }

    function getSecretNumber(uint256 _slot) external view returns (bytes memory) {
        assembly {
            let content := sload(_slot)
            mstore(0x40, content)
            return(0x40, 0x20)
        }
    }

    function hashStringMemory(string memory _str) external view returns (bytes32) {
        assembly {
            // in assembly `_str` is just a pointer in memory where the data starts
            // at `_str` we have the length of the string
            // at `_str` + 32 -> we have the string itself
            let strSize := mload(_str)

            // here we add 32 to that address, so that we have the address of the string itself
            let strAddr := add(_str, 32)

            // we then pass the address of the string, and its size. This will hash our string
            let hashed := keccak256(strAddr, strSize)

            // this is used as temporary storage (scratch space)
            // no need to get the free memory pointer, it is faster (and cheaper) to use `0`
            mstore(0, hashed)

            // we return what is stored at slot 0 (our hash) and the length of the hash (32)
            return(0, 32)
        }
    }

    function seeAddSlot() external pure returns (uint256) {
        assembly {
            let slot := myAdd.slot // read slot from addr
            mstore(0, slot) // store on memory slot 0 the value to return
            return(0, 0x20) // return the value
        }
    }
}
