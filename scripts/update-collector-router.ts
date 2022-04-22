import { ethers } from "hardhat";
import {
  ARTHX_STAKING_COLLECTOR,
  ARTH_ROUTER,
  ARTH_STAKING_COLLECTOR,
} from "./config";

async function main() {
  const instance1 = await ethers.getContractAt(
    "StakingCollector",
    ARTH_STAKING_COLLECTOR
  );
  const tx1 = await instance1.setRouter(ARTH_ROUTER);
  console.log(tx1.hash);

  const instance2 = await ethers.getContractAt(
    "StakingCollector",
    ARTHX_STAKING_COLLECTOR
  );
  const tx2 = await instance2.setRouter(ARTH_ROUTER);
  console.log(tx2.hash);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
