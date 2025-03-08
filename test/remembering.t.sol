// //SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";
// import {ConcentratedLiquidity} from "../src/ConcentratedLiquidity.sol";
// import {MockAUSD} from "../src/mocks/tokens/MockAUSD.sol";
// import {MockKARI} from "../src/mocks/tokens/MockKARI.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// contract ConcentratedLiquidity is Test{
//     ConcentratedLiquidity public concentratedLiquidity;
//     MockAUSD public ausd;
//     MockKARI public kari;

//     function setUp() public {
//         ausd = new MockAUSD();
//         kari = new MockKARI();
//         concentratedLiquidity = new ConcentratedLiquidity(0xC36442b4a4522E871399CD717aBDD847Ab11FE88, address(kari), address(ausd), 3000);
//         deal(address(ausd), address(this), 1000e6);
//         deal(address(kari), address(this), 10000e18);
//     }

//     function test_Init() public {
//         IERC20(ausd).approve(address(concentratedLiquidity), 1000e6);
//         kari.mint(address(concentratedLiquidity), 10000e18);
//         concentratedLiquidity.initPool(79224306130848112672356);
//     }
// }