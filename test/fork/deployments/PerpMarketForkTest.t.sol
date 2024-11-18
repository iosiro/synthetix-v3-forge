//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {vm} from "test/common/Vm.t.sol";

import {Proxy} from "@synthetixio/main/contracts/Proxy.sol";

// Shared
import {InitialModuleBundle} from "@synthetixio/main/contracts/modules/InitialModuleBundle.sol";
import {AssociatedSystemsModule} from
    "@synthetixio/main/contracts/modules/associated-systems/AssociatedSystemsModule.sol";
import {AccountModule} from "@synthetixio/main/contracts/modules/core/AccountModule.sol";

import {PerpMarketRouter, IPerpMarketRouter} from "src/generated/routers/PerpMarketRouter.g.sol";

import {CoreModule} from "@synthetixio/perps-market/contracts/modules/CoreModule.sol";
import {PerpsMarketFactoryModule} from "@synthetixio/perps-market/contracts/modules/PerpsMarketFactoryModule.sol";
import {PerpsAccountModule} from "@synthetixio/perps-market/contracts/modules/PerpsAccountModule.sol";
import {PerpsMarketModule} from "@synthetixio/perps-market/contracts/modules/PerpsMarketModule.sol";
import {AsyncOrderModule} from "@synthetixio/perps-market/contracts/modules/AsyncOrderModule.sol";
import {AsyncOrderSettlementPythModule} from
    "@synthetixio/perps-market/contracts/modules/AsyncOrderSettlementPythModule.sol";
import {AsyncOrderCancelModule} from "@synthetixio/perps-market/contracts/modules/AsyncOrderCancelModule.sol";
import {FeatureFlagModule} from "@synthetixio/perps-market/contracts/modules/FeatureFlagModule.sol";
import {LiquidationModule} from "@synthetixio/perps-market/contracts/modules/LiquidationModule.sol";
import {MarketConfigurationModule} from "@synthetixio/perps-market/contracts/modules/MarketConfigurationModule.sol";
import {CollateralConfigurationModule} from
    "@synthetixio/perps-market/contracts/modules/CollateralConfigurationModule.sol";
import {GlobalPerpsMarketModule} from "@synthetixio/perps-market/contracts/modules/GlobalPerpsMarketModule.sol";

library PerpMarketForkTest {
    function upgrade(address PERP_MARKET_PROXY) public {
        PerpMarketRouter perpMarketRouter = new PerpMarketRouter(
            PerpMarketRouter.Modules({
                accountModule: address(new AccountModule()),
                associatedSystemsModule: address(new AssociatedSystemsModule()),
                coreModule: address(new CoreModule()),
                perpsMarketFactoryModule: address(new PerpsMarketFactoryModule()),
                perpsAccountModule: address(new PerpsAccountModule()),
                perpsMarketModule: address(new PerpsMarketModule()),
                asyncOrderModule: address(new AsyncOrderModule()),
                asyncOrderSettlementPythModule: address(new AsyncOrderSettlementPythModule()),
                asyncOrderCancelModule: address(new AsyncOrderCancelModule()),
                featureFlagModule: address(new FeatureFlagModule()),
                liquidationModule: address(new LiquidationModule()),
                marketConfigurationModule: address(new MarketConfigurationModule()),
                collateralConfigurationModule: address(new CollateralConfigurationModule()),
                globalPerpsMarketModule: address(new GlobalPerpsMarketModule())
            })
        );

        vm.prank(IPerpMarketRouter(PERP_MARKET_PROXY).owner());
        IPerpMarketRouter(PERP_MARKET_PROXY).upgradeTo(address(perpMarketRouter));
    }
}
