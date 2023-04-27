// SPDX-License-Identifier: None
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import "../../src/v2/tokens/ERC1155m.sol";
import "../../src/v2/MoleculeController.sol";
import "../../src/v2/MoleculeLogicList.sol";

contract ERC1155MTest is Test {
    event ListAdded(address[] addresses);
    event MoleculeUpdated(address molecule, MoleculeType mtype);
    event Selected(uint32[] ids);
    event LogicAdded(
        uint32 indexed id,
        address indexed logicContract,
        bool isAllowList,
        string name,
        bool reverseLogic
    );
    enum Status {
        Gated,
        Blocked,
        Bypassed
    }
    enum MoleculeType {
        Approve,
        Burn,
        Mint,
        Transfer
    }

    ERC1155m public molToken;
    MoleculeController public molecule;
    MoleculeLogicList public logicList;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");
    address daisy = makeAddr("daisy");
    address eric = makeAddr("eric");

    function setUp() public {
        molToken = new ERC1155m("molecule");
        molecule = new MoleculeController("molecule controller");
        logicList = new MoleculeLogicList("logic", true);
    }

    function setBlockList() public {
        // list of addresses
        address[] memory blockList = new address[](3);
        blockList[0] = alice;
        blockList[1] = bob;
        blockList[2] = charlie;

        uint32 logicId = 1;
        uint32[] memory ids = new uint32[](1);
        ids[0] = logicId;

        // add batch to logic contract
        vm.expectEmit(true, false, false, false);
        emit ListAdded(blockList);
        bool batchAdded = logicList.addBatch(blockList);
        assertEq(batchAdded, true);

        // add logic contract to Molecule for access control
        vm.expectEmit(true, true, true, true);
        // 3rd param: false means we're setting a blocklist
        emit LogicAdded(logicId, address(logicList), true, "test", true);
        molecule.addLogic(logicId, address(logicList), "test", true);

        vm.expectEmit(true, false, false, false);
        emit Selected(ids);
        molecule.select(ids);
    }

    function setAllowlist() public {
        // list of addresses
        address[] memory allowList = new address[](3);
        allowList[0] = alice;
        allowList[1] = bob;
        allowList[2] = charlie;

        uint32 logicId = 1;
        uint32[] memory ids = new uint32[](1);
        ids[0] = logicId;

        // add batch to logic contract
        vm.expectEmit(true, false, false, false);
        emit ListAdded(allowList);
        bool batchAdded = logicList.addBatch(allowList);
        assertEq(batchAdded, true);

        // add logic contract to Molecule for access control
        vm.expectEmit(true, true, true, true);
        // 3rd param: true means we're setting an allowlist
        emit LogicAdded(logicId, address(logicList), true, "test", false);
        molecule.addLogic(logicId, address(logicList), "test", false);

        vm.expectEmit(true, false, false, false);
        emit Selected(ids);
        molecule.select(ids);
    }

    function test_erc1155token_withoutMolecule() public {
        // alice owns and mints from the token contract, alice == msg.sender
        vm.startPrank(alice);
        molToken.mint(alice, 1, 500, "yy");
        assertEq(molToken.balanceOf(alice, 1), 500);

        molToken.burn(alice, 1, 50);
        assertEq(molToken.balanceOf(alice, 1), 450);

        molToken.setApprovalForAll(bob, true);
        vm.stopPrank();

        // bob == msg.sender()
        vm.startPrank(bob);
        molToken.safeTransferFrom(alice, bob, 1, 50, "yy");
        assertEq(molToken.balanceOf(alice, 1), 400);
        assertEq(molToken.balanceOf(bob, 1), 50);
        vm.stopPrank();
    }

    function test_erc1155token_withMolecule() public {
        setBlockList();

        // tell token contract which actions are to be gated: Mint
        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(molecule), MoleculeType.Mint);
        molToken.updateMolecule(address(molecule), ERC1155m.MoleculeType.Mint);
        assertEq(molToken._moleculeMint(), address(molecule));

        vm.startPrank(alice);
        bytes4 selector = bytes4(keccak256("AccountNotAllowedToMint(address)"));
        vm.expectRevert(abi.encodeWithSelector(selector, alice));
        molToken.mint(alice, 1, 500, "yy");
        vm.stopPrank();

        vm.startPrank(eric);
        molToken.mint(eric, 1, 500, "yy");
        assertEq(molToken.balanceOf(eric, 1), 500);
        vm.stopPrank();

        // un-gate the mint function
        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(0), MoleculeType.Mint);
        molToken.updateMolecule(address(0), ERC1155m.MoleculeType.Mint);
        assertEq(molToken._moleculeMint(), address(0));

        // gate the Burn function
        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(molecule), MoleculeType.Burn);
        molToken.updateMolecule(address(molecule), ERC1155m.MoleculeType.Burn);
        assertEq(molToken._moleculeBurn(), address(molecule));

        vm.startPrank(bob);
        molToken.mint(bob, 1, 500, "yy");
        assertEq(molToken.balanceOf(bob, 1), 500);

        bytes4 selector2 = bytes4(
            keccak256("AccountNotAllowedToBurn(address)")
        );
        vm.expectRevert(abi.encodeWithSelector(selector2, bob));
        molToken.burn(bob, 1, 50);
        vm.stopPrank();

        vm.startPrank(eric);
        molToken.burn(eric, 1, 50);
        assertEq(molToken.balanceOf(eric, 1), 450);

        vm.stopPrank();
    }
}
