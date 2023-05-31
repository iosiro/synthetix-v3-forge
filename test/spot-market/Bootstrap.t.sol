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
        
        // Single Pool
        uint128 poolId = 1;
        PoolModule(synthetixV3).createPool(1, address(this));

        bytes32[] memory tokenNames = new bytes32[](3);
        tokenNames[0] = "ETH";
        tokenNames[1] = "BTC";
        tokenNames[2] = "LINK";
        uint[] memory prices = new uint[](3);
        prices[0] = 1000 ether;
        prices[1] = 50_000 ether;
        prices[2] = 20 ether;

        createTokensAndSpotMarkets(accountId, poolId, tokenNames, tokenNames, prices);     
    }



    function createTokensAndSpotMarkets(uint128 accountId, uint128 poolId, bytes32[] memory tokenName, bytes32[] memory tokenSymbol, uint[] memory prices) internal {
        require(tokenName.length == tokenSymbol.length, "tokenName and tokenSymbol must be the same length");
        require(tokenName.length == prices.length, "tokenName and prices must be the same length");
        uint128[] memory marketIds = new uint128[](tokenName.length);

        MarketConfiguration.Data[] memory configs = new MarketConfiguration.Data[](tokenName.length);

        for (uint i = 0 ; i < tokenName.length; i++) {
            // Setup a collateral vault and pool
            {
                CollateralMock collateral = new CollateralMock();
                collateral.mint(address(this), 1_000_000 ether);

                
                (bytes32 oracleNodeId, AggregatorV3Mock aggregator) = createOracleNode(prices[i]); 
                CollateralConfigurationModule(synthetixV3).configureCollateral(CollateralConfiguration.Data({
                    tokenAddress: address(collateral),
                    depositingEnabled: true,
                    oracleNodeId: oracleNodeId,
                    issuanceRatioD18: 5 ether,
                    liquidationRatioD18: 1.5 ether,
                    liquidationRewardD18: 20 ether,
                    minDelegationD18: 20 ether
                }));
                
                
                collateral.approve(synthetixV3, 100 ether);
                CollateralModule(synthetixV3).deposit(accountId, address(collateral), 100 ether);
                VaultModule(synthetixV3).delegateCollateral(accountId, poolId, address(collateral), 100 ether, 1 ether);

                tokenInfo[tokenName[i]] = TokenInfo({
                    token: IERC20(address(collateral)),
                    oracleNodeId: oracleNodeId,
                    aggregator: aggregator,
                    spotMarketId: 0
                });
            }

            {
                marketIds[i] = SpotMarketFactoryModule(spotMarkets).createSynth(string(abi.encodePacked("s", tokenName[i])), string(abi.encodePacked("s", tokenSymbol[i])), address(this));
                IERC20 synth = IERC20(SpotMarketFactoryModule(spotMarkets).getSynth(marketIds[i]));
                MarketCollateralModule(synthetixV3).configureMaximumMarketCollateral(marketIds[i], address(tokenInfo[tokenName[i]].token), type(uint256).max);
                (bytes32 oracleNodeId, AggregatorV3Mock aggregator) = createOracleNode(prices[i]);
                SpotMarketFactoryModule(spotMarkets).updatePriceData(marketIds[i], oracleNodeId, oracleNodeId); // Buy/Sell the same
                tokenInfo[bytes32(abi.encodePacked("s", tokenName[i]))] = TokenInfo({
                    token: synth,
                    oracleNodeId: oracleNodeId,
                    aggregator: aggregator,
                    spotMarketId: marketIds[i]
                });

                configs[i] = MarketConfiguration.Data({
                    marketId: marketIds[i],
                    weightD18: 1 ether,
                    maxDebtShareValueD18: 1 ether
                });
            }       
        }

        PoolModule(synthetixV3).setPoolConfiguration(poolId, configs);   
    }

   
    function createOracleNode(uint price) internal returns(bytes32 nodeId, AggregatorV3Mock aggregator) {
        aggregator = new AggregatorV3Mock();
        aggregator.mockSetCurrentPrice(price);
        bytes32[] memory parents;
        nodeId = NodeModule(oracleManager).registerNode(NodeDefinition.NodeType.CHAINLINK, abi.encode(address(aggregator), 0, 18), parents);
    }
}