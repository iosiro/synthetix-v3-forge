// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {OwnerModule} from "@synthetixio/core-modules/contracts/modules/OwnerModule.sol";
import {UpgradeModule} from "@synthetixio/core-modules/contracts/modules/UpgradeModule.sol";

import {Proxy} from "@synthetixio/synthetix-main/contracts/Proxy.sol";

import {AccountModule} from "@synthetixio/synthetix-main/contracts/modules/core/AccountModule.sol";
import {LiquidationsModule} from "@synthetixio/synthetix-main/contracts/modules/core/LiquidationModule.sol";
import {PoolModule} from "@synthetixio/synthetix-main/contracts/modules/core/PoolModule.sol";
import {CollateralModule} from "@synthetixio/synthetix-main/contracts/modules/core/CollateralModule.sol";
import {MulticallModule} from "@synthetixio/synthetix-main/contracts/modules/core/MulticallModule.sol";
import {PoolConfigurationModule} from "@synthetixio/synthetix-main/contracts/modules/core/PoolConfigurationModule.sol";
import {AssociatedSystemsModule} from "@synthetixio/synthetix-main/contracts/modules/core/AssociatedSystemsModule.sol";
import {MarketCollateralModule} from "@synthetixio/synthetix-main/contracts/modules/core/MarketCollateralModule.sol";
import {UtilsModule} from "@synthetixio/synthetix-main/contracts/modules/core/UtilsModule.sol";
import {RewardDistributorModule} from "@synthetixio/synthetix-main/contracts/modules/core/RewardDistributorModule.sol";
import {MarketManagerModule} from "@synthetixio/synthetix-main/contracts/modules/core/MarketManagerModule.sol";
import {RewardsManagerModule} from "@synthetixio/synthetix-main/contracts/modules/core/RewardsManagerModule.sol";
import {VaultModule} from "@synthetixio/synthetix-main/contracts/modules/core/VaultModule.sol";

import {AccountTokenModule} from "@synthetixio/synthetix-main/contracts/modules/account/AccountTokenModule.sol";

import {SNXTokenModule} from "@synthetixio/synthetix-main/contracts/modules/snx/SNXTokenModule.sol";
import {USDTokenModule} from "@synthetixio/synthetix-main/contracts/modules/usd/USDTokenModule.sol";
import {ESNXTokenModule} from "@synthetixio/synthetix-main/contracts/modules/esnx/ESNXTokenModule.sol";

import {SNXTokenRouter} from "@synthetixio/router/SNXTokenRouter.sol";
import {USDTokenRouter} from "@synthetixio/router/USDTokenRouter.sol";
import {ESNXTokenRouter} from "@synthetixio/router/ESNXTokenRouter.sol";
import {AccountTokenRouter} from "@synthetixio/router/AccountTokenRouter.sol";

import "@synthetixio/router/Router.sol";

import {AggregatorV3Mock} from "@synthetixio/synthetix-main/contracts/mocks/AggregatorV3Mock.sol";
import {MockMarket} from "@synthetixio/synthetix-main/contracts/mocks/MockMarket.sol";

contract SynthetixV3Test is Test {
    SNXTokenRouter internal snxRouter = new SNXTokenRouter();
    USDTokenRouter internal usdRouter = new USDTokenRouter();
    ESNXTokenRouter internal esnxRouter = new ESNXTokenRouter();
    AccountTokenRouter internal accountRouter = new AccountTokenRouter();

    OwnerModule internal ownerModule;
    UpgradeModule internal upgradeModule;
    AccountModule internal accountModule;
    LiquidationsModule internal liquidationsModule;
    PoolModule internal poolModule;
    CollateralModule internal collateralModule;
    MulticallModule internal multicallModule;
    PoolConfigurationModule internal poolConfigurationModule;
    AssociatedSystemsModule internal associatedSystemsModule;
    MarketCollateralModule internal marketCollateralModule;
    UtilsModule internal utilsModule;
    RewardDistributorModule internal rewardDistributorModule;
    MarketManagerModule internal marketManagerModule;
    RewardsManagerModule internal rewardsManagerModule;
    VaultModule internal vaultModule;

    SNXTokenModule snx;
    USDTokenModule usd;
    ESNXTokenModule esnx;

    Proxy coreProxy;

    MockMarket market;

    function _bootstrap() internal {
        coreProxy = new Proxy(address(new Router()));

        ownerModule = OwnerModule(address(coreProxy));
        upgradeModule = UpgradeModule(address(coreProxy));
        accountModule = AccountModule(address(coreProxy));
        liquidationsModule = LiquidationsModule(address(coreProxy));
        poolModule = PoolModule(address(coreProxy));
        collateralModule = CollateralModule(address(coreProxy));
        multicallModule = MulticallModule(address(coreProxy));
        poolConfigurationModule = PoolConfigurationModule(address(coreProxy));
        associatedSystemsModule = AssociatedSystemsModule(address(coreProxy));
        marketCollateralModule = MarketCollateralModule(address(coreProxy));
        utilsModule = UtilsModule(address(coreProxy));
        rewardDistributorModule = RewardDistributorModule(address(coreProxy));
        marketManagerModule = MarketManagerModule(address(coreProxy));
        rewardsManagerModule = RewardsManagerModule(address(coreProxy));
        vaultModule = VaultModule(address(coreProxy));

        vm.etch(_OWNER_MODULE, address(new OwnerModule()).code);
        vm.etch(_UPGRADE_MODULE, address(new UpgradeModule()).code);

        vm.etch(_SNXTOKEN_MODULE, address(new SNXTokenModule()).code);
        vm.etch(_ESNXTOKEN_MODULE, address(new ESNXTokenModule()).code);
        vm.etch(_USDTOKEN_MODULE, address(new USDTokenModule()).code);
        vm.etch(_ACCOUNT_TOKEN_MODULE, address(new AccountTokenModule()).code);

        vm.etch(_ACCOUNT_MODULE, address(new AccountModule()).code);
        vm.etch(_LIQUIDATIONS_MODULE, address(new LiquidationsModule()).code);
        vm.etch(_POOL_MODULE, address(new PoolModule()).code);
        vm.etch(_COLLATERAL_MODULE, address(new CollateralModule()).code);
        vm.etch(_MULTICALL_MODULE, address(new MulticallModule()).code);
        vm.etch(_POOL_CONFIGURATION_MODULE, address(new PoolConfigurationModule()).code);
        vm.etch(_ASSOCIATED_SYSTEMS_MODULE, address(new AssociatedSystemsModule()).code);
        vm.etch(_MARKET_COLLATERAL_MODULE, address(new MarketCollateralModule()).code);
        vm.etch(_UTILS_MODULE, address(new UtilsModule()).code);
        vm.etch(_REWARD_DISTRIBUTOR_MODULE, address(new RewardDistributorModule()).code);
        vm.etch(_MARKET_MANAGER_MODULE, address(new MarketManagerModule()).code);
        vm.etch(_VAULT_MODULE, address(new VaultModule()).code);

        ownerModule.initializeOwnerModule(address(this));

        associatedSystemsModule.initOrUpgradeNft(
            "accountNft", "Synthetix Account", "SACCT", "https://synthetix.io", address(accountRouter)
        );
        associatedSystemsModule.initOrUpgradeToken("SNXToken", "Synthetix System Token", "SNX", 18, address(snxRouter));
        associatedSystemsModule.initOrUpgradeToken("eSNXToken", "Escrowed SNX", "eSNX", 18, address(esnxRouter));
        associatedSystemsModule.initOrUpgradeToken(
            "USDToken", "Synthetic USD Token v3", "snxUSD", 18, address(usdRouter)
        );

        // mock aggregator
        AggregatorV3Mock snxAggregator = new AggregatorV3Mock();
        snxAggregator.mockSetCurrentPrice(1 ether);

        // bootstrap
        (address snxProxy,) = associatedSystemsModule.getAssociatedSystem("SNXToken");
        (address esnxProxy,) = associatedSystemsModule.getAssociatedSystem("ESNXToken");
        (address usdProxy,) = associatedSystemsModule.getAssociatedSystem("ESNXToken");

        snx = SNXTokenModule(snxProxy);
        esnx = ESNXTokenModule(esnxProxy);
        usd = USDTokenModule(usdProxy);

        collateralModule.configureCollateral(address(snx), address(snxAggregator), 5 ether, 1.5 ether, 20 ether, true);
        utilsModule.mintInitialSystemToken(address(this), 1e6 ether);
    }

    function _bootstrapWithStakedPool() internal {
        _bootstrap();
        // bootstrap with staked pool
        poolModule.createPool(1, address(this));
        accountModule.createAccount(1);
        snx.approve(address(coreProxy), type(uint256).max);
        collateralModule.depositCollateral(1, address(snx), 1000 ether);
        vaultModule.delegateCollateral(1, 1, address(snx), 1000 ether, 1 ether);
    }

    function _bootstrapWithMarket() internal {
        _bootstrapWithStakedPool();

        market = new MockMarket();
        uint256 id = marketManagerModule.registerMarket(address(market));

        market.initialize(address(coreProxy), id, 1 ether);
        uint256[] memory ids = new uint[](1);
        uint256[] memory weights = new uint[](1);
        int256[] memory maxdebts = new int[](1);
        (ids[0], weights[0], maxdebts[0]) = (id, 1 ether, 1 ether);
        poolModule.setPoolConfiguration(1, ids, weights, maxdebts);
    }
}
