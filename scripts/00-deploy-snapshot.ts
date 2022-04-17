// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { wait } from "./utils";
import hre, { ethers } from "hardhat";

async function main() {
  const Contract = await ethers.getContractFactory("Snapshot");
  const instance = await Contract.deploy();
  await instance.deployed();
  console.log("deployed to ", instance.address);

  await wait(30 * 1000);

  await hre.run("verify:verify", {
    address: instance.address,
    constructorArguments: [],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(console.error);
