// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NovelContractSecret is ERC721Enumerable, Ownable {
    using Strings for uint256;

    bool public _isSaleActive = true;
    bool public _revealed = true;

    // Constants
    uint256 public constant MAX_SUPPLY = 200;
    uint256 public mintPrice = 0.000000000001 ether;
    uint256 public maxBalance = 200;
    uint256 public maxMint = 200;

    string baseURI;
    string baseURI_PDF;
    string public notRevealedUri;
    string public baseExtension = ".json";
    string public _contractURI;


    mapping(uint256 => string) private _tokenURIs;

    constructor(string memory initBaseURI, string memory tokenName, string memory tokenSymbol, string memory myContractURI, string memory baseURI_Pdf)
        ERC721(tokenName, tokenSymbol)
    {
        baseURI = initBaseURI;
        baseURI_PDF = baseURI_Pdf;
        _contractURI = myContractURI;
    }

    function mintPDF(uint256 tokenQuantity) public payable {
        require(
            msg.sender == owner(),
            "You are not the contract owner"
        );
        require(
            totalSupply() + tokenQuantity <= MAX_SUPPLY,
            "Sale would exceed max supply"
        );
        require(
            balanceOf(msg.sender) + tokenQuantity <= maxBalance,
            "Sale would exceed max balance"
        );
        require(
            tokenQuantity * mintPrice <= msg.value,
            "Not enough ether sent"
        );
        require(tokenQuantity <= maxMint, "Can only mint 1 tokens at a time");

        _mintPDF(tokenQuantity);
        
    }

    function _mintPDF(uint256 tokenQuantity) internal {
        for (uint256 i = 0; i < tokenQuantity; i++) {
            uint256 mintIndex = totalSupply();

            if (totalSupply() < MAX_SUPPLY) {
                _safeMint(msg.sender, mintIndex);
            }
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (_revealed == false) {
            return notRevealedUri;
        }

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return
            string(abi.encodePacked(base, tokenId.toString(), baseExtension));
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    //only owner
    function flipSaleActive() public onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    function flipReveal() public onlyOwner {
        _revealed = !_revealed;
    }

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function setMaxBalance(uint256 _maxBalance) public onlyOwner {
        maxBalance = _maxBalance;
    }

    function setMaxMint(uint256 _maxMint) public onlyOwner {
        maxMint = _maxMint;
    }

    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }
    
    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

     function getPDF(uint256 ownedTokenID) public view returns (string memory){

        string memory _sender = toAsciiString(msg.sender);
        if(msg.sender == ownerOf(ownedTokenID)){
            return string(abi.encodePacked(baseURI_PDF, ownedTokenID.toString(), ".pdf"));
            
        }
        else{
            string memory _prefix = "You are not holder";
            return string(abi.encodePacked(_sender,_prefix));
        }

    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

}
