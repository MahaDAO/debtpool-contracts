// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { wait } from "./utils";
import hre from "hardhat";

async function main() {
  // set this accordingly
  const poolToken = "0x7518ebe3e2a9fc8464c82062467799f9808bca13";

  const Contract = await hre.ethers.getContractFactory("SnapshotBoardroom");
  const instance = await Contract.deploy(poolToken);
  await instance.deployed();
  console.log("deployed to ", instance.address);

  await wait(30 * 1000);

  await hre.run("verify:verify", {
    address: instance.address,
    constructorArguments: [poolToken],
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
