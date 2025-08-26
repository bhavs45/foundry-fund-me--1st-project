//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // Test cases for the FundMe contract
    // This file will contain tests for the fund, withdraw, and other functions
    // It will also test the onlyOwner modifier and the getVersion function
    uint256 public number;
    FundMe public fundme;
    address me = makeAddr("me");

    function setUp() external {
        // Set up the test environment
        // This function will run before each test case
        // You can deploy the FundMe contract here if needed
        // number = 42; // Example setup
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(me, 10 * 10 ** 18); // Give the test account some ETH
        // vm.deal(fundme.isOwner(), 10 * 10 ** 18); // Give the owner some ETH
    }

    function testMinimumDollar() public {
        // // Test the demo function
        // console.log(number);
        // console.log("This is a demo test function");
        // // This is a simple test that checks if the number is set correctly
        // // You can use assert or require to check conditions
        // // For example, we can check if the number is 42
        // assertEq(number, 42, "Number should be 42");

        //us --> FunMeTest-->fundme
        assertEq(
            fundme.MINIMUM_USD(),
            5 * 10 ** 18,
            "Minimum USD should be 5 ETH"
        );
    }

    function testisTheOwner() public {
        assertEq(
            fundme.i_owner(),
            address(msg.sender),
            "Owner should be the contract deployer"
        );
    }

    function testGetVersion() public {
        // Test the getVersion function
        uint256 version = fundme.getVersion(); // Get the version from the price feed;
        console.log(version);

        if (block.chainid == 11155111) {
            assertEq(fundme.getVersion(), 4, "Version should be 4 on Sepolia");
        } else if (block.chainid == 1) {
            assertEq(fundme.getVersion(), 6, "Version should be 4 on Mainnet");
        } else if (block.chainid == 31337) {
            assertEq(fundme.getVersion(), 4, "Version should be 4 on Anvil");
        } else {
            revert("Unsupported network");
        }
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundme.fund(); // Attempt to fund with less than the minimum USD value {value: 0}
    }

    function testUpdatedDataStructs() public {
        vm.prank(me);
        fundme.fund{value: 10 * 10 ** 18}(); // Fund with 10 ETH
        uint256 amount = fundme.addressToAmountFunded(me);
        assertEq(amount, 10 * 10 ** 18, "Amount funded should be 10 ETH");
    }

    function testFundersArray() public {
        vm.prank(me);
        fundme.fund{value: 10 * 10 ** 18}();
        address funderr = fundme.funders(0);
        assertEq(funderr, me, "Funder should be the test account");
    }

    modifier funded() {
        vm.prank(me);
        fundme.fund{value: 10 * 10 ** 18}();
        _;
    }

    function testCheaperWithdraw() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;
        for (uint160 i = startingIndex; i <= numberOfFunders; i++) {
            hoax(address(i), 10 * 10 ** 18);
            fundme.fund{value: 10 * 10 ** 18}(); //
        }
        //act
        // vm.txGasPrice(10000000);
        uint256 startGas = gasleft();
        vm.prank(fundme.isOwner());
        fundme.cheaperWithdraw(); // Withdraw as the owner
        uint256 endGas = gasleft();
        console.log("Gas used for withdrawal:", startGas - endGas);
        //assert
        uint256 startingOwnerBalance = fundme.isOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;
        uint256 endingOwnerBalance = fundme.isOwner().balance;
        uint256 endingFundMeBalance = address(fundme).balance;
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance,
            "Owner balance should be equal to starting balance plus fundme balance"
        );
        assertEq(
            endingFundMeBalance,
            0,
            "FundMe balance should be 0 after withdrawal"
        );
    }

    function testWithdraw() public funded {
        vm.expectRevert();
        vm.prank(me);
        fundme.withdraw(); // Attempt to withdraw as a non-owner should revert
        // vm.prank(fundme.i_owner());
        // fundme.withdraw(); // Withdraw as the owner
    }

    function testWithdrawByOwner() public {
        // vm.prank(fundme.isOwner());
        // fundme.fund{value: 10 * 10 ** 18}(); // Fund the contract
        // uint256 amount = fundme.addressToAmountFunded(fundme.isOwner());
        // assertEq(amount, 10 * 10 ** 18, "Amount funded should be 10 ETH");
        // vm.prank(fundme.isOwner());
        // fundme.withdraw(); // Withdraw as the owner
        // assertEq(amount, 0, "0 ETH");

        //arrange
        uint256 startingOwnerBalance = fundme.isOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;
        //Act
        vm.prank(fundme.isOwner());
        fundme.withdraw(); // Withdraw as the owner
        //Assert
        uint256 endingOwnerBalance = fundme.isOwner().balance;
        uint256 endingFundMeBalance = address(fundme).balance;
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance,
            "Owner balance should be equal to starting balance plus fundme balance"
        );
        assertEq(
            endingFundMeBalance,
            0,
            "FundMe balance should be 0 after withdrawal"
        );
    }

    function testFundingFromMultipleFunders() public {
        //arrange
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;
        for (uint160 i = startingIndex; i <= numberOfFunders; i++) {
            hoax(address(i), 10 * 10 ** 18);
            fundme.fund{value: 10 * 10 ** 18}(); //
        }
        //act
        vm.txGasPrice(10000000);
        uint256 startGas = gasleft();
        vm.prank(fundme.isOwner());
        fundme.withdraw(); // Withdraw as the owner
        uint256 endGas = gasleft();
        console.log("Gas used for withdrawal:", startGas - endGas);
        //assert
        uint256 startingOwnerBalance = fundme.isOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;
        uint256 endingOwnerBalance = fundme.isOwner().balance;
        uint256 endingFundMeBalance = address(fundme).balance;
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance,
            "Owner balance should be equal to starting balance plus fundme balance"
        );
        assertEq(
            endingFundMeBalance,
            0,
            "FundMe balance should be 0 after withdrawal"
        );
    }
}
