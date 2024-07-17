//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {IOracleManagerRouter} from "src/generated/routers/OracleManagerRouter.g.sol";
import {ICoreRouter} from "src/generated/routers/CoreRouter.g.sol";
import {IAccountRouter} from "src/generated/routers/AccountRouter.g.sol";
import {IUSDRouter} from "src/generated/routers/USDRouter.g.sol";

import {Cannon} from "test/cannon/Cannon.sol";
import {CannonScript as OracleManager} from "test/cannon/schemas/oracle-manager.cannon.sol";
import {CannonScript as Synthetix} from "test/cannon/schemas/synthetix.cannon.sol";

import "forge-std/Test.sol";

contract SynthetixIntegrationTestBase is Test {
    IOracleManagerRouter oracleManager;
    ICoreRouter synthetix;
    IAccountRouter account;
    IUSDRouter usd;

    
    function setUp() public {
        OracleManager.deploy();
        Synthetix.deploy();
        
        oracleManager = IOracleManagerRouter(Cannon.resolve("oracle-manager.Proxy"));
        synthetix = ICoreRouter(Cannon.resolve("synthetix.CoreProxy"));
        usd = IUSDRouter(Cannon.resolve("synthetix.USDProxy"));
        account = IAccountRouter(Cannon.resolve("synthetix.AccountProxy"));
    }
}