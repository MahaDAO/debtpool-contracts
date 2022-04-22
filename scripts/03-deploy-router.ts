// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { wait } from "./utils";
import hre, { ethers } from "hardhat";

import {
  STAKING_DURATION,
  ARTHX_STAKING_COLLECTOR,
  ARTH_STAKING_COLLECTOR,
  MAHA,
  ARTH,
  USDC,
} from "./config";
import { BigNumber } from "ethers";

async function main() {
  const e18 = BigNumber.from(10).pow(18);

  const Contract = await ethers.getContractFactory("Router");
  const instance = await Contract.deploy(
    ARTH_STAKING_COLLECTOR,
    ARTHX_STAKING_COLLECTOR,
    [MAHA, ARTH, USDC],
    [e18.mul(10), 0, 0],
    STAKING_DURATION
  );
  await instance.deployed();
  console.log("deployed to ", instance.address);

  await wait(30 * 1000);

  await hre.run("verify:verify", {
    address: instance.address,
    constructorArguments: [
      ARTH_STAKING_COLLECTOR,
      ARTHX_STAKING_COLLECTOR,
      [MAHA, ARTH, USDC],
      [e18.mul(10), 0, 0],
      STAKING_DURATION,
    ],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(console.error);
