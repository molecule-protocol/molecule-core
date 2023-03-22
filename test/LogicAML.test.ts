import { expect, use } from "chai";
import { Contract } from "ethers";
import { deployContract, MockProvider, solidity } from "ethereum-waffle";
import Molecule from "../build/Molecule.json";
import LogicAML from "../build/LogicAML.json";

use(solidity);

describe("LogicAML", () => {
  const [wallet, wallet1] = new MockProvider().getWallets();
  let molecule: Contract;
  let logicAML: Contract;

  beforeEach(async () => {
    molecule = await deployContract(wallet, Molecule, []);
    logicAML = await deployContract(wallet, LogicAML, []);
  });

  it("check(address): does not find address in list", async () => {
    await molecule.addLogic(1, logicAML.address, true, "test", false);
    await molecule.select([1]);
    expect(await molecule["check(address)"](logicAML.address)).to.be.false;
  });

  it("updateList: updates the list", async () => {
    await molecule.addLogic(1, logicAML.address, true, "test", false);
    await molecule.select([1]);
    await logicAML.updateList([wallet1.address]);
    await expect(logicAML.updateList([wallet1.address]))
      .to.emit(logicAML, "ListAdded")
      .withArgs([wallet1.address]);
  });

  it("check(address): finds address in list", async () => {
    await molecule.addLogic(1, logicAML.address, true, "test", false);
    await molecule.select([1]);
    await logicAML.updateList([wallet1.address]);
    expect(await molecule["check(address)"](wallet1.address)).to.be.true;
  });

  it("removeFromList: removes from the list", async () => {
    await molecule.addLogic(1, logicAML.address, true, "test", false);
    await molecule.select([1]);
    await logicAML.updateList([wallet1.address]);
    await expect(logicAML.removeFromList([wallet1.address]))
      .to.emit(logicAML, "ListRemoved")
      .withArgs([wallet1.address]);
  });

  it.skip("setStatus");
});
