import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import path from "path";
import fs from "fs";
import { ARTHX_SNAPSHOT, ARTH_SNAPSHOT } from "./config";
import { wait } from "./utils";

async function main() {
  const isARTH = true;

  const snapshot = isARTH ? ARTH_SNAPSHOT : ARTHX_SNAPSHOT;
  const instance = await ethers.getContractAt("Snapshot", snapshot);

  const text = fs.readFileSync(
    path.resolve(__dirname, "../output/address.json")
  );

  const mappedValues = JSON.parse(text.toString());
  const filteredValues = mappedValues.filter((t: any) => {
    const val = BigNumber.from(isARTH ? t.arth : t.arthx);
    return val.gt(0);
  });

  const addresses = filteredValues.map((t: any) => t.address);
  const e18 = BigNumber.from(10).pow(18);
  const e1 = BigNumber.from(1);

  const values = filteredValues.map((t: any) =>
    BigNumber.from(isARTH ? t.arth : t.arthx).mul(e1)
  );

  // console.log('approving usdc spend');
  // const infinity = decimals.mul(9999999999);
  // await USDC.approve(instance.address, infinity);
  // console.log('approved usdc spend');

  const gap = 100;
  for (let index = 0; index < values.length / gap; index++) {
    const addressSnip = addresses.slice(index * gap, (index + 1) * gap);
    const valuesSnip = values.slice(index * gap, (index + 1) * gap);

    console.log(addressSnip, valuesSnip);
    console.log("working on n =", valuesSnip.length);
    const tx1 = await instance.registerMultiple(valuesSnip, addressSnip);
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
