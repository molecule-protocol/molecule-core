// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IMoleculeController.sol";
import "./interfaces/IMoleculeLogic.sol";

/// @title Molecule Protocol Controller Contract
/// @dev This contract implements the IMoleculeController interface
contract MoleculeController is Ownable, IMoleculeController {
    // Human readable name of the controller
    string public _controllerName;
    // default logic combinations to use
    uint32[] public _selected;
    // current status of the contract
    Status public _status = Status.Gated;

    // list id => atomic logic contract address
    mapping(uint32 => address) private _logicContract;
    // list id => allow- (true) or block- (false) list
    mapping(uint32 => bool) private _isAllowList;
    // list id => list name
    mapping(uint32 => string) private _logicName;
    // list id => logic modifier: add negation if true or false for as-is
    mapping(uint32 => bool) private _reverseLogic;

    // Note: Enum & Events are defined by the interface

    constructor(string memory name_) {
        _controllerName = name_;
        emit ControllerDeployed(name_);
    }

    // Use default logic combination
    function check(address account) external view returns (bool) {
        return _check(_selected, account);
    }

    // Use custom logic combination, passed in as an array of list ids
    function check(
        uint32[] memory ids,
        address account
    ) external view returns (bool) {
        return _check(ids, account);
    }

    // Get the controller name
    function controllerName() external view returns (string memory) {
        return _controllerName;
    }

    // Get the current selected logic combination
    function selected() external view returns (uint32[] memory) {
        return _selected;
    }

    // Get the current status of the contract
    function status() external view returns (Status) {
        return _status;
    }

    // Owner only functions
    // Change the controller name
    function setControllerName(string memory name_) external onlyOwner {
        _controllerName = name_;
        emit ControllerDeployed(name_);
    }

    // Control the status of the contract
    function setStatus(Status newStatus) external onlyOwner {
        _status = newStatus;
        emit StatusChanged(newStatus);
    }

    // Preselect logic combinations
    function select(uint32[] memory ids) external onlyOwner {
        for (uint i = 0; i < ids.length; ) {
            require(
                _logicContract[ids[i]] != address(0),
                "Molecule: logic id not found"
            );
            unchecked {
                ++i;
            }
        }
        _selected = ids;
        emit Selected(ids);
    }

    function addLogic(
        uint32 id,
        address logicContract,
        string memory name,
        bool reverseLogic
    ) external onlyOwner {
        _addLogic(id, logicContract, name, reverseLogic);
    }

    // Note: may break selected logic combinations if id is in use
    function removeLogic(uint32 id) external onlyOwner {
        _removeLogic(id);
    }

    function addLogicBatch(
        uint32[] memory ids,
        address[] memory logicContracts,
        string[] memory names,
        bool[] memory reverseLogics
    ) external onlyOwner {
        require(
            ids.length == logicContracts.length,
            "MoleculeAML: ids and logicContracts must be same length"
        );
        require(
            ids.length == names.length,
            "MoleculeAML: ids and names must be same length"
        );
        require(
            ids.length == reverseLogics.length,
            "MoleculeAML: ids and reverseLogics must be same length"
        );
        for (uint i = 0; i < ids.length; i++) {
            _addLogic(ids[i], logicContracts[i], names[i], reverseLogics[i]);
        }
    }

    // Note: may break selected logic combinations if id is in use
    function removeLogicBatch(uint32[] memory ids) external onlyOwner {
        for (uint i = 0; i < ids.length; ) {
            _removeLogic(ids[i]);
            unchecked {
                ++i;
            }
        }
    }

    // Internal functions
    function _check(
        uint32[] memory ids,
        address account
    ) internal view returns (bool) {
        // Contract status checks
        if (_status == Status.Blocked) return false;
        if (_status == Status.Bypassed) return true;
        require(ids.length > 0, "Molecule: no logic ids provided");
        for (uint i = 0; i < ids.length; ) {
            uint32 id = ids[i];
            require(
                _logicContract[id] != address(0),
                "MoleculeAML: list not found"
            );
            bool result = IMoleculeLogic(_logicContract[id]).check(account);
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
            unchecked {
                ++i;
            }
        }
        return true;
    }

    function _addLogic(
        uint32 id,
        address logicContract,
        string memory name,
        bool reverseLogic
    ) internal onlyOwner {
        require(
            _logicContract[id] == address(0),
            "Molecule: logic id already exists"
        );
        require(
            logicContract != address(0),
            "Molecule: logic contract address cannot be zero"
        );
        _logicContract[id] = logicContract;
        // extract the isAllowList value from the logic contract
        _isAllowList[id] = IMoleculeLogic(logicContract).isAllowlist();
        // if a name is provided, use it, otherwise use the name from the logic contract
        if (bytes(name).length > 0) {
            _logicName[id] = name;
        } else {
            _logicName[id] = IMoleculeLogic(logicContract).logicName();
        }
        _reverseLogic[id] = reverseLogic; // NOT used, should always be false
        emit LogicAdded(
            id,
            logicContract,
            _isAllowList[id],
            _logicName[id],
            reverseLogic
        );
    }

    function _removeLogic(uint32 id) internal onlyOwner {
        require(
            _logicContract[id] != address(0),
            "Molecule: logic id not found"
        );
        delete _logicContract[id];
        delete _isAllowList[id];
        delete _logicName[id];
        delete _reverseLogic[id];
        emit LogicRemoved(id);
    }

    function addLogic(
        uint32 id,
        address logicContract,
        bool isAllowList,
        string memory name,
        bool reverseLogic
    ) external override {}

    function addLogicBatch(
        uint32[] memory ids,
        address[] memory logicContracts,
        bool[] memory isAllowLists,
        string[] memory names,
        bool[] memory reverseLogics
    ) external override {}
}
