// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ConcentratedLiquidity} from "../src/ConcentratedLiquidity.sol";

contract CounterTest is Test {
    ConcentratedLiquidity public lp;

    function setUp() public {
        lp = new ConcentratedLiquidity();
        //counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}