// Root file: v1/contracts/ILogicAddress.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Interface for Molecule Smart Contract
interface ILogicAddress {
    function check(address account) external view returns (bool);
}
