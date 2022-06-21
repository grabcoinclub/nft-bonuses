// scripts/deploy.ts
import { ethers } from "hardhat";

async function main() {
  const GrabClub = await ethers.getContractFactory("GrabClub");
  console.log("Deploying GrabClub Token...");
  const grabClub = await GrabClub.deploy();
  await grabClub.deployed();

  const GrabCoinClub = await ethers.getContractFactory("GrabCoinClub");
  console.log("Deploying GrabCoinClub...");
  const grabCoinClub = await GrabCoinClub.deploy();
  await grabCoinClub.deployed();

  const Dividends = await ethers.getContractFactory("Dividends");
  console.log("Deploying Dividends...");
  const dividends = await Dividends.deploy(
    grabCoinClub.address,
    grabClub.address
  );
  await dividends.deployed();

  console.log("Deployed Dividends address", dividends.address);
  console.log("Deployed GrabCoinClub address", grabCoinClub.address);
  console.log("Deployed GrabClub address", grabClub.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
