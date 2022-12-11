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

  const [deployer] = await ethers.getSigners();
  const usdc = await getOutputAddress("USDC");
  const burnRate = BigNumber.from(10).pow(12 + 18);

  const staker = await deployOrLoadAndVerify(
    "StakingRewardsV2",
    "StakingRewardsV2",
    [
      usdc,
      debtToken.address,
      "0x67c569F960C1Cc0B9a7979A851f5a67018c5A3b0",
      "0x67c569F960C1Cc0B9a7979A851f5a67018c5A3b0",
      burnRate,
    ]
  );

  // address _rewardsToken,
  // address _debtToken,
  // address _notifier,
  // address _governance,
  // uint256 _burnRate // the rate at which tokens are burn

  console.log(staker.address);
  await debtToken.connect(deployer).grantMintRole(staker.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
