// Root file: src/IMolecule.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Interface for Molecule Smart Contract
interface IMolecule {
    // mappings
    // list id => atomic logic contract address
    // mapping(uint32 => address) private _atom;
    // list id => allow- (true) or block- (false) list
    // mapping(uint32 => bool) private _allow;
    // list id => list name
    // mapping(uint32 => string) private _name;
    // list id => logic modifier: _allow or NOT(_allow)
    // mapping(uint32 => bool) private _logic; // NOT used, always true

    // Add a new list to the Molecule
    function addAtom(uint32 id, address atom, bool allow, string memory name, bool logic) external;
    // Remove a list from the Molecule
    function removeAtom(uint32 id) external;
    // returns true if account is on a blocklist ("isSanctioned")
    function check(uint32 [] memory ids, address account) external view returns (bool);
    // event emitted when a new list is added
    event AtomAdded(uint32 indexed id, address indexed atom, bool allow, string name, bool logic);
    // event emitted when a list is removed
    event AtomRemoved(uint32 indexed id);
}
