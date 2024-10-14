//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {SpotMarketBootstrapWithMarketBaseTest} from
    "test/legacy/markets/spot-market/common/SpotMarketBootstrapWithMarketBaseTest.t.sol";

import {IAsyncOrderConfigurationModule} from
    "@synthetixio/spot-market/contracts/interfaces/IAsyncOrderConfigurationModule.sol";
import {SettlementStrategy} from "@synthetixio/spot-market/contracts/modules/AsyncOrderConfigurationModule.sol";

import "forge-std/console.sol";

contract AsyncOrderConfigurationModule is SpotMarketBootstrapWithMarketBaseTest {
    SettlementStrategy.Data internal settlementStrategy;

    function setUp() public override {
        super.setUp();

        settlementStrategy = SettlementStrategy.Data({
            strategyType: SettlementStrategy.Type.PYTH,
            settlementDelay: 500,
            settlementWindowDuration: 100,
            priceVerificationContract: 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045,
            feedId: "feedId",
            url: "url",
            settlementReward: 100,
            priceDeviationTolerance: 0.01 ether,
            minimumUsdExchangeAmount: 0.01 ether,
            maxRoundingLoss: 0.0001 ether,
            disabled: true
        });
    }

    function test_adding_strategy() public {
        // fails using non-owner
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("OnlyMarketOwner(address,address)", address(0), user1));
        IAsyncOrderConfigurationModule(address(spotMarketProxy)).addSettlementStrategy(marketId, settlementStrategy);

        // emits event on success
        // vm.expectEmit();
        // emit IAsyncOrderConfigurationModule.SettlementStrategyAdded(marketId, 0);
        // IAsyncOrderConfigurationModule(address(spotMarketProxy)).addSettlementStrategy(marketId, settlementStrategy);
    }
}
