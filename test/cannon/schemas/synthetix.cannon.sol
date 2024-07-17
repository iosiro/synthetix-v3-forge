//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {Cannon} from "test/cannon/Cannon.sol";

import {Proxy} from "@synthetixio/main/contracts/Proxy.sol";

// Shared
import {InitialModuleBundle} from "@synthetixio/main/contracts/modules/InitialModuleBundle.sol";
import {AssociatedSystemsModule} from "@synthetixio/main/contracts/modules/associated-systems/AssociatedSystemsModule.sol";

// CoreRouter
import {FeatureFlagModule} from "@synthetixio/main/contracts/modules/core/FeatureFlagModule.sol";
import {AccountModule} from "@synthetixio/main/contracts/modules/core/AccountModule.sol";
import {AssociateDebtModule} from "@synthetixio/main/contracts/modules/core/AssociateDebtModule.sol";
import {CcipReceiverModule} from "@synthetixio/main/contracts/modules/core/CcipReceiverModule.sol";
import {CollateralModule} from "@synthetixio/main/contracts/modules/core/CollateralModule.sol";
import {CollateralConfigurationModule} from "@synthetixio/main/contracts/modules/core/CollateralConfigurationModule.sol";
import {CrossChainUSDModule} from "@synthetixio/main/contracts/modules/core/CrossChainUSDModule.sol";
import {IssueUSDModule} from "@synthetixio/main/contracts/modules/core/IssueUSDModule.sol";
import {LiquidationModule} from "@synthetixio/main/contracts/modules/core/LiquidationModule.sol";
import {MarketCollateralModule} from "@synthetixio/main/contracts/modules/core/MarketCollateralModule.sol";
import {MarketManagerModule} from "@synthetixio/main/contracts/modules/core/MarketManagerModule.sol";
import {PoolConfigurationModule} from "@synthetixio/main/contracts/modules/core/PoolConfigurationModule.sol";
import {PoolModule} from "@synthetixio/main/contracts/modules/core/PoolModule.sol";
import {RewardsManagerModule} from "@synthetixio/main/contracts/modules/core/RewardsManagerModule.sol";
import {UtilsModule} from "@synthetixio/main/contracts/modules/core/UtilsModule.sol";
import {VaultModule} from "@synthetixio/main/contracts/modules/core/VaultModule.sol";

// AccountRouter
import {AccountTokenModule} from "@synthetixio/main/contracts/modules/account/AccountTokenModule.sol";

// USDRouter
import {USDTokenModule} from "@synthetixio/main/contracts/modules/usd/USDTokenModule.sol";


import {CoreRouter, ICoreRouter} from "src/generated/routers/CoreRouter.g.sol";
import {AccountRouter, IAccountRouter} from "src/generated/routers/AccountRouter.g.sol";
import {USDRouter} from "src/generated/routers/USDRouter.g.sol";

import {IOracleManagerRouter} from "src/generated/routers/OracleManagerRouter.g.sol";


library CannonScript {
    function deploy() internal {
        // [router.CoreRouter]
        new InitialModuleBundle{salt: 0x00}();
        new FeatureFlagModule{salt: 0x00}();
        new AccountModule{salt: 0x00}();
        new AssociateDebtModule{salt: 0x00}();
        new CcipReceiverModule{salt: 0x00}();
        new CollateralModule{salt: 0x00}();
        new CollateralConfigurationModule{salt: 0x00}();
        new CrossChainUSDModule{salt: 0x00}();
        new IssueUSDModule{salt: 0x00}();
        new LiquidationModule{salt: 0x00}();
        new MarketCollateralModule{salt: 0x00}();
        new MarketManagerModule{salt: 0x00}();
        new PoolConfigurationModule{salt: 0x00}();
        new PoolModule{salt: 0x00}();
        new RewardsManagerModule{salt: 0x00}();
        new UtilsModule{salt: 0x00}();
        new VaultModule{salt: 0x00}();
        new AssociatedSystemsModule{salt: 0x00}();

        // [invoke.upgrade_core_proxy]
        Cannon.register("synthetix.CoreProxy", address(new Proxy{salt: 0x00}(address(new CoreRouter()), address(this))));

        // [router.AccountRouter]
        new AccountTokenModule{salt: 0x00}();
        AccountRouter accountRouter = new AccountRouter{salt: 0x00}();
      
        // [router.USDRouter]
        new USDTokenModule{salt: 0x00}();
        USDRouter usdRouter = new USDRouter{salt: 0x00}();

        ICoreRouter coreProxy = ICoreRouter(Cannon.resolve("synthetix.CoreProxy"));
        IOracleManagerRouter oracleManager = IOracleManagerRouter(Cannon.resolve("oracle-manager.Proxy"));

        // [invoke.init_account]
        
        coreProxy.initOrUpgradeNft("accountNft", "Synthetix Account", "SACCT", "https://synthetix.io", address(accountRouter));
        IAccountRouter accountProxy = IAccountRouter(coreProxy.getAccountTokenAddress());
        Cannon.register("synthetix.AccountProxy", address(accountProxy));

        // [invoke.init_usd]
        coreProxy.initOrUpgradeToken("USDToken", "Synthetic USD Token v3", "snxUSD", 18, address(usdRouter));
        USDRouter usdProxy = USDRouter(payable(coreProxy.getUsdToken()));
        Cannon.register("synthetix.USDProxy", address(usdProxy));

        // [invoke.set_oracle_manager]
        coreProxy.configureOracleManager(address(oracleManager));

        // [invoke.enable_feature_createAccount]
        coreProxy.setFeatureFlagAllowAll("createAccount", true);

        // [invoke.enable_feature_deposit]
        coreProxy.setFeatureFlagAllowAll("deposit", true);

        // [invoke.enable_feature_withdraw]
        coreProxy.setFeatureFlagAllowAll("withdraw", true);

        // [invoke.enable_feature_mintUsd]
        coreProxy.setFeatureFlagAllowAll("mintUsd", true);

        // [invoke.enable_feature_burnUsd]
        coreProxy.setFeatureFlagAllowAll("burnUsd", true);

        // [invoke.enable_feature_liquidate]
        coreProxy.setFeatureFlagAllowAll("liquidate", true);

        // [invoke.enable_feature_liquidateVault]
        coreProxy.setFeatureFlagAllowAll("liquidateVault", true);

        // [invoke.enable_feature_depositMarketCollateral]
        coreProxy.setFeatureFlagAllowAll("depositMarketCollateral", true);

        // [invoke.enable_feature_withdrawMarketCollateral]
        coreProxy.setFeatureFlagAllowAll("withdrawMarketCollateral", true);

        // [invoke.enable_feature_depositMarketUsd]
        coreProxy.setFeatureFlagAllowAll("depositMarketUsd", true);

        // [invoke.enable_feature_withdrawMarketUsd]
        coreProxy.setFeatureFlagAllowAll("withdrawMarketUsd", true);

        // [invoke.enable_feature_claimRewards]
        coreProxy.setFeatureFlagAllowAll("claimRewards", true);

        // [invoke.enable_feature_delegateCollateral]
        coreProxy.setFeatureFlagAllowAll("delegateCollateral", true);

        // [invoke.register_const_one_oracle]
        bytes32 const_one_oracle_id;
        {
            bytes32[] memory args;
            const_one_oracle_id = oracleManager.registerNode(IOracleManagerRouter.NodeType.wrap(8), abi.encode([uint256(1 ether)]), args);
        }

        // [invoke.configure_usd_collateral]
        {
            coreProxy.configureCollateral(ICoreRouter.Data({
                tokenAddress: Cannon.resolve("synthetix.USDProxy"), 
                oracleNodeId: const_one_oracle_id,
                issuanceRatioD18: 10 ether,
                liquidationRatioD18: 10 ether,
                liquidationRewardD18: 0,
                minDelegationD18: type(uint256).max,
                depositingEnabled: true
            }));
        }
    }
}