// require('babel-register')
// require('babel-polyfill')
require('dotenv').config()
const HDWalletProvider = require('@truffle/hdwallet-provider')
const mnemonic = process.env.MNEMONIC
module.exports = {
  // Configure networks (Localhost, Rinkeby, etc.)
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*', // Match any network id
    },
    sepolia: {
      provider: () => new HDWalletProvider(mnemonic, "https://rpc.sepolia.org"),
      network_id: 11155111, // Replace with the network ID of Sepolia
      gas: 8000000, // Set the gas limit to an appropriate value
      // gasPrice: 10000000000, // Set the gas price (optional)
      confirmations: 2, // Number of confirmations to wait between deployments (optional)
      timeoutBlocks: 2, // Number of blocks to wait before deployment times out (optional)
      
    }
    
  },
  contracts_directory: './src/contracts/',
  contracts_build_directory: './src/abis/',
  // Configure your compilers
  compilers: {
    solc: {
      version: '0.8.11',
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
}
