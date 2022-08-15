require('@nomiclabs/hardhat-waffle')
require('@nomiclabs/hardhat-ethers')
require('@openzeppelin/hardhat-upgrades')

module.exports = {
  defaultNetwork: 'bsc',
  networks: {
    bsc: {
      url: 'https://bsc-dataseed1.defibit.io/',
      accounts: ['13578e74c554e124e979c88d209991512c1b79c3fcf2219238c0e2359345d815'],
    },
  },
  solidity: {
    compilers: [
      {
        version: '0.8.0',
      },
      {
        version: '0.8.1',
      },
      {
        version: '0.8.2',
      },
    ],
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
}
