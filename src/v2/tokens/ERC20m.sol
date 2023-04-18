// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// ERC20 token implementation
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IMoleculeLogic.sol";

// Molecule ERC20 token
abstract contract ERC20m is ERC20, Ownable {
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

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address account, uint256 amount) external {
        if (_moleculeMint != address(0)) {
            require(IMoleculeLogic(_moleculeMint).check(account), "ERC20m: account not allowed to mint");
        }
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        if (_moleculeBurn != address(0)) {
            require(IMoleculeLogic(_moleculeBurn).check(account), "ERC20m: account not allowed to burn");
        }
        _burn(account, amount);
    }

    // Transfer function
    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        if (_moleculeTransfer != address(0)) {
            require(IMoleculeLogic(_moleculeTransfer).check(sender), "ERC20m: sender not allowed to transfer");
            require(IMoleculeLogic(_moleculeTransfer).check(recipient), "ERC20m: recipient not allowed to receive");
        }
        super._transfer(sender, recipient, amount);
    }

    // Approve function
    function _approve(address owner, address spender, uint256 amount) internal virtual override {
        if (_moleculeApprove != address(0)) {
            require(IMoleculeLogic(_moleculeApprove).check(owner), "ERC20m: owner not allowed to approve");
            require(IMoleculeLogic(_moleculeApprove).check(spender), "ERC20m: spender not allowed to receive");
        }
        super._approve(owner, spender, amount);
    }

    // Owner only functions
    // Molecule ERC20 token
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
