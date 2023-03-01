# molecule-aml

## How to use the AML smart contract?

```
import "@molecule/IMolecule.sol";

contract MyContract {
  safeTransfer(address _to) {
    require(IMolecule(_molecule_address).check([1, 2], msg.sender), "MyContract: Sender is on sanction list");
    require(IMolecule(_molecule_address).check([1, 2], _to), "MyContract: Recipient is on sanction list");
    // implementation
  }
}
```

1. Import the Molecule Protocol Interface smart contract
2. Cast the sanction list address and call to check the sender & recipient
3. You can pick a list of sanction list or deploy your own custom list
