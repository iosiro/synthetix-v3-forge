//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {IAccountModule} from "@synthetixio/main/contracts/interfaces/IAccountModule.sol";
import {IERC721Metadata} from "forge-std/interfaces/IERC721.sol";

import {SynthetixLegacyTestBase} from "test/legacy/protocol/main/common/SynthetixLegacyTestBase.t.sol";

// Based on:
// - https://github.com/Synthetixio/synthetix-v3/blob/main/protocol/synthetix/test/integration/modules/core/AccountModule/AccountModule.create.test.ts
// - https://github.com/Synthetixio/synthetix-v3/blob/main/protocol/synthetix/test/integration/modules/core/AccountModule/AccountModule.init.test.SynthetixLegacyTestBase
// - https://github.com/Synthetixio/synthetix-v3/blob/main/protocol/synthetix/test/integration/modules/core/AccountModule/AccountModule.transfer.test.ts
// - https://github.com/Synthetixio/synthetix-v3/blob/main/protocol/synthetix/test/integration/modules/core/AccountModule/AccountModule.mint.test.ts

contract AccountModuleCreateTest is SynthetixLegacyTestBase {
    uint128 constant HALF_UINT128_MAX = type(uint128).max / 2;

    function setUp() public override {
        super.setUp();
    }

    // when the core and account systems are deployed and set up
    function test_initialization() public view {
        // sets the account system address in the core system
        assertEq(synthetix.getAccountTokenAddress(), address(account));

        // sets the core system as the owner of the account system
        assertEq(account.owner(), address(synthetix));

        // initializes the account system correctly
        assertEq(IERC721Metadata(address(account)).name(), "Synthetix Account");
        assertEq(IERC721Metadata(address(account)).symbol(), "SACCT");
    }

    event AccountCreated(uint128 indexed accountId, address indexed owner);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function test_createAccount() public as_user(user1) {
        vm.expectEmit();
        emit AccountCreated(1, address(user1));
        emit Transfer(address(0), address(user1), 1);
        synthetix.createAccount(1);

        assertEq(account.ownerOf(1), address(user1));
        assertEq(account.balanceOf(address(user1)), 1);

        vm.expectRevert(abi.encodeWithSignature("TokenAlreadyMinted(uint256)", 1));
        synthetix.createAccount(1);
    }

    function test_createAccountOverMax() public as_user(user1) {
        vm.expectRevert(abi.encodeWithSignature("InvalidAccountId(uint128)", HALF_UINT128_MAX));
        synthetix.createAccount(HALF_UINT128_MAX);

        vm.expectRevert(abi.encodeWithSignature("InvalidAccountId(uint128)", HALF_UINT128_MAX + 1));
        synthetix.createAccount(HALF_UINT128_MAX + 1);
    }

    function test_createSeries() public as_user(user1) {
        vm.expectEmit();
        emit AccountCreated(HALF_UINT128_MAX, address(user1));
        uint128 accountId = synthetix.createAccount();
        assertEq(accountId, HALF_UINT128_MAX);

        vm.expectEmit();
        emit AccountCreated(HALF_UINT128_MAX + 1, address(user1));
        accountId = synthetix.createAccount();
        assertEq(accountId, HALF_UINT128_MAX + 1);
    }

    function test_mint() public as_user(user1) {
        // when a user attempts to mint an account token via the account system directly
        vm.expectRevert(abi.encodeWithSignature("Unauthorized(address)", user1));
        account.mint(user1, 1);
    }

    // when an account NFT is transferred
    function test_transfer() public as_user(user1) {
        synthetix.createAccount(1);

        // grant some permissions
        synthetix.grantPermission(1, "REWARDS", user1);
        synthetix.grantPermission(1, "WITHDRAW", user3);
        synthetix.grantPermission(1, "DELEGATE", user2);

        synthetix.grantPermission(1, "DELEGATE", user1);

        account.transferFrom(user1, user2, 1);

        // records the new owner in the account system
        assertEq(account.ownerOf(1), user2);
        assertEq(account.balanceOf(user2), 1);
        assertEq(account.balanceOf(user1), 0);

        // records the new owner in the core system
        assertEq(synthetix.getAccountOwner(1), user2);

        // shows the previous owner permissions have been revoked
        assertEq(synthetix.hasPermission(1, "DELEGATE", user1), false);

        // shows that other accounts permissions have been revoked
        assertEq(synthetix.hasPermission(1, "WITHDRAW", user3), false);
        assertEq(synthetix.hasPermission(1, "ADMIN", user3), false);
    }
}
