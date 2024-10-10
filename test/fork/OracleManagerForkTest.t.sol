//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {vm} from "test/common/Vm.t.sol";

import {Proxy} from "@synthetixio/main/contracts/Proxy.sol";

// Shared
import {InitialModuleBundle} from "@synthetixio/main/contracts/modules/InitialModuleBundle.sol";
import {AssociatedSystemsModule} from "@synthetixio/main/contracts/modules/associated-systems/AssociatedSystemsModule.sol";
import {AccountModule} from "@synthetixio/main/contracts/modules/core/AccountModule.sol";

import {OracleManagerRouter, IOracleManagerRouter} from "src/generated/routers/OracleManagerRouter.g.sol";

import {CoreModule} from "@synthetixio/oracle-manager/contracts/modules/CoreModule.sol";
import { NodeModule } from "@synthetixio/oracle-manager/contracts/modules/NodeModule.sol";

library OracleManagerForkTest {
    function upgrade(address ORACLE_MANAGER_PROXY) public {
        
        OracleManagerRouter oracleManagerRouter = new OracleManagerRouter(OracleManagerRouter.Modules({
            nodeModule: address(new NodeModule()),
            coreModule: address(new CoreModule())
        }));

        vm.prank(IOracleManagerRouter(ORACLE_MANAGER_PROXY).owner());
        IOracleManagerRouter(ORACLE_MANAGER_PROXY).upgradeTo(address(oracleManagerRouter));
    }
}