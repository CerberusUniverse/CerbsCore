// scripts/deploy_berusupgradeable.js
const { ethers, upgrades } = require("hardhat");

berusTotalSupply = 10_000_000_000_000;  // 10 Trillion

async function main() {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // We get the contract to deploy
    BerusUpgradeable = await ethers.getContractFactory("BerusUpgradeable");
    console.log('Deploying CDoge...');
    berusup = await upgrades.deployProxy(BerusUpgradeable, [berusTotalSupply], {initializer: 'initialize'});
    await berusup.deployed();
    console.log('BerusUpgradeable deployed to:', berusup.address);
  }

  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });      