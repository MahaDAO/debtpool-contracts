// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { wait } from "./utils";
import hre from "hardhat";

async function main() {
  // set this accordingly
  const owner = "0xa1bc5163FADAbE25880897C95d3701ed388A2AA0";

  const arth = "0xe52509181feb30eb4979e29ec70d50fd5c44d590";
  const maha = "0xedd6ca8a4202d4a36611e2fff109648c4863ae19";
  const usdc = "0x2791bca1f2de4661ed88a30c99a7a9449aa84174";

  const poolTokens = [arth, maha, usdc];

  const Contract = await hre.ethers.getContractFactory("PoolToken");
  const instance = await Contract.deploy(
    "Dept Pool Token",
    "DP-POOL",
    poolTokens,
    owner
  );
  await instance.deployed();

  await wait(30 * 1000);

  await hre.run("verify:verify", {
    address: instance.address,
    constructorArguments: ["Dept Pool Token", "DP-POOL", poolTokens, owner],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
