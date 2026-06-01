// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Setup} from "./Setup.sol";

import "src/Morpho.sol";
import {IMorpho} from "src/interfaces/IMorpho.sol";
import {IERC20} from "src/interfaces/IERC20.sol";



// ghost variables for tracking state variable values before and after function calls
abstract contract BeforeAfter is Setup {

        enum OpType { GENERIC, SUPPLY, WITHDRAW, REPAY, BORROW, FLASHLOAN }

    using MarketParamsLib for MarketParams;

    struct Vars {
        uint256 totalSupplyShares;
        uint256 totalBorrowShares;
        uint256 totalSupplyAssets;
        uint256 totalBorrowAssets;
        uint256 flashLoanAmount;
    }

    Vars internal _before;
    Vars internal _after;
    OpType internal currentOp;

    modifier updateGhosts() {
        __before();
        _;        
        __after();
    }

    modifier updateGhostsWithType(OpType op) {
        currentOp = op;
        __before();
        _;        
        __after();
    }

    function __before() internal {
        Market memory market =  IMorpho(address(morpho)).market(activeMarketParams.id());

        _before.totalSupplyShares = market.totalSupplyShares;
        _before.totalBorrowShares = market.totalBorrowShares;
        _before.totalSupplyAssets = market.totalSupplyAssets;
        _before.totalBorrowAssets = market.totalBorrowAssets;
        _before.flashLoanAmount = IERC20(activeAsset).balanceOf(address(morpho)); 
    }

    function __after() internal {
        Market memory market =  IMorpho(address(morpho)).market(activeMarketParams.id());

        _after.totalSupplyShares = market.totalSupplyShares;
        _after.totalBorrowShares = market.totalBorrowShares;
        _after.totalSupplyAssets = market.totalSupplyAssets;
        _after.totalBorrowAssets = market.totalBorrowAssets;
        _after.flashLoanAmount = IERC20(activeAsset).balanceOf(address(morpho)); 
    }

    function _totalBorrowActorsShares() internal view returns (uint256 totalBorrowActorShares) {
        for (uint256 i = 0; i < _getActors().length; i++) {
            address actor = _getActors()[i];
            (,uint128 borrowShares,) = morpho.position(activeMarketParams.id(), actor);
            totalBorrowActorShares += borrowShares;
        }
    }

    function _totalCollateralActorsAmount() internal view returns (uint256 totalCollateralActorAmount) {
        for (uint256 i = 0; i < _getActors().length; i++) {
            address actor = _getActors()[i];
            (,,uint128 collateralAmount) = morpho.position(activeMarketParams.id(), actor);
            totalCollateralActorAmount += collateralAmount;
        }
    }

    function _usersHealthy() internal returns (bool) {
        address[] memory actors = _getActors();

        bool healthy = true;
        for (uint256 i = 0; i < actors.length; i++) {
            healthy = healthy && morpho.isHealthy(activeMarketParams, actors[i]);
        }

        return healthy;
    }

}