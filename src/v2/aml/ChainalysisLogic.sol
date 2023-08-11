// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../MoleculeLogic.sol";

// Chainalysis SanctionList template
// https://go.chainalysis.com/chainalysis-oracle-docs.html
interface SanctionsList {
    function isSanctioned(address addr) external view returns (bool);
}

// This contract is immutable, no way to change once deployed
contract AML is MoleculeLogic {
    // Chainalysis SanctionList contract address
    address public immutable sanctionList = 0x40C57923924B5c5c5455c48D93317139ADDaC8fb;

    // Constructor arguments:
    // logicLabel = "Chainalysis SanctionList"
    // isAllowlistBool = false
    constructor() MoleculeLogic("Chainalysis SanctionList", false) {}

    function check(address account) external view override returns (bool) {
        return SanctionsList(sanctionList).isSanctioned(account);
    }
}
