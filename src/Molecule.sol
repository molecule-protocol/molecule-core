// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMolecule.sol";
import "./ILogic.sol";

contract Molecule is Ownable, IMolecule {
    // selected logic combinations
    uint32[] public _selected;
    Status public _status = Status.Gated;

    // list id => atomic logic contract address
    mapping(uint32 => address) private _logicContract;
    // list id => allow- (true) or block- (false) list
    mapping(uint32 => bool) private _isAllowList;
    // list id => list name
    mapping(uint32 => string) private _name;
    // list id => logic modifier: add negation if true or false for as-is
    mapping(uint32 => bool) private _reverseLogic;

    // Enum & Events are defined by the interface

    // Use default logic combination
    function check(bytes memory data) external view returns (bool) {
        return _check(_selected, data);
    }

    // Use custom logic combination
    function check(uint32[] memory ids, bytes memory data) external view returns (bool) {
        return _check(ids, data);
    }

    // Owner only functions
    function setStatus(Status newStatus) external onlyOwner {
        _status = newStatus;
        emit StatusChanged(newStatus);
    }

    // Preselect logic combinations
    function select(uint32[] memory ids) external onlyOwner {
        for (uint256 i = 0; i < ids.length; i++) {
            require(_logicContract[ids[i]] != address(0), "Molecule: logic id not found");
        }
        _selected = ids;
        emit Selected(ids);
    }

    function addLogic(uint32 id, address logicContract, bool isAllowList, string memory name, bool reverseLogic)
        external
        onlyOwner
    {
        _addLogic(id, logicContract, isAllowList, name, reverseLogic);
    }

    // Note: may break selected logic combinations if id is in use
    function removeLogic(uint32 id) external onlyOwner {
        _removeLogic(id);
    }

    function addLogicBatch(
        uint32[] memory ids,
        address[] memory logicContracts,
        bool[] memory isAllowLists,
        string[] memory names,
        bool[] memory reverseLogics
    ) external onlyOwner {
        require(ids.length == logicContracts.length, "MoleculeAML: ids and logicContracts must be same length");
        require(ids.length == isAllowLists.length, "MoleculeAML: ids and isAllowLists must be same length");
        require(ids.length == names.length, "MoleculeAML: ids and names must be same length");
        require(ids.length == reverseLogics.length, "MoleculeAML: ids and reverseLogics must be same length");
        for (uint256 i = 0; i < ids.length; i++) {
            _addLogic(ids[i], logicContracts[i], isAllowLists[i], names[i], reverseLogics[i]);
        }
    }

    // Note: may break selected logic combinations if id is in use
    function removeLogicBatch(uint32[] memory ids) external onlyOwner {
        for (uint256 i = 0; i < ids.length; i++) {
            _removeLogic(ids[i]);
        }
    }

    // Internal functions
    function _check(uint32[] memory ids, bytes memory data) internal view returns (bool) {
        if (_status == Status.Blocked) return false;
        if (_status == Status.Bypassed) return true;

        uint256 listLength = ids.length;
        require(ids.length > 0, "Molecule: no logic ids provided");
        for (uint256 i = 0; i < listLength; i++) {
            uint32 id = ids[i];
            require(_logicContract[id] != address(0), "MoleculeAML: list not found");
            bool result = ILogic(_logicContract[id]).check(data);
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

    function _addLogic(uint32 id, address logicContract, bool isAllowList, string memory name, bool reverseLogic)
        internal
        onlyOwner
    {
        require(_logicContract[id] == address(0), "Molecule: logic id already exists");
        require(logicContract != address(0), "Molecule: logic contract address cannot be zero");
        _logicContract[id] = logicContract;
        _isAllowList[id] = isAllowList; // sanction list should always be false (blocklist)
        _name[id] = name;
        _reverseLogic[id] = reverseLogic; // NOT used, should always be false
        emit LogicAdded(id, logicContract, isAllowList, name, reverseLogic);
    }

    function _removeLogic(uint32 id) internal onlyOwner {
        require(_logicContract[id] != address(0), "Molecule: logic id not found");
        delete _logicContract[id];
        delete _isAllowList[id];
        delete _name[id];
        delete _reverseLogic[id];
        emit LogicRemoved(id);
    }
}
