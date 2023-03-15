# molecule-core


## What is the Molecule Protocol?

Molecule Protocol defines a set of smart contracts for custom rule engine constructions.

The `Molecule.sol` smart contract serves as the controller smart contract, while `Logic*.sol` smart contracts are for the rule constructions.

By adding and removing rules from the Molecule smart contract, it creates a rule engine that returns `true` or `false`. It allows construction of both simple or complex logics.

A `status` setting is also included in each Molecule smart contract, where it can be set to always return `true` (bypassed), always return `false` (blocked), or return a boolean based on the rule engine (gated).

## What is the Molecule Protocol used for?

By putting one or more require statements in functions, you can gate the functions using one or more rule engines. The following are some sample use cases.

### NFT Mint Whitelisting

Whitelisting is a common use-case for NFT minting. By using the Molecule Protocol in the NFT smart contract, the whitelist can be added and managed easily. After the mint, the Molecule Protocol smart contract can be set to bypass entirely.

### On-Chain Compliance

AML: Most DeFi protocols are enforcing AML (Anti-Money-Laundering) on the UI level only. The Molecule Protocol enables AML checks at the smart contract level, so there is no known unauthorized counterparties at any time.

KYC: The NFT whitelisting can also be used for KYC (Know-Your-Customer) enforcements.

With Molecule Protocol, any DeFi project can become compliance with 1-line of code (the require statement).

### Soulbound and Conditional Soulbound tokens

Soulbound token refers to NFT tokens that cannot be transferred. For example, for KYC tokens, identity token is tied to each wallet address, transfer is prohibited.

For many Web3 loyal programs or GameFi projects, by preventing transfer, it prevents "farming." However, transfer should be conditionally allowed during redemption. Tokens should be either burned or transferred to treasury.

Implementing these with Molecule Protocol is trivial and is more flexible than hardcoding.

### Subscription Payment

Proof of payment can be implemented with whitelisting logic. By adding this payment check, proof of payment and even subscription payment can be verified before allowing smart contract executions. By de-coupling the payment at the smart contract level, it enables subscriptions, installments, and many other payment options for DeFi projects.

## Ecosystem

Features like payment services, AML and KYC are common use cases. Service providers can publish their Molecule Smart Contract address and allow any project to use their service. It can also use Molecule Protocol to implement the payment services, essentially enabling the SaaS model on-chain.

By standardizing the construction of rule engines using Molecule Protocol, even complex rules can be implemented easily and in a composable way. It removes duplicate implementations and maximize the values for service providers as well.

## Contribution

Can you think of more use cases that Molecule Protocol can support? Please describe your idea, or demo your idea to us, so we can share it to the entire community.

## Questions?

Send us questions on Twitter: [@moleculepro](https://twitter.com/moleculepro)
or join our Discord: https://discord.gg/J8dqFK8ufA


# Additional Information

## How to use the Molecule smart contract?

```
import "@moleculeprotocol/molecule-core/src/IMolecule.sol";

contract MyContract {
  safeTransfer(address _to) {
    require(IMolecule(_molecule_address).check(abi.encode(_to)), "MyContract: access denied.");
    // implementation
  }
}
```

```
import "@moleculeprotocol/molecule-core/src/IMoleculeAddress.sol";

contract MyContract {
  safeTransfer(address _to) {
    require(IMoleculeAddress(_molecule_address).check(_to), "MyContract: access denied.");
    // implementation
  }
}
```

1. Import the Molecule Protocol Interface smart contract
2. Cast the molecule smart contract address and call to check the recipient
3. You can configure your custom logic in the molecule smart contract


## AML Deployments

Goerli Testnet:

- Molecule contract : [0x3e3B446fA3c53b0c522ad0704319D59a271dCA13](https://goerli.etherscan.io/address/0x3e3B446fA3c53b0c522ad0704319D59a271dCA13)

- LogicAML US (ID:840) contract address : [0x508f44aa951551616AE7Ca9B1cdC6E1F8AD2156c](https://goerli.etherscan.io/address/0x508f44aa951551616AE7Ca9B1cdC6E1F8AD2156c)

- LogicAML UK (ID:826) contract address :[0x4e394fe5e9237764F2Da3DCE209776Ee2e5f8E74](https://goerli.etherscan.io/address/0x4e394fe5e9237764F2Da3DCE209776Ee2e5f8E74)
