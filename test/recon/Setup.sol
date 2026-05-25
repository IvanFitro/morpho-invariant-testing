// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

// Chimera deps
import {BaseSetup} from "@chimera/BaseSetup.sol";
import {vm} from "@chimera/Hevm.sol";

// Managers
import {ActorManager} from "@recon/ActorManager.sol";
import {AssetManager} from "@recon/AssetManager.sol";

// Helpers
import {Utils} from "@recon/Utils.sol";

// Your deps
import "src/Morpho.sol";
import "src/mocks/IrmMock.sol";
import "src/mocks/OracleMock.sol";
import {ERC20Mock} from "src/mocks/ERC20Mock.sol";
import {MarketParamsLib} from "src/libraries/MarketParamsLib.sol";


abstract contract Setup is BaseSetup, ActorManager, AssetManager, Utils {

    using MarketParamsLib for MarketParams;

    Morpho morpho;
    IrmMock irm;
    OracleMock oracle;
    ERC20Mock asset;
    ERC20Mock liability;

    MarketParams marketParams;
    Id id;

    
    /// === Setup === ///
    /// This contains all calls to be performed in the tester constructor, both for Echidna and Foundry
    function setup() internal virtual override {

        morpho = new Morpho(address(this)); 
        irm = new IrmMock();
        oracle = new OracleMock();
        asset = new ERC20Mock();
        liability = new ERC20Mock();

        morpho.enableIrm(address(irm));
        morpho.enableLltv(0.5e18);

        marketParams = MarketParams({
            loanToken: address(liability),
            collateralToken: address(asset),
            oracle: address(oracle),
            irm: address(irm),
            lltv: 0.5e18
        });

        id = marketParams.id();

        morpho.createMarket(marketParams);

        asset.setBalance(address(this), type(uint88).max);
        liability.setBalance(address(this), type(uint88).max);

        asset.approve(address(morpho), type(uint256).max);
        liability.approve(address(morpho), type(uint256).max);

        oracle.setPrice(1e18);
    }

    /// === MODIFIERS === ///
    /// Prank admin and actor
    
    modifier asAdmin {
        vm.prank(address(this));
        _;
    }

    modifier asActor {
        vm.prank(address(_getActor()));
        _;
    }
}
