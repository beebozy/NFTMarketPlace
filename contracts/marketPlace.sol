// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyERC721 is ERC721{
    uint256 public tokenCounter;
    address public owner;
    constructor() ERC721("MyNFT", "MNFT") {
        tokenCounter = 0;
    }
modifier onlyOwner() {
    require(msg.sender==owner,"Only owner can perform this opereation");
    _;
}

// we can implement the 
    function createToken(address to) public onlyOwner returns (uint256) {
        uint256 newTokenId = tokenCounter;
        require(balanceOf(to)>0,"You cannot mint");
        _safeMint(to, newTokenId);
        tokenCounter += 1;
        return newTokenId;
    }
}
