//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {LegacyMarket} from "@synthetixio/legacy-market/contracts/LegacyMarket.sol";
import {InitialModuleBundle} from "@synthetixio/legacy-market/contracts/InitialModuleBundle.sol";
import {Proxy} from "@synthetixio/legacy-market/contracts/Proxy.sol";

import "src/generated/routers/LegacyMarketRouter.g.sol";

import {SynthetixV3Deployment} from "./SynthetixV3.t.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

import {vm} from "./Vm.t.sol";

library LegacyMarketDeployment {
    struct LegacyMarketSystem {
        address core;
        address oracleManager;
        IERC20 snxUSD;
        IERC721 accountNft;
        address accountRouter;
        address usdRouter;
        address legacyMarket;
    }

    function deploy() internal returns (LegacyMarketSystem memory system) {
        SynthetixV3Deployment.SynthetixV3System memory synthetixV3 = SynthetixV3Deployment.deploy();

        system.core = synthetixV3.core;
        system.oracleManager = synthetixV3.oracleManager;
        system.snxUSD = synthetixV3.snxUSD;
        system.accountNft = synthetixV3.accountNft;
        system.accountRouter = synthetixV3.accountRouter;
        system.usdRouter = synthetixV3.usdRouter;
        //vm.etch(_INITIAL_MODULE_BUNDLE, address(new InitialModuleBundle()).code);
        vm.etch(_LEGACY_MARKET, address(new LegacyMarket(address(this))).code);

        LegacyMarketRouter legacyMarketRouter = new LegacyMarketRouter();
        Proxy legacyMarketRouterProxy = new Proxy(address(legacyMarketRouter), address(this));

        system.legacyMarket = address(legacyMarketRouterProxy);

        //LegacyMarket(legacyMarket).setSystemAddresses(, synthetixV3)
    }
}
