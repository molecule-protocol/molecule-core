// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@moleculeprotocol/molecule-core/v2/contracts/interfaces/IMoleculeLogic.sol";

/// @title Molecule Protocol Logic List
/// @dev This contract implements the ILogicAddress interface with address input
///      It will return true if the `account` exists in the List
abstract contract MoleculeLogicList is Ownable, IMoleculeLogic {
    // Human readable name of the list
    string public _name;
    // True if the list is an allowlist, false if it is a Blocklist
    bool public _isAllowlist;

    mapping(address => bool) public _list;

    event ListAdded(address[] addresses);
    event ListRemoved(address[] addresses);
    event LogicCreated(string name, bool isAllowlist);

    constructor(string memory name_, bool isAllowlist_) {
        // Name and the allowlist/blocklist can only be set during creation
        _name = name_;
        _isAllowlist = isAllowlist_;
        emit LogicCreated(name_, isAllowlist_);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function isAllowlist() external view returns (bool) {
        return _isAllowlist;
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
}