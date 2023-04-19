// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IMoleculeLogic.sol";

contract ERC721m is ERC721, Ownable {
    enum MoleculeType {
        Approve,
        Burn,
        Mint,
        Transfer
    }

    // Custom error definitions
    error AccountNotAllowedToMint(address to);
    error AccountNotAllowedToBurn(address burner);
    error SenderNotAllowedToTransfer(address sender);
    error OwnerNotAllowedToApprove(address owner);
    error SpenderNotAllowedToReceive(address spender);

    // Molecule addresses
    address public _moleculeApprove;
    address public _moleculeBurn;
    address public _moleculeMint;
    address public _moleculeTransfer;

    event MoleculeUpdated(address molecule, MoleculeType mtype);

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {}

    function mint(address to, uint256 tokenId) external {
        if (_moleculeMint != address(0)) {
            if (!IMoleculeLogic(_moleculeMint).check(to)) {
                revert AccountNotAllowedToMint(to);
            }
        }
        _safeMint(to, tokenId);
    }

    function burn(uint256 tokenId) external {
        address tokenOwner = ownerOf(tokenId);
        if (_moleculeBurn != address(0)) {
            if (!IMoleculeLogic(_moleculeBurn).check(tokenOwner)) {
                revert AccountNotAllowedToBurn(tokenOwner);
            }
        }
        _burn(tokenId);
    }

    // Transfer function
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        if (_moleculeTransfer != address(0)) {
            if (!IMoleculeLogic(_moleculeTransfer).check(from)) {
                revert SenderNotAllowedToTransfer(from);
            }
            if (!IMoleculeLogic(_moleculeTransfer).check(to)) {
                revert SpenderNotAllowedToReceive(to);
            }
        }
        super._transfer(from, to, tokenId);
    }

    // Approve function
    function _approve(address to, uint256 tokenId) internal virtual override {
        if (_moleculeApprove != address(0)) {
            address tokenOwner = ownerOf(tokenId);
            if (!IMoleculeLogic(_moleculeApprove).check(tokenOwner)) {
                revert OwnerNotAllowedToApprove(tokenOwner);
            }
            if (!IMoleculeLogic(_moleculeApprove).check(to)) {
                revert SpenderNotAllowedToReceive(to);
            }
        }
        super._approve(to, tokenId);
    }

    // Owner only functions
    // Molecule ERC721 token
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
