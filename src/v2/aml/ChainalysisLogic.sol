// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../MoleculeLogic.sol";

// Chainalysis SanctionList template
// https://go.chainalysis.com/chainalysis-oracle-docs.html
interface SanctionsList {
    function isSanctioned(address addr) external view returns (bool);
}

// This contract is immutable, no way to change once deployed
contract AML is MoleculeLogic,Ownable {
    // Chainalysis SanctionList contract address
    address public sanctionList ; 

    // Constructor arguments:
    // logicLabel = "Chainalysis SanctionList"
    // isAllowlistBool = false
    constructor() MoleculeLogic("Chainalysis SanctionList", false) {}

     function setSanctionListAddress(address _sanctionList) external onlyOwner() {
        sanctionList = _sanctionList;
    }

    function check(address account) external view override returns (bool) {
        return SanctionsList(sanctionList).isSanctioned(account);
    }
}
