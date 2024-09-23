MyERC721Marketplace - NFT Marketplace Smart Contract
Overview
The MyERC721Marketplace is a decentralized NFT marketplace that allows users to mint, list, and buy ERC-721 tokens. It includes functionalities for setting marketplace fees, transferring NFTs, and securing transactions with reentrancy protection.

Features
Minting NFTs: Users can mint new ERC-721 tokens.
Listing NFTs for Sale: NFT owners can list their tokens for sale at a specified price.
Buying NFTs: Anyone can buy listed NFTs by sending the required Ether to the contract.
Marketplace Fee: A small percentage of each sale goes to the marketplace owner.
Withdrawing Fees: The marketplace owner can withdraw accumulated fees.
Reentrancy Protection: The ReentrancyGuard ensures secure transactions and prevents reentrancy attacks.
Key Components
1. State Variables
tokenCounter: Tracks the total number of tokens minted.
marketplaceFee: A percentage fee (set to 2% by default) that the marketplace takes from each sale.
marketplaceOwner: The address of the marketplace owner who can manage fees and withdraw them.
orders: A mapping that stores the details of listed NFTs.
userBalances: A mapping that tracks the balances for fee withdrawals by the owner.
2. Modifiers
onlyNFTOwner(tokenId): Ensures the caller owns the specified NFT.
isListedForSale(nftContract, tokenId): Ensures the NFT is listed for sale.
