//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {LegacyMarketDeployment} from "test/deployments/LegacyMarket.t.sol";

import {LegacyMarket} from "@synthetixio/legacy-market/contracts/LegacyMarket.sol";
import {IAddressResolver} from "synthetix/contracts/interfaces/IAddressResolver.sol";

import {IV3CoreProxy} from "@synthetixio/legacy-market/contracts/interfaces/external/IV3CoreProxy.sol";
import {ISynthetixDebtShare} from "synthetix/contracts/interfaces/ISynthetixDebtShare.sol";

import {FeatureFlagModule} from "@synthetixio/perps-market/contracts/modules/FeatureFlagModule.sol";

import {NodeModule} from "@synthetixio/oracle-manager/contracts/modules/NodeModule.sol";
import {NodeDefinition} from "@synthetixio/oracle-manager/contracts/modules/NodeModule.sol";

import {CollateralConfigurationModule} from "@synthetixio/main/contracts/modules/core/CollateralConfigurationModule.sol";
import {CollateralConfiguration} from "@synthetixio/main/contracts/storage/CollateralConfiguration.sol";

import {PoolModule} from "@synthetixio/main/contracts/modules/core/PoolModule.sol";
import {VaultModule} from "@synthetixio/main/contracts/modules/core/VaultModule.sol";

import {MarketConfiguration} from "@synthetixio/main/contracts/modules/core/PoolModule.sol";
import {PoolConfigurationModule} from "@synthetixio/main/contracts/modules/core/PoolConfigurationModule.sol";


import "forge-std/Test.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract ForkTest is Test {
    LegacyMarketDeployment.LegacyMarketSystem internal system;

    address constant _SNX_ADDRESS_RESOLVER = 0x95A6a3f44a70172E7d50a9e28c85Dfd712756B8C;
    address constant _SNX_AGGREGATOR_ADDRESS = 0x2FCF37343e916eAEd1f1DdaaF84458a359b53877;
    address constant _SNX_TOKEN = 0x8700dAec35aF8Ff88c16BdF0418774CB3D7599B4;
    address constant _SUSD_TOKEN = 0x8c6f28f2F1A3C87F0f938b96d27520d9751ec8d9;
    address constant _SNX_OWNER = 0x6d4a64C57612841c2C6745dB2a4E4db34F002D20;
    address constant _SNX_DEBT_SHARE = 0x45c55BF488D3Cb8640f12F63CbeDC027E8261E79;
    address constant _SNX_WHALE_1 = 0x759a159D78342340EbACffB027c05910c093f430; // Under collateralized
    address constant _SNX_WHALE_2 = 0x22866c5c7F2b5475Cff41465C53aA813b4c22B13; // Under collateralized
    address constant _SNX_WHALE_3 = 0xB5A9621B0397Bfc5B45896CaE5998b6111bcDCe6;
    function setUp() public {
        vm.createSelectFork("https://opt-mainnet.g.alchemy.com/v2/HtREH3dtltxWtoyrhdu74TudnnqDlP8-", 105782175);
      
        system = LegacyMarketDeployment.deploy();

        LegacyMarket(system.legacyMarket).setSystemAddresses(IAddressResolver(_SNX_ADDRESS_RESOLVER), IV3CoreProxy(system.core));             
        FeatureFlagModule(system.core).addToFeatureFlagAllowlist("createPool", address(this));
        FeatureFlagModule(system.core).addToFeatureFlagAllowlist("registerMarket", system.legacyMarket);
        FeatureFlagModule(system.core).addToFeatureFlagAllowlist("associateDebt", system.legacyMarket);
        LegacyMarket(system.legacyMarket).registerMarket();

        // Register SNX
        bytes32[] memory parents;
        bytes32 oracleNodeId = NodeModule(system.oracleManager).registerNode(
            NodeDefinition.NodeType.CHAINLINK, abi.encode(_SNX_AGGREGATOR_ADDRESS, 0, 8), parents
        );


        CollateralConfigurationModule(system.core).configureCollateral(
            CollateralConfiguration.Data({
                tokenAddress: _SNX_TOKEN,
                depositingEnabled: true,
                oracleNodeId: oracleNodeId,
                issuanceRatioD18: 3 ether,
                liquidationRatioD18: 2 ether,
                liquidationRewardD18: 1 ether,
                minDelegationD18: 1 ether
            })
        );

      
        bytes32[] memory names = new bytes32[](1);
        address[] memory destinations = new address[](1);
        names[0] = "LegacyMarket";
        destinations[0] = system.legacyMarket;
        
        {
            vm.startPrank(_SNX_OWNER);

            IAddressResolver(_SNX_ADDRESS_RESOLVER).owner();

            IAddressResolver(_SNX_ADDRESS_RESOLVER).importAddresses(
                names,
                destinations
            );

            ISynthetixDebtShare(_SNX_DEBT_SHARE).addAuthorizedBroker(system.legacyMarket);
            vm.stopPrank();
        }

        PoolModule(system.core).createPool(1, address(this));

        MarketConfiguration.Data[] memory config = new MarketConfiguration.Data[](1);
        config[0] = MarketConfiguration.Data({marketId: 1, weightD18: 1 ether, maxDebtShareValueD18: 10 ether});
        PoolModule(system.core).setPoolConfiguration(1, config);

        PoolConfigurationModule(system.core).setPreferredPool(1);
    }   

    function test_basicFork() public {
        IERC20 snx = IERC20(_SNX_TOKEN);
        IERC20 sUSD = IERC20(_SUSD_TOKEN);
        vm.startPrank(_SNX_WHALE_3);
    
        snx.approve(system.legacyMarket, type(uint256).max);
        LegacyMarket(system.legacyMarket).migrate(1);

        VaultModule(system.core).getPosition(1, 1, _SNX_TOKEN);
    }

}