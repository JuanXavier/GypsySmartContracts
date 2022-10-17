// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Will
 * @author Juan Xavier Valverde M.
 * @dev This is a very basic template of a death will.
 * As aggregated ideas, there could be an Oracle from the government, and
 * through the oracle this contract could receive the official information
 * of the deceased person, and so it could  make the inheritance repartition
 *  Also there could be declared some internal IERC20' interfaces to declare
 */

contract Will {
    address public owner;
    uint256 public fortune;
    bool public deceased;
    address payable[] public familyWallets;
    mapping(address => uint256) public inheritance;

    constructor(uint256 _fortune) payable {
        owner = msg.sender;
        deceased = false;
        fortune = _fortune;
    }

    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }

    modifier isDeceased() {
        require(deceased == true);
        _;
    }

    function declareERC20(address newToken) external returns (bool) {
        IERC20 _token = IERC20(newToken);
        ownedTokens.push(_token);
        return true;
    }

    function declareERC721(address[] calldata tokens) external returns (bool) {
        IERC20 _token = IERC20(newToken);
        ownedTokens.push(address(_token));
        return true;
    }

    function addInheritor(address payable _inheritor, uint256 value) public ownerOnly {
        require(msg.sender != tx.origin);
        familyWallets.push(_inheritor);
        inheritance[_inheritor] = value;
    }

    function payout() public ownerOnly isDeceased {
        for (uint256 i = 0; i < familyWallets.length; i++) {
            familyWallets[i].call{ value: inheritance[familyWallets[i]] }("");
            fortune = fortune - inheritance[familyWallets[i]];
        }
    }

    function declareDeath() public ownerOnly {
        deceased = true;
        payout();
    }

    receive() external payable {}
}
