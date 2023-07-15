// SPDX-License-Identifier: MIT
// The SPDX-License-Identifier specifies the license under which the code is released. In this case, it is the MIT license.

pragma solidity >=0.7.0 <0.9.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
// These files are present in the contract folder.
import "@openzeppelin/contracts/access/Ownable.sol";

// Inheritance
contract TimelessNFT is ERC721Enumerable, Ownable {

    // Conversion of uint to string
    using Strings for uint256;

    // Mapping that holds information of every URI that has been minted in this platform
    mapping(string => uint8) existingURIs;

    // Holds minted NFTs
    mapping(uint256 => address) public holderOf;

    // NFT artist address
    address public artist;

    // Royalty fee
    uint256 public royaltyFee;

    uint256 public supply = 0;
    uint256 public totalTx = 0;

    // Cost for minting
    uint256 public cost = 0.01 ether;

    // Sales event, fired when an NFT is minted or transferred from one person to another
    event Sale(
        uint256 id,
        address indexed owner,
        uint256 cost,
        string metadataURI,
        uint256 timestamp
    );

    // Hold information of each transaction happening
    struct TransactionStruct {
        uint256 id;
        address owner;
        uint256 cost;
        string title;
        string description;
        string metadataURI;
        uint256 timestamp;
    }

    // Array of transactions and minted NFTs
    TransactionStruct[] transactions;
    TransactionStruct[] minted;

    // Runs once at the beginning
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _royaltyFee,
        address _artist
    ) ERC721(_name, _symbol) {
        royaltyFee = _royaltyFee;
        artist = _artist;
    }

    // Pay to mint an NFT
    function payToMint(
        string memory title,
        string memory description,
        string memory metadataURI,
        uint256 salesPrice
    ) external payable {
        require(msg.value >= cost, "Ether too low for minting!");
        require(existingURIs[metadataURI] == 0, "This NFT is already minted!");

        // Calculate royalty amount
        uint256 royalty = (msg.value * royaltyFee) / 100;

        // Pay royalty to the artist
        payTo(artist, royalty);

        // Pay minting cost to the contract owner
        payTo(owner(), (msg.value - royalty));

        supply++;

        // Add the minted NFT to the minted array
        minted.push(
            TransactionStruct(
                supply,
                msg.sender,
                salesPrice,
                title,
                description,
                metadataURI,
                block.timestamp
            )
        );

        // Emit the Sale event to notify that an NFT has been minted
        emit Sale(
            supply,
            msg.sender,
            msg.value,
            metadataURI,
            block.timestamp
        );

        // Mint the NFT and assign it to the sender
        _safeMint(msg.sender, supply);
        existingURIs[metadataURI] = 1;

        // Record the address of the new NFT holder
        holderOf[supply] = msg.sender;
    }

    // Pay to buy an NFT
    function payToBuy(uint256 id) external payable {
        require(msg.value >= minted[id - 1].cost, "Ether too low for purchase!");
        require(msg.sender != minted[id - 1].owner, "Operation Not Allowed!");

        // Calculate royalty amount
        uint256 royalty = (msg.value * royaltyFee) / 100;

        // Pay royalty to the artist
        payTo(artist, royalty);

        // Pay the purchase cost to the current NFT owner
        payTo(minted[id - 1].owner, (msg.value - royalty));

        totalTx++;

        // Add the transaction to the transactions array
        transactions.push(
            TransactionStruct(
                totalTx,
                msg.sender,
                msg.value,
                minted[id - 1].title,
                minted[id - 1].description,
                minted[id - 1].metadataURI,
                block.timestamp
            )
        );

        // Emit the Sale event to notify that an NFT has been purchased
        emit Sale(
            totalTx,
            msg.sender,
            msg.value,
            minted[id - 1].metadataURI,
            block.timestamp
        );

        // Change the owner of the NFT
        minted[id - 1].owner = msg.sender;
    }

    // Change the price of an NFT
    function changePrice(uint256 id, uint256 newPrice) external returns (bool) {
        require(newPrice > 0 ether, "Ether too low!");
        require(msg.sender == minted[id - 1].owner, "Operation Not Allowed!");

        minted[id - 1].cost = newPrice;
        return true;
    }

    // Pay money to the given address
    function payTo(address to, uint256 amount) internal {
        (bool success, ) = payable(to).call{value: amount}("");
        require(success);
    }

    // Get all minted NFTs
    function getAllNFTs() external view returns (TransactionStruct[] memory) {
        return minted;
    }

    // Get information about a specific NFT
    function getNFT(uint256 id) external view returns (TransactionStruct memory) {
        return minted[id - 1];
    }

    // Get all transactions
    function getAllTransactions() external view returns (TransactionStruct[] memory) {
        return transactions;
    }
}
