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


// Dependency file: src/IAtomAddress.sol

// pragma solidity ^0.8.17;

// Interface for Molecule Smart Contract
interface IAtomAddress {
    function check(address account) external view returns (bool);
}


// Root file: src/MoleculeAML.sol

pragma solidity ^0.8.17;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "src/IMolecule.sol";
// import "src/IAtomAddress.sol";

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
