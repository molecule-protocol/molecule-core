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


// Dependency file: v1/contracts/ILogicAddress.sol

// pragma solidity ^0.8.17;

// Interface for Molecule Smart Contract
interface ILogicAddress {
    function check(address account) external view returns (bool);
}


// Root file: v1/contracts/LogicACLAddress.sol

pragma solidity ^0.8.17;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "v1/contracts/ILogicAddress.sol";

/// @title Molecule Protocol Access Control List
/// @dev This contract implements the ILogicAddress interface with address input
///      It will return true if the `account` exists in the List
contract LogicACL is Ownable, ILogicAddress {
    // Human readable name of the list
    string public _name;

    // Change to public if the list is public
    mapping(address => bool) private _list;

    event ListAdded(address[] addresses);
    event ListRemoved(address[] addresses);
    event NameSet(string name);

    constructor(string memory name_) {
        setName(name_);
    }

    // Returns true if the address is sanctioned
    function check(address account) external view returns (bool) {
        return _list[account];
    }

    // Owner only functions
    // Add addresses to the List
    function addBatch(address[] memory addresses) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < addresses.length; i++) {
            _list[addresses[i]] = true;
        }
        emit ListAdded(addresses);
        return true;
    }

    // Remove addresses from the List
    function removeBatch(address[] memory addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _list[addresses[i]] = false;
        }
        emit ListRemoved(addresses);
    }

    // Set the name of the list
    function setName(string memory name_) public onlyOwner {
        _name = name_;
        emit NameSet(name_);
    }
}
