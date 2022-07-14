/* eslint-disable camelcase */
import * as dotenv from "dotenv";

// eslint-disable-next-line no-unused-vars
import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";

dotenv.config();

// // This is a sample Hardhat task. To learn how to create your own go to
// // https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// // You need to export an object to set up your config
// // Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.6.12",
      },
      {
        version: "0.6.6",
      },
      {
        version: "0.8.0",
      },
    ],
  },
  networks: {
    ropsten: {
      url: process.env.ROPSTEN_URL || "",
      gas: 2100,
      gasPrice: 8000,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    polygon: {
      url: process.env.POLYGON_RPC || "",
      gas: 2100,
      gasPrice: 100 * 1e9,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    maticMumbai: {
      url: process.env.MATICMUMBAI_URL || "",
      gas: 2100000,
      gasPrice: 8000,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/3a9a6018905e45669f505505420d81d6`,
      gasPrice: 8000,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;

// /**
//  * @type import('hardhat/config').HardhatUserConfig
//  */

// eslint-disable-next-line camelcase
// const Private_Key = `${process.env.PRIVATE_KEY}`;

// module.exports = {
//   solidity: {
//     compilers: [
//       {
//         version: "0.6.12",
//       },
//       {
//         version: "0.6.6",
//       },
//       {
//         version: "0.8.0",
//       },
//     ],
//   },
//   networks: {
//     rinkeby: {
//       url: `https://rinkeby.infura.io/v3/3a9a6018905e45669f505505420d81d6`,
//       // eslint-disable-next-line camelcase
//       accounts: [`0x${Private_Key}`],
//       gas: 2100000,
//       gasPrice: 8000000000,
//     },
//     ropsten: {
//       url: `https://ropsten.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161`,
//       accounts: [`0x${Private_Key}`],
//       gas: 2100000,
//       gasPrice: 8000000000,
//     },
//     mumbai: {
//       url: `https://matic-mumbai.chainstacklabs.com`,
//       accounts: [`0x${Private_Key}`],
//       gas: 2100000,
//       gasPrice: 8000000000, // process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
//     },
//     polygon: {
//       url: `https://rpc-mainnet.maticvigil.com`,
//       gas: 2100000,
//       gasPrice: 100 * 1e9,
//       accounts: [`0x${Private_Key}`],
//     },
//   },
//   etherscan: {
//     apiKey: process.env.ETHERSCAN_API_KEY, // using the etherscan key created for testnet
//   },
// };
