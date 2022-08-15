// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require('hardhat')

async function main() {
  let cdogeAddress = '0x000000...'
  let berusAddress = '0x000000...'

  const Level = await hre.ethers.getContractFactory('LevelUtil')
  const level = await Level.deploy()
  await level.deployed()

  const MDC = await hre.ethers.getContractFactory('MillionDogeClub')
  const mdc = await MDC.deploy()
  await mdc.deployed()

  const Repository = await hre.ethers.getContractFactory('MillionDogeClubRepository')
  const repository = await Repository.deploy(_doge, _berus, mdc.address, level.address)
  await repository.deployed()

  // uint256 _rate,
  // address _pro,
  // address _level,
  // address _berus,
  // address _mdc,
  // address _referral
  let _rate = ethers.utils.parseEther('1')
  let _ref = '0x000000...'
  const Pool = await hre.ethers.getContractFactory('BerusPool')
  const pool = await Pool.deploy(_rate, repository.address, level.address, _berus, mdc.address, _ref)
  await pool.deployed()

  console.log('level deployed to:', level.address)
  console.log('MDC deployed to:', mdc.address)
  console.log('repository deployed to:', repository.address)
  console.log('Pool deployed to:', pool.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})

const laterSet = async () => {
  const provider = ethers.provider
  const signer = provider.getSigner()

  const Level = await ethers.getContractAt('LevelUtil', '0x000000...', signer)
  const MDC = await ethers.getContractAt('MillionDogeClub', '0x000000...', signer)
  const repository = await ethers.getContractAt('MillionDogeClubRepository', '0x000000...', signer)

  // who can do
  let manageAddress = '0x000000...'
  await Level.addManage(manageAddress)
  console.log('addManage:', manageAddress)

  let referralAdress = '0x000000...'
  await MDC.addManage(referralAdress)
  console.log('addManage:', referralAdress)

  let marketAddress = '0x000000...'
  await repository.addManage(marketAddress)
  console.log('addManage:', marketAddress)
}
