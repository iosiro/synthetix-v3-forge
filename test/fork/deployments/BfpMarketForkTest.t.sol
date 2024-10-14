//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {AccountModule} from "@synthetixio/main/contracts/modules/core/AccountModule.sol";
import {AssociatedSystemsModule} from
    "@synthetixio/main/contracts/modules/associated-systems/AssociatedSystemsModule.sol";
import {CoreModule} from "@synthetixio/bfp-market/contracts/modules/CoreModule.sol";
import {FeatureFlagModule} from "@synthetixio/bfp-market/contracts/modules/FeatureFlagModule.sol";
import {PerpMarketFactoryModule} from "@synthetixio/bfp-market/contracts/modules/PerpMarketFactoryModule.sol";
import {MarketConfigurationModule} from "@synthetixio/bfp-market/contracts/modules/MarketConfigurationModule.sol";
import {PerpAccountModule} from "@synthetixio/bfp-market/contracts/modules/PerpAccountModule.sol";
import {MarginModule} from "@synthetixio/bfp-market/contracts/modules/MarginModule.sol";
import {OrderModule} from "@synthetixio/bfp-market/contracts/modules/OrderModule.sol";
import {LiquidationModule} from "@synthetixio/bfp-market/contracts/modules/LiquidationModule.sol";
import {PerpRewardDistributorFactoryModule} from
    "@synthetixio/bfp-market/contracts/modules/PerpRewardDistributorModule/PerpRewardDistributorFactoryModule.sol";
import {SettlementHookModule} from "@synthetixio/bfp-market/contracts/modules/SettlementHookModule.sol";
import {SplitAccountConfigurationModule} from
    "@synthetixio/bfp-market/contracts/modules/SplitAccountConfigurationModule.sol";

import {BfpMarketRouter, IBfpMarketRouter} from "src/generated/routers/BfpMarketRouter.g.sol";

import {vm} from "test/common/Vm.t.sol";

library BfpMarketForkTest {
    function upgrade(address BFP_MARKET_PROXY, address CORE_PROXY) public {
        BfpMarketRouter bfpMarketRouter = new BfpMarketRouter(
            BfpMarketRouter.Modules({
                accountModule: address(new AccountModule()),
                associatedSystemsModule: address(new AssociatedSystemsModule()),
                coreModule: address(new CoreModule()),
                featureFlagModule: address(new FeatureFlagModule()),
                perpMarketFactoryModule: address(new PerpMarketFactoryModule(CORE_PROXY)),
                marketConfigurationModule: address(new MarketConfigurationModule(CORE_PROXY)),
                perpAccountModule: address(new PerpAccountModule(CORE_PROXY)),
                marginModule: address(new MarginModule(CORE_PROXY)),
                orderModule: address(new OrderModule(CORE_PROXY)),
                liquidationModule: address(new LiquidationModule(CORE_PROXY)),
                perpRewardDistributorFactoryModule: address(new PerpRewardDistributorFactoryModule(CORE_PROXY)),
                settlementHookModule: address(new SettlementHookModule()),
                splitAccountConfigurationModule: address(new SplitAccountConfigurationModule())
            })
        );

        vm.prank(IBfpMarketRouter(BFP_MARKET_PROXY).owner());
        IBfpMarketRouter(BFP_MARKET_PROXY).upgradeTo(address(bfpMarketRouter));
    }
}
