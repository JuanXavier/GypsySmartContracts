pragma solidity ^0.8.17;

contract TestAssemblyAndRevert {
    function test(
        address from,
        address to,
        uint256 value
    ) public {
        // a standard erc20 token
        address token = 0xedc2d4aca4f9b6a23904fbb0e513ea0668737643;

        // call transferFrom() of token using assembly
        assembly {
            let ptr := mload(0x40)

            // keccak256('transferFrom(address,address,uint256)') & 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000
            mstore(ptr, 0x23b872dd00000000000000000000000000000000000000000000000000000000)

            // calldatacopy(t, f, s) copy s bytes from calldata at position f to mem at position t
            // copy from, to, value from calldata to memory
            calldatacopy(add(ptr, 4), 4, 96)

            // call ERC20 Token contract transferFrom function
            let result := call(gas(), token, 0, ptr, 100, ptr, 32)

            if eq(result, 1) {
                return(0, 0)
            }
        }

        revert("TOKEN_TRANSFER_FROM_ERROR");
    }
}
