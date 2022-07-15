// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { wait } from "./utils";
import { ethers } from "hardhat";
import {
  ARTHX_STAKING_COLLECTOR,
  ARTH_ARTHX_STAKING_CHILD,
  ARTH_ARTH_STAKING_CHILD,
  ARTH_STAKING_COLLECTOR,
  MAHA_ARTHX_STAKING_CHILD,
  MAHA_ARTH_STAKING_CHILD,
  USDC_ARTHX_STAKING_CHILD,
  USDC_ARTH_STAKING_CHILD,
} from "./config";

async function main() {
  const isARTH = false;

  const stakingCollectorAddress = isARTH
    ? ARTH_STAKING_COLLECTOR
    : ARTHX_STAKING_COLLECTOR;

  const stakingChildren = isARTH
    ? [
        MAHA_ARTH_STAKING_CHILD,
        ARTH_ARTH_STAKING_CHILD,
        USDC_ARTH_STAKING_CHILD,
      ]
    : [
        MAHA_ARTHX_STAKING_CHILD,
        ARTH_ARTHX_STAKING_CHILD,
        USDC_ARTHX_STAKING_CHILD,
      ];

  for (let index = 2; index < stakingChildren.length; index++) {
    const stakingChild = stakingChildren[index];
    const instance = await ethers.getContractAt("StakingChild", stakingChild);

    console.log("updating staking child with collector", instance.address);
    await instance.changeStakingCollector(stakingCollectorAddress);
    console.log("done with", index);

    await wait(10 * 1000);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(console.error);
