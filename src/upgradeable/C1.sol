//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract C1 {
	string public myStr;

	constructor (string memory _str) {
		myStr = _str;
	}

	function setValue(string memory _str) external {
		myStr = _str;
	}	
}
