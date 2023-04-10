// Root file: v1/contracts/ILogic.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Interface for Molecule Smart Contract
interface ILogic {
    function check(bytes memory data) external view returns (bool);
}
