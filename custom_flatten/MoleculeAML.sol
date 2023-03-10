// Dependency file: @openzeppelin/contracts/utils/Context.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

// pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// Dependency file: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// Dependency file: src/IMolecule.sol

// pragma solidity ^0.8.17;

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


// Dependency file: src/ILogicAddress.sol

// pragma solidity ^0.8.17;

// Interface for Molecule Smart Contract
interface ILogicAddress {
    function check(address account) external view returns (bool);
}


// Root file: src/MoleculeAML.sol

pragma solidity ^0.8.17;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "src/IMolecule.sol";
// import "src/ILogicAddress.sol";

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
