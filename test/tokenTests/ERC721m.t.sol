// SPDX-License-Identifier: None
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import "../../src/v2/tokens/ERC721m.sol";
import "../../src/v2/MoleculeController.sol";
import "../../src/v2/MoleculeLogicList.sol";

contract ERC721MTest is Test {
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

    ERC721m public molToken;
    MoleculeController public molecule;
    MoleculeLogicList public logicList;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");
    address daisy = makeAddr("daisy");
    address eric = makeAddr("eric");

    function setUp() public {
        molToken = new ERC721m("molecule", "MOL");
        molecule = new MoleculeController("molecule controller");
        logicList = new MoleculeLogicList("booyah", true);
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

    function test_erc721_functions() public {
        // mint token
        molToken.mint(bob, 1);
        assertEq(molToken.balanceOf(bob), 1);

        // burn token
        molToken.burn(1);
        assertEq(molToken.balanceOf(bob), 0);
    }

    function test_erc721_MoleculeAllowlist_MintGate() public {
        setAllowlist();

        // tell token contract which actions are to be gated
        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(molecule), MoleculeType.Mint);
        molToken.updateMolecule(address(molecule), ERC721m.MoleculeType.Mint);
        assertEq(molToken._moleculeMint(), address(molecule));

        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(molecule), MoleculeType.Burn);
        molToken.updateMolecule(address(molecule), ERC721m.MoleculeType.Burn);
        assertEq(molToken._moleculeBurn(), address(molecule));

        vm.startPrank(alice);
        molToken.mint(alice, 1);
        assertEq(molToken.balanceOf(alice), 1);

        molToken.burn(1);
        assertEq(molToken.balanceOf(alice), 0);
        vm.stopPrank();

        vm.startPrank(daisy);
        bytes4 selector = bytes4(keccak256("AccountNotAllowedToMint(address)"));
        vm.expectRevert(abi.encodeWithSelector(selector, daisy));
        molToken.mint(daisy, 2);

        vm.stopPrank();
    }

    function test_erc721_MoleculeBlocklist_MintGate() public {
        setBlockList();

        // tell token contract which actions are to be gated: Mint and Burn
        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(molecule), MoleculeType.Mint);
        molToken.updateMolecule(address(molecule), ERC721m.MoleculeType.Mint);
        assertEq(molToken._moleculeMint(), address(molecule));

        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(molecule), MoleculeType.Burn);
        molToken.updateMolecule(address(molecule), ERC721m.MoleculeType.Burn);
        assertEq(molToken._moleculeBurn(), address(molecule));

        vm.startPrank(daisy);
        molToken.mint(daisy, 1);
        assertEq(molToken.balanceOf(daisy), 1);

        molToken.burn(1);
        assertEq(molToken.balanceOf(daisy), 0);
        vm.stopPrank();

        // alice is part of the blocklist array, hence not allowed to mint
        vm.startPrank(alice);
        bytes4 selector = bytes4(keccak256("AccountNotAllowedToMint(address)"));
        vm.expectRevert(abi.encodeWithSelector(selector, alice));
        molToken.mint(alice, 2);

        vm.stopPrank();
    }

    function test_erc721_MoleculeBlockList_transferGate() public {
        setBlockList();

        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(molecule), MoleculeType.Transfer);
        molToken.updateMolecule(
            address(molecule),
            ERC721m.MoleculeType.Transfer
        );
        assertEq(molToken._moleculeTransfer(), address(molecule));

        vm.startPrank(daisy);
        molToken.mint(daisy, 1);
        assertEq(molToken.balanceOf(daisy), 1);

        bytes4 selector = bytes4(
            keccak256("SpenderNotAllowedToReceive(address)")
        );
        vm.expectRevert(abi.encodeWithSelector(selector, bob));
        molToken.transferFrom(daisy, bob, 1);
        vm.stopPrank();

        vm.startPrank(daisy);
        // daisy and eric are not part of the blocklist, they may freely exchange tokens
        molToken.mint(daisy, 2);
        assertEq(molToken.balanceOf(daisy), 2);
        molToken.transferFrom(daisy, eric, 1);
        assertEq(molToken.balanceOf(eric), 1);

        vm.stopPrank();
    }

    function test_erc721_MoleculeAllowList_ApproveGate() public {
        setAllowlist();

        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(molecule), MoleculeType.Approve);
        molToken.updateMolecule(
            address(molecule),
            ERC721m.MoleculeType.Approve
        );
        assertEq(molToken._moleculeApprove(), address(molecule));

        vm.startPrank(daisy);
        molToken.mint(daisy, 1);
        assertEq(molToken.balanceOf(daisy), 1);

        // approval not allowed since daisy is not on allowlist
        bytes4 selector = bytes4(
            keccak256("OwnerNotAllowedToApprove(address)")
        );
        vm.expectRevert(abi.encodeWithSelector(selector, daisy));
        molToken.approve(bob, 1);

        vm.stopPrank();

        vm.startPrank(bob);
        molToken.mint(bob, 3);
        assertEq(molToken.balanceOf(bob), 1);
        // approval not allowed since daisy is not on allowlist
        bytes4 selector2 = bytes4(
            keccak256("SpenderNotAllowedToReceive(address)")
        );
        vm.expectRevert(abi.encodeWithSelector(selector2, daisy));
        molToken.approve(daisy, 3);
        vm.stopPrank();
    }
}
