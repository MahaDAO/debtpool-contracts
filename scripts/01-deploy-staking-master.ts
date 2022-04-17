// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { wait } from "./utils";
import hre, { ethers } from "hardhat";
import { ARTH_SNAPSHOT, ARTHX_SNAPSHOT, GOVERNANCE } from "./config";

async function main() {
  // set this accordingly
  const isARTH = true;
  const params = [GOVERNANCE, isARTH ? ARTH_SNAPSHOT : ARTHX_SNAPSHOT];

  const Contract = await ethers.getContractFactory("StakingMaster");
  const instance = await Contract.deploy(params[0], params[1]);
  await instance.deployed();
  console.log("deployed to ", instance.address);

  await wait(30 * 1000);

  await hre.run("verify:verify", {
    address: instance.address,
    constructorArguments: params,
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
