// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {BeforeAfter} from "./BeforeAfter.sol";

import "src/Morpho.sol";

import {IMorpho} from "src/interfaces/IMorpho.sol";
import {IERC20} from "src/interfaces/IERC20.sol";


abstract contract Properties is BeforeAfter, Asserts {

    using MarketParamsLib for MarketParams;

    function property_totalSupplyShares_totalSupplyAssets_SUPPLY() public {
        if (currentOp == OpType.SUPPLY) {
            gte(_after.totalSupplyShares, _before.totalSupplyShares, "_after.totalSupplyShares < _before.totalSupplyShares");
            gte(_after.totalSupplyAssets, _before.totalSupplyAssets, "_after.totalSupplyAssets < _before.totalSupplyAssets");
        }
    }

    function property_totalBorrowShares_totalBorrowAssets_BORROW() public {
        if (currentOp == OpType.BORROW) {
            gte(_after.totalBorrowShares, _before.totalBorrowShares, "_after.totalBorrowShares < _before.totalBorrowShares");
            gte(_after.totalBorrowAssets, _before.totalBorrowAssets, "_after.totalBorrowAssets < _before.totalBorrowAssets");
        }
    }

    function property_totalSupplyShares_totalSupplyAssets_WITHDRAW() public {
        if (currentOp == OpType.WITHDRAW) {
            lte(_after.totalSupplyShares, _before.totalSupplyShares, "_after.totalSupplyShares > _before.totalSupplyShares");
            lte(_after.totalSupplyAssets, _before.totalSupplyAssets, "_after.totalSupplyAssets > _before.totalSupplyAssets");
        }
    }

    function property_totalBorrowShares_totalBorrowAssets_REPAY() public {
        if (currentOp == OpType.REPAY) {
            lte(_after.totalBorrowShares, _before.totalBorrowShares, "_after.totalBorrowShares > _before.totalBorrowShares");
            lte(_after.totalBorrowAssets, _before.totalBorrowAssets, "_after.totalBorrowAssets > _before.totalBorrowAssets");
        }
    }

    function property_totalSupplyShares_totalSupplyAssets_FLASHLOAN() public {
        if (currentOp == OpType.FLASHLOAN) {
            eq(_after.flashLoanAmount, _before.flashLoanAmount, "_after.flashLoanAmount != _before.flashLoanAmount");
        }
    }

    function property_totalAssets_gte_totalBorrow() public {
       Market memory market =  IMorpho(address(morpho)).market(activeMarketParams.id());

        if (market.totalBorrowAssets > 0) {
            gte(market.totalSupplyAssets, market.totalBorrowAssets, "market.totalSupplyAssets < market.totalBorrowAssets");
        }
    }

    function property_totalBorrowShares_eq_totalActorsShares() public {
        Market memory market =  IMorpho(address(morpho)).market(activeMarketParams.id());

        uint256 totalBorrowActorShares = _totalBorrowActorsShares();
        
        eq(market.totalBorrowShares, totalBorrowActorShares, "market.totalBorrowShares != totalBorrowActorShares");
    }

    function property_morphoCollateral_gte_totalActorsCollateral() public {
        Market memory market =  IMorpho(address(morpho)).market(activeMarketParams.id());

        uint256 totalActorsCollateral = _totalCollateralActorsAmount();
    
        address collateralToken = activeMarketParams.collateralToken;

        gte(IERC20(collateralToken).balanceOf(address(morpho)), totalActorsCollateral, "market.collateral < totalActorsCollateral");
    }

    function property_userBorrow_mustHasCollateral() public {

        for (uint256 i = 0; i < _getActors().length; i++) {
            address actor = _getActors()[i];
            (,,uint128 collateralAmount) = morpho.position(activeMarketParams.id(), actor);
            (,uint128 borrowShares,) = morpho.position(activeMarketParams.id(), actor);

            if (borrowShares > 0) {
                gt(collateralAmount, 0, "actor has borrow shares but no collateral");
            }
        }
    }

    function property_marketBorrow0Assets_borrow0Shares() public {
        Market memory market =  IMorpho(address(morpho)).market(activeMarketParams.id());

        if (market.totalBorrowAssets == 0) {
            eq(market.totalBorrowShares, 0, "market has borrow assets = 0 but borrow shares > 0");
        }
    }

    function property_noBorrows_AllUsersHealthy() public {
        Market memory market =  IMorpho(address(morpho)).market(activeMarketParams.id());

        if (market.totalBorrowAssets == 0) {
                bool isHealthy = _usersHealthy();
                t(isHealthy, "market has no borrows but some users are unhealthy");
        }
    }
}