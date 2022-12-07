/* eslint-disable node/no-missing-import */
/* eslint-disable no-process-exit */
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import { deployOrLoadAndVerify, getOutputAddress } from "./utils";

async function main() {
  const debtToken = await ethers.getContractAt(
    "DebtToken",
    await getOutputAddress("DebtToken")
  );

  const usdc = await getOutputAddress("USDC");
  const burnRate = BigNumber.from(10).pow(12 + 18);

  const staker = await deployOrLoadAndVerify(
    "StakingRewardsV2",
    "StakingRewardsV2",
    [usdc, debtToken.address, burnRate]
  );

  console.log(staker.address);
  await debtToken.grantRole(
    "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6",
    "0x03998b014EC8B603Db40F30B89E7213d06d48eEd"
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
