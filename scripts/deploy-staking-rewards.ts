/* eslint-disable node/no-missing-import */
/* eslint-disable no-process-exit */
import { deployOrLoadAndVerify, getOutputAddress, wait } from "./utils";


async function main() {
    const debtToken = await getOutputAddress("DebtToken");
    const usdc = "0x2791bca1f2de4661ed88a30c99a7a9449aa84174"
    const burnRate = "30000000000000000000"

    await deployOrLoadAndVerify("StakingRewardsV2", "StakingRewardsV2", [usdc, debtToken, burnRate]);
  

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });