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


import "forge-std/console2.sol";
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

        uint numberOfMarkets = 50;
        uint numberOfPools = 20;

        uint128[] memory poolIds = getPoolIdsArray(numberOfPools);
        bytes32[] memory tokenName =  getTokenNamesArray(numberOfMarkets);
        uint[] memory prices = getPricesArray(numberOfMarkets);
        
        createTokensAndSpotMarkets(accountId, poolIds, tokenName, tokenName, prices);     
    }

    function createTokensAndSpotMarkets(
        uint128 accountId,
        uint128[] memory poolIds,
        bytes32[] memory tokenName,
        bytes32[] memory tokenSymbol,
        uint[] memory prices
    ) internal {
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
                    liquidationRewardD18: 5 ether,
                    minDelegationD18: 5 ether
                }));
                
                
                collateral.approve(synthetixV3, 100 ether);
                uint256 depositAmount =  100 ether / poolIds.length;
                
                for (uint j = 0; j < poolIds.length; j++) {
                    CollateralModule(synthetixV3).deposit(accountId, address(collateral), depositAmount);
                    VaultModule(synthetixV3).delegateCollateral(accountId, poolIds[j], address(collateral), depositAmount, 1 ether);
                }
                

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
        for (uint i = 0; i < poolIds.length; i++) {
            PoolModule(synthetixV3).setPoolConfiguration(poolIds[i], configs); 
        }          
    }

   
    function createOracleNode(uint price) internal returns(bytes32 nodeId, AggregatorV3Mock aggregator) {
        aggregator = new AggregatorV3Mock();
        aggregator.mockSetCurrentPrice(price);
        bytes32[] memory parents;
        nodeId = NodeModule(oracleManager).registerNode(NodeDefinition.NodeType.CHAINLINK, abi.encode(address(aggregator), 0, 18), parents);
    }


    function getTokenNamesArray(uint length) internal returns (bytes32[] memory tokenNames) {
        bytes32[] memory listOfTokenNames = new bytes32[](50);
        require(length <= listOfTokenNames.length, "Invalid length for Token names");

        listOfTokenNames[0] = "ETH";
        listOfTokenNames[1] = "BTC";
        listOfTokenNames[2] = "LINK";
        listOfTokenNames[3] = "BNB";
        listOfTokenNames[4] = "SOL";
        listOfTokenNames[5] = "ADA";
        listOfTokenNames[6] = "DOGE";
        listOfTokenNames[7] = "AAVE";
        listOfTokenNames[8] = "AVAX";
        listOfTokenNames[9] = "UNI";
        listOfTokenNames[10] = "dETH";
        listOfTokenNames[11] = "dBTC";
        listOfTokenNames[12] = "dLINK";
        listOfTokenNames[13] = "dBNB";
        listOfTokenNames[14] = "dSOL";
        listOfTokenNames[15] = "dADA";
        listOfTokenNames[16] = "dDOGE";
        listOfTokenNames[17] = "dAAVE";
        listOfTokenNames[18] = "dAVAX";
        listOfTokenNames[19] = "dUNI";
        listOfTokenNames[20] = "aETH";
        listOfTokenNames[21] = "aBTC";
        listOfTokenNames[22] = "aLINK";
        listOfTokenNames[23] = "aBNB";
        listOfTokenNames[24] = "aSOL";
        listOfTokenNames[25] = "aADA";
        listOfTokenNames[26] = "aDOGE";
        listOfTokenNames[27] = "aAAVE";
        listOfTokenNames[28] = "aAVAX";
        listOfTokenNames[29] = "aUNI";
        listOfTokenNames[30] = "bETH";
        listOfTokenNames[31] = "bBTC";
        listOfTokenNames[32] = "bLINK";
        listOfTokenNames[33] = "bBNB";
        listOfTokenNames[34] = "bSOL";
        listOfTokenNames[35] = "bADA";
        listOfTokenNames[36] = "bDOGE";
        listOfTokenNames[37] = "bAAVE";
        listOfTokenNames[38] = "bAVAX";
        listOfTokenNames[39] = "bUNI";
        listOfTokenNames[40] = "cETH";
        listOfTokenNames[41] = "cBTC";
        listOfTokenNames[42] = "cLINK";
        listOfTokenNames[43] = "cBNB";
        listOfTokenNames[44] = "cSOL";
        listOfTokenNames[45] = "cADA";
        listOfTokenNames[46] = "cDOGE";
        listOfTokenNames[47] = "cAAVE";
        listOfTokenNames[48] = "cAVAX";
        listOfTokenNames[49] = "cUNI";

        bytes32[] memory tokenNames = new bytes32[](length);
        for(uint i = 0; i < length; i++) {
            tokenNames[i] = listOfTokenNames[i];
        }
        return tokenNames;
    }

    function getPricesArray(uint length) internal returns (uint[] memory prices) {
        uint[] memory listOfPrices = new uint[](50);
        require(length <= listOfPrices.length, "Invalid length for Prices");

        listOfPrices[0] = 1000 ether;
        listOfPrices[1] = 50_000 ether;
        listOfPrices[2] = 20 ether;
        listOfPrices[3] = 500 ether;
        listOfPrices[4] = 100 ether;
        listOfPrices[5] = 2 ether;
        listOfPrices[6] = 0.1 ether;
        listOfPrices[7] = 200 ether;
        listOfPrices[8] = 50 ether;
        listOfPrices[9] = 20 ether;
        listOfPrices[10] = 1000 ether;
        listOfPrices[11] = 50_000 ether;
        listOfPrices[12] = 20 ether;
        listOfPrices[13] = 500 ether;
        listOfPrices[14] = 100 ether;
        listOfPrices[15] = 2 ether;
        listOfPrices[16] = 0.1 ether;
        listOfPrices[17] = 200 ether;
        listOfPrices[18] = 50 ether;
        listOfPrices[19] = 20 ether;
        listOfPrices[20] = 1000 ether;
        listOfPrices[21] = 50_000 ether;
        listOfPrices[22] = 20 ether;
        listOfPrices[23] = 500 ether;
        listOfPrices[24] = 100 ether;
        listOfPrices[25] = 2 ether;
        listOfPrices[26] = 0.1 ether;
        listOfPrices[27] = 200 ether;
        listOfPrices[28] = 50 ether;
        listOfPrices[29] = 20 ether;
        listOfPrices[30] = 1000 ether;
        listOfPrices[31] = 50_000 ether;
        listOfPrices[32] = 20 ether;
        listOfPrices[33] = 500 ether;
        listOfPrices[34] = 100 ether;
        listOfPrices[35] = 2 ether;
        listOfPrices[36] = 0.1 ether;
        listOfPrices[37] = 200 ether;
        listOfPrices[38] = 50 ether;
        listOfPrices[39] = 20 ether;
        listOfPrices[40] = 1000 ether;
        listOfPrices[41] = 50_000 ether;
        listOfPrices[42] = 20 ether;
        listOfPrices[43] = 500 ether;
        listOfPrices[44] = 100 ether;
        listOfPrices[45] = 2 ether;
        listOfPrices[46] = 0.1 ether;
        listOfPrices[47] = 200 ether;
        listOfPrices[48] = 50 ether;
        listOfPrices[49] = 20 ether;


        uint[] memory prices = new uint[](length);
        for(uint i = 0; i < length; i++) {
            prices[i] = listOfPrices[i];
        }
        return prices;
    }

    function getPoolIdsArray(uint length) internal returns (uint128[] memory poolIds) {
        uint128[] memory listOfPoolIds = new uint128[](20);
        require(length <= listOfPoolIds.length, "Invalid length for pool Ids");

        listOfPoolIds[0] = 1;
        listOfPoolIds[1] = 2;
        listOfPoolIds[2] = 3;
        listOfPoolIds[3] = 4;
        listOfPoolIds[4] = 5;
        listOfPoolIds[5] = 6;
        listOfPoolIds[6] = 7;
        listOfPoolIds[7] = 8;
        listOfPoolIds[8] = 9;
        listOfPoolIds[9] = 10;
        listOfPoolIds[10] = 11;
        listOfPoolIds[11] = 12;
        listOfPoolIds[12] = 13;
        listOfPoolIds[13] = 14;
        listOfPoolIds[14] = 15;
        listOfPoolIds[15] = 16;
        listOfPoolIds[16] = 17;
        listOfPoolIds[17] = 18;
        listOfPoolIds[18] = 19;
        listOfPoolIds[19] = 20;

        uint128[] memory poolIds = new uint128[](length);
        for(uint i = 0; i < length; i++) {
            PoolModule(synthetixV3).createPool(listOfPoolIds[i], address(this));
            poolIds[i] = listOfPoolIds[i];
        }
        return poolIds;
    }
}
