//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {IOracleManagerRouter} from "src/generated/routers/OracleManagerRouter.g.sol";
import {ICoreRouter} from "src/generated/routers/CoreRouter.g.sol";
import {IUSDRouter} from "src/generated/routers/USDRouter.g.sol";

import {Cannon} from "test/cannon/Cannon.sol";
import {CannonScript as OracleManager} from "test/cannon/schemas/oracle-manager.cannon.sol";
import {CannonScript as Synthetix} from "test/cannon/schemas/synthetix.cannon.sol";

import {SynthetixIntegrationTestBase} from "./SynthetixIntegrationTestBase.t.sol";

contract SynthetixUSDIntegrationTest is SynthetixIntegrationTestBase {

    function test_owner() public view {
        assertEq(usd.owner(), address(synthetix));
    }
}