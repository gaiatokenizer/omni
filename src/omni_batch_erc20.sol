// SPDX-License-Identifier: BSD-2-Clause-Patent
// Developed by Jeff Prestes
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract OmniRecycleFactory is AccessControl {
    bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");

    event NewRecycleCreditToken(address token, bytes32 hashID, string name, string symbol);

    struct RecycleCreditToken {
        address token;
        bytes32 hashID;
        string name;
        string symbol;
    }

    RecycleCreditToken[] public creditTokens;
    mapping(bytes32 => address) public existingTokens;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(CREATOR_ROLE, msg.sender);
    }

    function getTotalTokens() public view returns (uint256) {
        return creditTokens.length;
    }

    function generateNewRecycleCreditToken(
        string memory _name, 
        string memory _symbol, 
        address _coletador, 
        address _recicladora, 
        string memory _govCategory
    ) external  onlyRole(CREATOR_ROLE) returns (bool) {
        bytes32 hashID = keccak256(abi.encode(_name, _symbol));
        address exists = existingTokens[hashID];
        require(exists==address(0x0), "a token using same name was already minted");

        OmniRecycle token = new OmniRecycle(_name, _symbol, _coletador, _recicladora, _govCategory);
        RecycleCreditToken memory creditToken = RecycleCreditToken(address(token), hashID, _name, _symbol);
        creditTokens.push(creditToken);
        existingTokens[hashID] = address(token);
        emit NewRecycleCreditToken(address(token), hashID, _name, _symbol);
        return true;
    }

}


contract OmniRecycle is ERC20, ERC20Burnable, Pausable, AccessControl, ERC20Permit {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    enum StatusNFT {
        SENT,
        RECYCLED,
        DISCARTED,
        REUSED,
        DISASSEMBLED
    }

    struct Asset {
        address nftContract;
        uint256 nftID;
        StatusNFT status;
    }

    struct GovDoc {
        bytes32 imageHash;
        string ID;
        uint expeditionDate;
    }

    GovDoc public mtrInfo;
    GovDoc public cdfInfo;
    GovDoc public nfeInfo;

    Asset[] public assets;

    address public coletador;
    address public recicladora;
    string public govCategory;
    uint256 public recycledAmount;

    constructor(string memory _name, string memory _symbol, address _coletador, address _recicladora, string memory _govCategory) 
        ERC20(_name, _symbol) 
        ERC20Permit(_name) 
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, _coletador);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, _coletador);
        _grantRole(MINTER_ROLE, msg.sender);
        coletador = _coletador;
        recicladora = _recicladora;
        govCategory = _govCategory;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function registerNFTAsset(address _nftContract, uint256 _id)  
        external
        onlyRole(MINTER_ROLE)
    {
        Asset memory newAsset = Asset({nftContract: _nftContract, nftID: _id, status: StatusNFT.SENT});
        assets.push(newAsset);
    }

    function getTotalAssets() 
        public
        view
        returns (uint256)
    {
        return assets.length;
    }

    function setMTR(bytes32 _imageHash, string memory _ID, uint _expeditionDate) 
        external
        onlyRole(MINTER_ROLE)
    {
        GovDoc memory doc = GovDoc({imageHash: _imageHash, ID: _ID, expeditionDate: _expeditionDate});
        mtrInfo = doc;
    }

    function setCDF(bytes32 _imageHash, string memory _ID, uint _expeditionDate, uint256 _recycledAmount, uint[] memory recycledItems, uint[] memory reusableItems) 
        external
        onlyRole(MINTER_ROLE)
    {
        require(assets.length >= recycledItems.length, "invalid number of recycled items");
        for (uint i=0; i<assets.length; i++) {
            assets[recycledItems[i]].status = StatusNFT.RECYCLED;
        }
        require(assets.length >= reusableItems.length, "invalid number of reusable items");
        for (uint i=0; i<assets.length; i++) {
            assets[reusableItems[i]].status = StatusNFT.REUSED;
        }
        GovDoc memory doc = GovDoc({imageHash: _imageHash, ID: _ID, expeditionDate: _expeditionDate});
        cdfInfo = doc;
        recycledAmount = _recycledAmount;
        _mint(address(this), recycledAmount);
    }

    function setNFE(bytes32 _imageHash, string memory _ID, uint _expeditionDate, uint256 _recycledAmount, uint[] memory recycledItems, uint[] memory reusableItems) 
        external
        onlyRole(MINTER_ROLE)
    {
        require(assets.length >= recycledItems.length, "invalid number of recycled items");
        for (uint i=0; i<assets.length; i++) {
            assets[recycledItems[i]].status = StatusNFT.RECYCLED;
        }
        require(assets.length >= reusableItems.length, "invalid number of reusable items");
        for (uint i=0; i<assets.length; i++) {
            assets[reusableItems[i]].status = StatusNFT.REUSED;
        }
        
        GovDoc memory doc = GovDoc({imageHash: _imageHash, ID: _ID, expeditionDate: _expeditionDate});
        nfeInfo = doc;
        recycledAmount = _recycledAmount;
        _mint(address(this), recycledAmount);
    }
}