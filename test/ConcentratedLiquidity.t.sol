// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ConcentratedLiquidity} from "../src/ConcentratedLiquidity.sol";
import {MockAUSD} from "../src/mocks/tokens/MockAUSD.sol";
import {MockKARI} from "../src/mocks/tokens/MockKARI.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ConcentratedLiquidityTest is Test {
    ConcentratedLiquidity public concentratedLiquidity;
    MockAUSD public ausd;
    MockKARI public kari;
    // address public ausd = address(mockAusd);
    // address public kari = address(mockKari);

    function setUp() public {
        //set the blockchain that we are going to use
        vm.createSelectFork("https://arb-mainnet.g.alchemy.com/v2/IpWFQVx6ZTeZyG85llRd7h6qRRNMqErS", 306368675); //306368675

        ausd = new MockAUSD();
        kari = new MockKARI();

        //address _pool, address _baseToken, address _token0, uint24 _fee
        concentratedLiquidity = new ConcentratedLiquidity(0xC36442b4a4522E871399CD717aBDD847Ab11FE88, address(kari), address(ausd), 3000);
        deal(address(ausd), address(this), 10000e6);
        deal(address(kari), address(this), 10000e18);
    }

    function test_initPool() public {
        IERC20(ausd).approve(address(concentratedLiquidity), 2000e6);
        console.log("AUSD", IERC20(ausd).balanceOf(address(this)));
        //kari.mint(address(concentratedLiquidity), 999999948301786405);
        //kari.mint(address(concentratedLiquidity), 10000e18);
        //console.log("KARI", IERC20(kari).balanceOf(address(concentratedLiquidity)));
        concentratedLiquidity.initPool(79224306130848112672356);
        console.log("NFT Id", concentratedLiquidity.anchorTokenId());
    }
}