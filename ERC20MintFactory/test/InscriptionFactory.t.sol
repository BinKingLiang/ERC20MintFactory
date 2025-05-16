// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/InscriptionFactory.sol";
import "../src/InscriptionToken.sol";

contract InscriptionFactoryTest is Test {
    InscriptionFactory public factory;
    address public owner = address(1);
    address public user = address(2);
    address public feeRecipient = address(999);

    function setUp() public {
        vm.prank(owner);
        factory = new InscriptionFactory(feeRecipient);
    }

    function testDeployInscription() public {
        vm.prank(user);
        address tokenAddr = factory.deployInscription("TEST", 1000, 10, 1 ether);

        InscriptionToken token = InscriptionToken(tokenAddr);
        assertEq(token.symbol(), "TEST");
        assertEq(token.name(), "Inscription TEST");
        assertEq(token.maxSupply(), 1000);
        assertEq(token.perMint(), 10);
        assertEq(token.price(), 1 ether);
    }

    function testMintInscription() public {
        vm.prank(user);
        address tokenAddr = factory.deployInscription("TEST", 1000, 10, 1 ether);
        
        uint256 cost = 1 ether * 10; // price * perMint
        // Setup initial balances
        vm.deal(user, cost * 2);
        uint256 initialFeeRecipientBalance = address(feeRecipient).balance;
        uint256 initialCreatorBalance = address(user).balance;
        
        // First mint
        vm.prank(user);
        factory.mintInscription{value: cost}(tokenAddr);

        InscriptionToken token = InscriptionToken(tokenAddr);
        assertEq(token.balanceOf(user), 10);
        
        // Verify fee distribution (5% to feeRecipient)
        uint256 expectedFee = cost * 5 / 100;
        assertEq(address(feeRecipient).balance - initialFeeRecipientBalance, expectedFee);
        
        // Verify creator received correct share (95% of cost)
        uint256 expectedCreatorShare = cost - expectedFee;
        assertEq(address(user).balance, initialCreatorBalance + expectedCreatorShare - cost);
        
        // Verify total supply after first mint
        assertEq(token.totalSupply(), 10);
        
        // Second mint
        vm.prank(user);
        factory.mintInscription{value: cost}(tokenAddr);
        
        // Verify total supply after second mint
        assertEq(token.totalSupply(), 20);
    }

    function testMaxSupply() public {
        vm.prank(user);
        address tokenAddr = factory.deployInscription("TEST", 100, 10, 1 ether);
        
        uint256 cost = 1 ether * 10;
        vm.deal(user, cost * 11); // Enough for 10 mints (100 tokens)
        
        // Mint 10 times (total 100 tokens)
        for (uint i = 0; i < 10; i++) {
            vm.prank(user);
            factory.mintInscription{value: cost}(tokenAddr);
        }
        
        InscriptionToken token = InscriptionToken(tokenAddr);
        assertEq(token.totalSupply(), 100);
        
        // Should fail on 11th mint
        vm.expectRevert("Exceeds max supply");
        vm.prank(user);
        factory.mintInscription{value: cost}(tokenAddr);
    }
}
