import Web3 from 'web3'
import { setGlobalState, getGlobalState, setAlert } from './store'
import abi from './abis/TimelessNFT.json'

// Initialize Web3 using the injected Ethereum provider (e.g., MetaMask)
const { ethereum } = window
window.web3 = new Web3(ethereum)
window.web3 = new Web3(window.web3.currentProvider)

// Get the Ethereum contract based on the current network
const getEtheriumContract = async () => {
  const web3 = window.web3
  const networkId = await web3.eth.net.getId()
  const networkData = abi.networks[networkId]

  if (networkData) {
    const contract = new web3.eth.Contract(abi.abi, networkData.address)
    return contract
  } else {
    return null
  }
}

// Connect the wallet and set the connected account in the global state
const connectWallet = async () => {
  try {
    if (!ethereum) return reportError('Please install Metamask')
    const accounts = await ethereum.request({ method: 'eth_requestAccounts' })
    setGlobalState('connectedAccount', accounts[0].toLowerCase())
  } catch (error) {
    reportError(error)
  }
}

// Check if the wallet is connected and handle events like chain change or account change
const isWallectConnected = async () => {
  try {
    if (!ethereum) return reportError('Please install Metamask')
    const accounts = await ethereum.request({ method: 'eth_accounts' })

    // Reload the page when the chain changes
    window.ethereum.on('chainChanged', (chainId) => {
      window.location.reload()
    })
// Update the connected account when it changes
    window.ethereum.on('accountsChanged', async () => {
      setGlobalState('connectedAccount', accounts[0].toLowerCase())
      await isWallectConnected()
    })

    if (accounts.length) {
      setGlobalState('connectedAccount', accounts[0].toLowerCase())
    } else {
      setGlobalState('connectedAccount', '')
      reportError('Please connect wallet.')
    }
  } catch (error) {
    reportError(error)
  }
}
// Structure the NFTs data by converting units, reversing the order, and lowercasing addresses
const structuredNfts = (nfts) => {
  return nfts
    .map((nft) => ({
      id: Number(nft.id),
      owner: nft.owner.toLowerCase(),
      cost: window.web3.utils.fromWei(nft.cost),
      title: nft.title,
      description: nft.description,
      metadataURI: nft.metadataURI,
      timestamp: nft.timestamp,
    }))
    .reverse()
}


// Get all NFTs and transactions from the contract and update the global state
const getAllNFTs = async () => {
  try { 
    if (!ethereum) return reportError('Please install Metamask')

    const contract = await getEtheriumContract()
    const nfts = await contract.methods.getAllNFTs().call()
    const transactions = await contract.methods.getAllTransactions().call()

    setGlobalState('nfts', structuredNfts(nfts))
    setGlobalState('transactions', structuredNfts(transactions))
  } catch (error) {
    reportError(error)
  }
}

// Mint an NFT by paying the specified price
const mintNFT = async ({ title, description, metadataURI, price }) => {
  try {
    price = window.web3.utils.toWei(price.toString(), 'ether')
    const contract = await getEtheriumContract()
    const account = getGlobalState('connectedAccount')
    const mintPrice = window.web3.utils.toWei('0.01', 'ether')

    await contract.methods
      .payToMint(title, description, metadataURI, price)
      .send({ from: account, value: mintPrice })

    return true
  } catch (error) {
    reportError(error)
  }
}

// Buy an NFT by paying the specified cost
const buyNFT = async ({ id, cost }) => {
  try {
    cost = window.web3.utils.toWei(cost.toString(), 'ether')
    const contract = await getEtheriumContract()
    const buyer = getGlobalState('connectedAccount')

    await contract.methods
      .payToBuy(Number(id))
      .send({ from: buyer, value: cost })

    return true
  } catch (error) {
    reportError(error)
  }
}


// Update the price of an NFT
const updateNFT = async ({ id, cost }) => {
  try {
    cost = window.web3.utils.toWei(cost.toString(), 'ether')
    const contract = await getEtheriumContract()
    const buyer = getGlobalState('connectedAccount')

    await contract.methods.changePrice(Number(id), cost).send({ from: buyer })
  } catch (error) {
    reportError(error)
  }
}

// Report an error by setting an alert message with red color
const reportError = (error) => {
  setAlert(JSON.stringify(error), 'red')
}

export {
  getAllNFTs,
  connectWallet,
  mintNFT,
  buyNFT,
  updateNFT,
  isWallectConnected,
}

