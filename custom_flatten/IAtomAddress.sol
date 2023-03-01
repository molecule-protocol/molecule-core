// Root file: src/IAtomAddress.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Interface for Molecule Smart Contract
interface IAtomAddress {
    function check(address account) external view returns (bool);
}
