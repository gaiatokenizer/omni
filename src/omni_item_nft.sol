// SPDX-License-Identifier: BSD-2-Clause-Patent
// Developed by Jeff Prestes
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract OmniItem is ERC1155, AccessControl, ERC1155Supply {
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    using Strings for uint256;
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(uint64 => string) public category;
    uint64 public categoryId;

    mapping(uint64 => string) public manufactor;
    uint64 public manufactorId;

    mapping(uint => uint64) public tokenManufactor;
    mapping(uint => uint64) public tokenCategory;
    mapping(uint => uint) public tokenOrigin;


    constructor() ERC1155("https://omnigaiatokenizer.herokuapp.com/token/") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        category[1234] = "teste";
        categoryId++;
        manufactor[1234] = "Telco";
        manufactorId++;
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function mint(address account, uint256 amount, uint64 categoryID, uint64 manufactorID, uint256 originToken)
        public
        onlyRole(MINTER_ROLE)
    {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();

        require(bytes(manufactor[manufactorID]).length > 0, "manufactor not found");
        tokenManufactor[tokenId] = manufactorID;

        require(bytes(category[categoryID]).length > 0, "category not found");
        tokenCategory[tokenId] = categoryID;
    
        if (originToken > 0) {
            require(tokenId > originToken, "invalid origin");
            tokenOrigin[tokenId] = originToken;
        } else {
            tokenOrigin[tokenId] = 0;
        }

        _mint(account, tokenId, amount, "");
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function addManufactor(string memory _name) 
        public
        onlyRole(DEFAULT_ADMIN_ROLE) 
    {
        manufactorId++;
        manufactor[manufactorId] = _name;
    }

    function addOrEditCategory(string memory _name, uint64 _categoryId) 
        public
        onlyRole(DEFAULT_ADMIN_ROLE) 
    {
        if (_categoryId != 0 && bytes(category[_categoryId]).length > 0) {
            category[_categoryId] = _name;
        } else {
            categoryId++;
            category[categoryId] = _name;
        }
    }

    function getLastTokenId() public view returns(uint256) {
        return _tokenIdCounter.current();
    }


    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_tokenId <= getLastTokenId(), "invalid token id");
        return bytes(_uri).length > 0 ? string(abi.encodePacked(_uri, _tokenId.toString(), ".json")) : "";
    }

    function tokenData(uint256 _tokenId) public view virtual returns (string memory, string memory, string memory) {
        require(_tokenId <= getLastTokenId(), "invalid token id");
        string memory uritmp = bytes(_uri).length > 0 ? string(abi.encodePacked(_uri, _tokenId.toString(), ".json")) : "";
        string memory manufactorTmp = manufactor[tokenManufactor[_tokenId]];
        string memory categorytmp = category[tokenCategory[_tokenId]];
        return (uritmp, manufactorTmp, categorytmp);
    }

}