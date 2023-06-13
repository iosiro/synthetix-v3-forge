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
import {MarketCollateralModule} from "@synthetixio/main/contracts/modules/core/MarketCollateralModule.sol";

import {CollateralConfiguration} from "@synthetixio/main/contracts/modules/core/CollateralConfigurationModule.sol";
import {NodeDefinition} from "@synthetixio/oracle-manager/contracts/modules/NodeModule.sol";
import {MarketConfiguration} from "@synthetixio/main/contracts/modules/core/PoolModule.sol";

import {AggregatorV3Mock} from "@synthetixio/main/contracts/mocks/AggregatorV3Mock.sol";
import {CollateralMock} from "@synthetixio/main/contracts/mocks/CollateralMock.sol";
import {MockMarket} from "@synthetixio/main/contracts/mocks/MockMarket.sol";

contract VaultModuleTest is SynthetixV3Test {
    MockMarket internal market;
    uint128 internal marketId;

    function setUp() public {
        bootstrapWithStakedPool();

        uint128 poolId = system.pools[0];

        FeatureFlagModule(system.synthetix).addToFeatureFlagAllowlist("registerMarket", address(this));

        market = new MockMarket();
        marketId = MarketManagerModule(system.synthetix).registerMarket(address(market));
        market.initialize(system.synthetix, marketId, 1 ether);

        MarketConfiguration.Data[] memory config = new MarketConfiguration.Data[](1);
        config[0] = MarketConfiguration.Data({
            marketId: marketId,
            weightD18: 1 ether,
            maxDebtShareValueD18: 10000000000000000 ether
        });
        PoolModule(system.synthetix).setPoolConfiguration(poolId, config);
    }

    function test_freshVault() public {
        // create empty vault
        address collateral = address(system.collateralInfo["SNX"].token);
        uint128 poolId = 209372;
        PoolModule(system.synthetix).createPool(poolId, address(this));

        // returns 0 debt
        assertEq(VaultModule(system.synthetix).getVaultDebt(poolId, collateral), 0);

        // returns 0 collateral
        (uint256 amount,) = VaultModule(system.synthetix).getVaultCollateral(poolId, collateral);
        assertEq(amount, 0);

        // returns 0 collateral ratio
        assertEq(VaultModule(system.synthetix).getVaultCollateralRatio(poolId, collateral), 0);
    }

    function test_delegateCollateral() public {
        uint128 accountId = system.accountInfo[user1].accountId;
        uint128 poolId = system.pools[0];
        // after bootstrap have correct amounts
        verifyAccountState(accountId, poolId, 1000 ether, 0);

        // has max cratio
        assertEq(
            VaultModule(system.synthetix).getPositionCollateralRatio(accountId, poolId, collateralAddress()),
            type(uint256).max,
            "max cratio"
        );

        // after bootstrap liquidity is delegated all the way back to the market
        assertEq(MarketManagerModule(system.synthetix).getMarketCollateral(marketId), 0);

        // verifies permission for account
        vm.prank(user2);
        vm.expectRevert(
            abi.encodeWithSignature("PermissionDenied(uint128,bytes32,address)", accountId, bytes32("DELEGATE"), user2)
        );
        VaultModule(system.synthetix).delegateCollateral(accountId, poolId, collateralAddress(), 2_000 ether, 1 ether);

        // verifies leverage
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("InvalidLeverage(uint256)", 1.1 ether));
        VaultModule(system.synthetix).delegateCollateral(accountId, poolId, collateralAddress(), 2_000 ether, 1.1 ether);

        // fails when trying to delegate less than minDelegation amount
        uint256 delegateAmount = uint256(1_000 ether) / 51;
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("InsufficientDelegation(uint256)", 20 ether));
        VaultModule(system.synthetix).delegateCollateral(
            accountId, poolId, collateralAddress(), delegateAmount, 1 ether
        );

        // fails when new collateral amount equals current collateral amount
        delegateAmount = 1_000 ether;
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("InvalidCollateralAmount()"));
        VaultModule(system.synthetix).delegateCollateral(
            accountId, poolId, collateralAddress(), delegateAmount, 1 ether
        );

        // fails when pool does not exist
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("PoolNotFound(uint128)", 42));
        VaultModule(system.synthetix).delegateCollateral(accountId, 42, collateralAddress(), delegateAmount, 1 ether);

        //
        bytes memory data = abi.encodeWithSelector(
            VaultModule.delegateCollateral.selector, accountId, 42, collateralAddress(), delegateAmount / 50, 1 ether
        );
        this.verifyUsesFeatureFlag(FeatureFlagModule(system.synthetix), system.synthetix, data, "delegateCollateral");
    }

    function test_whenCollateralIsDisabled() public {
        uint128 fakePoolId = 93729028;

        PoolModule(system.synthetix).createPool(fakePoolId, address(this));

        // disable collateral
        CollateralConfiguration.Data[] memory beforeConfig =
            CollateralConfigurationModule(system.synthetix).getCollateralConfigurations(true);

        CollateralConfiguration.Data memory config = beforeConfig[0];
        config.depositingEnabled = false;
        CollateralConfigurationModule(system.synthetix).configureCollateral(config);

        // fails when trying to open delegation position with disabled collateral
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature("CollateralDepositDisabled(address)", address(system.collateralInfo["SNX"].token))
        );
        VaultModule(system.synthetix).delegateCollateral(
            system.accountInfo[user1].accountId,
            fakePoolId,
            address(system.collateralInfo["SNX"].token),
            20 ether,
            1 ether
        );

        // user1 has expected initial position
        verifyAccountState(system.accountInfo[user1].accountId, system.pools[0], 1000 ether, 0);
    }

    function test_marketDebtAccumlation() public {
        uint128 poolId = system.pools[0];
        uint128 accountId = system.accountInfo[user1].accountId;
        // user1 goes into debt
        market.setReportedDebt(100 ether);

        PoolModule(system.synthetix).rebalancePool(poolId, address(0));

        assertEq(
            VaultModule(system.synthetix).getVaultDebt(poolId, collateralAddress()),
            100 ether,
            "has allocated debt to vault"
        );

        verifyAccountState(accountId, poolId, 1000 ether, 100 ether, "user1 has become indebted");

        assertEq(
            VaultModule(system.synthetix).getVaultCollateralRatio(poolId, collateralAddress()),
            1000 ether * 1 ether / 100 ether,
            "vault c-ratio is affected"
        );

        // second user delegates
        uint128 user2AccountId = 283847;
        CollateralMock collateral = CollateralMock(system.collateralInfo["SNX"].token);
        collateral.mint(user2, 2_000 ether);

        vm.startPrank(user2);
        collateral.approve(system.synthetix, 2_000 ether);
        AccountModule(system.synthetix).createAccount(user2AccountId);
        CollateralModule(system.synthetix).deposit(user2AccountId, address(collateral), 2_000 ether);
        VaultModule(system.synthetix).delegateCollateral(
            user2AccountId, poolId, address(collateral), uint256(1_000 ether) / 3, 1 ether
        );

        IssueUSDModule(system.synthetix).mintUsd(user2AccountId, poolId, address(collateral), 10 ether);
        vm.stopPrank();

        market.setLocked(1400 ether);

        verifyAccountState(accountId, poolId, 1_000 ether, 100 ether, "user1 has not changed");

        verifyAccountState(user2AccountId, poolId, uint256(1_000 ether) / 3, 10 ether, "user2 has become indebted");
    }

    function verifyAccountState(
        uint128 accountId,
        uint128 poolId,
        uint256 collateralAmount,
        int256 debt,
        string memory err
    ) internal {
        (uint256 amount,) = VaultModule(system.synthetix).getPositionCollateral(accountId, poolId, collateralAddress());
        assertEq(amount, collateralAmount, string(abi.encodePacked("collateral amount:", err)));
        assertEq(
            VaultModule(system.synthetix).getPositionDebt(accountId, poolId, collateralAddress()),
            debt,
            string(abi.encodePacked("debt:", err))
        );
        assertEq(
            VaultModule(system.synthetix).getPositionCollateralRatio(accountId, poolId, collateralAddress()),
            expectedCollateralRatio(collateralAmount, debt),
            string(abi.encodePacked("collateral ratio:", err))
        );
    }

    function verifyAccountState(uint128 accountId, uint128 poolId, uint256 collateralAmount, int256 debt) internal {
        verifyAccountState(accountId, poolId, collateralAmount, debt, "");
    }

    function collateralAddress() internal view returns (address) {
        return address(system.collateralInfo["SNX"].token);
    }

    function expectedCollateralRatio(uint256 value, int256 debt) internal pure returns (uint256) {
        if (debt == 0) {
            return type(uint256).max;
        }

        return value * 1e18 / uint256(debt);
    }
}
