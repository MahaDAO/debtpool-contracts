import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";

describe("DebtRepayment", function () {
  let operator: SignerWithAddress;
  let chicken: SignerWithAddress;

  let contract: Contract;
  let staker: Contract;
  let usdc: Contract;

  const ONEe18 = BigNumber.from(10).pow(18);
  const debtSample = ONEe18.mul(1000);

  before("setup accounts & deploy libraries", async () => {
    [operator, chicken] = await ethers.getSigners();
  });

  beforeEach("deploy all contracts", async () => {
    // deploy arth
    const DebtRepayment = await ethers.getContractFactory("DebtRepayment");
    const StakingContract = await ethers.getContractFactory("StakingContract");

    const USDC = await ethers.getContractFactory("MockERC20");

    contract = await DebtRepayment.connect(operator).deploy();
    usdc = await USDC.connect(operator).deploy("USD Coin", "USDC", 6);
    staker = await StakingContract.connect(operator).deploy(
      usdc.address,
      contract.address
    );

    contract.initialize(staker.address);
  });

  it("should deploy properly", async function () {
    expect(await contract.rewards()).eq(staker.address);
    expect(await staker.rewardsToken()).eq(usdc.address);
    expect(await staker.snapshot()).eq(contract.address);
  });

  describe("should mint properly to a user", async () => {
    beforeEach("should mint debt to user", async () => {
      await contract.register(debtSample, chicken.address);
    });

    it("should report proper fragments", async () => {
      expect(await contract.debtFragmentBalances(chicken.address)).eq(
        debtSample
      );
    });

    it("should report proper debtx factor", async () => {
      expect(await contract.userDebtxFactor(chicken.address)).eq(ONEe18);
    });

    it("should report proper debtx balance", async () => {
      expect(await contract.balanceOfDebtx(chicken.address)).eq(debtSample);
    });
  });
});
