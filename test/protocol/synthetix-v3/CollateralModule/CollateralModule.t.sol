//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {SynthetixV3Test} from "test/protocol/synthetix-v3/SynthetixV3Test.t.sol";

import {AccountModule} from "@synthetixio/main/contracts/modules/core/AccountModule.sol";
import {CollateralModule} from "@synthetixio/main/contracts/modules/core/CollateralModule.sol";
import {FeatureFlagModule} from "@synthetixio/main/contracts/modules/core/FeatureFlagModule.sol";
import {UtilsModule} from "@synthetixio/main/contracts/modules/core/UtilsModule.sol";
import {CollateralConfigurationModule} from "@synthetixio/main/contracts/modules/core/CollateralConfigurationModule.sol";
import {CollateralMock} from "@synthetixio/main/contracts/mocks/CollateralMock.sol";
import {CollateralConfiguration} from "@synthetixio/main/contracts/storage/CollateralConfiguration.sol";
import {CollateralLock} from "@synthetixio/main/contracts/storage/CollateralLock.sol";

import "forge-std/console.sol";

contract CollateralModuleTest is SynthetixV3Test {
    CollateralMock collateral;
    bytes32 oracleNodeId;

    uint256 constant mintAmount = 1000 * 1e6;
    uint256 constant depositAmount = 1e6;
    uint256 constant depositAmountD18 = 1 ether;

    CollateralModule internal collateralModule;
    AccountModule internal accountModule;
    UtilsModule internal utilsModule;

    function setUp() public {
        bootstrap();

        collateralModule = CollateralModule(system.synthetix);
        accountModule = AccountModule(system.synthetix);
        utilsModule = UtilsModule(system.synthetix);

        // create some accounts
        vm.prank(user1);
        accountModule.createAccount(1);

        vm.prank(user2);
        accountModule.createAccount(2);

        (collateral,, oracleNodeId,) = addCollateral("Synthetix Token", "SNX", 400, 200);

        // mint some tokens
        collateral.mint(user1, mintAmount);
        collateral.mint(user2, mintAmount);

        // when accounts provide allowance
        vm.prank(user1);
        collateral.approve(address(system.synthetix), type(uint256).max);

        vm.prank(user2);
        collateral.approve(address(system.synthetix), type(uint256).max);
    }

    function test_collateralInit() public {
        // is well configured
        CollateralConfiguration.Data memory collateralType =
            CollateralConfigurationModule(system.synthetix).getCollateralConfiguration(address(collateral));
        assertEq(collateralType.tokenAddress, address(collateral));
        assertEq(collateralType.oracleNodeId, oracleNodeId);
        assertEq(collateralType.issuanceRatioD18, 400);
        assertEq(collateralType.liquidationRatioD18, 200);
        assertEq(collateralType.depositingEnabled, true);

        // show correct balances
        assertEq(collateral.balanceOf(user1), mintAmount);
        assertEq(collateral.balanceOf(user2), mintAmount);
    }

    // when a collateral is added
    function test_accessCollateral() public {
        // when an unauthorized account tries to withdraw collateral
        vm.prank(user2);
        vm.expectRevert(
            abi.encodeWithSignature("PermissionDenied(uint128,bytes32,address)", 1, bytes32("WITHDRAW"), user2)
        );
        collateralModule.withdraw(1, address(collateral), 100);

        // when an account authorizes other users to operate
        // grant WITHDRAW permissions
        vm.prank(user1);
        accountModule.grantPermission(1, "WITHDRAW", user3);

        // when the authorized account deposits collateral
        vm.prank(user2);
        collateralModule.deposit(1, address(collateral), depositAmount);

        // shows that tokens have moved
        assertEq(collateral.balanceOf(user2), mintAmount - depositAmount);

        // shows that the collateral has been registered
        (uint256 totalStaked, uint256 totalAssigned,) = collateralModule.getAccountCollateral(1, address(collateral));
        uint256 totalAvailable = collateralModule.getAccountAvailableCollateral(1, address(collateral));

        assertEq(totalStaked, depositAmountD18);
        assertEq(totalAssigned, 0);
        assertEq(totalAvailable, depositAmountD18);
    }

    event Deposited(
        uint128 indexed accountId, address indexed collateralType, uint256 tokenAmount, address indexed sender
    );

    function test_depositCollateral() public as_user(user1) {
        uint256 amount = mintAmount + 1;

        // when attempting to deposit more tokens than the user has
        vm.expectRevert(
            abi.encodeWithSignature("FailedTransfer(address,address,uint256)", user1, address(system.synthetix), amount)
        );
        collateralModule.deposit(1, address(collateral), amount);

        // verifyUsesFeatureFlag
        bytes memory data = abi.encodeWithSelector(CollateralModule.deposit.selector, 1, address(collateral), 1);
        this.verifyUsesFeatureFlag(FeatureFlagModule(system.synthetix), system.synthetix, data, "deposit");

        // fails when depositing to nonexistant account
        vm.expectRevert(abi.encodeWithSignature("AccountNotFound(uint128)", 283729));
        collateralModule.deposit(283729, address(collateral), depositAmount);

        // when depositing collateral
        vm.expectEmit();
        emit Deposited(1, address(collateral), depositAmount, user1);
        collateralModule.deposit(1, address(collateral), depositAmount);

        // shows that tokens have moved
        assertEq(collateral.balanceOf(user1), mintAmount - depositAmount);

        // shows that the collateral has been registered
        (uint256 totalStaked, uint256 totalAssigned,) = collateralModule.getAccountCollateral(1, address(collateral));
        uint256 totalAvailable = collateralModule.getAccountAvailableCollateral(1, address(collateral));

        assertEq(totalStaked, depositAmountD18);
        assertEq(totalAssigned, 0);
        assertEq(totalAvailable, depositAmountD18);

        // when attempting to withdraw more than available collateral
        uint256 errorAmount = depositAmountD18 + 1;
        data = abi.encodeWithSelector(CollateralModule.withdraw.selector, 1, address(collateral), errorAmount);
        vm.expectRevert(abi.encodeWithSignature("InsufficientAccountCollateral(uint256)", errorAmount));
        (bool success,) = system.synthetix.call(data);
        assertEq(success, false);

        this.verifyUsesFeatureFlag(FeatureFlagModule(system.synthetix), system.synthetix, data, "withdraw");
    }

    event Withdrawn(
        uint128 indexed accountId, address indexed collateralType, uint256 tokenAmount, address indexed sender
    );

    function test_withdrawTimeout() public {
        test_depositCollateral();

        utilsModule.setConfig("accountTimeoutWithdraw", bytes32(uint256(180)));

        {
            vm.startPrank(user1);

            // Use grant Permission to set lastInteraction - opposed to Account_set_lastInteraction
            accountModule.grantPermission(1, "ADMIN", user1);

            // Sanity check interaction
            assertEq(accountModule.getAccountLastInteraction(1), block.timestamp);

            // should not allow withdrawal because of account interaction

            vm.expectRevert(
                abi.encodeWithSignature(
                    "AccountActivityTimeoutPending(uint128,uint256,uint256)", 1, block.timestamp, 181
                )
            );
            collateralModule.withdraw(1, address(collateral), depositAmount);

            // time passes
            vm.warp(block.timestamp + 180);

            vm.expectEmit();
            emit Withdrawn(1, address(collateral), depositAmount, user1);
            collateralModule.withdraw(1, address(collateral), depositAmount);

            // show that the tokens have moved
            assertEq(collateral.balanceOf(user1), mintAmount);
            assertEq(collateral.balanceOf(system.synthetix), 0);

            // shows that the registered collateral has been updated accordingly
            (uint256 totalStaked, uint256 totalAssigned,) =
                collateralModule.getAccountCollateral(1, address(collateral));
            uint256 totalAvailable = collateralModule.getAccountAvailableCollateral(1, address(collateral));

            assertEq(totalStaked, 0);
            assertEq(totalAssigned, 0);
            assertEq(totalAvailable, 0);

            vm.stopPrank();
        }
    }

    function test_lockCollateral() public as_user(user2) {
        collateralModule.deposit(2, address(collateral), depositAmount);
        collateralModule.createLock(2, address(collateral), depositAmount, uint64(block.timestamp + 30 days));

        // reverts when attempting to withdraw locked collateral
        vm.expectRevert(abi.encodeWithSignature("InsufficientAccountCollateral(uint256)", depositAmountD18));
        collateralModule.withdraw(2, address(collateral), depositAmount);

        vm.warp(block.timestamp + 30 days);

        // can withdraw on expiry
        collateralModule.withdraw(2, address(collateral), depositAmount);

        // show that the tokens have moved
        assertEq(collateral.balanceOf(user2), mintAmount);
        assertEq(collateral.balanceOf(system.synthetix), 0);

        // shows that the registered collateral has been updated accordingly
        (uint256 totalStaked, uint256 totalAssigned,) = collateralModule.getAccountCollateral(2, address(collateral));
        uint256 totalAvailable = collateralModule.getAccountAvailableCollateral(2, address(collateral));

        assertEq(totalStaked, 0);
        assertEq(totalAssigned, 0);
        assertEq(totalAvailable, 0);
    }

    function test_createLock_validations() public as_user(user1) {
        vm.expectRevert(
            abi.encodeWithSignature("PermissionDenied(uint128,bytes32,address)", 2, bytes32("ADMIN"), user1)
        );
        collateralModule.createLock(2, address(collateral), depositAmountD18 / 10, uint64(block.timestamp + 30 days));

        vm.expectRevert(
            abi.encodeWithSignature("InvalidParameter(string,string)", "expireTimestamp", "must be in the future")
        );
        collateralModule.createLock(1, address(collateral), depositAmountD18 / 10, uint64(block.timestamp));

        vm.expectRevert(abi.encodeWithSignature("InvalidParameter(string,string)", "amount", "must be nonzero"));
        collateralModule.createLock(1, address(collateral), 0, uint64(block.timestamp + 30 days));

        // fails when insufficient collateral in account to lock
        vm.expectRevert(abi.encodeWithSignature("InsufficientAccountCollateral(uint256)", 1));
        collateralModule.createLock(1, address(collateral), 1, uint64(block.timestamp + 30 days));
    }

    event CollateralLockCreated(
        uint128 indexed accountId, address indexed collateralType, uint256 tokenAmount, uint64 expireTimestamp
    );

    function test_createLock() public as_user(user1) {
        collateralModule.deposit(1, address(collateral), depositAmount);

        vm.expectEmit();
        emit CollateralLockCreated(1, address(collateral), depositAmountD18, uint64(block.timestamp + 30 days));
        collateralModule.createLock(1, address(collateral), depositAmountD18, uint64(block.timestamp + 30 days));
    }

    function test_createLockMulti() public as_user(user1) {
        collateralModule.deposit(1, address(collateral), depositAmount);

        collateralModule.createLock(1, address(collateral), depositAmountD18 / 10, uint64(block.timestamp + 30 days));
        collateralModule.createLock(
            1, address(collateral), 4 * depositAmountD18 / 10, uint64(block.timestamp + 30 days + 1)
        );

        // increments account locked amount
        (,, uint256 locked) = collateralModule.getAccountCollateral(1, address(collateral));
        assertEq(locked, depositAmountD18 / 2);

        CollateralLock.Data[] memory locks = collateralModule.getLocks(1, address(collateral), 0, type(uint256).max);

        // created locks with the given specification
        assertEq(locks.length, 2);

        assertEq(locks[0].amountD18, depositAmountD18 / 10);
        assertEq(locks[0].lockExpirationTime, block.timestamp + 30 days);

        assertEq(locks[1].amountD18, 4 * depositAmountD18 / 10);
        assertEq(locks[1].lockExpirationTime, block.timestamp + 30 days + 1);
    }

    event CollateralLockExpired(
        uint128 indexed accountId, address indexed collateralType, uint256 tokenAmount, uint64 expireTimestamp
    );

    function test_expiringLocks() internal {
        collateralModule.deposit(1, address(collateral), depositAmount);

        collateralModule.createLock(1, address(collateral), depositAmountD18 / 10, uint64(block.timestamp + 200));
        collateralModule.createLock(1, address(collateral), depositAmountD18 / 10, uint64(block.timestamp + 400));
        collateralModule.createLock(1, address(collateral), depositAmountD18 / 10, uint64(block.timestamp + 300));
        collateralModule.createLock(1, address(collateral), depositAmountD18 / 10, uint64(block.timestamp + 100));

        vm.warp(block.timestamp + 300);
    }

    function test_expiringLocks_1() public as_user(user1) {
        uint256 timestamp = block.timestamp;
        test_expiringLocks();

        // invoke on the whole thing
        vm.expectEmit();
        emit CollateralLockExpired(1, address(collateral), depositAmountD18 / 10, uint64(timestamp + 200));
        emit CollateralLockExpired(1, address(collateral), depositAmountD18 / 10, uint64(timestamp + 100));
        emit CollateralLockExpired(1, address(collateral), depositAmountD18 / 10, uint64(timestamp + 300));
        collateralModule.cleanExpiredLocks(1, address(collateral), 0, 0);

        // only has the one unexpired lock remaining
        CollateralLock.Data[] memory locks = collateralModule.getLocks(1, address(collateral), 0, 0);
        assertEq(locks.length, 1);
    }

    function test_expiringLocks_2() public as_user(user1) {
        test_expiringLocks();

        // invoke on a portion
        collateralModule.cleanExpiredLocks(1, address(collateral), 1, 2);

        // only one expired lock could be removed
        CollateralLock.Data[] memory locks = collateralModule.getLocks(1, address(collateral), 0, 0);
        assertEq(locks.length, 3);
    }

    function test_expiringLocks_3() public as_user(user1) {
        test_expiringLocks();

        // partial remove from off the end
        collateralModule.cleanExpiredLocks(1, address(collateral), 1, 10000);

        // only one additional expired lock could be removed
        CollateralLock.Data[] memory locks = collateralModule.getLocks(1, address(collateral), 0, 0);
        assertEq(locks.length, 2);
    }
}
