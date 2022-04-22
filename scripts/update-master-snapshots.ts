import { ethers } from "hardhat";
import {
  ARTHX_SNAPSHOT,
  ARTHX_STAKING_MASTER,
  ARTH_SNAPSHOT,
  ARTH_STAKING_MASTER,
} from "./config";

async function main() {
  const isARTH = false;

  const snapshot = isARTH ? ARTH_SNAPSHOT : ARTHX_SNAPSHOT;
  const master = isARTH ? ARTH_STAKING_MASTER : ARTHX_STAKING_MASTER;
  const instance = await ethers.getContractAt("StakingMaster", master);

  const tx = await instance.setSnapshot(snapshot);
  console.log(tx.hash);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
