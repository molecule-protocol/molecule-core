# molecule-core

[![Foundry][foundry-badge]][foundry]

[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg

[foundry]: https://getfoundry.sh/

## What is the Molecule Protocol?

The Molecule Protocol defines a set of smart contracts for custom rule engine construction for your smart contracts.

The `MoleculeController.sol` smart contract serves as the controller smart contract, while `MoleculeLogic\*.sol` smart contracts are for rule construction.

By adding and removing rules from the Molecule Controller smart contract, it creates a rule engine that returns `true` or `false`. This allows for the construction of both simple and complex logics.

Each Molecule smart contract also includes a status setting. It can be set to always return true (`bypassed`), always return false (`blocked`), or return a boolean based on the rule engine (`gated`).

## What is the Molecule Protocol used for?

By placing one or more `require` statements in functions, you can gate the functions using your custom rule engines. The following are some sample use cases:

### NFT Mint Allowlist (Whitelist)

Allow list (whitelist) is a common use case for NFT minting. By using the Molecule Protocol in the NFT smart contract, the allow list can be added and managed easily. After the mint, the Molecule Protocol smart contract can be set to bypass entirely.

### On-Chain Compliance

AML: Most DeFi protocols enforce AML (Anti-Money-Laundering) at the UI level only. The Molecule Protocol enables AML checks at the smart contract level, ensuring no unauthorized counterparties at any time.

KYC: NFT allow lists can also be used for KYC (Know-Your-Customer) enforcement. With the Molecule Protocol, any DeFi project can achieve compliance as simple as adding one line of code (the `require` statement).

### Soulbound and Conditional Soulbound Tokens

A soulbound token refers to an NFT token that cannot be transferred. For example, for KYC tokens, the identity token is tied to each wallet address, and transfer is prohibited.

Many Web3 loyalty programs or GameFi projects prevent transfer to avoid "farming." However, transfer should be conditionally allowed during redemption. Tokens should either be burned or transferred to the treasury.

Implementing these with the Molecule Protocol is trivial and more flexible than hardcoding.

### Subscription Payment

Proof of payment can be implemented with adding an allowlist logic. By adding this payment check, proof of payment and even subscription payment can be verified before allowing smart contract executions. By decoupling the payment at the smart contract level, it enables subscriptions, installments, and many other payment options for DeFi projects.

## Ecosystem

Features like payment services, AML, and KYC are common use cases. Service providers can publish their Molecule Smart Contract address and allow any project to use their services. They can also use the Molecule Protocol to implement payment services, essentially enabling the SaaS model on-chain.

By standardizing the construction of rule engines using the Molecule Protocol, even complex rules can be implemented easily and in a composable way. This removes duplicate implementations and maximizes value for service providers.

## Contribution

Can you think of more use cases that the Molecule Protocol can support? Please describe your idea, or demo your idea, or submit a PR (pull request) to us so we can share it with the entire community!

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

- Molecule AML Deployment: [0x1D2048b4673a7D3C874D5Ca0cB584695Fcc4CC7e](https://goerli.etherscan.io/address/0x1d2048b4673a7d3c874d5ca0cb584695fcc4cc7e)

- US Sanction List: [0x36fcB28EA4F1a227F6FB17005046b59Fb164BEA1](https://goerli.etherscan.io/address/0x36fcb28ea4f1a227f6fb17005046b59fb164bea1)

- EU Sanction List: [0xAB73E85dd23f87E205D1C7C2354a372C3841c829](https://goerli.etherscan.io/address/0xab73e85dd23f87e205d1c7c2354a372c3841c829)

Goerli Testnet (Old):

- MoleculeAddress contract : [0x692f0Ac3eDDF405C8a864643DC104b3B01F594C2](https://goerli.etherscan.io/address/0x692f0Ac3eDDF405C8a864643DC104b3B01F594C2)

- LogicAddressAML US (ID:840) contract address : [0x6ff3F2DAa62e11D6fEC233410d2151948234d496](https://goerli.etherscan.io/address/0x6ff3F2DAa62e11D6fEC233410d2151948234d496)

- LogicAddressAML UK (ID:826) contract address :[0x3daD441A8C07eF64AA22e6114c39d690a098783F](https://goerli.etherscan.io/address/0x3daD441A8C07eF64AA22e6114c39d690a098783F)

## Gas Comparison on Batch updations

| Task           | chain                 | Transaction Gas Amount (Gas usage) | Gas price          | Cost                    |
| -------------- | --------------------- | ---------------------------------- | ------------------ | ----------------------- |
| Batch updation | Tenderly mainnet fork | 1,287,779                          | 50 Gwei            | 0.064 ETH               |
| Batch updation | polygon mumbai        | 1,496,526                          | 50 Gwei            | 0.0748263 MATIC ($0.08) |
| Batch updation | Base EVM              | 999,026                            | 50 Gwei            | 0.05485969674721        |
| Batch updation | scroll EVM            | 979,116                            | 50 Gwei            | 0.0489558 ETH           |
| Batch updation | Goerli                | 999,026                            | 195.268257805 Gwei | 0.200000 ETH            |

## Gas Comparison on Molecule contracts

| Task                               | chain   | Transaction Gas Amount (Gas usage) | Gas price | Cost                     |
| ---------------------------------- | ------- | ---------------------------------- | --------- | ------------------------ |
| Deploy ERC20m                      | sepolia | 2,450,487                          | 2.50 Gwei | 0.006126217517153409 ETH |
| Mint ERC20m (without gating)       | sepolia | 71,152                             | 2.50 Gwei | 0.000177880000569216 ETH |
| Transfer ERC20 (without gating)    | sepolia | 49,587 (91.17%)                    | 2.50 Gwei | 0.000123967500396696 ETH |
| Mint ERC20m (with gating)          | sepolia | 78,679                             | 2.50 Gwei | 0.000196697500708111 ETH |
| Transfer ERC20m (with gating)      | sepolia | 64,741 (93.1%)                     | 2.50 Gwei | 0.000161852500517928 ETH |
| Deploy ERC20 oz                    | sepolia | 1,819,416                          | 2.50 Gwei | 0.004548540014555328 ETH |
| Mint ERC20 oz                      | sepolia | 71,527                             | 2.50 Gwei | 0.000178817500572216 ETH |
| Transfer ERC20 oz                  | sepolia | 49,631                             | 2.50 Gwei | 0.000124077500397048 ETH |
| Deploy ERC721m                     | sepolia | 3,262,692                          | 2.50 Gwei | 0.008156730026101536 ETH |
| Mint ERC721m (without gating)      | sepolia | 74,524                             | 2.50 Gwei | 0.00018631000074524 ETH  |
| Transfer ERC721m (without gating)  | sepolia | 58,471 (92.41%)                    | 2.50 Gwei | 0.000146177500643181 ETH |
| Mint ERC721m (with gating)         | sepolia | 99,151                             | 2.50 Gwei | 0.000247877500892359 ETH |
| Transfer ERC721m (with gating)     | sepolia | 73,631 (93.88%)                    | 2.50 Gwei | 0.000184077500662679 ETH |
| Deploy ERC721 oz                   | sepolia | 2,634,838                          | 2.50 Gwei | 0.006587095021078704 ETH |
| Mint ERC721 oz                     | sepolia | 96,921 (100%)                      | 2.50 Gwei | 0.000242302500872289 ETH |
| Transfer ERC721 oz                 | sepolia | 58,508 (92.42%)                    | 2.50 Gwei | 0.000146270000526572 ETH |
| Deploy ERC1155m                    | sepolia | 3,484,645                          | 2.50 Gwei | 0.008711612531361805 ETH |
| Mint ERC1155m (without gating)     | sepolia | 56,803                             | 2.50 Gwei | 0.00014200750056803 ETH  |
| Transfer ERC1155m (without gating) | sepolia | 55,929 (92.1%)                     | 2.50 Gwei | 0.000139822500503361 ETH |
| Mint ERC1155m (with gating)        | sepolia | 94,684                             | 2.50 Gwei | 0.000236710001041524 ETH |
| Transfer ERC1155m (with gating)    | sepolia | 71,083 (93.67%)                    | 2.50 Gwei | 0.00017770750071083 ETH  |
| Deploy ERC1155 oz                  | sepolia | 3,359,382                          | 2.50 Gwei | 0.00839845503359382 ETH  |
| Mint ERC1155 oz                    | sepolia | 54,693                             | 2.50 Gwei | 0.00013673250054693 ETH  |
| Transfer ERC1155 oz                | sepolia | 53,704 (91.8%)                     | 2.50 Gwei | 0.000134260000483336 ETH |

