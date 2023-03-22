import { expect, use } from "chai";
import { Contract, utils } from "ethers";
import { deployContract, MockProvider, solidity } from "ethereum-waffle";
import Molecule from "../build/Molecule.json";
import LogicAML from "../build/LogicAML.json";

use(solidity);

describe("Molecule", () => {
  const [wallet, wallet1, wallet2] = new MockProvider().getWallets();
  let molecule: Contract;
  let logicAML: Contract;
  const moleculeIface = new utils.Interface(Molecule.abi);

  beforeEach(async () => {
    molecule = await deployContract(wallet, Molecule, []);
    logicAML = await deployContract(wallet, LogicAML, []);
  });

  it("addLogic: adds logic contract to molecule", async () => {
    expect(await molecule.addLogic(1, logicAML.address, true, "test", false)).to
      .be.ok;
  });

  it("addLogic: creates logic record with values", async () => {
    const { data, value } = await molecule.addLogic(
      1,
      logicAML.address,
      true,
      "test",
      false
    );
    const parsed = moleculeIface.parseTransaction({ data, value });
    expect(parsed.args.isAllowList).to.be.true;
    expect(parsed.args.name).to.equal("test");
    expect(parsed.args.reverseLogic).to.be.false;
  });

  it("select: throws when logic id does not exist", async () => {
    await expect(molecule.select([1])).to.be.revertedWith(
      "Molecule: logic id not found"
    );
  });

  it("select: selects logic by id", async () => {
    await molecule.addLogic(1, logicAML.address, true, "test", false);
    expect(await molecule.select([1])).to.be.ok;
  });

  it.skip("setStatus");
  it.skip("removeLogic");
  it.skip("addLogicBatch");
  it.skip("removeLogicBatch");
});
