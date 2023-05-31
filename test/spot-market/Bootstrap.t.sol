//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import { Test } from "forge-std/Test.sol";
import { SpotMarketDeployment } from "test/deployments/SpotMarket.t.sol";
import "test/deployments/Modules.t.sol";


import { CollateralMock } from "@synthetixio/main/contracts/mocks/CollateralMock.sol";
import { FeeCollectorMock } from "@synthetixio/spot-market/contracts/mocks/FeeCollectorMock.sol";
import { OracleVerifierMock } from "@synthetixio/spot-market/contracts/mocks/OracleVerifierMock.sol";

import { AggregatorV3Mock } from "@synthetixio/main/contracts/mocks/AggregatorV3Mock.sol";
import { CollateralConfiguration } from "@synthetixio/main/contracts/modules/core/CollateralConfigurationModule.sol";
import { NodeDefinition } from "@synthetixio/oracle-manager/contracts/modules/NodeModule.sol";
import { MarketConfiguration } from "@synthetixio/main/contracts/modules/core/PoolModule.sol";

import { IERC20 } from "forge-std/interfaces/IERC20.sol";

contract SpotMarketBootstrap is SpotMarketDeployment  {
   
    FeeCollectorMock feeCollector;
    OracleVerifierMock oracleVerifier;

    struct TokenInfo {
        IERC20 token;
        bytes32 oracleNodeId;
        AggregatorV3Mock aggregator;
        uint128 spotMarketId;
    }

    struct TradersInfo {
        uint128 accountId;
    }
   
    mapping(bytes32 => TokenInfo) internal tokenInfo;

    mapping(address => TradersInfo) internal tradersInfo;

    address[] internal traders;

    function setUp() public virtual override {
        SpotMarketDeployment.setUp();

        feeCollector = new FeeCollectorMock();
        oracleVerifier = new OracleVerifierMock();

        // Give owner permission to create pools
        FeatureFlagModule(synthetixV3).addToFeatureFlagAllowlist("createPool", address(this)); 

        // Setup our account
        uint128 accountId = AccountModule(synthetixV3).createAccount();
        tradersInfo[address(this)] = TradersInfo({
            accountId: accountId
        });
        traders.push(address(this));
        
        // Setup a ETH collateral vault and pool
        {
            CollateralMock collateral = new CollateralMock();
            collateral.mint(address(this), 1_000_000 ether);

            uint128 poolId = 1;
            (bytes32 oracleNodeId, AggregatorV3Mock aggregator) = createOracleNode(2000 ether); // 2000 USD per ETH
            CollateralConfigurationModule(synthetixV3).configureCollateral(CollateralConfiguration.Data({
                tokenAddress: address(collateral),
                depositingEnabled: true,
                oracleNodeId: oracleNodeId,
                issuanceRatioD18: 5 ether,
                liquidationRatioD18: 1.5 ether,
                liquidationRewardD18: 20 ether,
                minDelegationD18: 20 ether
            }));
            PoolModule(synthetixV3).createPool(poolId, address(this));
            
            collateral.approve(synthetixV3, 100 ether);
            CollateralModule(synthetixV3).deposit(accountId, address(collateral), 100 ether);
            VaultModule(synthetixV3).delegateCollateral(accountId, poolId, address(collateral), 100 ether, 1 ether);

            tokenInfo["ETH"] = TokenInfo({
                token: IERC20(address(collateral)),
                oracleNodeId: oracleNodeId,
                aggregator: aggregator,
                spotMarketId: 0
            });
        }

        // Setup ETH Spot Market
        {

            uint128 marketId = SpotMarketFactoryModule(spotMarkets).createSynth("sETH", "sETH", address(this));
            IERC20 sETH = IERC20(SpotMarketFactoryModule(spotMarkets).getSynth(marketId));
            MarketCollateralModule(synthetixV3).configureMaximumMarketCollateral(marketId, address(tokenInfo["ETH"].token), type(uint256).max);
            (bytes32 oracleNodeId, AggregatorV3Mock aggregator) = createOracleNode(2000 ether);
            SpotMarketFactoryModule(spotMarkets).updatePriceData(marketId, oracleNodeId, oracleNodeId); // Buy/Sell the same
            tokenInfo["sETH"] = TokenInfo({
                token: sETH,
                oracleNodeId: oracleNodeId,
                aggregator: aggregator,
                spotMarketId: marketId
            });

           
            MarketConfiguration.Data[] memory configs = new MarketConfiguration.Data[](1);
            configs[0] = MarketConfiguration.Data({
                marketId: marketId,
                weightD18: 1 ether,
                maxDebtShareValueD18: 1 ether
            });
            PoolModule(synthetixV3).setPoolConfiguration(1, configs);
        }

      
    }

   
    function createOracleNode(uint price) internal returns(bytes32 nodeId, AggregatorV3Mock aggregator) {
        aggregator = new AggregatorV3Mock();
        aggregator.mockSetCurrentPrice(price);
        bytes32[] memory parents;
        nodeId = NodeModule(oracleManager).registerNode(NodeDefinition.NodeType.CHAINLINK, abi.encode(address(aggregator), 0, 18), parents);
    }
}