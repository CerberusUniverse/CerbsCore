require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
require('@openzeppelin/hardhat-upgrades');

module.exports = {
<<<<<<< HEAD
  defaultNetwork: "bsc",
  networks: {
    bsc: {
      url: 'https://bsc-dataseed1.defibit.io/',
      accounts: ['']
    }
  },
  solidity: {
    compilers: [
      {
        version: "0.8.0"
      },
      {
        version: "0.8.1"
      },
      {
        version: "0.8.2"
      }
    ],
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
=======
  solidity: "0.8.2",
>>>>>>> 0a13fbd49f9e70cd1cf1ec0042d61872ef3e8d86
};
