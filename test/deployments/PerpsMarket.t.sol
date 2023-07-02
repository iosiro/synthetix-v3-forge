//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "src/generated/routers/PerpsMarketRouter.g.sol";

import { Proxy } from "src/markets/perps-market/contracts/Proxy.sol";
import { SynthRouter, _SYNTH_TOKEN_MODULE } from "src/generated/routers/SynthRouter.g.sol";

import { SynthetixV3Deployment } from "./SynthetixV3.t.sol";

contract PerpsMarketDeployment is SynthetixV3Deployment {
   
    address internal perpsMarket;

    function setUp() public virtual override {
        SynthetixV3Deployment.setUp();

        PerpsMarketRouter perpsMarketRouter = new PerpsMarketRouter();
        Proxy perpsMarketRouterProxy = new Proxy(address(perpsMarketRouter), address(this));
        SynthRouter synthRouter = new SynthRouter();

        perpsMarket = address(perpsMarketRouterProxy);
    }
}