const { ethers} = require('hardhat')

const main = async () => {
  const Market = await (await ethers.getContractFactory("CerberusNFTMarket")).deploy()
  console.log('Market deployed to : ', Market.address)

  /**
   * TODO: must set
   * @_referral (address) || string - Address of referral contract
   * @_repository (address) || string - Address of repository contract
   * @_depositepercent (uint256) || number - Percent of depositing Cdoge to MDC
   * @_sellpercent (uint256) || number - Percent of sell
   * @_referralpercent (uint256) || number - Percent of depositing Cdoge to referral
   * @_feepercent (uint256) || number - Percent of fee
   * @_feeto (address) || string - Address of fee to
   */

  const _referral = '0x000000...'
  const _repository = '0x000000...'
  const _depositepercent = 1690
  const _sellpercent = 7310
  const _referralpercent = 1000
  const _feepercent = 69
  const _feeto = '0x000000...'

  // await Market.setReferral(_referral)
  // console.log('setReferral:', _referral)

  // await Market.setRepository(_repository)
  // console.log('setRepository:', _repository)

  await Market.setDepositePercent(_depositepercent)
  console.log('setDepositePercent:', _depositepercent)

  await Market.setSellPercent(_sellpercent)
  console.log('setSellPercent:', _sellpercent)

  await Market.setReferralPercent(_referralpercent)
  console.log('setReferralPercent:', _referralpercent)

  await Market.setFeeToAndFeePercent(_feeto, _feepercent)
  console.log('setFeeToAndFeePercent:', _feeto, _feepercent)

  console.log('Everything is done well !')
}

main()
  .catch((error) => {
    console.error(error)
    process.exitCode = 1
  })

const laterSet = async () => {

  const provider = ethers.provider
  const signer = provider.getSigner()

  const Market = await ethers.getContractAt('CerberusNFTMarket', '0x000000...', signer)
  
  const _referral = '0x000000...'
  const _repository = '0x000000...'
  
  await Market.setReferral(_referral)
  console.log('setReferral:', _referral)

  await Market.setRepository(_repository)
  console.log('setRepository:', _repository)
}

// laterSet()
//   .catch((error) => {
//     console.error(error)
//     process.exitCode = 1
//   })