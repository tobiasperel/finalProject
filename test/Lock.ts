import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("MyToken", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployToken() {
    
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const MyToken = await ethers.getContractFactory("ReferenceConsumer");
    const myToken = await MyToken.deploy("0x614715d2Af89E6EC99A233818275142cE88d1Cfd");
    return {myToken, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("FIJARSE EL PRECIO VOTEN A MILIEIIII", async function () {
      const { myToken,owner } = await loadFixture(deployToken);
      console.log(await myToken.connect(owner).getLatestAnswer()); 
    });
    
    
  });

});
