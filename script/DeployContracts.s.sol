// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/v2/MoleculeController.sol";
import "../src/v2/MoleculeLogicList.sol";

contract DeployContracts is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address controller = address(new MoleculeController("Controller"));
        address logic = address(new MoleculeLogicList("list1", true));

        console.log("");
        console.log("Controller Deployed at:", controller);
        console.log("Logic List Deployed at:", logic);

        vm.stopBroadcast();
    }
}
