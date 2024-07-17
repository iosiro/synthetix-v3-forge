//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {IAccountModule} from "@synthetixio/main/contracts/interfaces/IAccountModule.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

import {SynthetixLegacyTestBase} from "test/legacy/protocol/main/common/SynthetixLegacyTestBase.t.sol";

// Based off of https://github.com/Synthetixio/synthetix-v3/blob/main/protocol/synthetix/test/integration/modules/core/AccountModule/AccountModule.grant.test.ts

contract AccountModuleCreateTest is SynthetixLegacyTestBase {

    function setUp() public override {
        super.setUp();
        
        vm.prank(user1);
        synthetix.createAccount(1);
    }

    // before permissions have been granted
    function test_initialPermissions() public as_user(user1) {
        // shows that certain permissions have not been granted
        assertEq(synthetix.hasPermission(1, "WITHDRAW", user2), false);
        assertEq(synthetix.hasPermission(1, "ADMIN", user2), false);

        // shows that the owner is authorized
        assertEq(synthetix.isAuthorized(1, "WITHDRAW", user1), true);
        assertEq(synthetix.isAuthorized(1, "ADMIN", user1), true);

        // shows that the other user not authorized
        assertEq(synthetix.isAuthorized(1, "WITHDRAW", user2), false);
        assertEq(synthetix.isAuthorized(1, "ADMIN", user2), false);
    }

    // when a non-authorized user attempts to grant permissions
    function test_permissionDenied() public as_user(user2) {
        vm.expectRevert(
            abi.encodeWithSignature("PermissionDenied(uint128,bytes32,address)", 1, bytes32("ADMIN"), user2)
        );
        synthetix.grantPermission(1, "WITHDRAW", user2);
    }

    // when a an authorized user attempts to grant an invalid permission
    function test_invalidPermission() public as_user(user1) {
        vm.expectRevert(abi.encodeWithSignature("InvalidPermission(bytes32)", bytes32("INVALID")));
        synthetix.grantPermission(1, "INVALID", user2);
    }

    // when a permission is granted by the owner
    function test_grantPermission() public as_user(user1) {
        vm.expectEmit();
        emit IAccountModule.PermissionGranted(1, "WITHDRAW", user2, user1);
        synthetix.grantPermission(1, "WITHDRAW", user2);

        // shows that the permission is granted
        assertEq(synthetix.hasPermission(1, "WITHDRAW", user2), true);
    }

    // when a permission is revoked
    function test_revokePermission() public as_user(user1) {
        synthetix.grantPermission(1, "WITHDRAW", user2);

        // revoke the permission
        synthetix.revokePermission(1, "WITHDRAW", user2);
    }

    // when the ADMIN permission is granted by the owner
    function test_adminPermissions() public as_user(user1) {
        // owner grants the admin permission
        synthetix.grantPermission(1, "ADMIN", user2);

        // shows that the admin permission is granted by the owner
        synthetix.hasPermission(1, "ADMIN", user2);

        // shows that the admin is authorized to all permissions
        assertEq(synthetix.isAuthorized(1, "ADMIN", user2), true);
        assertEq(synthetix.isAuthorized(1, "DELEGATE", user2), true);
        assertEq(synthetix.isAuthorized(1, "MINT", user2), true);
        assertEq(synthetix.isAuthorized(1, "WITHDRAW", user2), true);
    }

    // admin is able to grant permission
    function test_adminGrantPermissions() public {
        // owner grants the admin permission
        vm.prank(user1);
        synthetix.grantPermission(1, "ADMIN", user2);

        // admin grants a permission
        vm.prank(user2);
        synthetix.grantPermission(1, "WITHDRAW", user3);

        // shows that the permission is granted
        assertEq(synthetix.hasPermission(1, "WITHDRAW", user3), true);

        // admin is able to revoke a permission
        vm.prank(user2);
        synthetix.revokePermission(1, "WITHDRAW", user3);
        assertEq(synthetix.hasPermission(1, "WITHDRAW", user3), false);
    }
}