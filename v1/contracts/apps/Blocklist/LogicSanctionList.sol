// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../../ILogicAddress.sol";

/// @title Molecule Protocol LogicAML contract
/// @dev This contract implements the ILogicAddress interface with address input
///      It will return true if the `account` exists in the List
contract LogicSanctionList is Ownable, ILogicAddress {
    // enum Type {Blocklist, Allowlist, Data}

    // Human readable name of the list
    string public _name;
    // Type public _type;

    // Change to public if the list is public
    mapping(address => bool) private _sanctioned;

    event ListAdded(address[] addresses);
    event ListRemoved(address[] addresses);

    event NameSet(string name);

    // event TypeSet(Type listType);

    constructor(string memory name_) {
        setName(name_);
        // setType(Type.Blocklist);
    }

    // Returns true if the address is sanctioned
    function check(address account) external view returns (bool) {
        return _sanctioned[account];
    }

    function getName() external view returns (string memory) {
        return _name;
    }

    // function getType() external view returns (Type) {
    //     return _type;
    // }

    // Owner only functions
    // Add addresses to the List
    function addBatch(address[] memory addresses) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < addresses.length; i++) {
            _sanctioned[addresses[i]] = true;
        }
        emit ListAdded(addresses);
        return true;
    }

    // Remove addresses from the List
    function removeBatch(address[] memory addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _sanctioned[addresses[i]] = false;
        }
        emit ListRemoved(addresses);
    }

    // Set the name of the list
    function setName(string memory name_) public onlyOwner {
        _name = name_;
        emit NameSet(name_);
    }

    // Set the type of the list
    // function setType(Type listType) public onlyOwner {
    //     _type = listType;
    //     emit TypeSet(listType);
    // }
}
