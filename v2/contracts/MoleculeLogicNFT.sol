// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@moleculeprotocol/molecule-core/v2/contracts/interfaces/IMoleculeLogic.sol";

/// @title Molecule Protocol Logic NFT-gating contract (ERC721 only)
/// @dev This contract implements the ILogicAddress interface with address input
///      It will return true if the `account` owns any NFTs in the specified contract
///  Note: 1155 requires tokenId as input, currently not supported
contract MoleculeLogicNFT is Ownable, IMoleculeLogic {
    // Human readable name of the list
    string public _name;
    // True if the list is an allowlist, false if it is a Blocklist
    bool public _isAllowlist;
    // NFT contract address
    address public _nftContract;

    event NFTContractSet(address nftContract);
    event NFTLogicCreated(string name, bool isAllowlist);

    constructor(string memory name_, bool isAllowlist_, address nftContract_) {
        // Name and the allowlist/blocklist can only be set during creation
        _name = name_;
        _isAllowlist = isAllowlist_;
        emit NFTLogicCreated(name_, isAllowlist_);
        setNFTContract(nftContract_);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function isAllowlist() external view returns (bool) {
        return _isAllowlist;
    }

    function nftContract() external view returns (address) {
        return _nftContract;
    }

    // Returns true if the address has the NFT
    function check(address account) external view override returns (bool) {
        return IERC721(_nftContract).balanceOf(account) > 0;
    }

    // Owner only functions
    // Set NFT contract address
    function setNFTContract(address nftContract_) public onlyOwner {
        _nftContract = nftContract_;
        emit NFTContractSet(nftContract_);
    }
}
