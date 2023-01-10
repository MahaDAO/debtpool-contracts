/* eslint-disable no-unused-vars */
/* eslint-disable node/no-missing-import */
/* eslint-disable no-process-exit */

// 0x7e5C1d1B1d4BB6e93D96f97dC6b69D96FA3710b4 arth snapshot <- balanceOf
// 0x17594C5a5305a5Ba032012AedD5bBd5906852020 ARTHX Staking <- balanceOf

import fs from "fs";
import path from "path";
import { ethers } from "hardhat";
import { BigNumber } from "ethers";

const Web3 = require("web3");

async function main() {
  const arthSnapshot = "0x7e5c1d1b1d4bb6e93d96f97dc6b69d96fa3710b4";
  const arthxStaking = "0x17594c5a5305a5ba032012aedd5bbd5906852020";
  const arthx = "0xAaA8e38F71A825353CE78183E1f0742ABcb1F05d";

  const e18 = BigNumber.from(10).pow(18);

  const output: string[] = [];

  const addresses = fs
    .readFileSync(path.resolve(__dirname, "./snapshots/arth-snapshot.txt"))
    .toString()
    .split("\n");

  const contract = await ethers.getContractAt("IERC20", arthx);

  for (let index = 0; index < addresses.length; index++) {
    const address = addresses[index];

    if (!ethers.utils.isAddress(address)) continue;
    const bal = await contract.balanceOf(address);

    console.log(`${address},${bal.div(e18).toString()}`);
    output.push(`${address},${bal.div(e18).toString()}`);
    fs.writeFileSync("./output.csv", output.join("\n"));
  }

  console.log(output);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
