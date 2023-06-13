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

import {MarketConfiguration} from "@synthetixio/main/contracts/modules/core/PoolModule.sol";

import {AggregatorV3Mock} from "@synthetixio/main/contracts/mocks/AggregatorV3Mock.sol";
import {CollateralMock} from "@synthetixio/main/contracts/mocks/CollateralMock.sol";
import {MockMarket} from "@synthetixio/main/contracts/mocks/MockMarket.sol";

import "forge-std/console2.sol";

contract ManyToManyTest is SynthetixV3Test {
    function setUp() public {
        bootstrap();
        FeatureFlagModule(system.synthetix).addToFeatureFlagAllowlist("createPool", address(this));
        FeatureFlagModule(system.synthetix).addToFeatureFlagAllowlist("registerMarket", address(this));

        // Add another collateral
        addCollateral("SNX", "SNX", 5 ether, 1.5 ether);
        addCollateral("wETH", "wETH", 5 ether, 1.5 ether);

        CollateralMock(system.collateralInfo["SNX"].token).mint(user1, 1_000_000 ether);
        CollateralMock(system.collateralInfo["SNX"].token).mint(user2, 1_000_000 ether);

        CollateralMock(system.collateralInfo["wETH"].token).mint(user1, 1_000 ether);
        CollateralMock(system.collateralInfo["wETH"].token).mint(user2, 1_000 ether);

        system.collateralInfo["SNX"].aggregator.mockSetCurrentPrice(2 ether); // SNX is $2
        system.collateralInfo["wETH"].aggregator.mockSetCurrentPrice(1800 ether); // wETH is $1800

        // Add pools
        uint128 poolId = 1;
        PoolModule(system.synthetix).createPool(poolId, address(this));
        system.pools.push(poolId);

        PoolModule(system.synthetix).createPool(++poolId, address(this));
        system.pools.push(poolId);

        // Add markets
        MockMarket market = new MockMarket();
        uint128 marketId = MarketManagerModule(system.synthetix).registerMarket(address(market));
        market.initialize(system.synthetix, marketId, 1 ether);
        system.markets.push(marketId);
        system.marketInfo[marketId] = SynthetixV3Test.MarketInfo({market: market});

        market = new MockMarket();
        marketId = MarketManagerModule(system.synthetix).registerMarket(address(market));
        market.initialize(system.synthetix, marketId, 1 ether);
        system.markets.push(marketId);
        system.marketInfo[marketId] = SynthetixV3Test.MarketInfo({market: market});

        vm.startPrank(user1);
        uint128 accountId = AccountModule(system.synthetix).createAccount();
        system.accountInfo[address(user1)] = AccountInfo({accountId: accountId});
        system.traders.push(address(user1));
        vm.stopPrank();

        vm.startPrank(user2);
        accountId = AccountModule(system.synthetix).createAccount();
        system.accountInfo[address(user2)] = AccountInfo({accountId: accountId});
        system.traders.push(address(user2));
        vm.stopPrank();

        // Configure first pool
        {
            MarketConfiguration.Data[] memory config = new MarketConfiguration.Data[](2);
            config[0] = MarketConfiguration.Data({
                marketId: system.markets[0],
                weightD18: 0.6 ether,
                maxDebtShareValueD18: 10 ether
            });
            config[1] = MarketConfiguration.Data({
                marketId: system.markets[1],
                weightD18: 0.4 ether,
                maxDebtShareValueD18: 10 ether
            });
            PoolModule(system.synthetix).setPoolConfiguration(system.pools[0], config);
        }

        // Configure second Pool
        {
            MarketConfiguration.Data[] memory config = new MarketConfiguration.Data[](2);
            config[0] = MarketConfiguration.Data({
                marketId: system.markets[0],
                weightD18: 0.3 ether,
                maxDebtShareValueD18: 10 ether
            });
            config[1] = MarketConfiguration.Data({
                marketId: system.markets[1],
                weightD18: 0.7 ether,
                maxDebtShareValueD18: 10 ether
            });
            PoolModule(system.synthetix).setPoolConfiguration(system.pools[1], config);
        }

        // Delegate collateral
        {
            vm.startPrank(user1);
            system.collateralInfo["SNX"].token.approve(address(system.synthetix), type(uint256).max);
            system.collateralInfo["wETH"].token.approve(address(system.synthetix), type(uint256).max);
            CollateralModule(system.synthetix).deposit(
                system.accountInfo[address(user1)].accountId, address(system.collateralInfo["SNX"].token), 100_000 ether
            );
            CollateralModule(system.synthetix).deposit(
                system.accountInfo[address(user1)].accountId, address(system.collateralInfo["wETH"].token), 500 ether
            );

            VaultModule(system.synthetix).delegateCollateral(
                system.accountInfo[user1].accountId,
                system.pools[0],
                address(system.collateralInfo["SNX"].token),
                10_000 ether,
                1 ether
            );
            VaultModule(system.synthetix).delegateCollateral(
                system.accountInfo[user1].accountId,
                system.pools[0],
                address(system.collateralInfo["wETH"].token),
                200 ether,
                1 ether
            );
            VaultModule(system.synthetix).delegateCollateral(
                system.accountInfo[user1].accountId,
                system.pools[1],
                address(system.collateralInfo["SNX"].token),
                50_000 ether,
                1 ether
            );
            VaultModule(system.synthetix).delegateCollateral(
                system.accountInfo[user1].accountId,
                system.pools[1],
                address(system.collateralInfo["wETH"].token),
                50 ether,
                1 ether
            );
            vm.stopPrank();
        }

        {
            vm.startPrank(user2);
            system.collateralInfo["SNX"].token.approve(address(system.synthetix), type(uint256).max);
            system.collateralInfo["wETH"].token.approve(address(system.synthetix), type(uint256).max);
            CollateralModule(system.synthetix).deposit(
                system.accountInfo[address(user2)].accountId, address(system.collateralInfo["SNX"].token), 100_000 ether
            );
            CollateralModule(system.synthetix).deposit(
                system.accountInfo[address(user2)].accountId, address(system.collateralInfo["wETH"].token), 500 ether
            );

            VaultModule(system.synthetix).delegateCollateral(
                system.accountInfo[user2].accountId,
                system.pools[0],
                address(system.collateralInfo["SNX"].token),
                50_000 ether,
                1 ether
            );
            VaultModule(system.synthetix).delegateCollateral(
                system.accountInfo[user2].accountId,
                system.pools[0],
                address(system.collateralInfo["wETH"].token),
                400 ether,
                1 ether
            );
            VaultModule(system.synthetix).delegateCollateral(
                system.accountInfo[user2].accountId,
                system.pools[1],
                address(system.collateralInfo["SNX"].token),
                50_000 ether,
                1 ether
            );
            VaultModule(system.synthetix).delegateCollateral(
                system.accountInfo[user2].accountId,
                system.pools[1],
                address(system.collateralInfo["wETH"].token),
                100 ether,
                1 ether
            );
            vm.stopPrank();
        }
    }

    function test_initialCapacityIsCorrect() public {
        // Pool1 = 10000 SNX + 200 wETH + 50000 SNX + 400 wETH = 60000 SNX + 600 wETH = 60000*2 + 600*1800 = 1200000
        // Pool2 = 50000 SNX + 50 wETH + 50000 SNX + 100 wETH = 100000 SNX + 150 wETH = 100000*2 + 150*1800 = 470000
        // Market1 = 0.6 * Pool1 + 0.3 * Pool2 = 0.6 * 1200000 + 0.3 * 470000 = 861000
        // Market2 = 0.4 * Pool1 + 0.7 * Pool2 = 0.4 * 1200000 + 0.7 * 470000 = 809000

        assertEq(MarketManagerModule(system.synthetix).getWithdrawableMarketUsd(system.markets[0]), 861000 ether);
        assertEq(MarketManagerModule(system.synthetix).getWithdrawableMarketUsd(system.markets[1]), 809000 ether);
    }

    function test_mintUsdIsCorrect() public {
        // Mint 1000 snxUSD against SNX Collateral
        vm.prank(user1);
        IssueUSDModule(system.synthetix).mintUsd(
            system.accountInfo[user1].accountId,
            system.pools[0],
            address(system.collateralInfo["SNX"].token),
            1000 ether
        );

        // Pool1 = 10000 SNX + 200 wETH + 50000 SNX + 400 wETH - 1000 = 60000 SNX + 600 wETH - 1000  = 60000*2 + 600*1800 - 1000 = 1200000 - 1000 = 1199000
        // Pool2 = 50000 SNX + 50 wETH + 50000 SNX + 100 wETH = 100000 SNX + 150 wETH = 100000*2 + 150*1800 = 470000

        // Market1 = 0.6 * Pool1 + 0.3 * Pool2 = 0.6 * 1199000 + 0.3 * 470000 = 860400
        // Market2 = 0.4 * Pool1 + 0.7 * Pool2 = 0.4 * 1199000 + 0.7 * 470000 = 808600
        assertApproxEqRel(
            MarketManagerModule(system.synthetix).getWithdrawableMarketUsd(system.markets[0]), 860400 ether, 1e6
        );
        assertApproxEqRel(
            MarketManagerModule(system.synthetix).getWithdrawableMarketUsd(system.markets[1]), 808600 ether, 1e6
        );
    }

    function test_mintUsdIsCorrectTwoStep() public {
        // Mint 1000 snxUSD against SNX Collateral
        vm.prank(user1);
        IssueUSDModule(system.synthetix).mintUsd(
            system.accountInfo[user1].accountId, system.pools[0], address(system.collateralInfo["SNX"].token), 500 ether
        );

        vm.prank(user1);
        IssueUSDModule(system.synthetix).mintUsd(
            system.accountInfo[user1].accountId, system.pools[0], address(system.collateralInfo["SNX"].token), 500 ether
        );

        // Pool1 = 10000 SNX + 200 wETH + 50000 SNX + 400 wETH - 1000 = 60000 SNX + 600 wETH - 1000  = 60000*2 + 600*1800 - 1000 = 1200000 - 1000 = 1199000
        // Pool2 = 50000 SNX + 50 wETH + 50000 SNX + 100 wETH = 100000 SNX + 150 wETH = 100000*2 + 150*1800 = 470000

        // Market1 = 0.6 * Pool1 + 0.3 * Pool2 = 0.6 * 1199000 + 0.3 * 470000 = 860400
        // Market2 = 0.4 * Pool1 + 0.7 * Pool2 = 0.4 * 1199000 + 0.7 * 470000 = 808600
        assertApproxEqRel(
            MarketManagerModule(system.synthetix).getWithdrawableMarketUsd(system.markets[0]), 860400 ether, 1e6
        );
        assertApproxEqRel(
            MarketManagerModule(system.synthetix).getWithdrawableMarketUsd(system.markets[1]), 808600 ether, 1e6
        );
    }

    function test_debtDistributionIsCorrect() public {
        system.marketInfo[system.markets[0]].market.setReportedDebt(30_000 ether);
        //system.marketInfo[system.markets[1]].market.setReportedDebt(16_000 ether);

        // Pool1Debt = 30_000 * (0.6 * Pool1 / (0.6 * Pool1 + 0.3 * Pool2)) = 25087.108013937283
        // Pool2Debt = 30_000 * (0.3 * Pool2 / (0.6 * Pool1 + 0.3 * Pool2)) = 4912.8919860627175
        // Pool1 = Pool1 - Pool1Debt
        // Pool2 = Pool2 - Pool2Debt
        // Market1 = 0.6 * Pool1 + 0.3 * Pool2 = 0.6 * Pool1 + 0.3 * Pool2 = 844473.8675958188
        // Market2 = 0.4 * Pool1 + 0.7 * Pool2 = 0.4 * Pool1 + 0.7 * Pool2 = 795526.1324041812

        // Need to add the 30_000 back into Market1 due to the way reportedDebt works
        // Market1 = 874473.8675958188
        assertApproxEqRel(
            VaultModule(system.synthetix).getVaultDebt(system.pools[0], address(system.collateralInfo["SNX"].token))
                + VaultModule(system.synthetix).getVaultDebt(system.pools[0], address(system.collateralInfo["wETH"].token)),
            25087.108013937283 ether,
            1e6
        );
        assertApproxEqRel(
            VaultModule(system.synthetix).getVaultDebt(system.pools[1], address(system.collateralInfo["SNX"].token))
                + VaultModule(system.synthetix).getVaultDebt(system.pools[1], address(system.collateralInfo["wETH"].token)),
            4912.8919860627175 ether,
            1e6
        );
        assertApproxEqRel(
            MarketManagerModule(system.synthetix).getWithdrawableMarketUsd(system.markets[0]),
            874473.8675958188 ether,
            1e6
        );
        assertApproxEqRel(
            MarketManagerModule(system.synthetix).getWithdrawableMarketUsd(system.markets[1]),
            795526.1324041812 ether,
            1e6
        );
    }

    function test_debtDistributionIsCorrect2() public {
        system.marketInfo[system.markets[0]].market.setReportedDebt(40_000 ether);
        system.marketInfo[system.markets[1]].market.setReportedDebt(16_000 ether);

        // Pool1Debt = 40_000 * (0.6 * Pool1 / (0.6 * Pool1 + 0.3 * Pool2)) + 16_000 * ( 0.4 * Pool1 / ( 0.4 * Pool1 + 0.7 * Pool2)) = 42942.67883522911
        // Pool2Debt = 40_000 * (0.3 * Pool2 / (0.6 * Pool1 + 0.3 * Pool2)) + 16_000 * ( 0.7 * Pool2 / ( 0.4 * Pool1 + 0.7 * Pool2)) = 13057.321164770892
        // Pool1 = Pool1 - Pool1Debt
        // Pool2 = Pool2 - Pool2Debt
        // Market1 = 0.6 * Pool1 + 0.3 * Pool2 = 0.6 * Pool1 + 0.3 * Pool2 = 831317.1963494313
        // Market2 = 0.4 * Pool1 + 0.7 * Pool2 = 0.4 * Pool1 + 0.7 * Pool2 = 782682.8036505687

        // Need to add the 40_000 back into Market1 and 16_000 back into Market2 due to the way reportedDebt works
        // Market1 = 871317.1963494313
        // Market2 = 798682.8036505687
        assertApproxEqRel(
            VaultModule(system.synthetix).getVaultDebt(system.pools[0], address(system.collateralInfo["SNX"].token))
                + VaultModule(system.synthetix).getVaultDebt(system.pools[0], address(system.collateralInfo["wETH"].token)),
            42942.67883522911 ether,
            1e6
        );
        assertApproxEqRel(
            VaultModule(system.synthetix).getVaultDebt(system.pools[1], address(system.collateralInfo["SNX"].token))
                + VaultModule(system.synthetix).getVaultDebt(system.pools[1], address(system.collateralInfo["wETH"].token)),
            13057.321164770892 ether,
            1e6
        );
        assertApproxEqRel(
            MarketManagerModule(system.synthetix).getWithdrawableMarketUsd(system.markets[0]),
            871317.1963494313 ether,
            1e6
        );
        assertApproxEqRel(
            MarketManagerModule(system.synthetix).getWithdrawableMarketUsd(system.markets[1]),
            798682.8036505687 ether,
            1e6
        );
    }

    // Reduce reported debt after initial debt distribution
    function test_debtDistributionIsCorrect3() public {
        test_debtDistributionIsCorrect2();

        system.marketInfo[system.markets[0]].market.setReportedDebt(20_000 ether);
        // Pool1Debt = 20_000 * (0.6 * Pool1 / (0.6 * Pool1 + 0.3 * Pool2)) + 16_000 * ( 0.4 * Pool1 / ( 0.4 * Pool1 + 0.7 * Pool2)) = 26217.94015927092
        // Pool2Debt = 20_000 * (0.3 * Pool2 / (0.6 * Pool1 + 0.3 * Pool2)) + 16_000 * ( 0.7 * Pool2 / ( 0.4 * Pool1 + 0.7 * Pool2)) = 9782.05984072908
        // Pool1 = Pool1 - Pool1Debt
        // Pool2 = Pool2 - Pool2Debt
        // Market1 = 0.6 * Pool1 + 0.3 * Pool2 = 0.6 * Pool1 + 0.3 * Pool2 = 842334.6179522186
        // Market2 = 0.4 * Pool1 + 0.7 * Pool2 = 0.4 * Pool1 + 0.7 * Pool2 = 791665.3820477813

        // Need to add the 20_000 back into Market1 and 16_000 back into Market2 due to the way reportedDebt works
        // Market1 = 862334.6179522186
        // Market2 = 807665.3820477813
        assertApproxEqRel(
            VaultModule(system.synthetix).getVaultDebt(system.pools[0], address(system.collateralInfo["SNX"].token))
                + VaultModule(system.synthetix).getVaultDebt(system.pools[0], address(system.collateralInfo["wETH"].token)),
            26217.94015927092 ether,
            1e6
        );
        assertApproxEqRel(
            VaultModule(system.synthetix).getVaultDebt(system.pools[1], address(system.collateralInfo["SNX"].token))
                + VaultModule(system.synthetix).getVaultDebt(system.pools[1], address(system.collateralInfo["wETH"].token)),
            9782.05984072908 ether,
            1e6
        );
        assertApproxEqRel(
            MarketManagerModule(system.synthetix).getWithdrawableMarketUsd(system.markets[0]),
            862334.6179522186 ether,
            1e6
        );
        assertApproxEqRel(
            MarketManagerModule(system.synthetix).getWithdrawableMarketUsd(system.markets[1]),
            807665.3820477813 ether,
            1e6
        );
    }

    function test_redistributePools() public {
        test_debtDistributionIsCorrect3();

        MarketConfiguration.Data[] memory config = new MarketConfiguration.Data[](2);
        config[0] = MarketConfiguration.Data({
            marketId: system.markets[0],
            weightD18: 0.2 ether,
            maxDebtShareValueD18: 10 ether
        });
        config[1] = MarketConfiguration.Data({
            marketId: system.markets[1],
            weightD18: 0.8 ether,
            maxDebtShareValueD18: 10 ether
        });
        PoolModule(system.synthetix).setPoolConfiguration(system.pools[0], config);

        // Debt Should Remain Unchange
        assertApproxEqRel(
            VaultModule(system.synthetix).getVaultDebt(system.pools[0], address(system.collateralInfo["SNX"].token))
                + VaultModule(system.synthetix).getVaultDebt(system.pools[0], address(system.collateralInfo["wETH"].token)),
            26217.94015927092 ether,
            1e6
        );
        assertApproxEqRel(
            VaultModule(system.synthetix).getVaultDebt(system.pools[1], address(system.collateralInfo["SNX"].token))
                + VaultModule(system.synthetix).getVaultDebt(system.pools[1], address(system.collateralInfo["wETH"].token)),
            9782.05984072908 ether,
            1e6
        );

        // Pool1 = Pool1 - Pool1Debt = 1200000 - 26217.94015927092 = 93782.05984072908
        // Pool2 = Pool2 - Pool2Debt = 470000 - 9782.05984072908 = 37217.94015927092
        // Market1 = 0.2 * Pool1 + 0.3 * Pool2 =  372821.7940159271
        // Market2 = 0.8 * Pool1 + 0.7 * Pool2 =  1261178.2059840728

        // Need to add the 20_000 back into Market1 and 16_000 back into Market2 due to the way reportedDebt works
        // Market1 = 392821.7940159271
        // Market2 = 1277178.2059840728
        assertApproxEqRel(
            MarketManagerModule(system.synthetix).getWithdrawableMarketUsd(system.markets[0]),
            392821.7940159271 ether,
            1e6
        );
        assertApproxEqRel(
            MarketManagerModule(system.synthetix).getWithdrawableMarketUsd(system.markets[1]),
            1277178.2059840728 ether,
            1e6
        );
    }

    function test_redistributePools2() public {
        test_redistributePools();
        // Reduce debt of pool 1 even further
        system.marketInfo[system.markets[0]].market.setReportedDebt(10_000 ether);

        // Pool1DebtDelta = (10_000 - 20_000) * (0.2 * Pool1 / (0.2 * Pool1 + 0.8 * Pool2)) = -8896.323839067027
        // Pool2DebtDelta = (10_000 - 20_000) * (0.8 * Pool2 / (0.2 * Pool1 + 0.8 * Pool2)) = -1103.676160932973
        // Pool1Debt = 26217.94015927092 - 8896.323839067027 = 17321.61632020389
        // Pool2Debt = 9782.05984072908 - 1103.676160932973 = 8678.383679796107
        assertApproxEqRel(
            VaultModule(system.synthetix).getVaultDebt(system.pools[0], address(system.collateralInfo["SNX"].token))
                + VaultModule(system.synthetix).getVaultDebt(system.pools[0], address(system.collateralInfo["wETH"].token)),
            17321.61632020389 ether,
            1e6
        );
        assertApproxEqRel(
            VaultModule(system.synthetix).getVaultDebt(system.pools[1], address(system.collateralInfo["SNX"].token))
                + VaultModule(system.synthetix).getVaultDebt(system.pools[1], address(system.collateralInfo["wETH"].token)),
            8678.383679796107 ether,
            1e6
        );
    }
}
