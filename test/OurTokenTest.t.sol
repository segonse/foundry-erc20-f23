// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployOurToken;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 1000;

    function setUp() external {
        deployOurToken = new DeployOurToken();
        ourToken = deployOurToken.run();

        vm.prank(msg.sender); //I -> test -> script -> OurToken，OurToken中的msg.sender还是I，是因为test、script没有上链还是foundry的一些设置？不过script的msg.sender确实是test的地址
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testMsgSenderBalance() public {
        assertEq(
            deployOurToken.INITIAL_SUPPLY() - STARTING_BALANCE,
            ourToken.balanceOf(msg.sender)
        );
    }

    function testAllowancesWork() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 500;

        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(ourToken.balanceOf(alice), transferAmount);
    }
}
