// SPDX-License-Identifier: None

pragma solidity ^0.8.17;

// solmate's ERC721
import "@solmate/src/tokens/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../../IMoleculeAddress.sol";

contract ERC721ms is ERC721, Ownable {
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

    // where do we track tokenID - Counter.Counters

    constructor() ERC721("Molecule", "MOL") {}

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
        address tokenOwner = ownerOf(tokenId);
        if (_moleculeBurn != address(0)) {
            require(
                IMoleculeAddress(_moleculeBurn).check(tokenOwner),
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
    ) external virtual {
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
        super.transferFrom(from, to, tokenId);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
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
        super.safeTransferFrom(from, to, tokenId);
    }

    // Approve function
    function _approve(address to, uint256 tokenId) external virtual {
        if (_moleculeApprove != address(0)) {
            address tokenOwner = ownerOf(tokenId);
            require(
                IMoleculeAddress(_moleculeApprove).check(tokenOwner),
                "ERC721m: owner not allowed to approve"
            );
            require(
                IMoleculeAddress(_moleculeApprove).check(to),
                "ERC721m: spender not allowed to receive"
            );
        }
        super.approve(to, tokenId);
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

    function tokenURI(
        uint256 id
    ) public view virtual override returns (string memory) {}
}
