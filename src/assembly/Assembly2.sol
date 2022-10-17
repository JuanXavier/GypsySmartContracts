//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract AngleExplainsBase {
    uint256 private secretNumber;
    mapping(address => uint256) public guesses;
    bytes32 public secretWord;

    // obviously this doesn't make sense
    // but it will be fun to write it in assembly :D
    function getSecretNumber() external view returns (uint256) {
        return secretNumber;
    }

    // this can only be set by an admin
    // no access control because we want to keep it simple in assembly
    function setSecretNumber(uint256 number) external {
        secretNumber = number;
    }

    // a user can add a guess
    function addGuess(uint256 _guess) external {
        guesses[msg.sender] = _guess;
    }

    // yes I know... it doesn't make sense because you can change guesses for any user
    // it's just to teach you how to parse arrays in assembly
    function addMultipleGuesses(address[] memory _users, uint256[] memory _guesses) external {
        for (uint256 i = 0; i < _users.length; i++) {
            guesses[_users[i]] = _guesses[i];
        }
    }

    // this is useless since the `secretWord` is not used anywhere
    // but this will teach us how to hash a string in assembly. Really cool! :)
    function hashSecretWord(string memory _str) external {
        secretWord = keccak256(abi.encodePacked(_str));
    }
}

contract AngleExplains {
    uint256 private secretNumber;
    mapping(address => uint256) public guesses;
    bytes32 public secretWord;

    function getSecretNumber() external view returns (uint256) {
        assembly {
            // We get the value for secretNumber which is at slot 0
            // in Yul, you also have access to the slot number of a variable through `.slot`
            // https://docs.soliditylang.org/en/latest/assembly.html#access-to-external-variables-functions-and-libraries
            // so we could also just write `sload(secretNumber.slot)`
            // SLOAD https://www.evm.codes/#54
            let _secretNumber := sload(0)

            // then we get the "free memory pointer"
            // that means we get the address in the memory where we can write to
            // we use the MLOAD opcode for that: https://www.evm.codes/#51
            // We get the value stored at 0x40 (64)
            // 0x40 is just a constant decided in the EVM where the address of the free memory is stored
            // see here: https://docs.soliditylang.org/en/latest/assembly.html#memory-management
            let ptr := mload(0x40)

            // we write our number at that address
            // to do that, we use the MSTORE opcode: https://www.evm.codes/#52
            // It takes 2 parameters: the address in memory where to store our value, and the value to store
            mstore(ptr, _secretNumber)

            // then we RETURN the value: https://www.evm.codes/#f3
            // we specify the address where the value is stored: `ptr`
            // and the size of the parameter returned: 32 bytes (remember values are always stored on 32 bytes)
            return(ptr, 0x20)

            // instead of using the free memory pointer, we could also store the value at `0`
            // because the first 2 slots in memory are used as "scratch space"
            // https://docs.soliditylang.org/en/latest/internals/layout_in_memory.html#layout-in-memory
            // this means they are used to store temporary values, such as return values
            // we would have had:
            // mstore(0, _secretNumber)
            // return(0, 0x20)
        }
    }

    function setSecretNumber(uint256 _number) external {
        assembly {
            // We get the slot number for `secretNumber`
            let slot := secretNumber.slot

            // We use SSTORE to store the new value
            // https://www.evm.codes/#51
            sstore(slot, _number)
        }
    }

    function addGuess(uint256 _guess) external {
        assembly {
            // first we compute the slot where we will store the value
            // https://solidity-fr.readthedocs.io/fr/latest/internals/layout_in_storage.html#mappings-and-dynamic-arrays
            // we have: keccak256(abi.encode(_user, 1)) where 1 is the slot number for `guesses`
            let ptr := mload(0x40)

            // we store the address of msg.sender at `ptr` address
            // CALLER opcode: https://www.evm.codes/#33
            mstore(ptr, caller())

            // then right after that, we store the slot number for `guesses`
            // in Assembly we can't do simple operations (+ - * /)
            // we need to use specific opcodes for that
            // here we use ADD to add 32 bytes to the address of `ptr`
            // this is equivalent to: ptr = ptr + 32
            // ADD: https://www.evm.codes/#01
            mstore(add(ptr, 0x20), guesses.slot)

            // the 2 previous MSTORE are equivalent to abi.encode(msg.sender, 1)

            // then we just compute the hash of the msg.Sender and guesses.slot
            // they are currently stored at `ptr` and use 2 slots (2x 32bytes -> 0x40)
            // KECCAK256 opcode https://www.evm.codes/#20
            // still appears as SHA3 on evm.codes which is the old name. Was later renamed as KECCAK256
            let slot := keccak256(ptr, 0x40)

            // we now only need to store the value at that slot
            sstore(slot, _guess)
        }
    }

    // computes the keccak256 hash of a string and stores it in a state variable
    function hashSecretWord1(string memory _str) external pure returns (bytes32) {
        assembly {
            // in assembly `_str` is just a pointer to the string
            // it represents the address in memory where the data for our string starts
            // at `_str` we have the length of the string
            // at `_str` + 32 -> we have the string itself

            // here we get the size of the string
            let strSize := mload(_str)

            // here we add 32 to that address, so that we have the address of the string itself
            let strAddr := add(_str, 32)

            // we then pass the address of the string, and its size. This will hash our string
            let hash := keccak256(strAddr, strSize)

            // we store the hash value at slot 0 in memory
            // just like we explained before, this is used as temporary storage (scratch space)
            // no need to get the free memory pointer, it is faster (and cheaper) to use `0`
            mstore(0, hash)

            // we return what is stored at slot 0 (our hash) and the length of the hash (32)
            return(0, 32)
        }
    }

    // this is the same as `hashSecretWord1` but using a different technique
    // here we use specific opcodes to manipulate calldata instead of using the parameters of the function
    // instead of returning the hash, we'll assign it to storage variable `secretWord`
    function hashSecretWord2(string calldata) external {
        assembly {
            // the calldata represents the entire data passed to a contract when calling a function
            // the first 4 bytes always represent the signature of the function, and the rest are the parameters
            // here we can skip the signature because we are already in the function, so the signature obviously represent the current function
            // we can use CALLDATALOAD to load 32 bytes from the calldata.
            // we use calldataload(4) to skip the signature bytes. This will therefore load the 1st parameter
            // when using non-value types (array, mapping, bytes, string) the first parameter is going to be the offset where the parameter starts
            // at that offset, we'll find the length of the parameter, and then the value

            // this is the offset in `calldata` where our string starts
            // here we use calldataload(4) -> loads the offset where the string starts
            // -> we add 4 to that offset to take into account the signature bytes
            // https://www.evm.codes/#35
            let strOffset := add(4, calldataload(4))

            // we use calldataload() again with the offset we just computed, this gives us the length of the string (the value stored at the offset)
            let strSize := calldataload(strOffset)

            // we load the free memory pointer
            let ptr := mload(0x40)

            // we copy the value of our string into that free memory
            // CALLDATACOPY https://www.evm.codes/#37
            // the string starts at the next memory slot, so we add 0x20 to it
            calldatacopy(ptr, add(strOffset, 0x20), strSize)

            // then we compute the hash of that string
            // remember, the string is now stored at `ptr`
            let hash := keccak256(ptr, strSize)

            // and we store it to storage
            sstore(secretWord.slot, hash)
        }
    }

    function addMultipleGuesses(address[] memory _users, uint256[] memory _guesses) external {
        assembly {
            // remember: `_users` is the address in memory where the parameter starts
            // This is where the size of the array is stored. And then 32 bytes after, we have the values of the array
            // so here we load what's at address `_users` -> which is the size of the array `_users`
            let usersSize := mload(_users)

            // same for `_guesses`
            let guessesSize := mload(_guesses)

            // we check that both arrays are the same size
            // eq() returns 1 if they are equal, 0 if not equal
            // we use iszero(). If they are not equal, we revert
            // ISZERO https://www.evm.codes/#15
            // EQ https://www.evm.codes/#14
            // iszero(eq(...)) is the equivalent in assembly to !eq(...)
            // REVERT https://www.evm.codes/#fd
            if iszero(eq(usersSize, guessesSize)) {
                revert(0, 0)
            }

            // we use a for-loop to loop through the items
            for {
                let i := 0
            } lt(i, usersSize) {
                i := add(i, 1)
            } {
                // to get the ith value from the array we multiply i by 32 (0x20) and add it to `_users`
                // we always have to add 1 to i first, because remember that `_users` is the size of the array, the values start 32 bytes after
                // we could also do it this way (maybe it makes more sense):
                // let userAddress := mload(add(add(_users, 0x20), mul(0x20, i)))
                let userAddress := mload(add(_users, mul(0x20, add(i, 1))))
                let userBalance := mload(add(_guesses, mul(0x20, add(i, 1))))

                // we use the 0 memory slot as temporary storage to compute our hash
                // we store the address there
                mstore(0, userAddress)
                // then the slot number for `guesses`
                mstore(0x20, guesses.slot)
                // we compute the slot number
                let slot := keccak256(0, 0x40)
                // and add our value to it
                sstore(slot, userBalance)
            }
        }
    }
}
