// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

contract Collections {
    struct User {
        address userAddress;
        uint256 balance;
    }
    User[] public users;

    function getUsers() external view returns (User[] memory) {
        return users;
    }

    function getUsersWithBalances() external view returns (address[] memory, uint256[] memory) {
        uint256 length = users.length;
        address[] memory userAddress = new address[](length);
        uint256[] memory balances = new uint256[](length);

        for (uint256 i; i < length; ++i) {
            userAddress[i] = users[i].userAddress;
            balances[i] = users[i].balance;
        }
        return (userAddress, balances);
    }
}
