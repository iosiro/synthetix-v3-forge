//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {CollateralMock} from "@synthetixio/main/contracts/mocks/CollateralMock.sol";
import {AggregatorV3Mock} from "@synthetixio/main/contracts/mocks/AggregatorV3Mock.sol";

import {ICollateralModule, CollateralLock} from "@synthetixio/main/contracts/interfaces/ICollateralModule.sol";
import {
    ICollateralConfigurationModule,
    CollateralConfiguration
} from "@synthetixio/main/contracts/interfaces/ICollateralConfigurationModule.sol";

import {SynthetixLegacyTestBase} from "test/legacy/protocol/main/common/SynthetixLegacyTestBase.t.sol";

contract CollateralModuleTest is SynthetixLegacyTestBase {
    CollateralMock collateral;
    bytes32 oracleNodeId;

    uint256 constant mintAmount = 1000 * 1e6;
    uint256 constant depositAmount = 1e6;
    uint256 constant depositAmountD18 = 1 ether;

    function setUp() public override {
        super.setUp();

        // create some accounts
        vm.prank(user1);
        synthetix.createAccount(1);

        vm.prank(user2);
        synthetix.createAccount(2);

        (collateral,, oracleNodeId,) = addCollateral("Synthetix Token", "SNX", 4 ether, 2 ether);

        // mint some tokens
        collateral.mint(user1, mintAmount);
        collateral.mint(user2, mintAmount);

        // when accounts provide allowance
        vm.prank(user1);
        collateral.approve(address(synthetix), type(uint256).max);

        vm.prank(user2);
        collateral.approve(address(synthetix), type(uint256).max);
    }

    // when a collateral is added
    function test_accessCollateral() public {
        // when an unauthorized account tries to withdraw collateral
        vm.prank(user2);
        vm.expectRevert(
            abi.encodeWithSignature("PermissionDenied(uint128,bytes32,address)", 1, bytes32("WITHDRAW"), user2)
        );
        synthetix.withdraw(1, address(collateral), 100);

        // when an account authorizes other users to operate
        // grant WITHDRAW permissions
        vm.prank(user1);
        synthetix.grantPermission(1, "WITHDRAW", user3);

        // when the authorized account deposits collateral
        vm.prank(user2);
        synthetix.deposit(1, address(collateral), depositAmount);

        // shows that tokens have moved
        assertEq(collateral.balanceOf(user2), mintAmount - depositAmount);

        // shows that the collateral has been registered
        (uint256 totalStaked, uint256 totalAssigned,) = synthetix.getAccountCollateral(1, address(collateral));
        uint256 totalAvailable = synthetix.getAccountAvailableCollateral(1, address(collateral));

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
            abi.encodeWithSignature("FailedTransfer(address,address,uint256)", user1, address(synthetix), amount)
        );
        synthetix.deposit(1, address(collateral), amount);

        // verifyUsesFeatureFlag
        bytes memory data = abi.encodeWithSelector(ICollateralModule.deposit.selector, 1, address(collateral), 1);
        this.verifyUsesFeatureFlag(address(synthetix), address(synthetix), data, "deposit");

        // fails when depositing to nonexistant account
        vm.expectRevert(abi.encodeWithSignature("AccountNotFound(uint128)", 283729));
        synthetix.deposit(283729, address(collateral), depositAmount);

        // when depositing collateral
        vm.expectEmit();
        emit Deposited(1, address(collateral), depositAmount, user1);
        synthetix.deposit(1, address(collateral), depositAmount);

        // shows that tokens have moved
        assertEq(collateral.balanceOf(user1), mintAmount - depositAmount);

        // shows that the collateral has been registered
        (uint256 totalStaked, uint256 totalAssigned,) = synthetix.getAccountCollateral(1, address(collateral));
        uint256 totalAvailable = synthetix.getAccountAvailableCollateral(1, address(collateral));

        assertEq(totalStaked, depositAmountD18);
        assertEq(totalAssigned, 0);
        assertEq(totalAvailable, depositAmountD18);

        // when attempting to withdraw more than available collateral
        uint256 errorAmount = depositAmountD18 + 1;
        data = abi.encodeWithSelector(ICollateralModule.withdraw.selector, 1, address(collateral), errorAmount);
        vm.expectRevert(abi.encodeWithSignature("InsufficientAccountCollateral(uint256)", errorAmount));
        (bool success,) = address(synthetix).call(data);
        assertEq(success, false);

        this.verifyUsesFeatureFlag(address(synthetix), address(synthetix), data, "withdraw");
    }

    event Withdrawn(
        uint128 indexed accountId, address indexed collateralType, uint256 tokenAmount, address indexed sender
    );

    function test_withdrawTimeout() public {
        test_depositCollateral();

        synthetix.setConfig("accountTimeoutWithdraw", bytes32(uint256(180)));

        {
            vm.startPrank(user1);

            // Use grant Permission to set lastInteraction - opposed to Account_set_lastInteraction
            synthetix.grantPermission(1, "ADMIN", user1);

            // Sanity check interaction
            assertEq(synthetix.getAccountLastInteraction(1), block.timestamp);

            // should not allow withdrawal because of account interaction

            vm.expectRevert(
                abi.encodeWithSignature(
                    "AccountActivityTimeoutPending(uint128,uint256,uint256)", 1, block.timestamp, block.timestamp + 180
                )
            );
            synthetix.withdraw(1, address(collateral), depositAmount);

            // time passes
            vm.warp(block.timestamp + 180);

            vm.expectEmit();
            emit Withdrawn(1, address(collateral), depositAmount, user1);
            synthetix.withdraw(1, address(collateral), depositAmount);

            // show that the tokens have moved
            assertEq(collateral.balanceOf(user1), mintAmount);
            assertEq(collateral.balanceOf(address(synthetix)), 0);

            // shows that the registered collateral has been updated accordingly
            (uint256 totalStaked, uint256 totalAssigned,) = synthetix.getAccountCollateral(1, address(collateral));
            uint256 totalAvailable = synthetix.getAccountAvailableCollateral(1, address(collateral));

            assertEq(totalStaked, 0);
            assertEq(totalAssigned, 0);
            assertEq(totalAvailable, 0);

            vm.stopPrank();
        }
    }

    function test_lockCollateral() public as_user(user2) {
        synthetix.deposit(2, address(collateral), depositAmount);
        synthetix.createLock(2, address(collateral), depositAmount, uint64(block.timestamp + 30 days));

        // reverts when attempting to withdraw locked collateral
        vm.expectRevert(abi.encodeWithSignature("InsufficientAccountCollateral(uint256)", depositAmountD18));
        synthetix.withdraw(2, address(collateral), depositAmount);

        vm.warp(block.timestamp + 30 days);

        // can withdraw on expiry
        synthetix.withdraw(2, address(collateral), depositAmount);

        // show that the tokens have moved
        assertEq(collateral.balanceOf(user2), mintAmount);
        assertEq(collateral.balanceOf(address(synthetix)), 0);

        // shows that the registered collateral has been updated accordingly
        (uint256 totalStaked, uint256 totalAssigned,) = synthetix.getAccountCollateral(2, address(collateral));
        uint256 totalAvailable = synthetix.getAccountAvailableCollateral(2, address(collateral));

        assertEq(totalStaked, 0);
        assertEq(totalAssigned, 0);
        assertEq(totalAvailable, 0);
    }

    function test_createLock_validations() public as_user(user1) {
        vm.expectRevert(
            abi.encodeWithSignature("PermissionDenied(uint128,bytes32,address)", 2, bytes32("ADMIN"), user1)
        );
        synthetix.createLock(2, address(collateral), depositAmountD18 / 10, uint64(block.timestamp + 30 days));

        vm.expectRevert(
            abi.encodeWithSignature("InvalidParameter(string,string)", "expireTimestamp", "must be in the future")
        );
        synthetix.createLock(1, address(collateral), depositAmountD18 / 10, uint64(block.timestamp));

        vm.expectRevert(abi.encodeWithSignature("InvalidParameter(string,string)", "amount", "must be nonzero"));
        synthetix.createLock(1, address(collateral), 0, uint64(block.timestamp + 30 days));

        // fails when insufficient collateral in account to lock
        vm.expectRevert(abi.encodeWithSignature("InsufficientAccountCollateral(uint256)", 1));
        synthetix.createLock(1, address(collateral), 1, uint64(block.timestamp + 30 days));
    }

    event CollateralLockCreated(
        uint128 indexed accountId, address indexed collateralType, uint256 tokenAmount, uint64 expireTimestamp
    );

    function test_createLock() public as_user(user1) {
        synthetix.deposit(1, address(collateral), depositAmount);

        vm.expectEmit();
        emit CollateralLockCreated(1, address(collateral), depositAmountD18, uint64(block.timestamp + 30 days));
        synthetix.createLock(1, address(collateral), depositAmountD18, uint64(block.timestamp + 30 days));
    }

    function test_createLockMulti() public as_user(user1) {
        synthetix.deposit(1, address(collateral), depositAmount);

        synthetix.createLock(1, address(collateral), depositAmountD18 / 10, uint64(block.timestamp + 30 days));
        synthetix.createLock(1, address(collateral), 4 * depositAmountD18 / 10, uint64(block.timestamp + 30 days + 1));

        // increments account locked amount
        (,, uint256 locked) = synthetix.getAccountCollateral(1, address(collateral));
        assertEq(locked, depositAmountD18 / 2);

        CollateralLock.Data[] memory locks =
            ICollateralModule(address(synthetix)).getLocks(1, address(collateral), 0, type(uint256).max);

        // created locks with the given specification
        assertEq(locks.length, 2);

        assertEq(locks[0].amountD18, depositAmountD18 / 10);
        assertEq(locks[0].lockExpirationTime, block.timestamp + 30 days);

        assertEq(locks[1].amountD18, 4 * depositAmountD18 / 10);
        assertEq(locks[1].lockExpirationTime, block.timestamp + 30 days + 1);
    }

    event CollateralLockExpired(uint256 tokenAmount, uint64 expireTimestamp);

    function test_expiringLocks() internal {
        synthetix.deposit(1, address(collateral), depositAmount);

        synthetix.createLock(1, address(collateral), depositAmountD18 / 10, uint64(block.timestamp + 200));
        synthetix.createLock(1, address(collateral), depositAmountD18 / 10, uint64(block.timestamp + 400));
        synthetix.createLock(1, address(collateral), depositAmountD18 / 10, uint64(block.timestamp + 300));
        synthetix.createLock(1, address(collateral), depositAmountD18 / 10, uint64(block.timestamp + 100));

        vm.warp(block.timestamp + 300);
    }

    function test_expiringLocks_1() public as_user(user1) {
        uint256 timestamp = block.timestamp;
        test_expiringLocks();

        // invoke on the whole thing
        vm.expectEmit();
        emit CollateralLockExpired(depositAmountD18 / 10, uint64(timestamp + 200));
        emit CollateralLockExpired(depositAmountD18 / 10, uint64(timestamp + 100));
        emit CollateralLockExpired(depositAmountD18 / 10, uint64(timestamp + 300));
        synthetix.cleanExpiredLocks(1, address(collateral), 0, 0);

        // only has the one unexpired lock remaining
        CollateralLock.Data[] memory locks =
            ICollateralModule(address(synthetix)).getLocks(1, address(collateral), 0, 0);
        assertEq(locks.length, 1);
    }

    function test_expiringLocks_2() public as_user(user1) {
        test_expiringLocks();

        // invoke on a portion
        synthetix.cleanExpiredLocks(1, address(collateral), 1, 2);

        // only one expired lock could be removed
        CollateralLock.Data[] memory locks =
            ICollateralModule(address(synthetix)).getLocks(1, address(collateral), 0, 0);
        assertEq(locks.length, 3);
    }

    function test_expiringLocks_3() public as_user(user1) {
        test_expiringLocks();

        // partial remove from off the end
        synthetix.cleanExpiredLocks(1, address(collateral), 1, 10000);

        // only one additional expired lock could be removed
        CollateralLock.Data[] memory locks =
            ICollateralModule(address(synthetix)).getLocks(1, address(collateral), 0, 0);
        assertEq(locks.length, 2);
    }
}
