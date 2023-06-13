//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {Test} from "forge-std/Test.sol";

import {SynthetixV3Deployment} from "../../deployments/SynthetixV3.t.sol";

import {AccountModule} from "@synthetixio/main/contracts/modules/core/AccountModule.sol";
import {CollateralConfigurationModule} from "@synthetixio/main/contracts/modules/core/CollateralConfigurationModule.sol";
import {CollateralModule} from "@synthetixio/main/contracts/modules/core/CollateralModule.sol";
import {FeatureFlagModule} from "@synthetixio/main/contracts/modules/core/FeatureFlagModule.sol";
import {MarketManagerModule} from "@synthetixio/main/contracts/modules/core/MarketManagerModule.sol";
import {PoolModule} from "@synthetixio/main/contracts/modules/core/PoolModule.sol";
import {VaultModule} from "@synthetixio/main/contracts/modules/core/VaultModule.sol";

import {NodeModule} from "@synthetixio/oracle-manager/contracts/modules/NodeModule.sol";

import {CollateralConfiguration} from "@synthetixio/main/contracts/modules/core/CollateralConfigurationModule.sol";
import {NodeDefinition} from "@synthetixio/oracle-manager/contracts/modules/NodeModule.sol";
import {MarketConfiguration} from "@synthetixio/main/contracts/modules/core/PoolModule.sol";

import {AggregatorV3Mock} from "@synthetixio/main/contracts/mocks/AggregatorV3Mock.sol";
import {CollateralMock} from "@synthetixio/main/contracts/mocks/CollateralMock.sol";
import {MockMarket} from "@synthetixio/main/contracts/mocks/MockMarket.sol";

import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";
import {BaseTest} from "test/BaseTest.t.sol";

contract SynthetixV3Test is BaseTest {
    struct System {
        address synthetix;
        address oracleManager;
        IERC721 account;
        IERC20 snxUSD;
        mapping(bytes32 => CollateralInfo) collateralInfo;
        mapping(address => AccountInfo) accountInfo;
        mapping(uint128 => MarketInfo) marketInfo;
        address[] traders;
        uint128[] pools;
        uint128[] markets;
    }

    struct CollateralInfo {
        CollateralMock token;
        bytes32 oracleNodeId;
        AggregatorV3Mock aggregator;
    }

    struct AccountInfo {
        uint128 accountId;
    }

    struct MarketInfo {
        MockMarket market;
    }

    System internal system;

    function bootstrap() internal {
        SynthetixV3Deployment.SynthetixV3System memory deployment = SynthetixV3Deployment.deploy();
        system.synthetix = deployment.core;
        system.account = deployment.accountNft;
        system.oracleManager = deployment.oracleManager;
        system.snxUSD = deployment.snxUSD;
    }

    function bootstrapWithStakedPool() internal {
        bootstrap();

        FeatureFlagModule(system.synthetix).addToFeatureFlagAllowlist("createPool", address(this));

        CollateralMock collateral = new CollateralMock();

        (bytes32 oracleNodeId, AggregatorV3Mock aggregator) = createOracleNode(1 ether);
        CollateralConfigurationModule(system.synthetix).configureCollateral(
            CollateralConfiguration.Data({
                tokenAddress: address(collateral),
                depositingEnabled: true,
                oracleNodeId: oracleNodeId,
                issuanceRatioD18: 5 ether,
                liquidationRatioD18: 1.5 ether,
                liquidationRewardD18: 20 ether,
                minDelegationD18: 20 ether
            })
        );

        system.collateralInfo["SNX"] =
            CollateralInfo({token: collateral, oracleNodeId: oracleNodeId, aggregator: aggregator});

        uint128 poolId = 1;
        PoolModule(system.synthetix).createPool(poolId, address(this));
        system.pools.push(poolId);

        collateral.mint(address(user1), 1_000_000 ether);

        // Setup our account
        vm.startPrank(user1);
        uint128 accountId = AccountModule(system.synthetix).createAccount();
        system.accountInfo[address(user1)] = AccountInfo({accountId: accountId});
        system.traders.push(address(user1));

        collateral.approve(system.synthetix, 10_000 ether);
        CollateralModule(system.synthetix).deposit(accountId, address(collateral), 1000 ether);
        VaultModule(system.synthetix).delegateCollateral(accountId, poolId, address(collateral), 1000 ether, 1 ether);
        vm.stopPrank();
    }

    function bootstrapWithMockMarketAndPool() internal {
        bootstrapWithStakedPool();

        FeatureFlagModule(system.synthetix).addToFeatureFlagAllowlist("registerMarket", address(this));
        MockMarket market = new MockMarket();

        uint128 marketId = MarketManagerModule(system.synthetix).registerMarket(address(market));
        market.initialize(system.synthetix, marketId, 1 ether);

        MarketConfiguration.Data[] memory config = new MarketConfiguration.Data[](1);
        config[0] = MarketConfiguration.Data({marketId: marketId, weightD18: 1 ether, maxDebtShareValueD18: 10 ether});
        PoolModule(system.synthetix).setPoolConfiguration(system.pools[0], config);

        system.markets.push(marketId);
        system.marketInfo[marketId] = MarketInfo({market: market});
    }

    function createOracleNode(uint256 price) internal returns (bytes32 nodeId, AggregatorV3Mock aggregator) {
        aggregator = new AggregatorV3Mock();
        aggregator.mockSetCurrentPrice(price);
        bytes32[] memory parents;
        nodeId = NodeModule(system.oracleManager).registerNode(
            NodeDefinition.NodeType.CHAINLINK, abi.encode(address(aggregator), 0, 18), parents
        );
    }

    function addCollateral(bytes32 tokenName, bytes32 tokenSymbol, uint256 issuanceRatio, uint256 liquidationRatio)
        internal
        returns (CollateralMock collateral, AggregatorV3Mock aggregator, bytes32 oracleNodeId, uint256 collateralPrice)
    {
        collateralPrice = 1;

        collateral = new CollateralMock();
        collateral.initialize(string(abi.encodePacked(tokenName)), string(abi.encodePacked(tokenSymbol)), 6);

        (oracleNodeId, aggregator) = createOracleNode(collateralPrice);

        CollateralConfigurationModule(system.synthetix).configureCollateral(
            CollateralConfiguration.Data({
                tokenAddress: address(collateral),
                depositingEnabled: true,
                oracleNodeId: oracleNodeId,
                issuanceRatioD18: issuanceRatio,
                liquidationRatioD18: liquidationRatio,
                liquidationRewardD18: 0 ether,
                minDelegationD18: 0 ether
            })
        );

        system.collateralInfo[tokenSymbol] =
            CollateralInfo({token: collateral, oracleNodeId: oracleNodeId, aggregator: aggregator});
    }

    function verifyUsesFeatureFlag(FeatureFlagModule featureModule, address target, bytes memory data, bytes32 flag)
        external
    {
        // disable feature
        featureModule.setFeatureFlagDenyAll(flag, true);

        // it fails with feature unavailable
        vm.expectRevert(abi.encodeWithSignature("FeatureUnavailable(bytes32)", flag));
        (bool success,) = target.call(data);
        assert(success);

        // enable feature
        featureModule.setFeatureFlagDenyAll(flag, false);
    }
}
