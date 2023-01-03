/* eslint-disable node/no-missing-import */
/* eslint-disable no-process-exit */
import { deployOrLoadAndVerify, getOutputAddress } from "./utils";

async function main() {
  const debtToken = await getOutputAddress("DebtToken");
  const maha = await getOutputAddress("MAHA");
  const usdc = await getOutputAddress("USDC");

  const instance = await deployOrLoadAndVerify(
    "MatchingMarket",
    "MatchingMarket",
    []
  );

  // console.log(debtToken, maha, usdc, instance.addTokenPairWhitelist);
  await instance.addTokenPairWhitelist(maha, debtToken);
  await instance.addTokenPairWhitelist(usdc, debtToken);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
