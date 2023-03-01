// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMolecule.sol";
import "./IAtomAddress.sol";

contract MoleculeAML is Ownable, IMolecule {
    // list id => atomic logic contract address
    mapping(uint32 => address) private _atom;
    // list id => allow- (true) or block- (false) list
    mapping(uint32 => bool) private _allow;
    // list id => list name
    mapping(uint32 => string) private _name;
    // list id => logic modifier: _allow or NOT(_allow)
    mapping(uint32 => bool) private _logic; // NOT used, always true

    // Events are defined by interface

    function addAtom(uint32 id, address atom, bool allow, string memory name, bool logic) external onlyOwner {
        _atom[id] = atom;
        _allow[id] = allow; // sanction list should always be false (blocklist)
        _name[id] = name;
        _logic[id] = logic; // NOT used, should always be true
        emit AtomAdded(id, atom, allow, name, logic);
    }

    function removeAtom(uint32 id) external onlyOwner {
        delete _atom[id];
        delete _allow[id];
        delete _name[id];
        delete _logic[id];
        emit AtomRemoved(id);
    }

    // returns true if account is on a blocklist ("isSanctioned")
    function check(uint32 [] memory ids, address account) external view returns (bool) {
        for (uint i = 0; i < ids.length; i++) {
            uint32 id = ids[i];
            require (_atom[id] != address(0), "MoleculeAML: list not found");
            if (IAtomAddress(_atom[id]).check(account)) {
                // Found on a blocklist
                return true;
            }
        }
        // Not found on blocklist
        return false;
    }
}
