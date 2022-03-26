import { BigNumber } from "ethers";
import { ethers } from "hardhat";

async function main() {
  const arthSnapshot = "0x3128582747D71d522f4700780a9Bd368A26B83bA";
  const arthxSnapshot = "0x541b414779926C609836cf2179107c9288225ecD";

  const instance = await ethers.getContractAt("Snapshot", arthSnapshot);

  const txs = ["0xeccE08c2636820a81FC0c805dBDC7D846636bbc4,2000"];

  const mappedValues = txs.map((t) => t.split(","));

  const addresses = mappedValues.map((t) => t[0]);
  const decimals = BigNumber.from(10).pow(18);

  const values = mappedValues.map((t) => BigNumber.from(t[1]).mul(decimals));

  // console.log('approving usdc spend');
  // const infinity = decimals.mul(9999999999);
  // await USDC.approve(instance.address, infinity);
  // console.log('approved usdc spend');

  const gap = 200;
  for (let index = 0; index < values.length / gap; index++) {
    const addressSnip = addresses.slice(index * gap, (index + 1) * gap);
    const valuesSnip = values.slice(index * gap, (index + 1) * gap);

    console.log("working on n =", valuesSnip.length);
    const tx1 = await instance.registerMultiple(valuesSnip, addressSnip);

    console.log("done", tx1.hash);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
