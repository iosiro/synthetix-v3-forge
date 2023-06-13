//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {AccountModule} from "@synthetixio/main/contracts/modules/core/AccountModule.sol";
import {AssociatedSystemsModule} from "@synthetixio/perps-market/contracts/modules/AssociatedSystemsModule.sol";
import {CoreModule} from "@synthetixio/perps-market/contracts/modules/CoreModule.sol";
import {PerpsMarketFactoryModule} from "@synthetixio/perps-market/contracts/modules/PerpsMarketFactoryModule.sol";
import {PerpsAccountModule} from "@synthetixio/perps-market/contracts/modules/PerpsAccountModule.sol";
import {AtomicOrderModule} from "@synthetixio/perps-market/contracts/modules/AtomicOrderModule.sol";
import {AsyncOrderModule} from "@synthetixio/perps-market/contracts/modules/AsyncOrderModule.sol";
import {CollateralModule} from "@synthetixio/perps-market/contracts/modules/CollateralModule.sol";
import {FeatureFlagModule} from "@synthetixio/perps-market/contracts/modules/FeatureFlagModule.sol";
import {LimitOrderModule} from "@synthetixio/perps-market/contracts/modules/LimitOrderModule.sol";
import {LiquidationModule} from "@synthetixio/perps-market/contracts/modules/LiquidationModule.sol";
import {MarketConfigurationModule} from "@synthetixio/perps-market/contracts/modules/MarketConfigurationModule.sol";
import {GlobalPerpsMarketModule} from "@synthetixio/perps-market/contracts/modules/GlobalPerpsMarketModule.sol";

import {Proxy} from "@synthetixio/perps-market/contracts/Proxy.sol";
import {ISynthetixSystem} from "@synthetixio/perps-market/contracts/interfaces/external/ISynthetixSystem.sol";
import {ISpotMarketSystem} from "@synthetixio/perps-market/contracts/interfaces/external/ISpotMarketSystem.sol";

import "src/generated/routers/PerpsMarketRouter.g.sol";

import {SpotMarketDeployment} from "./SpotMarket.t.sol";

import {vm} from "./Vm.t.sol";

import {SpotMarketDeployment} from "./SpotMarket.t.sol";

import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

library PerpsMarketDeployment {
    struct PerpsMarketSystem {
        address core;
        address oracleManager;
        IERC20 snxUSD;
        IERC721 accountNft;
        address accountRouter;
        address spotMarkets;
        address synthRouter;
        address perpsMarket;
    }

    function deploy() internal returns (PerpsMarketSystem memory system) {
        SpotMarketDeployment.SpotMarketSystem memory spotMarketSystem = SpotMarketDeployment.deploy();
        system.accountNft = spotMarketSystem.accountNft;
        system.snxUSD = spotMarketSystem.snxUSD;
        system.core = spotMarketSystem.core;
        system.oracleManager = spotMarketSystem.oracleManager;
        system.spotMarkets = spotMarketSystem.spotMarkets;
        system.synthRouter = spotMarketSystem.synthRouter;
        system.accountRouter = spotMarketSystem.accountRouter;

        vm.etch(_ACCOUNT_MODULE, address(new AccountModule()).code);
        vm.etch(_ASSOCIATED_SYSTEMS_MODULE, address(new AssociatedSystemsModule()).code);
        vm.etch(_CORE_MODULE, address(new CoreModule()).code);
        vm.etch(_PERPS_MARKET_FACTORY_MODULE, address(new PerpsMarketFactoryModule()).code);
        vm.etch(_PERPS_ACCOUNT_MODULE, address(new PerpsAccountModule()).code);
        vm.etch(_ATOMIC_ORDER_MODULE, address(new AtomicOrderModule()).code);
        vm.etch(_ASYNC_ORDER_MODULE, address(new AsyncOrderModule()).code);
        vm.etch(_COLLATERAL_MODULE, address(new CollateralModule()).code);
        vm.etch(_FEATURE_FLAG_MODULE, address(new FeatureFlagModule()).code);
        vm.etch(_LIMIT_ORDER_MODULE, address(new LimitOrderModule()).code);
        vm.etch(_LIQUIDATION_MODULE, address(new LiquidationModule()).code);
        vm.etch(_MARKET_CONFIGURATION_MODULE, address(new MarketConfigurationModule()).code);
        vm.etch(_GLOBAL_PERPS_MARKET_MODULE, address(new GlobalPerpsMarketModule()).code);

        PerpsMarketRouter perpsMarketRouter = new PerpsMarketRouter();
        Proxy perpsMarketRouterProxy = new Proxy(address(perpsMarketRouter), address(this));

        system.perpsMarket = address(perpsMarketRouterProxy);

        PerpsMarketFactoryModule(system.perpsMarket).setSynthetix(ISynthetixSystem(system.core));
        PerpsMarketFactoryModule(system.perpsMarket).setSpotMarket(ISpotMarketSystem(system.spotMarkets));

        AssociatedSystemsModule(system.perpsMarket).initOrUpgradeNft(
            "accountNft", "Perpetual Futures Account", "snxPerpsAcct", "", system.accountRouter
        );

        FeatureFlagModule(system.core).addToFeatureFlagAllowlist("registerMarket", system.perpsMarket);
        FeatureFlagModule(system.core).addToFeatureFlagAllowlist("createMarket", address(this));

        uint128[] memory priorities = new uint128[](1);
        priorities[0] = 0;
        GlobalPerpsMarketModule(system.perpsMarket).setSynthDeductionPriority(priorities);
        //PerpsMarket(perpsMarket).setSystemAddresses(, synthetixV3)
    }
}
