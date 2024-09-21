// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MyERC721Marketplace is ERC721, ReentrancyGuard {
    struct OrderList {
        address seller;
        uint256 tokenId;
        uint256 price;
        bool isListed;
    }

    uint256 public tokenCounter;
    uint256 public marketplaceFee = 2; // Fee in percentage
    address public marketplaceOwner; // Define the contract owner
    mapping(address => mapping(uint256 => OrderList)) public orders; // Map orders by seller address and tokenId
    mapping(address => uint256) public userBalances;

    // Constructor sets the token details (name, symbol)
    constructor() ERC721("MyNFT", "MNFT") {
        tokenCounter = 0;
        marketplaceOwner = msg.sender; // Set the deployer as the owner
    }

    // Modifier to ensure the caller is the owner of a specific NFT
    modifier onlyNFTOwner(uint256 tokenId) {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this NFT");
        _;
    }

    // Modifier to ensure that the NFT is listed for sale
    modifier isListedForSale(address nftContract, uint256 tokenId) {
        require(orders[nftContract][tokenId].isListed, "This NFT is not listed for sale");
        _;
    }

    // Function to mint a new NFT (any user can mint an NFT to themselves)
    function mintToken() external returns (uint256) {
        uint256 newTokenId = tokenCounter;
        _safeMint(msg.sender, newTokenId);
        tokenCounter += 1;
        return newTokenId;
    }

    // Function to list an NFT for sale (user can list their own NFT)
    function listNFT(uint256 tokenId, uint256 price) external onlyNFTOwner(tokenId) {
        require(price > 0, "Price must be greater than zero");

        orders[address(this)][tokenId] = OrderList(msg.sender, tokenId, price, true);
        emit NFTListed(msg.sender, tokenId, price);
    }

    // Function to buy an NFT (whether minted within the contract or deposited externally)
    function buyNFT(address nftContract, uint256 tokenId) external payable nonReentrant isListedForSale(nftContract, tokenId) {
        OrderList memory order = orders[nftContract][tokenId];
        require(msg.value >= order.price, "Insufficient payment");

        uint256 fee = (marketplaceFee * order.price) / 100;
        uint256 sellerAmount = order.price - fee;

        // Transfer the NFT from the contract or seller to buyer
        IERC721(nftContract).safeTransferFrom(address(this), msg.sender, tokenId);
        payable(order.seller).transfer(sellerAmount);
        userBalances[marketplaceOwner] += fee;

        // Update order status
        orders[nftContract][tokenId].isListed = false;

        emit NFTSold(order.seller, msg.sender, tokenId, order.price);
    }

    // Function to withdraw the marketplace fee by the marketplace owner
    function withdrawFees() external {
        require(msg.sender == marketplaceOwner, "Only marketplace owner can withdraw fees");
        uint256 balance = userBalances[marketplaceOwner];
        require(balance > 0, "No fees to withdraw");
        userBalances[marketplaceOwner] = 0;
        payable(marketplaceOwner).transfer(balance);
    }

    // Event emitted when an NFT is listed
    event NFTListed(address indexed seller, uint256 indexed tokenId, uint256 price);

    // Event emitted when an NFT is sold
    event NFTSold(address indexed seller, address indexed buyer, uint256 indexed tokenId, uint256 price);

    // Function to set the marketplace fee (only owner can do this)
    function setMarketplaceFee(uint256 _fee) external {
        require(msg.sender == marketplaceOwner, "Only marketplace owner can set fees");
        require(_fee <= 10, "Fee cannot exceed 10%");
        marketplaceFee = _fee;
    }
}
