//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {Cannon} from "test/legacy/cannon/Cannon.sol";

import {CoreModule} from "@synthetixio/spot-market/contracts/modules/CoreModule.sol";
import {FeatureFlagModule} from "@synthetixio/spot-market/contracts/modules/FeatureFlagModule.sol";
import {SpotMarketFactoryModule} from "@synthetixio/spot-market/contracts/modules/SpotMarketFactoryModule.sol";
import {AtomicOrderModule} from "@synthetixio/spot-market/contracts/modules/AtomicOrderModule.sol";
import {AsyncOrderModule} from "@synthetixio/spot-market/contracts/modules/AsyncOrderModule.sol";
import {AsyncOrderSettlementModule} from "@synthetixio/spot-market/contracts/modules/AsyncOrderSettlementModule.sol";
import {AsyncOrderConfigurationModule} from
    "@synthetixio/spot-market/contracts/modules/AsyncOrderConfigurationModule.sol";
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
        // [router.SpotMarketRouter]
        Cannon.register(
            "synthetix-spot-market.SpotMarketRouter",
            address(
                new SpotMarketRouter(
                    SpotMarketRouter.Modules({
                        featureFlagModule: address(new FeatureFlagModule()),
                        asyncOrderSettlementModule: address(new AsyncOrderSettlementModule()),
                        wrapperModule: address(new WrapperModule()),
                        spotMarketFactoryModule: address(new SpotMarketFactoryModule()),
                        atomicOrderModule: address(new AtomicOrderModule()),
                        asyncOrderModule: address(new AsyncOrderModule()),
                        coreModule: address(new CoreModule()),
                        asyncOrderConfigurationModule: address(new AsyncOrderConfigurationModule()),
                        marketConfigurationModule: address(new MarketConfigurationModule())
                    })
                )
            )
        );

        // [contract.InitialSpotMarketProxy]
        // [invoke.upgrade_spot_market_proxy]
        Cannon.register(
            "synthetix-spot-market.SpotMarketProxy",
            address(new Proxy(Cannon.resolve("synthetix-spot-market.SpotMarketRouter"), address(this)))
        );

        // [router.SynthRouter]
        Cannon.register(
            "synthetix-spot-market.SynthRouter",
            address(
                new SynthRouter(
                    SynthRouter.Modules({
                        coreModule: address(new CoreModule()),
                        synthTokenModule: address(new SynthTokenModule())
                    })
                )
            )
        );

        // [invoke.addSpotMarketToFeatureFlag]
        FeatureFlagModule(Cannon.resolve("synthetix.CoreProxy")).addToFeatureFlagAllowlist(
            "registerMarket", Cannon.resolve("synthetix-spot-market.SpotMarketProxy")
        );

        // [invoke.addCreateSynthToFeatureFlag]
        FeatureFlagModule(Cannon.resolve("synthetix.CoreProxy")).addToFeatureFlagAllowlist("createSynth", address(this));

        // [contract.FeeCollectorMock]
        Cannon.register("synthetix-spot-market.FeeCollectorMock", address(new FeeCollectorMock()));

        // [contract.MockPythERC7412Wrapper]
        Cannon.register("synthetix-spot-market.MockPythERC7412Wrapper", address(new MockPythERC7412Wrapper()));

        // [invoke.set_usd_token_for_fee_collector]
        FeeCollectorMock(Cannon.resolve("synthetix-spot-market.FeeCollectorMock")).setUsdToken(
            ITokenModule(Cannon.resolve("synthetix.USDProxy"))
        );
    }
}
