// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../interfaces/IMoleculeLogic.sol";

// Only accept ETH for now
// Each address can only have 1 token
// Exact mint price is needed for subscription
// Modified EIP-5643 reference implementation: https://eips.ethereum.org/EIPS/eip-5643
// -- tokenId is not relevant, checks are on user address instead
// -- use Molecule Logic Interface for validity check: checks NFT existence and expiration
// -- disallow subscription if user is sanctioned
// -- NFT is actually optional, but it allows subscription to show up on OpenSea/Marketplaces
//    and able to show up in user's NFT portfolio
contract Subscription is ERC721, IMoleculeLogic, Ownable {
    using Counters for Counters.Counter;

    // Human readable name of the list
    string public _logicName;
    // True if the list is an allowlist, false if it is a Blocklist
    bool public _isAllowlist;

    Counters.Counter private _tokenIds;

    uint256 public _price;
    uint64 public _duration;
    bool public _renewable;

    address public _molecule;

    // EIP-5643 reference implementation modified
    // owner address to experiation date
    mapping(address => uint64) public _expirations;

    event PriceUpdated(uint256 mintPrice);
    event DurationUpdated(uint256 duration);
    event Renewable(bool renewable);
    event MoleculeUpdated(address molecule);
    event Subscribed(address indexed user, uint64 expiration);
    event Unsubscribed(address indexed user);

    constructor() ERC721("Sample Molecule Subscription", "SUB") {
        // Set the subscription settings
        _logicName = "Sample Paywall using Subscription";
        _isAllowlist = true;
        updatePrice(0.001 ether);
        updateDuration(30 days);
        updateRenewable(true);
    }

    function logicName() external view override returns (string memory) {
        return _logicName;
    }

    function isAllowlist() external view override returns (bool) {
        return _isAllowlist;
    }

    // Molecule Logic function
    function check(address user) public view override returns (bool) {
        bool isSubscriber = IERC721(address(this)).balanceOf(user) > 0;
        bool hasExpired = _expirations[user] < block.timestamp;
        return isSubscriber && !hasExpired;
    }

    // Allow anybody to subscribe or renew for a user
    function subscribe(address user) public payable {
        // Allow deferred Molecule controller deployment
        if (_molecule != address(0)) {
            require(
                IMoleculeLogic(_molecule).check(user),
                "User is sanctioned"
            );
        }
        require(user != address(0), "Invalid address");
        // Only exact amount is accepted
        require(msg.value == _price, "Incorrect amount of Ether sent");

        // If the user does not have a subscription, mint a new NFT
        if (IERC721(address(this)).balanceOf(user) == 0) {
            _tokenIds.increment();
            uint256 newTokenId = _tokenIds.current();
            _safeMint(user, newTokenId);
            _expirations[user] = uint64(block.timestamp + _duration);
        } else {
            // If the user has a subscription, check if it is renewable
            require(_renewable, "Subscription is not renewable");
            _expirations[user] += _duration;
        }

        // Subscribe or renew emits the same event
        emit Subscribed(user, _expirations[user]);
    }

    function unsubscribe() public {
        require(
            IERC721(address(this)).balanceOf(msg.sender) > 0,
            "User does not have a subscription"
        );
        require(
            _expirations[msg.sender] > block.timestamp,
            "Subscription has already expired"
        );

        // We do NOT burn the NFT, only update the expirations
        _expirations[msg.sender] = 0;
        emit Unsubscribed(msg.sender);
    }

    // Owner only functions
    // Function to update the mint price
    function updatePrice(uint256 price) public onlyOwner {
        _price = price;
        emit PriceUpdated(price);
    }

    function updateDuration(uint64 duration) public onlyOwner {
        _duration = duration;
        emit DurationUpdated(duration);
    }

    function updateRenewable(bool renewable) public onlyOwner {
        _renewable = renewable;
        emit Renewable(renewable);
    }

    function updateMolecule(address molecule) public onlyOwner {
        _molecule = molecule;
        emit MoleculeUpdated(molecule);
    }

    // Function to withdraw the Ether collected from subscriptions
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function addBatch(address[] memory addresses) external returns (bool) {}

    function removeBatch(address[] memory addresses) external {}
}
