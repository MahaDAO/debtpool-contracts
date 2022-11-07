/* eslint-disable node/no-missing-import */
/* eslint-disable no-process-exit */
import { deployOrLoadAndVerify } from "./utils";

async function main() {
  await deployOrLoadAndVerify("DebtToken", "DebtToken", []);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
