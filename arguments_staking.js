const tokenAdrs = `${process.env.DP_TOKEN}`;
const duration = "30000000000000000000";

module.exports = [
  `${process.env.MainWalletAdrs}`,
  tokenAdrs,
  tokenAdrs,
  duration,
];
