// SPDX-License-Identifier: None
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import "../../src/v2/tokens/ERC20m.sol";
import "../../src/v2/MoleculeController.sol";
import "../../src/v2/MoleculeLogicList.sol";

contract ERC20MTest is Test {
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
    event Transfer(address indexed from, address indexed to, uint256 amount);
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

    ERC20m public molToken;
    MoleculeController public molecule;
    MoleculeLogicList public logicList;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");
    address daisy = makeAddr("daisy");
    address eric = makeAddr("eric");

    function setUp() public {
        molToken = new ERC20m("molecule", "MOL");
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

    function test_erc20tokenLifeTime_withoutMolecule() public {
        // mint token
        molToken.mint(bob, 20);
        assertEq(molToken.balanceOf(bob), 20);

        // burn token
        molToken.burn(bob, 10);
        assertEq(molToken.balanceOf(bob), 10);
    }

    function test_erc20tokenLifeTime_withMolecule_allowlist() public {
        setAllowlist();

        // tell token contract which actions are to be gated
        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(molecule), MoleculeType.Mint);
        molToken.updateMolecule(address(molecule), ERC20m.MoleculeType.Mint);
        assertEq(molToken._moleculeMint(), address(molecule));

        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(molecule), MoleculeType.Burn);
        molToken.updateMolecule(address(molecule), ERC20m.MoleculeType.Burn);
        assertEq(molToken._moleculeBurn(), address(molecule));

        vm.startPrank(alice);
        molToken.mint(alice, 20);
        assertEq(molToken.balanceOf(alice), 20);

        molToken.burn(alice, 15);
        assertEq(molToken.balanceOf(alice), 5);
        vm.stopPrank();

        vm.startPrank(daisy);
        bytes4 selector = bytes4(keccak256("AccountNotAllowedToMint(address)"));
        vm.expectRevert(abi.encodeWithSelector(selector, daisy));
        molToken.mint(daisy, 2);

        vm.stopPrank();
    }

    function test_erc20tokenLifeTime_withMolecule_blocklist() public {
        setBlockList();

        // tell token contract which actions are to be gated
        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(molecule), MoleculeType.Mint);
        molToken.updateMolecule(address(molecule), ERC20m.MoleculeType.Mint);
        assertEq(molToken._moleculeMint(), address(molecule));

        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(molecule), MoleculeType.Burn);
        molToken.updateMolecule(address(molecule), ERC20m.MoleculeType.Burn);
        assertEq(molToken._moleculeBurn(), address(molecule));

        vm.startPrank(daisy);
        molToken.mint(daisy, 20);
        assertEq(molToken.balanceOf(daisy), 20);

        molToken.burn(daisy, 15);
        assertEq(molToken.balanceOf(daisy), 5);
        vm.stopPrank();

        vm.startPrank(alice);
        bytes4 selector = bytes4(keccak256("AccountNotAllowedToMint(address)"));
        vm.expectRevert(abi.encodeWithSelector(selector, alice));
        molToken.mint(alice, 2);

        vm.stopPrank();
    }

    function test_erc20_MoleculeBlocklist_BurnGate() public {
        setBlockList();

        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(molecule), MoleculeType.Burn);
        molToken.updateMolecule(address(molecule), ERC20m.MoleculeType.Burn);
        assertEq(molToken._moleculeBurn(), address(molecule));

        vm.startPrank(daisy);
        molToken.mint(daisy, 20);
        assertEq(molToken.balanceOf(daisy), 20);

        molToken.burn(daisy, 15);
        assertEq(molToken.balanceOf(daisy), 5);
        vm.stopPrank();

        vm.startPrank(bob);
        molToken.mint(bob, 20);
        assertEq(molToken.balanceOf(bob), 20);

        // bob is on the blocklist, so shouldn't be able to burn his tokens
        bytes4 selector = bytes4(keccak256("AccountNotAllowedToBurn(address)"));
        vm.expectRevert(abi.encodeWithSelector(selector, bob));
        molToken.burn(bob, 2);
        vm.stopPrank();
    }

    function test_erc20_MoleculeBlocklist_TransferApproveGate() public {
        setBlockList();

        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(molecule), MoleculeType.Transfer);
        molToken.updateMolecule(
            address(molecule),
            ERC20m.MoleculeType.Transfer
        );
        assertEq(molToken._moleculeTransfer(), address(molecule));

        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(molecule), MoleculeType.Approve);
        molToken.updateMolecule(address(molecule), ERC20m.MoleculeType.Approve);
        assertEq(molToken._moleculeApprove(), address(molecule));

        vm.startPrank(alice);
        molToken.mint(alice, 20);
        assertEq(molToken.balanceOf(alice), 20);

        // alice is on the blocklist and hence cannot send tokens
        bytes4 selector = bytes4(
            keccak256("OwnerNotAllowedToApprove(address)")
        );
        vm.expectRevert(abi.encodeWithSelector(selector, alice));
        molToken.approve(daisy, 5);
        vm.stopPrank();

        vm.startPrank(daisy);
        molToken.mint(daisy, 20);
        assertEq(molToken.balanceOf(daisy), 20);

        // alice being on the blocklist cannot be approved to spend tokens either
        bytes4 selector2 = bytes4(
            keccak256("RecipientNotAllowedToReceive(address)")
        );
        vm.expectRevert(abi.encodeWithSelector(selector2, alice));
        molToken.approve(alice, 5);
        vm.stopPrank();

        // remove molecule access control for token approve, all users can set approval
        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(0), MoleculeType.Approve);
        molToken.updateMolecule(address(0), ERC20m.MoleculeType.Approve);
        assertEq(molToken._moleculeApprove(), address(0));

        // approve and transfer tokens
        vm.startPrank(alice);

        molToken.approve(alice, 10);

        // alice is on the blocklist and hence cannot send tokens
        bytes4 selector3 = bytes4(
            keccak256("SenderNotAllowedToTransfer(address)")
        );
        vm.expectRevert(abi.encodeWithSelector(selector3, alice));
        molToken.transferFrom(alice, daisy, 5);
        vm.stopPrank();

        vm.startPrank(eric);
        molToken.mint(eric, 20);
        assertEq(molToken.balanceOf(eric), 20);

        molToken.approve(eric, 20);

        bytes4 selector4 = bytes4(
            keccak256("RecipientNotAllowedToReceive(address)")
        );
        vm.expectRevert(abi.encodeWithSelector(selector4, alice));
        molToken.transferFrom(eric, alice, 5);

        // eric and daisy are not part of the blocklist
        vm.expectEmit(true, true, true, true);
        emit Transfer(eric, daisy, 5);
        molToken.transferFrom(eric, daisy, 5);
        assertEq(molToken.balanceOf(daisy), 25);
        vm.stopPrank();
    }
}
