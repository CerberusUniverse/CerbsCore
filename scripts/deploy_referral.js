const { ethers} = require('hardhat')

const main = async () => {
  Referral = await (await ethers.getContractFactory('CerberusMDCReferralV3')).deploy()
  console.log('ReferralV3 deployed to:', Referral.address)

  /**
   * TODO: must set
   * @_mdc (address) || string - Address of mdc
   * @_market (address) || string - Address of market contract
   * @_stake (address) || string - Address of stake contract
   * @_master (address) || string - Address of top referer
   * @_paytype (address) || string - Address of token that user purchase mdc
   * @_price (uint256) || number - The price of mdc
   * @_percents (uint256[]) || array - Level should shared
   */

  const _mdc = ''
  const _market = ''
  const _stake = ''
  const _master = '0x000000...'
  const _paytype = '0x000000...'
  const _price = '690'
  const _percents = [
    [0, 1500],
    [1, 2000],
    [2, 2500],
    [3, 5000],
    [4, 6000],
    [5, 7000],
    [6, 8000],
    [7, 10000]
  ]

  // await Referral.setMDC(_mdc)
  // console.log('setMDC to:', _mdc)

  // await Referral.setMarket(_market)
  // console.log('setMarket to:', _market)

  // await Referral.setStake(_stake)
  // console.log('setStake to:', _stake)

  await Referral.setMaster(_master)
  console.log('setMaster to:', _master)

  await Referral.setPaytype(_paytype)
  console.log('setPaytype to:', _paytype)

  await Referral.setPrice(ethers.utils.parseUnits(_price, 18))
  console.log('setPrice to:', _price)

  for(const item of _percents) {
    await Referral.setLevelShouldShared(item[0], item[1])
    console.log('level', item[0], 'should shared:', item[1])
  }

  console.log('Everything is done well!')
}

main()
  .catch((error) => {
    console.error(error)
    process.exitCode = 1
  })

const laterSet = async () => {

  const provider = ethers.provider
  const signer = provider.getSigner()

  const Referral = await ethers.getContractAt('CerberusMDCReferralV3', '0x000000...', signer)

  const _mdc = '0x000000...'
  const _market = '0x000000...'
  const _stake = '0x000000...'

  await Referral.setMDC(_mdc)
  console.log('setMDC to:', _mdc)

  await Referral.setMarket(_market)
  console.log('setMarket to:', _market)

  await Referral.setStake(_stake)
  console.log('setStake to:', _stake)
}

// laterSet()
//   .catch((error) => {
//     console.error(error)
//     process.exitCode = 1
//   })