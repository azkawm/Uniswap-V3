// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {INonfungiblePositionManager} from "@uniswapv3-periphery/interfaces/INonfungiblePositionManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IMockKari} from "./interfaces/IMockKari.sol";
import {console} from "forge-std/Test.sol";
// import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol';
// import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol';
interface IUniswapV3Factory {
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);
}

contract ConcentratedLiquidity{

    INonfungiblePositionManager public pool;
    IMockKari public kari;
    //IUniswapV3Factory public constant pool = IUniswapV3Factory(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);

    address baseToken;
    address token0;
    uint24 uniswap_V3_FEE;

    address public poolAddress;

    uint256 public anchorTokenId;

    uint256 public floorTokenId;

    uint256 public discoveryTokenId;
    
    constructor(address _pool, address _baseToken, address _token0, uint24 _fee) {
        pool = INonfungiblePositionManager(_pool); //0xC36442b4a4522E871399CD717aBDD847Ab11FE88
        baseToken = _baseToken;
        kari = IMockKari(_baseToken);
        token0 = _token0; //ausd
        uniswap_V3_FEE = _fee;
    }

    // function createAndInitializePoolIfNecessary(
    //     address token0,
    //     address token1,
    //     uint24 fee,
    //     uint160 sqrtPriceX96
    // ) external payable override returns (address pool)
    //79224306130848112672356

    // poolAddress=uniswapFactory.createAndInitializePoolIfNecessary(
    //         token0,
    //         token1,
    //         3000,
    //         sqrtPriceX96//sqrtPriceX96
    //     );


    // pool = nonfungiblePositionManager.createAndInitializePoolIfNecessary(
    //         token0, token1, UNISWAP_FEE_TIER, sqrtPriceX96
    //     );

    function initPool(uint160 sqrtPriceX96) external {
        console.log("xxx");
        poolAddress = pool.createAndInitializePoolIfNecessary(baseToken, token0, uniswap_V3_FEE, sqrtPriceX96);
        // uint256 amount0Desired = 999999948301786405;
        // uint256 amount1Desired = 3792990;
        uint256 amount0Anchor = 10000e18;
        uint256 amount1Anchor = 1000e6;
        IERC20(token0).transferFrom(msg.sender,address(this), amount1Anchor);
        kari.mint(address(this), amount0Anchor);
        console.log("KARI", IERC20(baseToken).balanceOf(address(this)));

        //mint anchor
        INonfungiblePositionManager.MintParams memory anchorParams = INonfungiblePositionManager.MintParams({
            token0: baseToken, //KARI
            token1: token0, //AUSD
            fee: 3000, //menentukan harga
            tickLower: -276420, //menentukan harga 
            tickUpper: -276300, //menentukan harga
            amount0Desired: amount0Anchor,
            amount1Desired: amount1Anchor,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        IERC20(baseToken).approve(address(pool), amount0Anchor);
        IERC20(token0).approve(address(pool), amount1Anchor);
        (uint256 atokenId,,,) = pool.mint(anchorParams);

        anchorTokenId = atokenId;

        uint256 amount1Floor = 1000e6;
        IERC20(token0).transferFrom(msg.sender,address(this), amount1Floor);

        INonfungiblePositionManager.MintParams memory floorParams = INonfungiblePositionManager.MintParams({
            token0: baseToken, //KARI
            token1: token0, //AUSD
            fee: 3000, //menentukan harga
            tickLower: -283260, //menentukan harga 
            tickUpper: -283200, //menentukan harga
            amount0Desired: 0,
            amount1Desired: amount1Floor,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        IERC20(token0).approve(address(pool), amount1Floor);
        (uint256 ftokenId,,,) = pool.mint(floorParams);

        floorTokenId = ftokenId;

        // kari.mint(address(this), 10000e18);
        // uint256 amount0Discovery = IERC20(baseToken).balanceOf(address(this));

        // INonfungiblePositionManager.MintParams memory discoveryParams = INonfungiblePositionManager.MintParams({
        //     token0: baseToken, //KARI
        //     token1: token0, //AUSD
        //     fee: 3000, //menentukan harga
        //     tickLower: -276420, //menentukan harga 
        //     tickUpper: -276300, //menentukan harga
        //     amount0Desired: amount0Discovery,
        //     amount1Desired: 0,
        //     amount0Min: 0,
        //     amount1Min: 0,
        //     recipient: address(this),
        //     deadline: block.timestamp
        // });

        // IERC20(token0).approve(address(pool), amount0Discovery);
        // (uint256 dtokenId,,,) = pool.mint(discoveryParams);

        // discoveryTokenId = dtokenId;
    }
}