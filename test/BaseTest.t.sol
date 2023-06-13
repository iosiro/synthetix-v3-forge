//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {Test} from "forge-std/Test.sol";

contract BaseTest is Test {
    address internal user1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address internal user2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address internal user3 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;

    modifier as_user(address user) {
        vm.startPrank(user);
        _;
        vm.stopPrank();
    }
}
