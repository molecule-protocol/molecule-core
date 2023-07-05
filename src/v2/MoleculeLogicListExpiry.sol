// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IMoleculeLogic.sol";

/// @title Molecule Protocol Logic List
/// @dev This contract implements the IMoleculeLogic interface with address input
///      It will return true if the `account` exists in the List
contract MoleculeLogicListExpiry is Ownable, IMoleculeLogic {
    // Human readable name of the list
    string public _logicLabel;
    // True if the list is an allowlist, false if it is a Blocklist
    bool public _isAllowlist;

    mapping(address => bool) public _list;
    mapping(address => uint64) public _expiry;

    event ListAdded(address[] addresses, uint64[] durations);
    event ListRemoved(address[] addresses);
    event LogicCreated(string name, bool isAllowlist);

    constructor(string memory label_) {
        // Name and the allowlist/blocklist can only be set during creation
        _logicLabel = label_;
        _isAllowlist = false;
        emit LogicCreated(label_, _isAllowlist);
    }

    function logicName() external view returns (string memory) {
        return _logicLabel;
    }

    function isAllowlist() external view returns (bool) {
        return _isAllowlist;
    }

    // Returns true if the address is sanctioned
    function check(address account) external view returns (bool) {
        bool timeBlocked = _expiry[account] < block.timestamp;
        return _list[account] && timeBlocked;
    }

    // Owner only functions
    // Add addresses to the block-list, with an auto-expiration time
    function addBatch(
        address[] calldata addresses,
        uint64[] calldata durations
    ) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < addresses.length; ) {
            _list[addresses[i]] = true;
            _expiry[addresses[i]] = durations[i];
            unchecked {
                ++i;
            }
        }
        emit ListAdded(addresses, durations);
        return true;
    }

    // Remove addresses from the List
    function removeBatch(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; ) {
            _list[addresses[i]] = false;
            unchecked {
                ++i;
            }
        }
        emit ListRemoved(addresses);
    }
}
