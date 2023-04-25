// SPDX-License-Identifier: None
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import "../src/v2/tokens/ERC20m.sol";
import "../src/v2/MoleculeController.sol";
import "../src/v2/MoleculeLogicList.sol";

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
    MoleculeLogicList public logicACL;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");
    address daisy = makeAddr("daisy");

    uint256 tokenId = 1;
    uint256 tokenId2 = 2;

    function setUp() public {
        molToken = new ERC20m("molecule", "MOL", 18);
        molecule = new MoleculeController("molecule controller");
        logicACL = new MoleculeLogicList("booyah", true);
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
        bool batchAdded = logicACL.addBatch(allowList);
        assertEq(batchAdded, true);

        // add logic contract to Molecule for access control
        vm.expectEmit(true, true, true, true);
        // 3rd param true means we're setting an allowlist
        emit LogicAdded(logicId, address(logicACL), true, "test", false);
        molecule.addLogic(logicId, address(logicACL), "test", false);

        vm.expectEmit(true, false, false, false);
        emit Selected(ids);
        molecule.select(ids);

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
        bool batchAdded = logicACL.addBatch(blockList);
        assertEq(batchAdded, true);

        // add logic contract to Molecule for access control
        vm.expectEmit(true, true, true, true);
        // 3rd param true means we're setting an allowlist
        emit LogicAdded(logicId, address(logicACL), true, "test", true);
        molecule.addLogic(logicId, address(logicACL), "test", true);

        vm.expectEmit(true, false, false, false);
        emit Selected(ids);
        molecule.select(ids);

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
}
