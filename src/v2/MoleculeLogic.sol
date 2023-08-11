// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IMoleculeLogic.sol";

/// @title Molecule Protocol Logic abstract contract
/// @dev This contract implements the IMoleculeLogic interface with address input
///      Override the `check` function to implement the logic
abstract contract MoleculeLogic is IMoleculeLogic {
    // Human readable name of the list
    string public logicLabel;
    // True if the list is an allowlist, false if it is a Blocklist
    bool public isAllowlistBool;

    event LogicCreated(string name, bool isAllowlist);

    constructor(string memory label_, bool isAllowlist_) {
        // Name and the allowlist/blocklist can only be set during creation
        logicLabel = label_;
        isAllowlistBool = isAllowlist_;
        emit LogicCreated(label_, isAllowlist_);
    }

    function logicName() external view returns (string memory) {
        return logicLabel;
    }

    function isAllowlist() external view returns (bool) {
        return isAllowlistBool;
    }

    // Override to implement the logic
    function check(address account) external view virtual returns (bool) {}
}
