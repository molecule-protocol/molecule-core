// Root file: src/IMolecule.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Interface for Molecule Smart Contract
interface IMolecule {
    // // selected logic combinations
    // uint32 [] private _selected;

    // // list id => atomic logic contract address
    // mapping(uint32 => address) private _logicContract;
    // // list id => allow- (true) or block- (false) list
    // mapping(uint32 => bool) private _isAllowList;
    // // list id => list name
    // mapping(uint32 => string) private _name;
    // // list id => logic modifier: add negation if true or false for as-is
    // mapping(uint32 => bool) private _reverseLogic; // NOT used, always false

    // Use default logic combination
    function check(address account) external view returns (bool);
    // Use custom logic combination
    function check(uint32 [] memory ids, address account) external view returns (bool);

    // Add a new logic
    function addLogic(uint32 id, address logicContract, bool isAllowList, string memory name, bool reverseLogic) external;
    // Remove a logic
    function removeLogic(uint32 id) external;
    // Add new logics in batch
    function addLogicBatch(uint32 [] memory ids, address [] memory logicContracts, bool [] memory isAllowLists, string [] memory names, bool [] memory reverseLogics) external;
    // Remove logics in batch
    function removeLogicBatch(uint32 [] memory ids) external;
    // Preselect logic combinations
    function select(uint32 [] memory ids) external;

    // event emitted when a new list is added
    event LogicAdded(uint32 indexed id, address indexed logicContract, bool isAllowList, string name, bool reverseLogic);
    // event emitted when a list is removed
    event LogicRemoved(uint32 indexed id);
}
