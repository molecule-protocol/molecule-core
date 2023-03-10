// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ILogicAddress.sol";

/// @title Molecule Protocol Logic NFT-gating contract (ERC721 only)
/// @dev This contract implements the ILogicAddress interface with address input
///      It will return true if the `account` owns any NFTs in the specified contract
///  Note: 1155 requires tokenId as input, currently not supported
contract LogicNFT is Ownable, ILogicAddress {
    // NFT contract address
    address public _nftContract;

    event NFTContractSet(address nftContract);

    // Returns true if the address has the NFT
    function check(address account) external view override returns (bool) {
        return IERC721(_nftContract).balanceOf(account) > 0;
    }

    // Owner only functions
    // Set NFT contract address
    function setNFTContract(address nftContract) external onlyOwner {
        _nftContract = nftContract;
        emit NFTContractSet(nftContract);
    }
}
