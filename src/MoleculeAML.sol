// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMolecule.sol";
import "./ILogicAddress.sol";

contract MoleculeAML is Ownable, IMolecule {
    // selected logic combinations
    uint32 [] private _selected;

    // list id => atomic logic contract address
    mapping(uint32 => address) private _logicContract;
    // list id => allow- (true) or block- (false) list
    mapping(uint32 => bool) private _isAllowList;
    // list id => list name
    mapping(uint32 => string) private _name;
    // list id => logic modifier: add negation if true or false for as-is
    mapping(uint32 => bool) private _reverseLogic; // NOT used, always false

    // Events are defined by the interface

    // returns true if the account is NOT on a blocklist ("isNotSanctioned")
    function check(address account) external view returns (bool) {
        uint32 [] memory ids = _selected;
        for (uint i = 0; i < ids.length; i++) {
            uint32 id = ids[i];
            require (_logicContract[id] != address(0), "MoleculeAML: list not found");
            if (ILogicAddress(_logicContract[id]).check(account)) {
                // Found on a blocklist
                return false;
            }
        }
        // Not found on blocklist
        return true;
    }

    // returns true if account is on a blocklist ("isSanctioned")
    function check(uint32 [] memory ids, address account) external view returns (bool) {
        for (uint i = 0; i < ids.length; i++) {
            uint32 id = ids[i];
            require (_logicContract[id] != address(0), "MoleculeAML: list not found");
            if (ILogicAddress(_logicContract[id]).check(account)) {
                // Found on a blocklist
                return false;
            }
        }
        // Not found on blocklist
        return true;
    }

    // Owner only functions
    // Preselect logic combinations
    function select(uint32 [] memory ids) external onlyOwner {
        _selected = ids;
    }

    function addLogic(
        uint32 id,
        address logicContract,
        bool isAllowList,
        string memory name,
        bool reverseLogic
    ) external onlyOwner {
        _addLogic(id, logicContract, isAllowList, name, reverseLogic);
    }

    function removeLogic(uint32 id) external onlyOwner {
        _removeLogic(id);
    }

    function addLogicBatch(
        uint32 [] memory ids,
        address [] memory logicContracts,
        bool [] memory isAllowLists,
        string [] memory names,
        bool [] memory reverseLogics
    ) external onlyOwner {
        require (ids.length == logicContracts.length, "MoleculeAML: ids and logicContracts must be same length");
        require (ids.length == isAllowLists.length, "MoleculeAML: ids and isAllowLists must be same length");
        require (ids.length == names.length, "MoleculeAML: ids and names must be same length");
        require (ids.length == reverseLogics.length, "MoleculeAML: ids and reverseLogics must be same length");
        for (uint i = 0; i < ids.length; i++) {
            _addLogic(ids[i], logicContracts[i], isAllowLists[i], names[i], reverseLogics[i]);
        }
    }

    function removeLogicBatch(uint32 [] memory ids) external onlyOwner {
        for (uint i = 0; i < ids.length; i++) {
            _removeLogic(ids[i]);
        }
    }

    // Internal functions
    function _addLogic(
        uint32 id,
        address logicContract,
        bool isAllowList,
        string memory name,
        bool reverseLogic
    ) internal onlyOwner {
        _logicContract[id] = logicContract;
        _isAllowList[id] = isAllowList; // sanction list should always be false (blocklist)
        _name[id] = name;
        _reverseLogic[id] = reverseLogic; // NOT used, should always be false
        emit LogicAdded(id, logicContract, isAllowList, name, reverseLogic);
    }

    function _removeLogic(uint32 id) internal onlyOwner {
        delete _logicContract[id];
        delete _isAllowList[id];
        delete _name[id];
        delete _reverseLogic[id];
        emit LogicRemoved(id);
    }
}
