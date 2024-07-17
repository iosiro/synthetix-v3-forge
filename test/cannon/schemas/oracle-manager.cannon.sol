//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {Cannon} from "test/cannon/Cannon.sol";

import {OracleManagerRouter} from "src/generated/routers/OracleManagerRouter.g.sol";

import {CoreModule} from "@synthetixio/oracle-manager/contracts/modules/CoreModule.sol";

import {Proxy} from "@synthetixio/oracle-manager/contracts/Proxy.sol";
import {NodeModule} from "@synthetixio/oracle-manager/contracts/modules/NodeModule.sol";

import "lib/synthetix-v3/protocol/synthetix/contracts/modules/account/AccountTokenModule.sol";

library CannonScript {

    function deploy() internal {
        new AccountTokenModule();
        new NodeModule{salt: 0x00}();
        new CoreModule{salt: 0x00}();
        Proxy proxy = new Proxy{salt: 0x00}(address(new OracleManagerRouter()), address(this));
        Cannon.register("oracle-manager.Proxy", address(proxy));
    }
}