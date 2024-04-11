// SPDX-License-Identifier: MIT                                                                                  
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./libraries/LibString.sol";
import "./ERC1155.sol";

contract PixelCanvasChronics is ERC721, Ownable {
    using LibString for string;

    ERC1155 public store;

    uint8 public bodyTypesAmount;
    uint8 public mouthsAmount;
    uint8 public earsAmount;
    uint8 public eyesAmount;
    uint8 public colorsAmount;

    address public hotWallet;

    uint256 public totalSupply;
    uint256 public pricePerHero;

    mapping(uint256 => string) private _bodyTypes;
    mapping(uint256 => string) private _mouths;
    mapping(uint256 => string) private _ears;
    mapping(uint256 => string) private _eyes;
    mapping(uint256 => string) private _colors;

    uint256[] private mintableHeroes;

    string private svgPrefix = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 -0.5 128 128" shape-rendering="crispEdges">';
    string private svgSuffix = '</svg>';

    modifier lessThanUint8(uint8 _amount, uint256 arraySize) {
        uint256 existAmount = _amount;
        require((existAmount + arraySize) <= type(uint8).max, "Sum of values exceeds uint8 max");
        _;
    }

    event MintedHero(address indexed account, uint256 indexed heroId);

    constructor(address _storeAddress, uint256 _pricePerHero) ERC721("Pixel Canvas Chronics", "PCC") {
        store = ERC1155(_storeAddress);
        pricePerHero = _pricePerHero;
    }

    function updateHotWallet(address _hotWallet) external onlyOwner {
        hotWallet = _hotWallet;
    }

    // function addBodyType(string memory bodyType) external onlyOwner {
    //     _bodyTypes[bodyTypesAmount] = bodyType;
    //     bodyTypesAmount++;
    // }

    // function addMouth(string memory mouth) external onlyOwner {
    //     _mouths[mouthsAmount] = mouth;
    //     mouthsAmount++;
    // }

    // function addEar(string memory ear) external onlyOwner {
    //     _ears[earsAmount] = ear;
    //     earsAmount++;
    // }

    // function addEye(string memory eye) external onlyOwner {
    //     _eyes[eyesAmount] = eye;
    //     eyesAmount++;
    // }

    // function addColor(string memory color) external onlyOwner {
    //     _colors[colorsAmount] = color;
    //     colorsAmount++;
    // }

    function addBodyTypes(string[] memory bodyType) 
        external
        onlyOwner
        lessThanUint8(bodyTypesAmount, bodyType.length)
    {
        for (uint8 i = 0; i < bodyType.length; i++) {
            _bodyTypes[bodyTypesAmount] = bodyType[i];
            bodyTypesAmount++;
        }
    }

    function addMouths(string[] memory mouth)
        external
        onlyOwner
        lessThanUint8(bodyTypesAmount, mouth.length)
    {
        for (uint8 i = 0; i < mouth.length; i++) {
            _mouths[mouthsAmount] = mouth[i];
            mouthsAmount++;
        }
    }

    function addEars(string[] memory ear)
        external
        onlyOwner
        lessThanUint8(bodyTypesAmount, ear.length) 
    {
        for (uint8 i = 0; i < ear.length; i++) {
            _ears[earsAmount] = ear[i];
            earsAmount++;
        }
    }

    function addEyes(string[] memory eye)
        external
        onlyOwner
        lessThanUint8(bodyTypesAmount, eye.length)
    {
        for (uint8 i = 0; i < eye.length; i++) {
            _eyes[eyesAmount] = eye[i];
            eyesAmount++;
        }
    }

    function addColors(string[] memory color)
        external
        onlyOwner
        lessThanUint8(bodyTypesAmount, color.length)
    {
        for (uint8 i = 0; i < color.length; i++) {
            _colors[colorsAmount] = color[i];
            colorsAmount++;
        }
    }

    function mintHero(address account) payable public {
        require(pricePerHero <= msg.value, "Insufficient funds");
        if (pricePerHero < msg.value) {
            // refund the overpaid amount
            payable(msg.sender).transfer(msg.value - pricePerHero);
        }

        payable(hotWallet).transfer(pricePerHero);

        _mint(account, totalSupply);

        totalSupply++;

        emit MintedHero(account, totalSupply - 1);
    }

    receive() external payable {
        mintHero(msg.sender);
    }

    fallback() external payable {
        mintHero(msg.sender);
    }
}

