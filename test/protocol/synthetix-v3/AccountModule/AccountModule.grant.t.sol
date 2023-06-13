//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {AccountModule} from "@synthetixio/main/contracts/modules/core/AccountModule.sol";
import {IAccountModule} from "@synthetixio/main/contracts/interfaces/IAccountModule.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

import {SynthetixV3Test} from "test/protocol/synthetix-v3/SynthetixV3Test.t.sol";

contract AccountModuleCreateTest is SynthetixV3Test {
    uint128 constant HALF_UINT128_MAX = type(uint128).max / 2;

    function setUp() public {
        bootstrap();

        {
            vm.prank(user1);
            AccountModule(system.synthetix).createAccount(1);
        }
    }

    // before permissions have been granted
    function test_initialPermissions() public as_user(user1) {
        // shows that certain permissions have not been granted
        assertEq(AccountModule(system.synthetix).hasPermission(1, "WITHDRAW", user2), false);
        assertEq(AccountModule(system.synthetix).hasPermission(1, "ADMIN", user2), false);

        // shows that the owner is authorized
        assertEq(AccountModule(system.synthetix).isAuthorized(1, "WITHDRAW", user1), true);
        assertEq(AccountModule(system.synthetix).isAuthorized(1, "ADMIN", user1), true);

        // shows that the other user not authorized
        assertEq(AccountModule(system.synthetix).isAuthorized(1, "WITHDRAW", user2), false);
        assertEq(AccountModule(system.synthetix).isAuthorized(1, "ADMIN", user2), false);
    }

    // when a non-authorized user attempts to grant permissions
    function test_permissionDenied() public as_user(user2) {
        vm.expectRevert(
            abi.encodeWithSignature("PermissionDenied(uint128,bytes32,address)", 1, bytes32("ADMIN"), user2)
        );
        AccountModule(system.synthetix).grantPermission(1, "WITHDRAW", user2);
    }

    // when a an authorized user attempts to grant an invalid permission
    function test_invalidPermission() public as_user(user1) {
        vm.expectRevert(abi.encodeWithSignature("InvalidPermission(bytes32)", bytes32("INVALID")));
        AccountModule(system.synthetix).grantPermission(1, "INVALID", user2);
    }

    event PermissionGranted(
        uint128 indexed accountId, bytes32 indexed permission, address indexed user, address sender
    );

    // when a permission is granted by the owner
    function test_grantPermission() public as_user(user1) {
        vm.expectEmit();
        emit PermissionGranted(1, "WITHDRAW", user2, user1);
        AccountModule(system.synthetix).grantPermission(1, "WITHDRAW", user2);

        // shows that the permission is granted
        assertEq(AccountModule(system.synthetix).hasPermission(1, "WITHDRAW", user2), true);
    }

    // when a permission is revoked
    function test_revokePermission() public as_user(user1) {
        AccountModule(system.synthetix).grantPermission(1, "WITHDRAW", user2);

        // revoke the permission
        AccountModule(system.synthetix).revokePermission(1, "WITHDRAW", user2);
    }

    // when the ADMIN permission is granted by the owner
    function test_adminPermissions() public as_user(user1) {
        // owner grants the admin permission
        AccountModule(system.synthetix).grantPermission(1, "ADMIN", user2);

        // shows that the admin permission is granted by the owner
        AccountModule(system.synthetix).hasPermission(1, "ADMIN", user2);

        // shows that the admin is authorized to all permissions
        assertEq(AccountModule(system.synthetix).isAuthorized(1, "ADMIN", user2), true);
        assertEq(AccountModule(system.synthetix).isAuthorized(1, "DELEGATE", user2), true);
        assertEq(AccountModule(system.synthetix).isAuthorized(1, "MINT", user2), true);
        assertEq(AccountModule(system.synthetix).isAuthorized(1, "WITHDRAW", user2), true);
    }

    // admin is able to grant permission
    function test_adminGrantPermissions() public {
        // owner grants the admin permission
        vm.prank(user1);
        AccountModule(system.synthetix).grantPermission(1, "ADMIN", user2);

        // admin grants a permission
        vm.prank(user2);
        AccountModule(system.synthetix).grantPermission(1, "WITHDRAW", user3);

        // shows that the permission is granted
        assertEq(AccountModule(system.synthetix).hasPermission(1, "WITHDRAW", user3), true);

        // admin is able to revoke a permission
        vm.prank(user2);
        AccountModule(system.synthetix).revokePermission(1, "WITHDRAW", user3);
        assertEq(AccountModule(system.synthetix).hasPermission(1, "WITHDRAW", user3), false);
    }
}
