// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ConcentratedLiquidity} from "../src/ConcentratedLiquidity.sol";
import {MockAUSD} from "../src/mocks/tokens/MockAUSD.sol";
import {MockKARI} from "../src/mocks/tokens/MockKARI.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "@uniswapv3-periphery/interfaces/ISwapRouter.sol";

contract ConcentratedLiquidityTest is Test {
    ConcentratedLiquidity public concentratedLiquidity;
    ISwapRouter public swapRouter;
    MockAUSD public ausd;
    MockKARI public kari;

    address router = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address alice = makeAddr("alice");
    // address public ausd = address(mockAusd);
    // address public kari = address(mockKari);

    function setUp() public {
        //set the blockchain that we are going to use
        vm.createSelectFork("https://arb-mainnet.g.alchemy.com/v2/IpWFQVx6ZTeZyG85llRd7h6qRRNMqErS", 306368675); //306368675

        ausd = new MockAUSD();
        kari = new MockKARI();
        swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

        //address _pool, address _baseToken, address _token0, uint24 _fee
        concentratedLiquidity = new ConcentratedLiquidity(0xC36442b4a4522E871399CD717aBDD847Ab11FE88, address(kari), address(ausd), 3000);
        deal(address(ausd), address(this), 10000e6);
        deal(address(kari), address(this), 10000e18);
        deal(address(ausd), alice, 2000e6);

        IERC20(ausd).approve(address(concentratedLiquidity), 2000e6);
        concentratedLiquidity.initPool(79224306130848112672356);
    }

    function test_initPool() public {
        IERC20(ausd).approve(address(concentratedLiquidity), 2000e6);
        concentratedLiquidity.initPool(79224306130848112672356);
        console.log("Anchor Id", concentratedLiquidity.anchorTokenId());
        console.log("Floor Id", concentratedLiquidity.floorTokenId());
        console.log("Discovery Id", concentratedLiquidity.discoveryTokenId());
    }

    function test_move() external{
        console.log("current Tick", concentratedLiquidity.getCurrentTick());
        uint256 swapAmount = 1000e6;
        //swap 10 ausd for kari
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: address(ausd),
                tokenOut: address(kari),
                fee: 3000, // 0.3
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: swapAmount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        vm.startPrank(alice);
        IERC20(ausd).approve(router, swapAmount); // approve kepada Uniswap
        swapRouter.exactInputSingle(params);
        vm.stopPrank();
        console.log("post Current Tick", concentratedLiquidity.getCurrentTick());

        concentratedLiquidity.move();
    }

}