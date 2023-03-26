// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@moleculeprotocol/molecule-core/src/ILogicAddress.sol";

/// @title Molecule Protocol Access Control List
/// @dev This contract implements the ILogicAddress interface with address input
///      It will return true if the `account` exists in the List
contract LogicACL is Ownable, ILogicAddress {
    // Human readable name of the list
    string public _name;

    // Change to public if the list is public
    mapping(address => bool) private _list;

    event ListAdded(address[] addresses);
    event ListRemoved(address[] addresses);
    event NameSet(string name);

    constructor(string memory name_) {
        setName(name_);
    }

    // Returns true if the address is sanctioned
    function check(address account) external view returns (bool) {
        return _list[account];
    }

    // Owner only functions
    // Add addresses to the List
    function addBatch(address[] memory addresses) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < addresses.length; i++) {
            _list[addresses[i]] = true;
        }
        emit ListAdded(addresses);
        return true;
    }

    // Remove addresses from the List
    function removeBatch(address[] memory addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _list[addresses[i]] = false;
        }
        emit ListRemoved(addresses);
    }

    // Set the name of the list
    function setName(string memory name_) public onlyOwner {
        _name = name_;
        emit NameSet(name_);
    }
}
