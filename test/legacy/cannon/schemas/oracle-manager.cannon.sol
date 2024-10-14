//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {Cannon} from "test/legacy/cannon/Cannon.sol";

import {OracleManagerRouter} from "src/generated/routers/OracleManagerRouter.g.sol";

import {CoreModule} from "@synthetixio/oracle-manager/contracts/modules/CoreModule.sol";

import {Proxy} from "@synthetixio/oracle-manager/contracts/Proxy.sol";
import {NodeModule} from "@synthetixio/oracle-manager/contracts/modules/NodeModule.sol";

library CannonScript {
    function deploy() internal {
        Proxy proxy = new Proxy(
            address(
                new OracleManagerRouter(
                    OracleManagerRouter.Modules({
                        nodeModule: address(new NodeModule()),
                        coreModule: address(new CoreModule())
                    })
                )
            ),
            address(this)
        );
        Cannon.register("oracle-manager.Proxy", address(proxy));
    }
}
