# molecule-core

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
