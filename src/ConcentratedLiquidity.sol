// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ConcentratedLiquidity{

    INonfungiblePositionManager public pool;

    address baseToken;
    address token0;
    uint24 uniswap_V3_FEE;

    address poolAddress;

    uint256 anchorTokenId;
    
    constructor(address _pool, address _baseToken, address _token0, uint24 _fee) {
        pool = INonfungiblePositionManager(_pool);
        baseToken = _baseToken;
        token0 = _token0;
        uniswap_V3_FEE = _fee;
    }

    // function createAndInitializePoolIfNecessary(
    //     address token0,
    //     address token1,
    //     uint24 fee,
    //     uint160 sqrtPriceX96
    // ) external payable override returns (address pool)
    //79224306130848112672356
    function initPool(uint160 sqrtPriceX96) external {
        poolAddress = pool.createAndInitializePoolIfNecessary(token0, baseToken, uniswap_V3_FEE, sqrtPriceX96);
        amount0Desired = 999999948301786405;
        amount1Desired = 3792990;

        INonfungiblePositionManager.MintParams memory anchorParams = INonfungiblePositionManager.MintParams({
            token0: baseToken, //KARI
            token1: token0, //AUSD
            fee: 3000, //menentukan harga
            tickLower: -276420, //menentukan harga 
            tickUpper: -276300, //menentukan harga
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        IERC20(baseToken).approve(address(nonfungiblePositionManager), amount0Desired);
        IERC20(token0).approve(address(nonfungiblePositionManager), amount1Desired);
        (uint256 atokenId,,,) = nonfungiblePositionManager.mint(anchorParams);

        anchorTokenId = atokenId;
    }
}