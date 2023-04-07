// SPDX-License-Identifier: None
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import "../src/experiments/solmate-integration/ERC721ms.sol";
import "../src/MoleculeAddress.sol";
import "../src/LogicACLAddress.sol";

contract ERC721MSTest is Test {
    // integration tests
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

    ERC721ms public solmateToken;
    Molecule public molecule;
    LogicACL public logicACL;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");
    address daisy = makeAddr("daisy");

    uint256 tokenId = 1;
    uint256 tokenId2 = 2;

    function setUp() public {
        solmateToken = new ERC721ms();
        molecule = new Molecule();
        logicACL = new LogicACL("test");
    }

    function testTokenLifetimeWithoutMolecule() public {
        vm.prank(bob);

        // mint token
        solmateToken.mint(bob, 1);
        assertEq(solmateToken.balanceOf(bob), 1);

        // transfer token
        // solmateToken._approve(alice, 1);
        // solmateToken._transfer(bob, alice, 1);
        // assertEq(solmateToken.balanceOf(bob), 0);
        // assertEq(solmateToken.balanceOf(alice), 1);

        // burn token
        solmateToken.burn(1);
        assertEq(solmateToken.balanceOf(bob), 0);
    }

    function testTokenLifeTimeWithMolecule() public {
        // list of addresses
        address[] memory incumbents = new address[](3);
        incumbents[0] = alice;
        incumbents[1] = bob;
        incumbents[2] = charlie;

        uint32 logicId = 1;
        uint32[] memory ids = new uint32[](1);
        ids[0] = logicId;

        // add batch to logic contract
        vm.expectEmit(true, false, false, false);
        emit ListAdded(incumbents);
        bool batchAdded = logicACL.addBatch(incumbents);
        assertEq(batchAdded, true);

        // add logic contract to Molecule for access control
        vm.expectEmit(true, true, true, true);
        // 3rd param true means we're setting an allowlist
        emit LogicAdded(logicId, address(logicACL), true, "test", false);
        molecule.addLogic(logicId, address(logicACL), true, "test", false);

        vm.expectEmit(true, false, false, false);
        emit Selected(ids);
        molecule.select(ids);

        // tell token contract which actions are to be gated
        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(molecule), MoleculeType.Mint);
        solmateToken.updateMolecule(
            address(molecule),
            ERC721ms.MoleculeType.Mint
        );
        assertEq(solmateToken._moleculeMint(), address(molecule));

        vm.expectEmit(true, true, false, false);
        emit MoleculeUpdated(address(molecule), MoleculeType.Burn);
        solmateToken.updateMolecule(
            address(molecule),
            ERC721ms.MoleculeType.Burn
        );
        assertEq(solmateToken._moleculeBurn(), address(molecule));

        vm.startPrank(alice);
        solmateToken.mint(alice, tokenId);
        assertEq(solmateToken.balanceOf(alice), 1);

        solmateToken.burn(tokenId);
        assertEq(solmateToken.balanceOf(alice), 0);
        vm.stopPrank();

        vm.startPrank(daisy);
        vm.expectRevert("ERC721m: account not allowed to mint");
        solmateToken.mint(daisy, tokenId2);
        vm.stopPrank();
    }
}
