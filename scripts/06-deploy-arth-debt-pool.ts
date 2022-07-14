/* eslint-disable node/no-missing-import */
/* eslint-disable no-process-exit */
import { wait } from "./utils";
import hre, { ethers } from "hardhat";

async function main() {
  console.log("here");
  // const [deployer] = await ethers.getSigners();
  // console.log("Deploying contracts with the account:", deployer.address);
  // console.log("Account balance:", (await deployer.getBalance()).toString());
  const Contract = await ethers.getContractFactory("ArthDebtPoolToken");
  // console.log("Contract", Contract);
  const instance = await Contract.deploy();
  await instance.deployed();
  // console.log("instance", instance);
  console.log("deployed to ", instance.address);

  await wait(50 * 1000);

  await hre.run("verify:verify", {
    address: instance.address,
    constructorArguments: [],
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
