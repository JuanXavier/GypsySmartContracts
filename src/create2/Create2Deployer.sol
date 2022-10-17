// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract SampleContract {
    uint256 public immutable x;

    constructor(uint256 a) {
        x = a;
    }
}

contract Create2Deployer {
    function createDSalted(bytes32 salt, uint256 arg) public {
        // This complicated expression just tells you how the address
        // can be pre-computed. It is just there for illustration.
        // You actually only need ``new D{salt: salt}(arg)``.
        address predictedAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(this),
                            salt,
                            keccak256(abi.encodePacked(type(SampleContract).creationCode, abi.encode(arg)))
                        )
                    )
                )
            )
        );

        SampleContract sampleContract = new SampleContract{ salt: salt }(arg);
        require(address(sampleContract) == predictedAddress);
    }
}
