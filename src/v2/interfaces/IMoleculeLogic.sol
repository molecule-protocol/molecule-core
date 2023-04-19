// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Interface for Molecule Smart Contract
interface IMoleculeLogic {
    // Recommended public variables for each MoleculeLogic contract
    // Human readable name of the list
    // string public _logicName;
    // True if the list is an allowlist, false if it is a Blocklist
    // string public _isAllowlist;

    function check(address account) external view returns (bool);

    // Recommended public functions for retrieving public variables
    function logicName() external view returns (string memory);

    function isAllowlist() external view returns (bool);

    // Recommended owner only functions, but not mandatory
    // function addBatch(address[] memory addresses) external returns (bool);
    // function removeBatch(address[] memory addresses) external;
}