// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMolecule.sol";
import "./ILogicAddress.sol";

contract Molecule is Ownable, IMolecule {
    // selected logic combinations
    uint32 [] public _selected;
    // when `paused` is true, all checks will return true, essentially removing all gates
    bool public _isPaused = false;

    // list id => atomic logic contract address
    mapping(uint32 => address) private _logicContract;
    // list id => allow- (true) or block- (false) list
    mapping(uint32 => bool) private _isAllowList;
    // list id => list name
    mapping(uint32 => string) private _name;
    // list id => logic modifier: add negation if true or false for as-is
    mapping(uint32 => bool) private _reverseLogic;

    // Events are defined by the interface

    // Use default logic combination
    function check(address account) external view returns (bool) {
        return _check(_selected, account);
    }

    // Use custom logic combination
    function check(uint32 [] memory ids, address account) external view returns (bool) {
        return _check(ids, account);
    }

    // Owner only functions
    // instead of using a toggle, we use separate functions to avoid confusion
    function pause() external onlyOwner {
        _isPaused = true;
        emit Paused(_isPaused);
    }
    function unpause() external onlyOwner {
        _isPaused = false;
        emit Paused(_isPaused);
    }


    // Preselect logic combinations
    function select(uint32 [] memory ids) external onlyOwner {
        for (uint i = 0; i < ids.length; i++) {
            require(_logicContract[ids[i]] != address(0), "Molecule: logic id not found");
        }
        _selected = ids;
        emit Selected(ids);
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

    // Note: may break selected logic combinations if id is in use
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

    // Note: may break selected logic combinations if id is in use
    function removeLogicBatch(uint32 [] memory ids) external onlyOwner {
        for (uint i = 0; i < ids.length; i++) {
            _removeLogic(ids[i]);
        }
    }

    // Internal functions
    function _check(uint32 [] memory ids, address account) internal view returns (bool) {
        if (_isPaused) return true;
        for (uint i = 0; i < ids.length; i++) {
            uint32 id = ids[i];
            require (_logicContract[id] != address(0), "MoleculeAML: list not found");
            bool result = ILogicAddress(_logicContract[id]).check(account);
            // If the list is NOT an allow list, reverse the result
            if (!_isAllowList[id]) {
                result = !result;
            }
            // If reverse logic is set, reverse the result
            if (_reverseLogic[id]) {
                result = !result;
            }
            // If any check failed, return false
            if (!result) {
                return false;
            }
        }
        return true;
    }

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
        if (_logicContract[id] != address(0)) {
            delete _logicContract[id];
            delete _isAllowList[id];
            delete _name[id];
            delete _reverseLogic[id];
            emit LogicRemoved(id);
        }
    }
}
