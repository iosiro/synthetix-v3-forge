//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {Cannon} from "test/cannon/Cannon.sol";

import {CoreModule} from "@synthetixio/spot-market/contracts/modules/CoreModule.sol";
import {FeatureFlagModule} from "@synthetixio/spot-market/contracts/modules/FeatureFlagModule.sol";
import {SpotMarketFactoryModule} from "@synthetixio/spot-market/contracts/modules/SpotMarketFactoryModule.sol";
import {AtomicOrderModule} from "@synthetixio/spot-market/contracts/modules/AtomicOrderModule.sol";
import {AsyncOrderModule} from "@synthetixio/spot-market/contracts/modules/AsyncOrderModule.sol";
import {AsyncOrderSettlementModule} from "@synthetixio/spot-market/contracts/modules/AsyncOrderSettlementModule.sol";
import {AsyncOrderConfigurationModule} from "@synthetixio/spot-market/contracts/modules/AsyncOrderConfigurationModule.sol";
import {WrapperModule} from "@synthetixio/spot-market/contracts/modules/WrapperModule.sol";
import {MarketConfigurationModule} from "@synthetixio/spot-market/contracts/modules/MarketConfigurationModule.sol";

import {SynthTokenModule} from "@synthetixio/spot-market/contracts/modules/token/SynthTokenModule.sol";

import {Proxy} from "@synthetixio/spot-market/contracts/Proxy.sol";

import {FeeCollectorMock, ITokenModule} from "@synthetixio/spot-market/contracts/mocks/FeeCollectorMock.sol";
import {MockPythERC7412Wrapper} from "@synthetixio/spot-market/contracts/mocks/MockPythERC7412Wrapper.sol";

import {SpotMarketRouter, ISpotMarketRouter} from "src/generated/routers/SpotMarketRouter.g.sol";
import {SynthRouter} from "src/generated/routers/SynthRouter.g.sol";

library CannonScript {

    function deploy() internal {
      
        // [contract.CoreModule]
        Cannon.register("synthetix-spot-market.CoreModule", address(new CoreModule{salt: 0x00}()));

        // [contract.SpotMarketFactoryModule]
        Cannon.register("synthetix-spot-market.SpotMarketFactoryModule", address(new SpotMarketFactoryModule{salt: 0x00}()));

        // [contract.AtomicOrderModule]
        Cannon.register("synthetix-spot-market.AtomicOrderModule", address(new AtomicOrderModule{salt: 0x00}()));

        // [contract.AsyncOrderModule]
        Cannon.register("synthetix-spot-market.AsyncOrderModule", address(new AsyncOrderModule{salt: 0x00}()));

        // [contract.AsyncOrderSettlementModule]
        Cannon.register("synthetix-spot-market.AsyncOrderSettlementModule", address(new AsyncOrderSettlementModule{salt: 0x00}()));

        // [contract.AsyncOrderConfigurationModule]
        Cannon.register("synthetix-spot-market.AsyncOrderConfigurationModule", address(new AsyncOrderConfigurationModule{salt: 0x00}()));

        // [contract.WrapperModule]
        Cannon.register("synthetix-spot-market.WrapperModule", address(new WrapperModule{salt: 0x00}()));

        // [contract.MarketConfigurationModule]
        Cannon.register("synthetix-spot-market.MarketConfigurationModule", address(new MarketConfigurationModule{salt: 0x00}()));

        // [contract.FeatureFlagModule]
        Cannon.register("synthetix-spot-market.FeatureFlagModule", address(new FeatureFlagModule{salt: 0x00}()));

        // [contract.SynthTokenModule]
        Cannon.register("synthetix-spot-market.SynthTokenModule", address(new SynthTokenModule{salt: 0x00}()));

        // [router.SpotMarketRouter]
        Cannon.register("synthetix-spot-market.SpotMarketRouter", address(new SpotMarketRouter{salt: 0x00}()));

        // [contract.InitialSpotMarketProxy]
        // [invoke.upgrade_spot_market_proxy]
        Cannon.register("synthetix-spot-market.SpotMarketProxy", address(new Proxy{salt: 0x00}(Cannon.resolve("synthetix-spot-market.SpotMarketRouter"), address(this))));
        
        // [router.SynthRouter]
        Cannon.register("synthetix-spot-market.SynthRouter", address(new SynthRouter{salt: 0x00}()));

        // Sanity check
        ISpotMarketRouter spotMarketProxy = ISpotMarketRouter(Cannon.resolve("synthetix-spot-market.SpotMarketProxy"));

        // [invoke.set_synthetix_system]
        spotMarketProxy.setSynthImplementation(Cannon.resolve("synthetix-spot-market.SynthTokenModule"));

        // [invoke.addSpotMarketToFeatureFlag]
        FeatureFlagModule(Cannon.resolve("synthetix.CoreProxy")).addToFeatureFlagAllowlist("registerMarket", Cannon.resolve("synthetix-spot-market.SpotMarketProxy"));

        // [invoke.addCreateSynthToFeatureFlag]
        FeatureFlagModule(Cannon.resolve("synthetix.CoreProxy")).addToFeatureFlagAllowlist("createSynth", address(this));

        // [contract.FeeCollectorMock]
        Cannon.register("synthetix-spot-market.FeeCollectorMock", address(new FeeCollectorMock()));

        // [contract.MockPythERC7412Wrapper]
        Cannon.register("synthetix-spot-market.MockPythERC7412Wrapper", address(new MockPythERC7412Wrapper()));

        // [invoke.set_usd_token_for_fee_collector]
        FeeCollectorMock(Cannon.resolve("synthetix-spot-market.FeeCollectorMock")).setUsdToken(ITokenModule(Cannon.resolve("synthetix.USDProxy")));
    }
}