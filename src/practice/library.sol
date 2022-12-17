// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Finance {
    function getBalanceContract() internal view returns (uint256) {
        return address(this).balance;
    }
}
