/* eslint-disable no-undef */
const TimelessNFT = artifacts.require('TimelessNFT')
//grab the artifacts i.e abi


module.exports = async (deployer) => {
  const accounts = await web3.eth.getAccounts()

  //grabs accnt tht are avalibale in tht nwtork
  await deployer.deploy(TimelessNFT, 'Timeless NFTs', 'TNT', 10, accounts[1])
  //deploy it
}