const { ethers } = require('hardhat')

const main = async () => {
    /**
     * TODO: must set
     * @_cdoge (address) || string - Address of Cdoge
     * @_berus (address) || string - Address of Cdoge
     */

    const _cdoge = '0x000000...'
    const _berus = '0x000000...'

    const vpool = await (await ethers.getContractFactory('Vpool')).deploy(1000, _cdoge, _berus)
    console.log('vpool deployed to:', vpool.address)
}

main()
    .catch(error => {
        console.log(error)
        process.exitCode = 1
    })