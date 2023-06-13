//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "src/generated/routers/SpotMarketRouter.g.sol";

import {
    SpotMarketFactoryModule,
    ISynthetixSystem
} from "@synthetixio/spot-market/contracts/modules/SpotMarketFactoryModule.sol";
import {AtomicOrderModule} from "@synthetixio/spot-market/contracts/modules/AtomicOrderModule.sol";
import {AsyncOrderModule} from "@synthetixio/spot-market/contracts/modules/AsyncOrderModule.sol";
import {AsyncOrderSettlementModule} from "@synthetixio/spot-market/contracts/modules/AsyncOrderSettlementModule.sol";
import {AsyncOrderConfigurationModule} from
    "@synthetixio/spot-market/contracts/modules/AsyncOrderConfigurationModule.sol";
import {WrapperModule} from "@synthetixio/spot-market/contracts/modules/WrapperModule.sol";
import {MarketConfigurationModule} from "@synthetixio/spot-market/contracts/modules/MarketConfigurationModule.sol";
import {FeatureFlagModule} from "@synthetixio/spot-market/contracts/modules/FeatureFlagModule.sol";
import {SynthTokenModule} from "@synthetixio/spot-market/contracts/modules/token/SynthTokenModule.sol";

import {CoreModule} from "@synthetixio/spot-market/contracts/modules/CoreModule.sol";
import {SynthRouter, _SYNTH_TOKEN_MODULE} from "src/generated/routers/SynthRouter.g.sol";

import {Proxy} from "@synthetixio/spot-market/contracts/Proxy.sol";

import {SynthetixV3Deployment} from "./SynthetixV3.t.sol";

import {vm} from "./Vm.t.sol";

import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

library SpotMarketDeployment {
    struct SpotMarketSystem {
        address core;
        address oracleManager;
        IERC20 snxUSD;
        IERC721 accountNft;
        address accountRouter;
        address spotMarkets;
        address synthRouter;
    }

    function deploy() internal returns (SpotMarketSystem memory system) {
        SynthetixV3Deployment.SynthetixV3System memory synthetixV3 = SynthetixV3Deployment.deploy();

        system.core = synthetixV3.core;
        system.oracleManager = synthetixV3.oracleManager;
        system.snxUSD = synthetixV3.snxUSD;
        system.accountNft = synthetixV3.accountNft;
        system.accountRouter = synthetixV3.accountRouter;

        vm.etch(_SPOT_MARKET_FACTORY_MODULE, address(new SpotMarketFactoryModule()).code);
        vm.etch(_ATOMIC_ORDER_MODULE, address(new AtomicOrderModule()).code);
        vm.etch(_ASYNC_ORDER_MODULE, address(new AsyncOrderModule()).code);
        vm.etch(_ASYNC_ORDER_SETTLEMENT_MODULE, address(new AsyncOrderSettlementModule()).code);
        vm.etch(_ASYNC_ORDER_CONFIGURATION_MODULE, address(new AsyncOrderConfigurationModule()).code);
        vm.etch(_CORE_MODULE, address(new CoreModule()).code);
        vm.etch(_FEATURE_FLAG_MODULE, address(new FeatureFlagModule()).code);
        vm.etch(_WRAPPER_MODULE, address(new WrapperModule()).code);
        vm.etch(_MARKET_CONFIGURATION_MODULE, address(new MarketConfigurationModule()).code);
        vm.etch(_SYNTH_TOKEN_MODULE, address(new SynthTokenModule()).code);

        SpotMarketRouter spotMarketRouter = new SpotMarketRouter();
        Proxy spotMarketRouterProxy = new Proxy(address(spotMarketRouter), address(this));
        system.synthRouter = address(new SynthRouter());

        system.spotMarkets = address(spotMarketRouterProxy);

        SpotMarketFactoryModule(system.spotMarkets).setSynthetix(ISynthetixSystem(system.core));
        SpotMarketFactoryModule(system.spotMarkets).setSynthImplementation(system.synthRouter);

        FeatureFlagModule(system.core).addToFeatureFlagAllowlist("registerMarket", system.spotMarkets);
        FeatureFlagModule(system.spotMarkets).addToFeatureFlagAllowlist("createSynth", address(this));
    }
}
