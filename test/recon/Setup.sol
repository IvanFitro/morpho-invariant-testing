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
import {IIrmMock} from "./mocks/IIrmMock.sol";
import {IMorphoFlashLoanCallbackMock} from "./mocks/IMorphoFlashLoanCallbackMock.sol";
import {IOracleMock} from "./mocks/IOracleMock.sol";

abstract contract Setup is BaseSetup, ActorManager, AssetManager, Utils {
    Morpho morpho;

    IIrmMock iIrmMock;
    IMorphoFlashLoanCallbackMock iMorphoFlashLoanCallbackMock;
    IOracleMock iOracleMock;

    address owner = address(0xABCD);

    MarketParams[] allMarketParams;
    MarketParams activeMarketParams;
    address activeAsset;

    bool hasRepaid;

    /// === Setup === ///
    /// This contains all calls to be performed in the tester constructor, both for Echidna and Foundry
    function setup() internal virtual override {
        morpho = new Morpho(owner);

        // Required mocks
        iIrmMock = new IIrmMock();
        iMorphoFlashLoanCallbackMock = new IMorphoFlashLoanCallbackMock();
        iOracleMock = new IOracleMock();

        // Enable our mock IRM
        vm.prank(owner);
        morpho.enableIrm(address(iIrmMock));

        _addActor(address("Alice"));
        _addActor(address("Bob"));
        _addActor(address("Charlie"));

        _newAsset(18);
        _newAsset(8);
        _newAsset(6);

        address[] memory approvalArray = new address[](1);
        approvalArray[0] = address(morpho);
        _finalizeAssetDeployment(_getActors(), approvalArray, type(uint88).max);
    }

    /// === MODIFIERS === ///
    /// Prank admin and actor

    modifier asAdmin {
        vm.startPrank(owner);
        _;
        vm.stopPrank();
    }

    modifier asActor {
        vm.startPrank(address(_getActor()));
        _;
        vm.stopPrank();
    }

    ///-------------------HELPER FUNCTIONS-------------------

    function add_market(uint256 loanTokenEntropy, uint256 collateralTokenEntropy, uint256 lltv) public {

        require(allMarketParams.length < 5, "Too many markets created"); 

        //loan token
        uint256 assetsLength = _getAssets(  ).length;
        uint256 loanTokenIndex = loanTokenEntropy % assetsLength;
        _switchAsset(loanTokenIndex);
        address loanToken = _getAsset();

        //collateral
        uint256 collateralTokenIndex = collateralTokenEntropy % assetsLength;
        _switchAsset(collateralTokenIndex);
        address collateralToken = _getAsset();

        MarketParams memory marketParams = MarketParams({
            loanToken: loanToken,
            collateralToken: collateralToken,
            oracle: address(iOracleMock),
            irm: address(iIrmMock),
            lltv: lltv
        });

        vm.prank(owner);
        morpho.enableLltv(lltv);

        morpho.createMarket(marketParams);

        allMarketParams.push(marketParams);
    }

    function _switchMarket(uint256 marketEntropy) internal {
        uint256 marketIndex = marketEntropy % allMarketParams.length;
        activeMarketParams = allMarketParams[marketIndex];

        activeAsset = activeMarketParams.loanToken;
    }

    function _getActorThenSwitchActor(uint256 actorEntropy) internal returns (address prevActor) {
        address actor = _getActor();

        uint256 actorIndex = actorEntropy % _getActors().length;
        _switchActor(actorIndex);

        return actor;
    }
}
