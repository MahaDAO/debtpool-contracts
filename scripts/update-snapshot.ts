import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import path from "path";
import fs from "fs";
import { ARTHX_STAKING_MASTER, ARTH_STAKING_MASTER } from "./config";
import { wait } from "./utils";

async function main() {
  const isARTH = false;

  const master = isARTH ? ARTH_STAKING_MASTER : ARTHX_STAKING_MASTER;
  const instance = await ethers.getContractAt("StakingMaster", master);

  const text = fs.readFileSync(
    path.resolve(__dirname, "../output/address.json")
  );

  const mappedValues = JSON.parse(text.toString());
  const filteredValues = mappedValues.filter((t: any) => {
    const val = BigNumber.from(isARTH ? t.arth : t.arthx);
    return val.gt(0);
  });

  const addresses = filteredValues.map((t: any) => t.address);

  // console.log('approving usdc spend');
  // const infinity = decimals.mul(9999999999);
  // await USDC.approve(instance.address, infinity);
  // console.log('approved usdc spend');

  const gap = 50;
  for (let index = 0; index < addresses.length / gap; index++) {
    const addressSnip = addresses.slice(index * gap, (index + 1) * gap);

    // console.log(addressSnip, valuesSnip);
    console.log("working on n =", index, addressSnip.length);
    const tx1 = await instance.updateRewardForMultiple(addressSnip);
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
