// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Oracle {
    address public admin;
    uint256 public rand;

    constructor() {
        admin = msg.sender;
    }

    function feedRandomness(uint256 _rand) external {
        if (msg.sender != admin) revert();
        rand = _rand;
    }
}

contract MyContract {
    Oracle public oracle;
    uint256 public nonce;

    constructor(address oracleAddress) {
        oracle = Oracle(oracleAddress);
    }

    function makeRand() external returns (string memory) {
        uint256 rand = _randModulus(100);
        string memory result;
        if (rand == 50) {
            result = "You win";
        }
        return result;
    }

    function _randModulus(uint256 mod) internal returns (uint256) {
        uint256 rand = uint256(
            keccak256(abi.encodePacked(nonce, oracle.rand(), block.timestamp, block.difficulty, msg.sender))
        ) % mod;
        nonce++;
        return rand;
    }
}
