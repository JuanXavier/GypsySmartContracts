// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/assembly/Slots.sol";

contract SlotsTest is Test {
    Slots public slots;

    function setUp() public {
        slots = new Slots();
    }
}
