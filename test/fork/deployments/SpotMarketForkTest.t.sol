//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {CoreModule} from "@synthetixio/spot-market/contracts/modules/CoreModule.sol";
import {SpotMarketFactoryModule} from "@synthetixio/spot-market/contracts/modules/SpotMarketFactoryModule.sol";
import {AtomicOrderModule} from "@synthetixio/spot-market/contracts/modules/AtomicOrderModule.sol";
import {AsyncOrderModule} from "@synthetixio/spot-market/contracts/modules/AsyncOrderModule.sol";
import {AsyncOrderSettlementModule} from "@synthetixio/spot-market/contracts/modules/AsyncOrderSettlementModule.sol";
import {AsyncOrderConfigurationModule} from
    "@synthetixio/spot-market/contracts/modules/AsyncOrderConfigurationModule.sol";
import {WrapperModule} from "@synthetixio/spot-market/contracts/modules/WrapperModule.sol";
import {MarketConfigurationModule} from "@synthetixio/spot-market/contracts/modules/MarketConfigurationModule.sol";
import {FeatureFlagModule} from "@synthetixio/spot-market/contracts/modules/FeatureFlagModule.sol";

import {SpotMarketRouter, ISpotMarketRouter} from "src/generated/routers/SpotMarketRouter.g.sol";

import {vm} from "test/common/Vm.t.sol";

library SpotMarketForkTest {
    function upgrade(address SPOT_MARKET_PROXY) public {
        SpotMarketRouter spotMarketRouter = new SpotMarketRouter(
            SpotMarketRouter.Modules({
                coreModule: address(new CoreModule()),
                spotMarketFactoryModule: address(new SpotMarketFactoryModule()),
                atomicOrderModule: address(new AtomicOrderModule()),
                asyncOrderModule: address(new AsyncOrderModule()),
                asyncOrderSettlementModule: address(new AsyncOrderSettlementModule()),
                asyncOrderConfigurationModule: address(new AsyncOrderConfigurationModule()),
                wrapperModule: address(new WrapperModule()),
                marketConfigurationModule: address(new MarketConfigurationModule()),
                featureFlagModule: address(new FeatureFlagModule())
            })
        );

        vm.prank(ISpotMarketRouter(SPOT_MARKET_PROXY).owner());
        ISpotMarketRouter(SPOT_MARKET_PROXY).upgradeTo(address(spotMarketRouter));
    }
}
