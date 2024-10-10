//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {Test} from "forge-std/Test.sol";

abstract contract BaseLegacyTest is Test {

    address internal owner = address(this);
    address internal user1 = vm.addr(1);
    address internal user2 = vm.addr(2);
    address internal user3 = vm.addr(3);
    
    function setUp() public virtual {
        vm.warp(365 days);
    }

    modifier as_user(address user) {
        vm.startPrank(user);
        _;
        vm.stopPrank();
    }
}