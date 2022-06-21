// test/GrabCoin.test.ts
import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";

describe("GrabCoin", function () {
  let grabCoinClub: Contract;
  let grabClub: Contract;
  let dividends: Contract;
  let owner: Signer;
  let user1: Signer;

  beforeEach(async function () {
    [owner, user1] = await ethers.getSigners();

    const GrabCoinClub = await ethers.getContractFactory("GrabCoinClub");
    grabCoinClub = await GrabCoinClub.deploy();
    await grabCoinClub.deployed();

    const GrabClub = await ethers.getContractFactory("GrabClub");
    grabClub = await GrabClub.deploy();
    await grabClub.deployed();

    const Dividends = await ethers.getContractFactory("Dividends");
    dividends = await Dividends.deploy(grabCoinClub.address, grabClub.address);
    await dividends.deployed();

    await grabCoinClub.mintAirdrop(0, [await user1.getAddress()]);
  });

  it("points to an implementation contract", async () => {
    const tx = await dividends.connect(user1).calcDividend(0);
    console.log(await tx.wait());
  });
});
