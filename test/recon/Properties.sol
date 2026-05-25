// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {BeforeAfter} from "./BeforeAfter.sol";

import "src/Morpho.sol";

import {IMorpho} from "src/interfaces/IMorpho.sol";


abstract contract Properties is BeforeAfter, Asserts {

    function property_totalAssets_greater_totalBorrow() public {
       Market memory market =  IMorpho(address(morpho)).market(id);

        if (market.totalBorrowAssets > 0) {
            gt(market.totalSupplyAssets, market.totalBorrowAssets, "market.totalSupplyAssets < market.totalBorrowAssets");
        }
    }

}