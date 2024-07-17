//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {IOracleManagerRouter} from "src/generated/routers/OracleManagerRouter.g.sol";

import {Cannon} from "test/cannon/Cannon.sol";
import {CannonScript as OracleManager} from "test/cannon/schemas/oracle-manager.cannon.sol";

import "forge-std/Test.sol";

contract OracleManagerIntegrationTest is Test {
    IOracleManagerRouter oracleManager;
    
    function setUp() public {
        OracleManager.deploy();        
        oracleManager = IOracleManagerRouter(Cannon.resolve("oracle-manager.Proxy"));
    }

    function test_owner() public view {
        assertEq(oracleManager.owner(), address(this));
    }
}