//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {AccountModule} from "@synthetixio/main/contracts/modules/core/AccountModule.sol";
import {AccountTokenModule} from "@synthetixio/main/contracts/modules/account/AccountTokenModule.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

import {InitialModuleBundle} from "@synthetixio/main/contracts/modules/InitialModuleBundle.sol";
import {IERC721Metadata} from "forge-std/interfaces/IERC721.sol";

import {Test} from "forge-std/Test.sol";

import {SynthetixV3Test} from "test/protocol/synthetix-v3/SynthetixV3Test.t.sol";

contract AccountModuleCreateTest is SynthetixV3Test {
    uint128 constant HALF_UINT128_MAX = type(uint128).max / 2;

    function setUp() public {
        bootstrap();
    }

    // when the core and account systems are deployed and set up
    function test_initialization() public {
        // sets the account system address in the core system
        assertEq(AccountModule(system.synthetix).getAccountTokenAddress(), address(system.account));

        // sets the core system as the owner of the account system
        assertEq(InitialModuleBundle(address(system.account)).owner(), address(system.synthetix));

        // initializes the account system correctly
        assertEq(IERC721Metadata(address(system.account)).name(), "Synthetix Account");
        assertEq(IERC721Metadata(address(system.account)).symbol(), "SACCT");
    }

    event AccountCreated(uint128 indexed accountId, address indexed owner);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function test_createAccount() public as_user(user1) {
        vm.expectEmit();
        emit AccountCreated(1, address(user1));
        emit Transfer(address(0), address(user1), 1);
        AccountModule(system.synthetix).createAccount(1);

        assertEq(system.account.ownerOf(1), address(user1));
        assertEq(system.account.balanceOf(address(user1)), 1);

        vm.expectRevert(abi.encodeWithSignature("TokenAlreadyMinted(uint256)", 1));
        AccountModule(system.synthetix).createAccount(1);
    }

    function test_createAccountOverMax() public as_user(user1) {
        vm.expectRevert(abi.encodeWithSignature("InvalidAccountId(uint128)", HALF_UINT128_MAX));
        AccountModule(system.synthetix).createAccount(HALF_UINT128_MAX);

        vm.expectRevert(abi.encodeWithSignature("InvalidAccountId(uint128)", HALF_UINT128_MAX + 1));
        AccountModule(system.synthetix).createAccount(HALF_UINT128_MAX + 1);
    }

    function test_createSeries() public as_user(user1) {
        vm.expectEmit();
        emit AccountCreated(HALF_UINT128_MAX, address(user1));
        uint128 accountId = AccountModule(system.synthetix).createAccount();
        assertEq(accountId, HALF_UINT128_MAX);

        vm.expectEmit();
        emit AccountCreated(HALF_UINT128_MAX + 1, address(user1));
        accountId = AccountModule(system.synthetix).createAccount();
        assertEq(accountId, HALF_UINT128_MAX + 1);
    }

    function test_mint() public as_user(user1) {
        // when a user attempts to mint an account token via the account system directly
        vm.expectRevert(abi.encodeWithSignature("Unauthorized(address)", user1));
        AccountTokenModule(address(system.account)).mint(user1, 1);
    }

    // when an account NFT is transferred
    function test_transfer() public as_user(user1) {
        AccountModule(system.synthetix).createAccount(1);

        // grant some permissions
        AccountModule(system.synthetix).grantPermission(1, "REWARDS", user1);
        AccountModule(system.synthetix).grantPermission(1, "WITHDRAW", user3);
        AccountModule(system.synthetix).grantPermission(1, "DELEGATE", user2);

        AccountModule(system.synthetix).grantPermission(1, "DELEGATE", user1);

        system.account.transferFrom(user1, user2, 1);

        // records the new owner in the account system
        assertEq(system.account.ownerOf(1), user2);
        assertEq(system.account.balanceOf(user2), 1);
        assertEq(system.account.balanceOf(user1), 0);

        // records the new owner in the core system
        assertEq(AccountModule(system.synthetix).getAccountOwner(1), user2);

        // shows the previous owner permissions have been revoked
        assertEq(AccountModule(system.synthetix).hasPermission(1, "DELEGATE", user1), false);

        // shows that other accounts permissions have been revoked
        assertEq(AccountModule(system.synthetix).hasPermission(1, "WITHDRAW", user3), false);
        assertEq(AccountModule(system.synthetix).hasPermission(1, "ADMIN", user3), false);
    }
}
