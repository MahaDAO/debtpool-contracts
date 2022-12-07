/* eslint-disable node/no-missing-import */
/* eslint-disable no-process-exit */
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import path from "path";
import fs from "fs";
import { getOutputAddress, wait } from "./utils";
import { parse } from "csv-parse/sync";

async function main() {
  const text = fs.readFileSync(path.resolve(__dirname, "./addresses.csv"));

  const records = parse(text, {
    columns: true,
    skip_empty_lines: true,
  });

  const addresses = records.map((t: any) => t.address);
  const e18 = BigNumber.from(10).pow(18);
  const values = records.map((t: any) =>
    BigNumber.from(Math.floor(t.debt)).mul(e18).toString()
  );

  const staker = await ethers.getContractAt(
    "StakingRewardsV2",
    await getOutputAddress("StakingRewardsV2")
  );

  const gap = 10;
  for (let index = 0; index < 1 /* values.length */ / gap; index++) {
    const addressSnip = addresses.slice(index * gap, (index + 1) * gap);
    const valuesSnip = values.slice(index * gap, (index + 1) * gap);

    console.log(addressSnip, valuesSnip);

    console.log("working on n =", index, valuesSnip.length);
    const tx1 = await staker.mintMultiple(addressSnip, valuesSnip);
    await wait(5 * 1000);

    console.log("done", tx1.hash);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
