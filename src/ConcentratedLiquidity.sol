// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {INonfungiblePositionManager} from "@uniswapv3-periphery/interfaces/INonfungiblePositionManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IMockKari} from "./interfaces/IMockKari.sol";
import {console} from "forge-std/Test.sol";
import {IUniswapV3Pool} from "@uniswapv3-core/interfaces/IUniswapV3Pool.sol";
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
    IUniswapV3Pool public poolState;
    IMockKari public kari;
    //IUniswapV3Factory public constant pool = IUniswapV3Factory(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);

    address baseToken;
    address token0;
    uint24 uniswap_V3_FEE;

    address public poolAddress;

    uint256 public anchorTokenId;

    uint256 public floorTokenId;

    uint256 public discoveryTokenId;
    uint256 public discovery_LENGTH = 30;
    
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
        poolAddress = pool.createAndInitializePoolIfNecessary(baseToken, token0, uniswap_V3_FEE, sqrtPriceX96);
        poolState = IUniswapV3Pool(poolAddress);
        uint256 amount0Anchor = 10000e18;
        uint256 amount1Anchor = 1000e6;
        IERC20(token0).transferFrom(msg.sender,address(this), amount1Anchor);
        kari.mint(address(this), amount0Anchor);
        console.log("currentTick", getCurrentTick());

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

        //mint floor
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
        //mint discovery
        kari.mint(address(this), 10000e18);
        uint256 amount0Discovery = IERC20(baseToken).balanceOf(address(this));
        INonfungiblePositionManager.MintParams memory discoveryParams = INonfungiblePositionManager.MintParams({
            token0: baseToken, //KARI
            token1: token0, //AUSD
            fee: 3000, //menentukan harga
            tickLower: -276240, //menentukan harga
            tickUpper: -274440, //menentukan harga
            amount0Desired: amount0Discovery,
            amount1Desired: 0,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        IERC20(baseToken).approve(address(pool), amount0Discovery);
        (uint256 dtokenId,,,) = pool.mint(discoveryParams);
        discoveryTokenId = dtokenId;
    }

    function getCurrentTick() public view returns(int24){
            // uint160 sqrtPriceX96,
            // int24 tick,
            // uint16 observationIndex,
            // uint16 observationCardinality,
            // uint16 observationCardinalityNext,
            // uint8 feeProtocol,
            // bool unlocked
        (,int24 tick,,,,,) = poolState.slot0();
        return tick;
    }

    function move() external{
            //move anchor to discovery
            //anchor
            //collect
            pool.collect(
                INonfungiblePositionManager.CollectParams({
                    tokenId: anchorTokenId,
                    recipient: address(this),
                    amount0Max: type(uint128).max,
                    amount1Max: type(uint128).max
                })
            );

            // withdraw semua/decreaseLiquidity
            (,,,,,,, uint128 aliquidity,,,,) = pool.positions(anchorTokenId);

            pool.decreaseLiquidity(
                INonfungiblePositionManager.DecreaseLiquidityParams({
                    tokenId: anchorTokenId,
                    liquidity: aliquidity,
                    amount0Min: 0,
                    amount1Min: 0,
                    deadline: block.timestamp
                })
            );

            // burn
            pool.collect(
                INonfungiblePositionManager.CollectParams({
                    tokenId: anchorTokenId,
                    recipient: address(this),
                    amount0Max: type(uint128).max,
                    amount1Max: type(uint128).max
                })
            );
            pool.burn(anchorTokenId);

            //discovery
            //collect
            pool.collect(
                INonfungiblePositionManager.CollectParams({
                    tokenId: discoveryTokenId,
                    recipient: address(this),
                    amount0Max: type(uint128).max,
                    amount1Max: type(uint128).max
                })
            );

            // withdraw semua/decreaseLiquidity
            (,,,,,,, uint128 dliquidity,,,,) = pool.positions(discoveryTokenId);
            
            pool.decreaseLiquidity(
                INonfungiblePositionManager.DecreaseLiquidityParams({
                    tokenId: discoveryTokenId,
                    liquidity: dliquidity,
                    amount0Min: 0,
                    amount1Min: 0,
                    deadline: block.timestamp
                })
            );

            pool.collect(
                INonfungiblePositionManager.CollectParams({
                    tokenId: discoveryTokenId,
                    recipient: address(this),
                    amount0Max: type(uint128).max,
                    amount1Max: type(uint128).max
                })
            );
            
            // burn
            pool.burn(discoveryTokenId);
            
            uint256 amount0Anchor = IERC20(baseToken).balanceOf(address(this));
            uint256 amount1Anchor = IERC20(token0).balanceOf(address(this));
            
            uint256 amount0Discovery = IERC20(baseToken).balanceOf(address(this)) - amount0Anchor;
        //mint anchor
        INonfungiblePositionManager.MintParams memory anchorParams = INonfungiblePositionManager.MintParams({
            token0: baseToken, //KARI
            token1: token0, //AUSD
            fee: 3000, //menentukan harga
            tickLower: -277320, //menentukan harga 
            tickUpper: -274920, //menentukan harga
            amount0Desired: amount0Anchor,
            amount1Desired: amount1Anchor,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });
        console.log("tickLower", -277320 );
        console.log("tickLower", -274920);
        console.log("kari balance", IERC20(baseToken).balanceOf(address(this)));
        console.log("ausd balance", IERC20(token0).balanceOf(address(this)));

        IERC20(baseToken).approve(address(pool), amount0Anchor);
        IERC20(token0).approve(address(pool), amount1Anchor);
        (uint256 atokenId,,,) = pool.mint(anchorParams);
        anchorTokenId = atokenId;
        console.log("kari balance", IERC20(baseToken).balanceOf(address(this)));
        console.log("ausd balance", IERC20(token0).balanceOf(address(this)));

        // //mint discovery
        // INonfungiblePositionManager.MintParams memory discoveryParams = INonfungiblePositionManager.MintParams({
        //     token0: baseToken, //KARI
        //     token1: token0, //AUSD
        //     fee: 3000, //menentukan harga
        //     tickLower: -274440, //menentukan harga
        //     tickUpper: -272640, //menentukan harga
        //     amount0Desired: amount0Discovery,
        //     amount1Desired: 0,
        //     amount0Min: 0,
        //     amount1Min: 0,
        //     recipient: address(this),
        //     deadline: block.timestamp
        // });

        // IERC20(baseToken).approve(address(pool), amount0Discovery);
        // (uint256 dtokenId,,,) = pool.mint(discoveryParams);
        // discoveryTokenId = dtokenId;
    }
}