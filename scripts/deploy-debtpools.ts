// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import hre from "hardhat";
import { BigNumber } from "@ethersproject/bignumber";

async function main() {
  // // set this accordingly
  // const token = "0xF2c96E402c9199682d5dED26D3771c6B192c01af";
  // const owner = "0x3E53029B647248EA368f59F4C9E6cDfD3eaFa3aE";
  // const beneficiary = "0x3E53029B647248EA368f59F4C9E6cDfD3eaFa3aE";

  const poolToken = "0x7518ebe3e2a9fc8464c82062467799f9808bca13";
  const arthSnapshotBoardroom = "0x8c0eB2dEE0596EF58c2b7C47e81B8b41F39a7BDE";
  const arthxSnapshotBoardroom = "0xCF9cCC08D0FE8f31c29617B89c3a4CB845ae694A";
  const amount = BigNumber.from(10).pow(18).mul(5000);

  const poolTokenInstance = await hre.ethers.getContractAt(
    "PoolToken",
    poolToken
  );

  const arthSnapshotBoardroomInstance = await hre.ethers.getContractAt(
    "SnapshotBoardroom",
    arthSnapshotBoardroom
  );

  const arthxSnapshotBoardroomInstance = await hre.ethers.getContractAt(
    "SnapshotBoardroom",
    arthxSnapshotBoardroom
  );

  console.log("approving pool token for arth boardroom");
  await poolTokenInstance.approve(
    arthSnapshotBoardroomInstance.address,
    amount
  );

  console.log("approving pool token for arthx boardroom");
  await poolTokenInstance.approve(
    arthxSnapshotBoardroomInstance.address,
    amount
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
