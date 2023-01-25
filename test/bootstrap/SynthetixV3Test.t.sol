// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {InitialModuleBundle} from "@synthetixio/main/contracts/modules/InitialModuleBundle.sol";

import {Proxy} from "@synthetixio/main/contracts/Proxy.sol";

import {AccountModule} from "@synthetixio/main/contracts/modules/core/AccountModule.sol";
import {AssociatedSystemsModule} from
    "@synthetixio/main/contracts/modules/associated-systems/AssociatedSystemsModule.sol";

import {
    CollateralConfigurationModule,
    CollateralConfiguration
} from "@synthetixio/main/contracts/modules/core/CollateralConfigurationModule.sol";
import {CollateralModule} from "@synthetixio/main/contracts/modules/core/CollateralModule.sol";
import {FeatureFlagModule} from "@synthetixio/main/contracts/modules/core/FeatureFlagModule.sol";
import {IssueUSDModule} from "@synthetixio/main/contracts/modules/core/IssueUSDModule.sol";
import {LiquidationModule} from "@synthetixio/main/contracts/modules/core/LiquidationModule.sol";
import {MarketCollateralModule} from "@synthetixio/main/contracts/modules/core/MarketCollateralModule.sol";
import {MarketManagerModule} from "@synthetixio/main/contracts/modules/core/MarketManagerModule.sol";
import {MulticallModule} from "@synthetixio/main/contracts/modules/core/MulticallModule.sol";
import {PoolConfigurationModule} from "@synthetixio/main/contracts/modules/core/PoolConfigurationModule.sol";
import {PoolModule, MarketConfiguration} from "@synthetixio/main/contracts/modules/core/PoolModule.sol";
import {RewardsManagerModule} from "@synthetixio/main/contracts/modules/core/RewardsManagerModule.sol";
import {UtilsModule} from "@synthetixio/main/contracts/modules/core/UtilsModule.sol";
import {VaultModule} from "@synthetixio/main/contracts/modules/core/VaultModule.sol";

import {USDTokenModule} from "@synthetixio/main/contracts/modules/usd/USDTokenModule.sol";
import {TokenModule} from "@synthetixio/core-modules/contracts/modules/TokenModule.sol";

import {AccountTokenModule} from "@synthetixio/main/contracts/modules/account/AccountTokenModule.sol";
import {NodeModule, NodeDefinition} from "@synthetixio/oracle-manager/contracts/modules/NodeModule.sol";
import {CoreModule} from "@synthetixio/oracle-manager/contracts/modules/CoreModule.sol";

import {CoreRouter} from "src/routers/CoreRouter.sol";
import {USDRouter} from "src/routers/USDRouter.sol";
import {AccountRouter} from "src/routers/AccountRouter.sol";
import {OracleRouter} from "src/routers/OracleRouter.sol";

import "src/routers/Routes.sol";

import {AggregatorV3Mock} from "@synthetixio/main/contracts/mocks/AggregatorV3Mock.sol";
import {MockMarket} from "@synthetixio/main/contracts/mocks/MockMarket.sol";
import {CollateralMock} from "@synthetixio/main/contracts/mocks/CollateralMock.sol";

import {IAggregatorV3Interface} from "@synthetixio/main/contracts/interfaces/external/IAggregatorV3Interface.sol";

import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract SynthetixV3Test is Test {
   
    USDRouter internal usdRouter = new USDRouter();
 
    Proxy internal accountRouter;

    InitialModuleBundle internal initialModuleBundle;

    AccountModule internal accountModule;
    AssociatedSystemsModule internal associatedSystemsModule;
    CollateralConfigurationModule internal collateralConfigurationModule;
    CollateralModule internal collateralModule;
    FeatureFlagModule internal featureFlagModule;
    IssueUSDModule internal issueUSDModule;
    LiquidationModule internal liquidationModule;
    MarketManagerModule internal marketManagerModule;
    MarketCollateralModule internal marketCollateralModule;
    MulticallModule internal multicallModule;
    PoolConfigurationModule internal poolConfigurationModule;
    PoolModule internal poolModule;
    RewardsManagerModule internal rewardsManagerModule;
    UtilsModule internal utilsModule;
    VaultModule internal vaultModule;

    NodeModule internal nodeModule;

    IERC20 internal snx;
    USDTokenModule internal usd;
   
    AccountTokenModule internal accountTokenModule;

    Proxy coreProxy;

    MockMarket market;

    AggregatorV3Mock snxAggregator;

    mapping(address => IAggregatorV3Interface) internal aggregators;

    function _bootstrap() internal {

        vm.etch(_ACCOUNT_TOKEN_MODULE, address(new AccountTokenModule()).code);
        vm.etch(_INITIAL_MODULE_BUNDLE, address(new InitialModuleBundle()).code);
       
        vm.etch(_ACCOUNT_MODULE, address(new AccountModule()).code);
        vm.etch(_ASSOCIATED_SYSTEMS_MODULE, address(new AssociatedSystemsModule()).code);
        vm.etch(_COLLATERAL_MODULE, address(new CollateralModule()).code);
        vm.etch(_COLLATERAL_CONFIGURATION_MODULE, address(new CollateralConfigurationModule()).code);
        vm.etch(_FEATURE_FLAG_MODULE, address(new FeatureFlagModule()).code);
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

        vm.etch(_USDTOKEN_MODULE, address(new USDTokenModule()).code);

        vm.etch(_NODE_MODULE, address(new NodeModule()).code);
        vm.etch(_CORE_MODULE, address(new CoreModule()).code);

        coreProxy = new Proxy(address(new CoreRouter()), address(this));
        InitialModuleBundle(address(coreProxy)).initializeOwnerModule(address(this));

        {
            Proxy proxy = new Proxy(address(new OracleRouter()), address(this));
            nodeModule = NodeModule(address(proxy));
        }

        accountModule = AccountModule(address(coreProxy));
        associatedSystemsModule = AssociatedSystemsModule(address(coreProxy));
        collateralConfigurationModule = CollateralConfigurationModule(address(coreProxy));
        collateralModule = CollateralModule(address(coreProxy));
        featureFlagModule = FeatureFlagModule(address(coreProxy));
        issueUSDModule = IssueUSDModule(address(coreProxy));
        liquidationModule = LiquidationModule(address(coreProxy));
        poolModule = PoolModule(address(coreProxy));   
        multicallModule = MulticallModule(address(coreProxy));
        poolConfigurationModule = PoolConfigurationModule(address(coreProxy));
        utilsModule = UtilsModule(address(coreProxy));
        rewardsManagerModule = RewardsManagerModule(address(coreProxy));
        marketCollateralModule = MarketCollateralModule(address(coreProxy));
        marketManagerModule = MarketManagerModule(address(coreProxy));
        vaultModule = VaultModule(address(coreProxy));


        

        associatedSystemsModule.initOrUpgradeToken(
            "USDToken", "Synthetic USD Token v3", "snxUSD", 18, address(usdRouter)
        );
        associatedSystemsModule.initOrUpgradeNft("accountNft", "Synthetix Account", "SACCT", "https://synthetix.io", address(new AccountRouter()));

        (address token, ) = associatedSystemsModule.getAssociatedSystem("USDToken");

        usd = USDTokenModule(token);
       
        featureFlagModule.addToFeatureFlagAllowlist("createPool", address(this));
        featureFlagModule.addToFeatureFlagAllowlist("registerMarket", address(this));

        {
            CollateralMock mockToken = new CollateralMock();
            mockToken.initialize("SNX", "SNX", 18);
            mockToken.mint(address(this), 1_000_000 ether);
            snx = IERC20(address(mockToken));
        }
       
        snxAggregator = new AggregatorV3Mock();
        snxAggregator.mockSetCurrentPrice(1 ether);



        utilsModule.configureOracleManager(address(nodeModule));

        bytes32[] memory parents;
        bytes32 nodeId = nodeModule.registerNode(NodeDefinition.NodeType.CHAINLINK, abi.encode(address(snxAggregator), 0, 18), parents);

        collateralConfigurationModule.configureCollateral(CollateralConfiguration.Data({
            tokenAddress: address(snx),
            oracleNodeId: nodeId,
            depositingEnabled: true,
            issuanceRatioD18: 5 ether,
            liquidationRatioD18: 1.5 ether,
            liquidationRewardD18: 20 ether,
            minDelegationD18: 20 ether
        }));

        //poolModule.setMinLiquidityRatio(2 ether);
        
    }

    function _bootstrapWithStakedPool() internal {
        _bootstrap();
        // bootstrap with staked pool
        poolModule.createPool(1, address(this));
        accountModule.createAccount(1);
        snx.approve(address(coreProxy), type(uint256).max);
        collateralModule.deposit(1, address(snx), 100 ether);
        vaultModule.delegateCollateral(1, 1, address(snx), 100 ether, 1 ether);
    }

    function _bootstrapWithMarket() internal {
        _bootstrapWithStakedPool();

        market = new MockMarket();
        uint128 id = uint128(marketManagerModule.registerMarket(address(market)));

        market.initialize(address(coreProxy), id, 1 ether);
        
        MarketConfiguration.Data[] memory markets = new  MarketConfiguration.Data[](1);
        markets[0] = MarketConfiguration.Data({
            marketId: id,
            weightD18: 1 ether,
            maxDebtShareValueD18: 1 ether 
        });
        poolModule.setPoolConfiguration(1, markets);
        marketCollateralModule.configureMaximumMarketCollateral(id, address(snx), 10000 ether);
        
    }
}
