const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Dao", function () {

  async function deployToken() {
    
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Dao = await ethers.getContractFactory("Dao");
    const dao = await Dao.deploy(2540);
    return {dao, owner, otherAccount };
  }

  it("Should mint initial supply to the owner", async function () {
    const { dao, owner } = await deployToken();
    await dao.connect(owner).deposit({ value: ethers.utils.parseEther("1") });
    expect(await dao.balancesUSD(owner.address)).to.equal(1000 * 1.05); // 1 ETH * 1000 USD/ETH * 1.05 interest
    expect(await dao.balanceOf(owner.address)).to.equal(1000);
  });

  it("Should allow withdrawal and update balances", async function () {
    const { dao, owner } = await deployToken();
    await dao.connect(owner).deposit({ value: ethers.utils.parseEther("1") });
    await dao.connect(owner).withdraw(500);
    expect(await dao.balancesUSD(owner.address)).to.equal(500 * 1.05);
    expect(await dao.balanceOf(owner.address)).to.equal(500);
  });

  it("Should allow interest rate change by owner", async function () {
    const { dao, owner } = await deployToken();
    await dao.connect(owner).deposit({ value: ethers.utils.parseEther("1") });
    await dao.connect(owner).withdraw(500);
    expect(await dao.balancesUSD(owner.address)).to.equal(500 * 1.05);
    expect(await dao.balanceOf(owner.address)).to.equal(500);
  });

  it("Should allow interest rate change by owner", async function () {
    const { dao, owner } = await deployToken();
    await dao.connect(owner).deposit({ value: ethers.utils.parseEther("1") });
    await dao.connect(owner).changeInterestRate(10);
    expect(await dao.interestRate()).to.equal(10);
  });

  it("Should allow ETH price change by owner", async function () {
    const { dao } = await deployToken();
    await dao.changeEthPrice(2000);
    expect(await dao.ethPrice()).to.equal(2000);
  });

  it("Should not allow non-owner to change interest rate", async function () {
    const { dao, owner } = await deployToken();

  it("Should allow ETH price change by owner", async function () {
    await dao.changeEthPrice(2000);
    expect(await dao.ethPrice()).to.equal(2000);
  });

  it("Should not allow non-owner to change interest rate", async function () {
    await expect(dao.connect(owner).changeInterestRateOwner(10)).to.be.revertedWith("Ownable: caller is not the owner");
  });

  it("Should not allow non-owner to change ETH price", async function () {
    await expect(dao.connect(owner).changeEthPrice(2000)).to.be.revertedWith("Ownable: caller is not the owner");
  });

  it("Should not allow withdrawal more than balance", async function () {
    await dao.connect(owner).deposit({ value: ethers.utils.parseEther("1") });
    await expect(dao.connect(owner).withdraw(1500)).to.be.revertedWith("Insufficient balance");
  });

  it("Should not allow deposit of 0 ETH", async function () {
    await expect(dao.connect(owner).deposit({ value: ethers.utils.parseEther("0") })).to.be.revertedWith("Deposit must be greater than 0");
  });

  it("Should not allow interest rate change to negative", async function () {
    await expect(dao.connect(owner).changeInterestRate(-10)).to.be.revertedWith("Interest rate must be positive");
  });

  it("Should not allow ETH price change to negative", async function () {
    await expect(dao.changeEthPrice(-2000)).to.be.revertedWith("ETH price must be positive");
  });
});
});
