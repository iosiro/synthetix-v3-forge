//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import { NodeModule } from "@synthetixio/oracle-manager/contracts/modules/NodeModule.sol";
import { CoreModule } from "@synthetixio/oracle-manager/contracts/modules/CoreModule.sol";

import "src/generated/routers/OracleRouter.g.sol";
import { Proxy } from "@synthetixio/main/contracts/Proxy.sol";

import { CoreModuleDeployment } from "./CoreModules.t.sol";

contract OracleManagerDeployment is CoreModuleDeployment {

    address internal oracleManager;

    function setUp() public virtual override {
        super.setUp();

        vm.etch(_CORE_MODULE, address(new CoreModule()).code);
        vm.etch(_NODE_MODULE, address(new NodeModule()).code);
    
        OracleRouter oracleRouter = new OracleRouter();
        Proxy oracleRouterProxy = new Proxy(address(oracleRouter), address(this));   

        oracleManager = address(oracleRouterProxy);
    }
}