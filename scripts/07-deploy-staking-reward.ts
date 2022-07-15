/* eslint-disable node/no-missing-import */
/* eslint-disable no-process-exit */
import { wait } from "./utils";
import hre, { ethers } from "hardhat";

async function main() {
  // const tokenAdrs = "0x2057d85f2eA34a3ff78E4fE092979DBF4dd32766"; // Rinkeby ARTH-DP token address
  const tokenAdrs = "0x2da2874F40c4c5DF7D80aBABe016d915fd8A9355";
  const duration = "30000000000000000000"; // 30 days
  const params = [
    `${process.env.MainWalletAdrs}`,
    tokenAdrs,
    tokenAdrs,
    duration,
  ];

  const Contract = await ethers.getContractFactory("StakingRewardsV2");

  const instance = await Contract.deploy(
    params[0],
    params[1],
    params[2],
    params[3]
  );
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
