// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../../ILogicAddress.sol";

/// @title Molecule Protocol LogicAML contract
/// @dev This contract implements the ILogicAddress interface with address input
///      It will return true if the `account` exists in the List
contract LogicAML is Ownable, ILogicAddress {
    constructor() {}

    mapping(address => bool) private batchData;

    event ListAdded(address[] addrs);
    event ListRemoved(address[] addrs);

    // To update the LogicAML list
    function updateList(
        address[] memory _addAddress
    ) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < _addAddress.length; i++) {
            batchData[_addAddress[i]] = true;
        }
        emit ListAdded(_addAddress);
        return true;
    }

    // Remove address from the List
    function removeFromList(
        address[] memory _removeAddress
    ) external onlyOwner {
        for (uint256 i = 0; i < _removeAddress.length; i++) {
            batchData[_removeAddress[i]] = false;
        }
        emit ListRemoved(_removeAddress);
    }

    // checks whether the address is present inside the list and returns true if its present
    function check(address account) external view returns (bool) {
        return batchData[account];
    }
}
