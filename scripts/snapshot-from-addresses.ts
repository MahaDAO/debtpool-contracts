import hre from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
  // set this accordingly
  const arthBoardroom = await hre.ethers.getContractAt(
    "IERC20",
    "0x8c0eB2dEE0596EF58c2b7C47e81B8b41F39a7BDE"
  );
  const arthxBoardroom = await hre.ethers.getContractAt(
    "IERC20",
    "0xcf9ccc08d0fe8f31c29617b89c3a4cb845ae694a"
  );

  const text = fs.readFileSync(
    path.resolve(__dirname, "../output/address.txt")
  );
  const addresses = text.toString().split("\n");

  const data = [];

  for (let index = 1; index < addresses.length; index++) {
    const address = addresses[index];
    const arth = (await arthBoardroom.balanceOf(address)).toString();
    const arthx = (await arthxBoardroom.balanceOf(address)).toString();
    console.log(address, arth, arthx);

    data.push({
      address,
      arth,
      arthx,
    });

    fs.writeFileSync(
      path.resolve(__dirname, "../output/address.json"),
      JSON.stringify(data, null, 2)
    );
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
