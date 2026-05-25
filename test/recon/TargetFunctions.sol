// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";

import "src/Morpho.sol";

// Targets
// NOTE: Always import and apply them in alphabetical order, so much easier to debug!
import { AdminTargets } from "./targets/AdminTargets.sol";
import { DoomsdayTargets } from "./targets/DoomsdayTargets.sol";
import { ManagersTargets } from "./targets/ManagersTargets.sol";
import { MorphoTargets } from "./targets/MorphoTargets.sol";
import {IMorpho} from "src/interfaces/IMorpho.sol";
import {FlashBorrowerMock} from "src/mocks/FlashBorrowerMock.sol";

abstract contract TargetFunctions is
    AdminTargets,
    DoomsdayTargets,
    ManagersTargets,
    MorphoTargets
{



    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///
    function morpho_supply_sepecific_market_assets_0data_clamped( uint256 assets, address onBehalf) public {
        morpho_supply(marketParams, assets, 0, onBehalf, "");
    }

    function morpho_supply_sepecific_market_shares_0data_clamped( uint256 shares, address onBehalf) public {
        morpho_supply(marketParams, 0, shares, onBehalf, "");
    }

    function morpho_setFee_clamped(uint256 newFee) public asAdmin() {
        newFee = between(newFee, 0, 0.25e18);
        morpho_setFee(marketParams, newFee);
    }

    function morpho_withdraw_sepecific_market_assets_0data_clamped(uint256 assets, address onBehalf) public {
        morpho_withdraw(marketParams, assets, 0, _getActor(), address(this));    
    }

    function morpho_withdraw_sepecific_market_shares_0data_clamped(uint256 shares, address onBehalf) public {
        morpho_withdraw(marketParams, 0, shares, _getActor(), address(this));    
    }

    function morpho_borrow_sepecific_market_assets_0data_clamped(uint256 assets, address onBehalf) public {
        morpho_borrow(marketParams, assets, 0, _getActor(), address(this));
        
    }

    function morpho_borrow_sepecific_market_shares_0data_clamped(uint256 shares, address onBehalf) public {
        morpho_borrow(marketParams, 0, shares, _getActor(), address(this));
        
    }

    function morpho_repay_sepecific_market_assets_0data_clamped(uint256 assets, address onBehalf) public {
        morpho_repay(marketParams, assets, 0, _getActor(), "");
    }

    function morpho_repay_sepecific_market_shares_0data_clamped(uint256 shares, address onBehalf) public {
        morpho_repay(marketParams, 0, shares, _getActor(), "");
    }

    function morpho_supplyCollateral_sepecific_market_assets_0data_clamped(uint256 assets, address onBehalf) public {
        morpho_supplyCollateral(marketParams, assets, _getActor(), "");
    }

    function morpho_withdrawCollateral_sepecific_market_assets_0data_clamped(uint256 assets, address onBehalf) public {
        morpho_withdrawCollateral(marketParams, assets, _getActor(), address(this));
    }

    function morpho_flashLoan_WithMock(uint256 assets) public {
        
        FlashBorrowerMock flashBorrower = new FlashBorrowerMock(IMorpho(address(morpho)));

        bytes memory data = abi.encode(address(asset));
        
        flashBorrower.flashLoan(address(asset), assets, data);
    }

    function morpho_accruesInterests_sepecific_market(uint256 assets, address onBehalf) public asActor {
        morpho_accrueInterest(marketParams);
    }

    function morpho_signature() public asActor {

        uint256 authorizerPk = 0xA11CE;
        address authorizer = vm.addr(authorizerPk);

        Authorization memory auth = Authorization({
            authorizer:   authorizer,
            authorized:   address(this),
            isAuthorized: true,
            nonce:        morpho.nonce(authorizer),
            deadline:     block.timestamp + 1 days
        });

        bytes32 AUTHORIZATION_TYPEHASH = keccak256(
            "Authorization(address authorizer,address authorized,bool isAuthorized,uint256 nonce,uint256 deadline)"
        );

        bytes32 hashStruct = keccak256(abi.encode(AUTHORIZATION_TYPEHASH, auth));
        bytes32 digest = keccak256(
            bytes.concat("\x19\x01", morpho.DOMAIN_SEPARATOR(), hashStruct)
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(authorizerPk, digest);
        Signature memory sig = Signature({v: v, r: r, s: s});

        morpho.setAuthorizationWithSig(auth, sig);
    }

    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///

    function morpho_accrueInterest(MarketParams memory marketParams) public asActor {
        morpho.accrueInterest(marketParams);
    }

    function morpho_borrow(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, address receiver) public asActor {
        morpho.borrow(marketParams, assets, shares, onBehalf, receiver);
    }

    function morpho_createMarket(MarketParams memory marketParams) public asActor {
        morpho.createMarket(marketParams);
    }

    function morpho_enableIrm(address irm) public asActor {
        morpho.enableIrm(irm);
    }

    function morpho_enableLltv(uint256 lltv) public asActor {
        morpho.enableLltv(lltv);
    }

    function morpho_flashLoan(address token, uint256 assets, bytes memory data) public asActor {
        morpho.flashLoan(token, assets, data);
    }

    function morpho_liquidate(MarketParams memory marketParams, address borrower, uint256 seizedAssets, uint256 repaidShares, bytes memory data) public asActor {
        morpho.liquidate(marketParams, borrower, seizedAssets, repaidShares, data);
    }

    function morpho_repay(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, bytes memory data) public asActor {
        morpho.repay(marketParams, assets, shares, onBehalf, data);
    }

    function morpho_setAuthorization(address authorized, bool newIsAuthorized) public asActor {
        morpho.setAuthorization(authorized, newIsAuthorized);
    }

    function morpho_setAuthorizationWithSig(Authorization memory authorization, Signature memory signature) public asActor {
        morpho.setAuthorizationWithSig(authorization, signature);
    }

    function morpho_setFee(MarketParams memory marketParams, uint256 newFee) public asActor {
        morpho.setFee(marketParams, newFee);
    }

    function morpho_setFeeRecipient(address newFeeRecipient) public asActor {
        morpho.setFeeRecipient(newFeeRecipient);
    }

    function morpho_setOwner(address newOwner) public asActor {
        morpho.setOwner(newOwner);
    }

    function morpho_supply(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, bytes memory data) public asActor {
        morpho.supply(marketParams, assets, shares, onBehalf, data);
    }

    function morpho_supplyCollateral(MarketParams memory marketParams, uint256 assets, address onBehalf, bytes memory data) public asActor {
        morpho.supplyCollateral(marketParams, assets, onBehalf, data);
    }

    function morpho_withdraw(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, address receiver) public asActor {
        morpho.withdraw(marketParams, assets, shares, onBehalf, receiver);
    }

    function morpho_withdrawCollateral(MarketParams memory marketParams, uint256 assets, address onBehalf, address receiver) public asActor {
        morpho.withdrawCollateral(marketParams, assets, onBehalf, receiver);
    }

    function morpho_extSloads(bytes32[] calldata slots) public asActor() {
        morpho.extSloads(slots);
    }
}