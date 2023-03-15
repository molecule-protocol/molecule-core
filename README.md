# molecule-core

## What is the Molecule Protocol?

The Molecule Protocol defines a set of smart contracts for custom rule engine construction.

The Molecule.sol smart contract serves as the controller smart contract, while Logic*.sol smart contracts are for rule construction.

By adding and removing rules from the Molecule smart contract, it creates a rule engine that returns true or false. This allows for the construction of both simple and complex logics.

Each Molecule smart contract also includes a status setting. It can be set to always return true (bypassed), always return false (blocked), or return a boolean based on the rule engine (gated).

## What is the Molecule Protocol used for?

By placing one or more require statements in functions, you can gate the functions using one or more rule engines. The following are some sample use cases:

### NFT Mint Whitelisting

Whitelisting is a common use case for NFT minting. By using the Molecule Protocol in the NFT smart contract, the whitelist can be added and managed easily. After the mint, the Molecule Protocol smart contract can be set to bypass entirely.

### On-Chain Compliance

AML: Most DeFi protocols enforce AML (Anti-Money-Laundering) at the UI level only. The Molecule Protocol enables AML checks at the smart contract level, ensuring no unauthorized counterparties at any time.
KYC: NFT whitelisting can also be used for KYC (Know-Your-Customer) enforcement.
With the Molecule Protocol, any DeFi project can achieve compliance with just one line of code (the require statement).

### Soulbound and Conditional Soulbound Tokens

A soulbound token refers to an NFT token that cannot be transferred. For example, for KYC tokens, the identity token is tied to each wallet address, and transfer is prohibited.

Many Web3 loyalty programs or GameFi projects prevent transfer to avoid "farming." However, transfer should be conditionally allowed during redemption. Tokens should either be burned or transferred to the treasury.

Implementing these with the Molecule Protocol is trivial and more flexible than hardcoding.

### Subscription Payment

Proof of payment can be implemented with whitelisting logic. By adding this payment check, proof of payment and even subscription payment can be verified before allowing smart contract executions. By decoupling the payment at the smart contract level, it enables subscriptions, installments, and many other payment options for DeFi projects.

## Ecosystem

Features like payment services, AML, and KYC are common use cases. Service providers can publish their Molecule Smart Contract address and allow any project to use their service. They can also use the Molecule Protocol to implement payment services, essentially enabling the SaaS model on-chain.

By standardizing the construction of rule engines using the Molecule Protocol, even complex rules can be implemented easily and in a composable way. This removes duplicate implementations and maximizes value for service providers.

## Contribution

Can you think of more use cases that the Molecule Protocol can support? Please describe your idea or demo your idea to us so we can share it with the entire community.

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
