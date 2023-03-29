// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../IMoleculeAddress.sol";

contract ERC721m is ERC721, Ownable {
    enum MoleculeType {
        Approve,
        Burn,
        Mint,
        Transfer
    }

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
            require(
                IMoleculeAddress(_moleculeMint).check(to),
                "ERC721m: account not allowed to mint"
            );
        }
        _safeMint(to, tokenId);
    }

    function burn(uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        if (_moleculeBurn != address(0)) {
            require(
                IMoleculeAddress(_moleculeBurn).check(owner),
                "ERC721m: account not allowed to burn"
            );
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
            require(
                IMoleculeAddress(_moleculeTransfer).check(from),
                "ERC721m: sender not allowed to transfer"
            );
            require(
                IMoleculeAddress(_moleculeTransfer).check(to),
                "ERC721m: recipient not allowed to receive"
            );
        }
        super._transfer(from, to, tokenId);
    }

    // Approve function
    function _approve(address to, uint256 tokenId) internal virtual override {
        if (_moleculeApprove != address(0)) {
            address owner = ownerOf(tokenId);
            require(
                IMoleculeAddress(_moleculeApprove).check(owner),
                "ERC721m: owner not allowed to approve"
            );
            require(
                IMoleculeAddress(_moleculeApprove).check(to),
                "ERC721m: spender not allowed to receive"
            );
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
