/* eslint-disable node/no-missing-import */
/* eslint-disable no-process-exit */
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import { deployOrLoadAndVerify, getOutputAddress, saveABI } from "./utils";

async function main() {
  const debtToken = await ethers.getContractAt(
    "DebtToken",
    await getOutputAddress("DebtToken")
  );

  const [deployer] = await ethers.getSigners();
  const usdc = await getOutputAddress("USDC");
  const burnRate = BigNumber.from(10).pow(12 + 18);

  const StakingRewardsV2 = await ethers.getContractFactory("StakingRewardsV2");
  const initData = StakingRewardsV2.interface.encodeFunctionData("initialize", [
    usdc,
    debtToken.address,
    deployer.address,
    deployer.address,
    burnRate,
  ]);

  const implementation = await deployOrLoadAndVerify(
    `StakingRewardsV2Impl`,
    "StakingRewardsV2",
    []
  );

  const proxy = await deployOrLoadAndVerify(
    `StakingRewardsV2Proxy`,
    "TransparentUpgradeableProxy",
    [
      implementation.address,
      "0xeccE08c2636820a81FC0c805dBDC7D846636bbc4",
      initData,
    ]
  );

  console.log("init data", initData);

  // const inst = await ethers.getContractAt(`StakingRewardsV2`, proxy.address);
  // await inst.grantRole(
  //   await inst.MINTER_ROLE(),
  //   "0x90366C6F59B2Db217E638DFD4CB04d8142e2fC3A"
  // );

  // await debtToken.grantMintRole(inst.address);

  await saveABI(`StakingRewardsV2`, "StakingRewardsV2", proxy.address, true);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
