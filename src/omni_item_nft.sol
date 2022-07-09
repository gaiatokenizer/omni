// SPDX-License-Identifier: BSD-2-Clause-Patent
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract OmniItem is ERC1155, AccessControl, ERC1155Supply {
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(uint => string) public category;
    uint public categoryId;

    mapping(uint => string) public manufactor;
    uint public manufactorId;


    constructor() ERC1155("https://omnigaiatokenizer.herokuapp.com/token/") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        uint256 tokenId = 0;
        if (id == 0) {
            tokenId = _tokenIdCounter.current();
        } else {
            tokenId = id;
        }
        _mint(account, tokenId, amount, data);
        _tokenIdCounter.increment();
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

    function addOrEditCategory(string memory _name, uint _categoryId) 
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
}