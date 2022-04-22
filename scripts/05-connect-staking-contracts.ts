// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { wait } from "./utils";
import { ethers } from "hardhat";
import {
  ARTH,
  ARTHX_STAKING_COLLECTOR,
  ARTHX_STAKING_MASTER,
  ARTH_ARTHX_STAKING_CHILD,
  ARTH_ARTH_STAKING_CHILD,
  ARTH_STAKING_COLLECTOR,
  ARTH_STAKING_MASTER,
  MAHA,
  MAHA_ARTHX_STAKING_CHILD,
  MAHA_ARTH_STAKING_CHILD,
  USDC,
  USDC_ARTHX_STAKING_CHILD,
  USDC_ARTH_STAKING_CHILD,
} from "./config";

async function main() {
  const isARTH = false;

  const stakingMasterAddress = isARTH
    ? ARTH_STAKING_MASTER
    : ARTHX_STAKING_MASTER;

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

  const tokensWithRate = [MAHA, ARTH, USDC];

  const stakingMaster = await ethers.getContractAt(
    "StakingMaster",
    stakingMasterAddress
  );

  const stakingCollector = await ethers.getContractAt(
    "StakingCollector",
    stakingCollectorAddress
  );

  // console.log("adding staking pools to master contract", stakingMaster.address);
  // await stakingMaster.addPools(stakingChildren);
  // console.log("added staking pools to master contract");
  // await wait(10 * 1000);

  // for (let index = 0; index < stakingChildren.length; index++) {
  //   const stakingChild = await ethers.getContractAt(
  //     "StakingChild",
  //     stakingChildren[index]
  //   );
  //   await stakingChild.changeStakingMaster(stakingMasterAddress);
  //   console.log("done with", stakingChildren[index]);
  //   await wait(10 * 1000);
  // }

  for (let index = 0; index < tokensWithRate.length; index++) {
    const stakingChild = stakingChildren[index];
    const token = tokensWithRate[index];

    console.log("registering token with collector", token);

    const tx = await stakingCollector.registerToken(token, stakingChild);
    console.log("done with", tx.hash);
    await wait(10 * 1000);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(console.error);
