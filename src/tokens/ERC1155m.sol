// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@moleculeprotocol/molecule-core/src/IMoleculeAddress.sol";

// Molecule ERC1155 token
contract ERC1155m is ERC1155, Ownable {
    enum MoleculeType {Approve, Burn, Mint, Transfer}

    // Molecule address
    address public _moleculeApprove;
    address public _moleculeBurn;
    address public _moleculeMint;
    address public _moleculeTransfer;

    event MoleculeUpdated(address molecule, MoleculeType mtype);

    constructor(string memory uri) ERC1155(uri) {}

    function mint(address account, uint256 id, uint256 amount, bytes memory data) external {
        if (_moleculeMint != address(0)) {
          require(IMoleculeAddress(_moleculeMint).check(account), "ERC1155m: account not allowed to mint");
        }
        _mint(account, id, amount, data);
    }

    function burn(address account, uint256 id, uint256 amount) external {
        if (_moleculeBurn != address(0)) {
          require(IMoleculeAddress(_moleculeBurn).check(account), "ERC1155m: account not allowed to burn");
        }
        _burn(account, id, amount);
    }

    // Transfer function: note this is used by all mint/burn/transfer functions
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        if (_moleculeTransfer != address(0)) {
          require(IMoleculeAddress(_moleculeTransfer).check(from), "ERC1155m: sender not allowed to transfer");
          require(IMoleculeAddress(_moleculeTransfer).check(to), "ERC1155m: recipient not allowed to receive");
        }
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    // Approve function
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual override {
        if (_moleculeApprove != address(0)) {
          require(IMoleculeAddress(_moleculeApprove).check(operator), "ERC1155m: owner not allowed to approve");
        }
        super._setApprovalForAll(owner, operator, approved);
    }

    // Owner only functions
    // Update molecule address
    function updateMolecule(address molecule, MoleculeType mtype) external onlyOwner {
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
