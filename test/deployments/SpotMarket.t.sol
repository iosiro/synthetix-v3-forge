//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "src/generated/routers/SpotMarketRouter.g.sol";

import { SpotMarketFactoryModule, ISynthetixSystem } from "@synthetixio/spot-market/contracts/modules/SpotMarketFactoryModule.sol";
import { AtomicOrderModule } from "@synthetixio/spot-market/contracts/modules/AtomicOrderModule.sol";
import { AsyncOrderModule } from "@synthetixio/spot-market/contracts/modules/AsyncOrderModule.sol";
import { AsyncOrderSettlementModule } from "@synthetixio/spot-market/contracts/modules/AsyncOrderSettlementModule.sol";
import { AsyncOrderConfigurationModule } from "@synthetixio/spot-market/contracts/modules/AsyncOrderConfigurationModule.sol";
import { WrapperModule } from "@synthetixio/spot-market/contracts/modules/WrapperModule.sol";
import { MarketConfigurationModule } from "@synthetixio/spot-market/contracts/modules/MarketConfigurationModule.sol";
import { FeatureFlagModule } from "@synthetixio/spot-market/contracts/modules/FeatureFlagModule.sol";
import { SynthTokenModule } from "@synthetixio/spot-market/contracts/modules/token/SynthTokenModule.sol";

import { CoreModule } from "@synthetixio/spot-market/contracts/modules/CoreModule.sol";
import { SynthRouter, _SYNTH_TOKEN_MODULE } from "src/generated/routers/SynthRouter.g.sol";

import { Proxy } from "@synthetixio/spot-market/contracts/Proxy.sol";

import { SynthetixV3Deployment } from "./SynthetixV3.t.sol";

contract SpotMarketDeployment is SynthetixV3Deployment {
   
    address internal spotMarkets;


    function setUp() public virtual override {
        SynthetixV3Deployment.setUp();
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
        SynthRouter synthRouter = new SynthRouter();

        spotMarkets = address(spotMarketRouterProxy);
        
        SpotMarketFactoryModule(spotMarkets).setSynthetix(ISynthetixSystem(synthetixV3));
        SpotMarketFactoryModule(spotMarkets).setSynthImplementation(address(synthRouter));

        FeatureFlagModule(synthetixV3).addToFeatureFlagAllowlist("registerMarket", address(spotMarketRouterProxy));
        FeatureFlagModule(spotMarkets).addToFeatureFlagAllowlist("createSynth", address(this));
    }
}