// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// ERC20 token implementation
import {ERC20} from "@solmate/tokens/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../../interfaces/IMoleculeController.sol";

// custom errors
error AccountNotAllowedToMint(address minter);
error AccountNotAllowedToBurn(address burner);
error SenderNotAllowedToTransfer(address sender);
error RecipientNotAllowedToReceive(address receipient);
error OwnerNotAllowedToApprove(address owner);

// Molecule ERC20 token
contract ERC20m is ERC20, Ownable {
    enum MoleculeType {
        Approve,
        Burn,
        Mint,
        Transfer
    }
    // Molecule address
    address public _moleculeApprove;
    address public _moleculeBurn;
    address public _moleculeMint;
    address public _moleculeTransfer;

    event MoleculeUpdated(address molecule, MoleculeType mtype);

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 tokenDecimals
    ) ERC20(_tokenName, _tokenSymbol, tokenDecimals) {}

    function mint(address account, uint256 amount) external {
        if (_moleculeMint != address(0)) {
            if (!IMoleculeController(_moleculeMint).check(account)) {
                revert AccountNotAllowedToMint(account);
            }
        }
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        if (_moleculeBurn != address(0)) {
            if (!IMoleculeController(_moleculeBurn).check(account)) {
                revert AccountNotAllowedToBurn(account);
            }
        }
        _burn(account, amount);
    }

    // Transfer function: solmate integration does not use an internal function like OZ
    function transfer(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual {
        if (_moleculeTransfer != address(0)) {
            if (!IMoleculeController(_moleculeTransfer).check(sender)) {
                revert SenderNotAllowedToTransfer(sender);
            }
            if (!IMoleculeController(_moleculeTransfer).check(recipient)) {
                revert RecipientNotAllowedToReceive(recipient);
            }
        }
        super.transfer(recipient, amount);
    }

    // Approve function
    function approve(
        address tokenOwner,
        address spender,
        uint256 amount
    ) public virtual {
        if (_moleculeApprove != address(0)) {
            if (!IMoleculeController(_moleculeApprove).check(tokenOwner)) {
                revert OwnerNotAllowedToApprove(tokenOwner);
            }
            if (!IMoleculeController(_moleculeApprove).check(spender)) {
                revert RecipientNotAllowedToReceive(spender);
            }
        }
        super.approve(spender, amount);
    }

    // Owner only functions
    // Molecule ERC20 token
    function updateMolecule(
        address molecule,
        MoleculeType mtype
    ) external onlyOwner {
        // allows 0x0 address to be set to remove molecule access control
        if (mtype == MoleculeType.Approve) {
            _moleculeApprove = molecule;
        } else if (mtype == MoleculeType.Burn) {
            _moleculeBurn = molecule;
        } else if (mtype == MoleculeType.Mint) {
            _moleculeMint = molecule;
        } else if (mtype == MoleculeType.Transfer) {
            _moleculeTransfer = molecule;
        }
        emit MoleculeUpdated(molecule, mtype);
    }
}
