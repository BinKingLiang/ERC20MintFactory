// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./InscriptionToken.sol";

contract InscriptionFactory {
    using Clones for address;
    
    address public immutable tokenImplementation;
    uint256 public constant FEE_PERCENT = 5; // 5% fee
    address public feeRecipient;
    
    mapping(address => bool) public isDeployedToken;
    mapping(address => address) public tokenCreators;

    event TokenDeployed(address indexed token, address indexed creator, string symbol);
    event TokenMinted(address indexed token, address indexed minter, uint256 amount);

    constructor(address _feeRecipient) {
        tokenImplementation = address(new InscriptionToken());
        feeRecipient = _feeRecipient;
    }

    function deployInscription(
        string memory symbol,
        uint256 totalSupply,
        uint256 perMint,
        uint256 price
    ) external returns (address) {
        address token = Clones.clone(tokenImplementation);
        InscriptionToken(token).initialize(
            symbol,
            totalSupply,
            perMint,
            price,
            address(this)
        );
        
        isDeployedToken[token] = true;
        tokenCreators[token] = msg.sender;
        
        emit TokenDeployed(token, msg.sender, symbol);
        return token;
    }

    function mintInscription(address tokenAddr) external payable {
        require(isDeployedToken[tokenAddr], "Invalid token address");
        
        InscriptionToken token = InscriptionToken(tokenAddr);
        uint256 cost = token.price() * token.perMint();
        require(msg.value >= cost, "Insufficient payment");
        
        // Mint tokens first
        token.mint(msg.sender);
        
        // Then distribute payment (5% fee, 95% to creator)
        uint256 fee = (msg.value * FEE_PERCENT) / 100;
        uint256 creatorShare = msg.value - fee;
        
        payable(feeRecipient).transfer(fee);
        payable(tokenCreators[tokenAddr]).transfer(creatorShare);
        emit TokenMinted(tokenAddr, msg.sender, token.perMint());
    }
}
