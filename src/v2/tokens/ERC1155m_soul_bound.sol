// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../interfaces/IMoleculeController.sol";

// custom errors
error AccountNotAllowedToMint(address minter);
error AccountNotAllowedToBurn(address burner);
error SenderNotAllowedToTransfer(address sender);
error RecipientNotAllowedToReceive(address receipient);
error OwnerNotAllowedToApprove(address owner);
// soul-bound error message
error TransfersNotAllowed();

// Molecule ERC1155 token
contract ERC1155m is ERC1155, Ownable {
    enum MoleculeType {
        Approve,
        Burn,
        Mint,
        Transfer
    }

    // Base URI for metadata
    string public _baseURI;

    // Molecule address
    address public _moleculeApprove;
    address public _moleculeBurn;
    address public _moleculeMint;
    address public _moleculeTransfer;

    event MoleculeUpdated(address molecule, MoleculeType mtype);
    event BaseUriUpdated(string baseURI);

    constructor(string memory baseURI) ERC1155("") {
        setBaseURI(baseURI);
    }

    // Set base URI for metadata, needed for displaying correctly on OpenSea
    function uri(
        uint256 id
    ) public view virtual override returns (string memory) {
        return string.concat(_baseURI, Strings.toString(id), ".json");
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external {
        if (_moleculeMint != address(0)) {
            if (!IMoleculeController(_moleculeMint).check(account)) {
                revert AccountNotAllowedToMint(account);
            }
        }
        _mint(account, id, amount, data);
    }

    function burn(address account, uint256 id, uint256 amount) external {
        if (_moleculeBurn != address(0)) {
            if (!IMoleculeController(_moleculeBurn).check(account)) {
                revert AccountNotAllowedToBurn(account);
            }
        }
        _burn(account, id, amount);
    }

    // Transfer function: note this is used by all mint/burn/transfer functions
    function _beforeTokenTransfer(
        address operator,
        address sender,
        address recipient,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        if (_moleculeTransfer != address(0)) {
            if (!IMoleculeController(_moleculeTransfer).check(sender)) {
                revert SenderNotAllowedToTransfer(sender);
            }
            if (!IMoleculeController(_moleculeTransfer).check(recipient)) {
                revert RecipientNotAllowedToReceive(recipient);
            }
        }
        // If no molecule specified, transfer is disabled by default
        // but mint or burn is allowed
        if (sender == address(0) || recipient == address(0)) {
            super._beforeTokenTransfer(
                operator,
                sender,
                recipient,
                ids,
                amounts,
                data
            );
            return;
        }

        // soul-bound, no transfer allowed, unless overwritten by Molecule
        revert TransfersNotAllowed();
    }

    // internal approve function
    function _setApprovalForAll(
        address tokenOwner,
        address operator,
        bool approved
    ) internal virtual override {
        if (_moleculeApprove != address(0)) {
            if (!IMoleculeController(_moleculeApprove).check(operator)) {
                revert OwnerNotAllowedToApprove(operator);
            }
        }
        super._setApprovalForAll(tokenOwner, operator, approved);
    }

    // Owner only functions
    // Update molecule address
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

    // Allow metadata uri to be updated by owner
    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseURI = baseURI;
        emit BaseUriUpdated(baseURI);
    }
}
