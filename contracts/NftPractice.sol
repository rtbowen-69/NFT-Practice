// SPDX-License-Identifier: Unlicesend
pragma solidity ^0.8.7;
// Testing the push from Remix

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NftPractice is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;
    uint256 maxSupply = 500;

    bool public publicMintOpen = false;
    bool public allowListMintOpen = false;

    // Allow only White List people to mint when White List Mint Window is open
    mapping(address => bool) public allowList;      

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("NftPractice", "NFTP") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmW8QvcP3LiTjCqhBVf2L6UdJEKa4jQPmvXD6MrGvMiCDo";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
    // This sets the Mint windows open or closed by Contract Owner
    function editMintWindows(
        bool _publicMintOpen,
        bool _allowListMintOpen        
    ) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;
    }

    // This is the WhiteList mint option
    function allowListMint() public payable {
        require(allowListMintOpen, 'Allow Mint list Closed!');
        require(allowList[msg.sender], 'Only Whitelist Members');
        require(msg.value == 0.001 ether, 'Not Enough ETH');
        internalMint();
    }

    // Add Payment
    // Add Limited Supply
    // Add publicMint and allow
    function publicMint() public payable {
        require(publicMintOpen, 'Public Mint Closed');
        require(msg.value == 0.01 ether, 'Not Enough ETH');
        internalMint();

    }

    function internalMint() internal  {
        require(totalSupply() < maxSupply, 'Sold Out!!!!!!!');
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);

    }

    function withdraw (address _addr) external  onlyOwner {
        // Get balance of contract
        uint256 balance = address(this).balance;
        payable(_addr).transfer(balance);
    }
 
    // Populate allow list
    function setAllowList(address[] calldata addresses) external onlyOwner {        // Creats the list of white listers
        for(uint256 i = 0; i < addresses.length; i++){
            allowList[addresses[i]] = true;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}