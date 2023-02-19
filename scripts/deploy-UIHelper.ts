import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import { deployOrLoadAndVerify, getOutputAddress } from "./utils";

async function main() {
  const debtToken = '0x71e9454df3ab9936d7aB97D24925719E0B319c59';
  const usdc = '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174';
  const matchingMarket = "0x45E85055C90B2a807F1e199d7F7C91ae9aCFEbe1"

  const factory = await ethers.getContractFactory("UIHelper");
  const instance = await factory.deploy();
  try {
    console.log('getBestBuyOrders instance', await instance.getBestBuyOrders(matchingMarket, debtToken, usdc, 7))

  } catch (error) {
    console.log('instance error', error)
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