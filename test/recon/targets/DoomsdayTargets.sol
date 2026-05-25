// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Properties} from "../Properties.sol";
// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";

import {IMorpho} from "src/interfaces/IMorpho.sol";
import "src/Morpho.sol";

import {Vm} from "forge-std/Vm.sol";




abstract contract DoomsdayTargets is
    BaseTargetFunctions,
    Properties
{
    /// Makes a handler have no side effects
    /// The fuzzer will call this anyway, and because it reverts it will be removed from shrinking
    /// Replace the "withGhosts" with "stateless" to make the code clean
    modifier stateless() {
        _;
        revert("stateless");
    }

    //TODO
    function morpho_liquidate_sepecific_market_clamped(uint256 amount) public asActor stateless {
        MarketParams memory params = IMorpho(address(morpho)).idToMarketParams(id);

        morpho.supplyCollateral(params, amount, _getActor(), "");

        morpho.borrow(params, amount / 2, 0, _getActor(), address(this));

        (,uint128 seizedShares, uint128 seizedAssets) = morpho.position(id, address(this));

        oracle.setPrice(1);

        vm.warp(block.timestamp + 30 days);   

        morpho.liquidate(params, _getActor(), seizedAssets, 0, "");
    }
}