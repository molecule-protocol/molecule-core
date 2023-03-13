# molecule-core

## How to use the Molecule smart contract?

```
import "@molecule/1.0/IMolecule.sol";

contract MyContract {
  safeTransfer(address _to) {
    require(IMolecule(_molecule_address).check(_to), "MyContract: Recipient is on sanction list");
    // implementation
  }
}
```

1. Import the Molecule Protocol Interface smart contract
2. Cast the sanction list address and call to check the recipient
3. You can pick a list of sanction list or deploy your own custom list in the molecule contract


## Deployments  Goerli 

- Molecule contract : [0x1B74ff3615C982872C150E6E237Ad303240031CC](https://goerli.etherscan.io/address/0x1b74ff3615c982872c150e6e237ad303240031cc)

- LogicAML US (ID:840) contract address : [0xEB98D082006422C7E72b480FCe912fc9fb7D1938](https://goerli.etherscan.io/address/0xEB98D082006422C7E72b480FCe912fc9fb7D1938)

- LogicAML UK (ID:826) contract address :[0xA31307ab146a5E8A593277911C276Ac078809FA4](https://goerli.etherscan.io/address/0xA31307ab146a5E8A593277911C276Ac078809FA4)