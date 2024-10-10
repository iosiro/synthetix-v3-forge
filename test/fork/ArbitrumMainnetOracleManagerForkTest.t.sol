//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;


import {Proxy} from "@synthetixio/main/contracts/Proxy.sol";

// Shared
import {InitialModuleBundle} from "@synthetixio/main/contracts/modules/InitialModuleBundle.sol";
import {AssociatedSystemsModule} from "@synthetixio/main/contracts/modules/associated-systems/AssociatedSystemsModule.sol";
import {AccountModule} from "@synthetixio/main/contracts/modules/core/AccountModule.sol";

import {OracleManagerRouter, IOracleManagerRouter} from "src/generated/routers/OracleManagerRouter.g.sol";

import {CoreModule} from "@synthetixio/oracle-manager/contracts/modules/CoreModule.sol";
import { NodeModule } from "@synthetixio/oracle-manager/contracts/modules/NodeModule.sol";

import {Test} from "forge-std/Test.sol";

contract ArbitrumMainnetOracleManagerForkTest is Test {
    //address constant private SPOT_MARKET_PROXY = 0xa65538A6B9A8442854dEcB6E3F85782C60757D60;
    address payable constant private ORACLE_MANAGER_PROXY = payable(0x0aaF300E148378489a8A471DD3e9E53E30cb42e3);

    function upgrade() virtual public {
        
        OracleManagerRouter oracleManagerRouter = new OracleManagerRouter(OracleManagerRouter.Modules({
            nodeModule: address(new NodeModule()),
            coreModule: address(new CoreModule())
        }));

        vm.prank(IOracleManagerRouter(ORACLE_MANAGER_PROXY).owner());
        IOracleManagerRouter(ORACLE_MANAGER_PROXY).upgradeTo(address(oracleManagerRouter));
    }
}