// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
//these filese are present in contract folder
import "@openzeppelin/contracts/access/Ownable.sol";

//inheritance
contract TimelessNFT is ERC721Enumerable, Ownable {

    //converison of unit to string 
    using Strings for uint256;

    //mappinhg which hold information of everyURi that has been minted in this platform
    mapping(string => uint8) existingURIs;
    //holds mindted nfts
    mapping(uint256 => address) public holderOf;

     //nft artist addres
    address public artist;
    //royalityFee
    uint256 public royalityFee;

    uint256 public supply = 0;
    uint256 public totalTx = 0;
    //cost for minting
    uint256 public cost = 0.01 ether;
    //sales event,when nft is minted or transferred frm once person to another this event is gonna fire
    event Sale(
        uint256 id,
        address indexed owner,
        uint256 cost,
        string metadataURI,
        uint256 timestamp
    );

//hold information of each transaction happening
    struct TransactionStruct {
        uint256 id;
        address owner;
        uint256 cost;
        string title;
        string description;
        string metadataURI;
        uint256 timestamp;
    }
// addray of those transactions and mints
    TransactionStruct[] transactions;
    TransactionStruct[] minted;
//runs once at the starting
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _royalityFee,
        address _artist
    ) ERC721(_name, _symbol) {
        royalityFee = _royalityFee;
        artist = _artist;
    }



    function payToMint(
        string memory title,
        string memory description,
        string memory metadataURI,
        uint256 salesPrice
    ) external payable {
        require(msg.value >= cost, "Ether too low for minting!");
        require(existingURIs[metadataURI] == 0, "This NFT is already minted!");
        
        //amount
        uint256 royality = (msg.value * royalityFee) / 100;
        //royalty goes to artist
        payTo(artist, royality);
        //minting goes to deployers
        payTo(owner(), (msg.value - royality));

        supply++;
   // we pust this data to minted array 
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
//fire the sale event to tell ok nft has been minted
        emit Sale(
            supply,
            msg.sender,
            msg.value,
            metadataURI,
            block.timestamp
        );

        _safeMint(msg.sender, supply);
        existingURIs[metadataURI] = 1;
        //send image to tht guy who paid?????
        holderOf[supply] = msg.sender;
    }

    function payToBuy(uint256 id) external payable {
        require(msg.value >= minted[id - 1].cost, "Ether too low for purchase!");
        require(msg.sender != minted[id - 1].owner, "Operation Not Allowed!");

        uint256 royality = (msg.value * royalityFee) / 100;
        payTo(artist, royality);
        payTo(minted[id - 1].owner, (msg.value - royality));

        totalTx++;

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

        emit Sale(
            totalTx,
            msg.sender,
            msg.value,
            minted[id - 1].metadataURI,
            block.timestamp
        );

        minted[id - 1].owner = msg.sender;
    }
    // if ur the owner of tht nft u can change the price or like new price
    function changePrice(uint256 id, uint256 newPrice) external returns (bool) {
        require(newPrice > 0 ether, "Ether too low!");
        require(msg.sender == minted[id - 1].owner, "Operation Not Allowed!");

        minted[id - 1].cost = newPrice;
        return true;
    }
    //paying the money to the address?
    function payTo(address to, uint256 amount) internal {
        (bool success, ) = payable(to).call{value: amount}("");
        require(success);
    }
//shows the list of minted nft fem nft array
    function getAllNFTs() external view returns (TransactionStruct[] memory) {
        return minted;
    }
//
    function getNFT(uint256 id) external view returns (TransactionStruct memory) {
        return minted[id - 1];
    }

    function getAllTransactions() external view returns (TransactionStruct[] memory) {
        return transactions;
    }
}