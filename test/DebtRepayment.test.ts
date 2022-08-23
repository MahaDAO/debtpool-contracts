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

  const e18 = BigNumber.from(10).pow(18);
  const b300 = e18.mul(300);

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

  describe.only("test factorMultiplierE18(x)", async () => {
    it("should report 1% if x = 100%", async () => {
      expect(await contract.factorMultiplierE18(e18)).eq(e18.div(100));
    });
    it("should report 1% if x = 99%", async () => {
      expect(await contract.factorMultiplierE18(e18.div(100).mul(99))).eq(
        e18.div(100)
      );
    });
    it("should report 81% if x = 10%", async () => {
      expect(await contract.factorMultiplierE18(e18.div(10))).eq(
        e18.div(100).mul(81)
      );
    });
    it("should report 98% if x = 1%", async () => {
      expect(await contract.factorMultiplierE18(e18.div(100))).eq(
        e18.div(10000).mul(9801)
      );
    });
  });

  describe("should mint properly to a user", async () => {
    beforeEach("should mint debt to user", async () => {
      await contract.register(b300, chicken.address);
    });

    it("should report proper fragments", async () => {
      expect(await contract.debtFragmentBalances(chicken.address)).eq(b300);
    });

    it("should report proper debtx factor", async () => {
      expect(await contract.userDebtxFactor(chicken.address)).eq(e18);
    });

    it("should report proper debtx balance", async () => {
      expect(await contract.balanceOfDebtx(chicken.address)).eq(b300);
    });

    describe("if the user rebase his debt down by 10%", async () => {
      beforeEach("should execute rebase properly", async () => {
        await contract.connect(chicken).rebaseDebt(e18.div(10).mul(9));
      });

      it("should report proper fragments", async () => {
        expect(await contract.debtFragmentBalances(chicken.address)).eq(b300);
      });

      it("should report proper debtx factor", async () => {
        expect(await contract.userDebtxFactor(chicken.address)).eq(
          e18.div(10).mul(9)
        );
      });

      it("should report proper debtx balance", async () => {
        expect(await contract.balanceOfDebtx(chicken.address)).eq(b300);
      });
    });
  });
});
