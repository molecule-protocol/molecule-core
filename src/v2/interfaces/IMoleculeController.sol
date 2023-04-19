// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Interface for Molecule Protocol Smart Contract
interface IMoleculeController {
    // Human readable name of the controller
    // string public _controllerName;
    // // selected logic combinations
    // uint32[] private _selected;

    // Gated: gated by logic
    // Blocked: always return `false`
    // Bypassed: always return `true`
    enum Status {
        Gated,
        Blocked,
        Bypassed
    }

    // // list id => atomic logic contract address
    // mapping(uint32 => address) private _logicContract;
    // // list id => allow- (true) or block- (false) list
    // mapping(uint32 => bool) private _isAllowList;
    // // list id => list name
    // mapping(uint32 => string) private _name;
    // // list id => logic modifier: add negation if true or false for as-is
    // mapping(uint32 => bool) private _reverseLogic; // NOT used, always false

    // event emitted when the controller name is changed
    event ControllerNameUpdated(string name);
    // event emitted when a new list is added
    event LogicAdded(
        uint32 indexed id,
        address indexed logicContract,
        bool isAllowList,
        string name,
        bool reverseLogic
    );
    // event emitted when a list is removed
    event LogicRemoved(uint32 indexed id);
    // event emitted when a new logic combination is selected
    event Selected(uint32[] ids);
    // event emitted when status changed
    event StatusChanged(Status status);

    // Use default logic combination
    function check(address toCheck) external view returns (bool);

    // Use custom logic combination, passed in as an array of list ids
    function check(
        uint32[] memory ids,
        address toCheck
    ) external view returns (bool);

    // Get the current selected logic combination
    function selected() external view returns (uint32[] memory);

    // Get the current status of the contract
    function status() external view returns (Status);

    // Owner only functions
    // Control the status of the contract
    function setStatus(Status status) external;

    // Preselect logic combinations
    function select(uint32[] memory ids) external;

    // Add a new logic
    function addLogic(
        uint32 id,
        address logicContract,
        bool isAllowList,
        string memory name,
        bool reverseLogic
    ) external;

    // Remove a logic
    function removeLogic(uint32 id) external;

    // Add new logics in batch
    function addLogicBatch(
        uint32[] memory ids,
        address[] memory logicContracts,
        bool[] memory isAllowLists,
        string[] memory names,
        bool[] memory reverseLogics
    ) external;

    // Remove logics in batch
    function removeLogicBatch(uint32[] memory ids) external;
}
