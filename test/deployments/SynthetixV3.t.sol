//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {InitialModuleBundle} from "@synthetixio/main/contracts/modules/InitialModuleBundle.sol";
import {FeatureFlagModule} from "@synthetixio/main/contracts/modules/core/FeatureFlagModule.sol";
import {AccountModule} from "@synthetixio/main/contracts/modules/core/AccountModule.sol";
import {AssociateDebtModule} from "@synthetixio/main/contracts/modules/core/AssociateDebtModule.sol";
import {AssociatedSystemsModule} from
    "@synthetixio/main/contracts/modules/associated-systems/AssociatedSystemsModule.sol";
import {CollateralModule} from "@synthetixio/main/contracts/modules/core/CollateralModule.sol";
import {CollateralConfigurationModule} from "@synthetixio/main/contracts/modules/core/CollateralConfigurationModule.sol";
import {IssueUSDModule} from "@synthetixio/main/contracts/modules/core/IssueUSDModule.sol";
import {LiquidationModule} from "@synthetixio/main/contracts/modules/core/LiquidationModule.sol";
import {MarketCollateralModule} from "@synthetixio/main/contracts/modules/core/MarketCollateralModule.sol";
import {MarketManagerModule} from "@synthetixio/main/contracts/modules/core/MarketManagerModule.sol";
import {MulticallModule} from "@synthetixio/main/contracts/modules/core/MulticallModule.sol";
import {PoolConfigurationModule} from "@synthetixio/main/contracts/modules/core/PoolConfigurationModule.sol";
import {PoolModule} from "@synthetixio/main/contracts/modules/core/PoolModule.sol";
import {RewardsManagerModule} from "@synthetixio/main/contracts/modules/core/RewardsManagerModule.sol";
import {UtilsModule} from "@synthetixio/main/contracts/modules/core/UtilsModule.sol";
import {VaultModule} from "@synthetixio/main/contracts/modules/core/VaultModule.sol";
import {AccountTokenModule} from "@synthetixio/main/contracts/modules/account/AccountTokenModule.sol";
import {USDTokenModule} from "@synthetixio/main/contracts/modules/usd/USDTokenModule.sol";

import {Proxy} from "@synthetixio/main/contracts/Proxy.sol";
import "src/generated/routers/CoreRouter.g.sol";
import {CoreRouter} from "src/generated/routers/CoreRouter.g.sol";
import {AccountRouter, _ACCOUNT_TOKEN_MODULE} from "src/generated/routers/AccountRouter.g.sol";
import {USDRouter, _USDTOKEN_MODULE} from "src/generated/routers/USDRouter.g.sol";

import {OracleManagerDeployment} from "./OracleManager.t.sol";

import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

import {vm} from "./Vm.t.sol";

library SynthetixV3Deployment {
    struct SynthetixV3System {
        address core;
        address oracleManager;
        IERC20 snxUSD;
        IERC721 accountNft;
        address accountRouter;
        address usdRouter;
    }

    function deploy() internal returns (SynthetixV3System memory system) {
        address oracleManager = OracleManagerDeployment.deploy();

        vm.etch(_INITIAL_MODULE_BUNDLE, address(new InitialModuleBundle()).code);
        vm.etch(_FEATURE_FLAG_MODULE, address(new FeatureFlagModule()).code);
        vm.etch(_ACCOUNT_MODULE, address(new AccountModule()).code);
        vm.etch(_ASSOCIATE_DEBT_MODULE, address(new AssociateDebtModule()).code);
        vm.etch(_ASSOCIATED_SYSTEMS_MODULE, address(new AssociatedSystemsModule()).code);
        vm.etch(_COLLATERAL_MODULE, address(new CollateralModule()).code);
        vm.etch(_COLLATERAL_CONFIGURATION_MODULE, address(new CollateralConfigurationModule()).code);
        vm.etch(_ISSUE_USDMODULE, address(new IssueUSDModule()).code);
        vm.etch(_LIQUIDATION_MODULE, address(new LiquidationModule()).code);
        vm.etch(_MARKET_COLLATERAL_MODULE, address(new MarketCollateralModule()).code);
        vm.etch(_MARKET_MANAGER_MODULE, address(new MarketManagerModule()).code);
        vm.etch(_MULTICALL_MODULE, address(new MulticallModule()).code);
        vm.etch(_POOL_CONFIGURATION_MODULE, address(new PoolConfigurationModule()).code);
        vm.etch(_POOL_MODULE, address(new PoolModule()).code);
        vm.etch(_REWARDS_MANAGER_MODULE, address(new RewardsManagerModule()).code);
        vm.etch(_UTILS_MODULE, address(new UtilsModule()).code);
        vm.etch(_VAULT_MODULE, address(new VaultModule()).code);
        vm.etch(_ACCOUNT_TOKEN_MODULE, address(new AccountTokenModule()).code);
        vm.etch(_USDTOKEN_MODULE, address(new USDTokenModule()).code);

        address coreRouterImpl = address(new CoreRouter());
        address usdRouterImpl = address(new USDRouter());
        address accountRouterImpl = address(new AccountRouter());

        Proxy coreRouterProxy = new Proxy(coreRouterImpl, address(this));
        coreRouterProxy = coreRouterProxy;
        address synthetixV3 = address(coreRouterProxy);

        AssociatedSystemsModule(synthetixV3).initOrUpgradeNft(
            "accountNft", "Synthetix Account", "SACCT", "https://synthetix.io", accountRouterImpl
        );
        AssociatedSystemsModule(synthetixV3).initOrUpgradeToken(
            "USDToken", "Synthetic USD Token v3", "snxUSD", 18, usdRouterImpl
        );
        UtilsModule(synthetixV3).configureOracleManager(address(oracleManager));

        FeatureFlagModule featureFlagModule = FeatureFlagModule(synthetixV3);
        featureFlagModule.setFeatureFlagAllowAll("createAccount", true);
        featureFlagModule.setFeatureFlagAllowAll("deposit", true);
        featureFlagModule.setFeatureFlagAllowAll("withdraw", true);
        featureFlagModule.setFeatureFlagAllowAll("mintUsd", true);
        featureFlagModule.setFeatureFlagAllowAll("burnUsd", true);
        featureFlagModule.setFeatureFlagAllowAll("liquidate", true);
        featureFlagModule.setFeatureFlagAllowAll("liquidateVault", true);
        featureFlagModule.setFeatureFlagAllowAll("depositMarketCollateral", true);
        featureFlagModule.setFeatureFlagAllowAll("withdrawMarketCollateral", true);
        featureFlagModule.setFeatureFlagAllowAll("depositMarketUsd", true);
        featureFlagModule.setFeatureFlagAllowAll("withdrawMarketUsd", true);
        featureFlagModule.setFeatureFlagAllowAll("claimRewards", true);
        featureFlagModule.setFeatureFlagAllowAll("delegateCollateral", true);

        (address addr,) = AssociatedSystemsModule(synthetixV3).getAssociatedSystem("USDToken");
        IERC20 snxUSD = IERC20(addr);

        (addr,) = AssociatedSystemsModule(synthetixV3).getAssociatedSystem("accountNft");
        IERC721 accountNft = IERC721(addr);

        system.core = synthetixV3;
        system.oracleManager = oracleManager;
        system.snxUSD = snxUSD;
        system.accountNft = accountNft;

        system.accountRouter = accountRouterImpl;
        system.usdRouter = usdRouterImpl;
    }
}
