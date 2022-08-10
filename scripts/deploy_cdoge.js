// scripts/deploy_cdoge.js
async function main() {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // We get the contract to deploy
    CDoge = await ethers.getContractFactory("CDoge");
    console.log('Deploying CDoge...');
    cdoge = await CDoge.deploy();
    await cdoge.deployed();
    console.log('CDoge deployed to:', cdoge.address);
  }

  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });       