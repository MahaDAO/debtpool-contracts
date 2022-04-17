// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { wait } from "./utils";
import hre, { ethers } from "hardhat";
import {
  ARTH,
  ARTHX_STAKING_COLLECTOR,
  ARTHX_STAKING_MASTER,
  ARTH_STAKING_COLLECTOR,
  ARTH_STAKING_MASTER,
  MAHA,
  STAKING_DURATION,
  USDC,
} from "./config";

async function main() {
  const tokens = [
    ["MAHA", MAHA],
    ["ARTH", ARTH],
    ["USDC", USDC],
  ];

  const isARTH = true;

  const Contract = await ethers.getContractFactory("StakingChild");
  const stakingMaster = isARTH ? ARTH_STAKING_MASTER : ARTHX_STAKING_MASTER;
  const stakingCollector = isARTH
    ? ARTH_STAKING_COLLECTOR
    : ARTHX_STAKING_COLLECTOR;

  for (let index = 0; index < tokens.length; index++) {
    const token = tokens[index];
    const instance = await Contract.deploy(
      token[1],
      stakingMaster,
      stakingCollector,
      STAKING_DURATION
    );
    await instance.deployed();

    console.log(token[0], "child deployed to ", instance.address);

    // if (index === 0) {
    //   await wait(30 * 1000);
    //   await hre.run("verify:verify", {
    //     address: instance.address,
    //     constructorArguments: [
    //       token[1],
    //       stakingMaster,
    //       stakingCollector,
    //       STAKING_DURATION,
    //     ],
    //   });
    // }
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
