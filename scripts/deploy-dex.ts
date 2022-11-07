/* eslint-disable node/no-missing-import */
/* eslint-disable no-process-exit */
import { deployOrLoadAndVerify, getOutputAddress } from "./utils";

async function main() {
  const debtToken = await getOutputAddress("DebtToken");
  const maha = "0xedd6ca8a4202d4a36611e2fff109648c4863ae19";
  const usdc = "0x2791bca1f2de4661ed88a30c99a7a9449aa84174";

  const instance = await deployOrLoadAndVerify(
    "MatchingMarket",
    "MatchingMarket",
    []
  );

  console.log(debtToken, maha, usdc, instance.addTokenPairWhitelist);
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
