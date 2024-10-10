//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {ArbitrumMainnetPerpMarketForkTest} from "./ArbitrumMainnetPerpMarketForkTest.t.sol";
import {ArbitrumMainnetSynthetixForkTest} from "./ArbitrumMainnetSynthetixForkTest.t.sol";
import {ArbitrumMainnetOracleManagerForkTest} from "./ArbitrumMainnetOracleManagerForkTest.t.sol";

import {IPerpMarketRouter} from "src/generated/routers/PerpMarketRouter.g.sol";

contract BaseMainnetForkTest is ArbitrumMainnetPerpMarketForkTest, ArbitrumMainnetSynthetixForkTest, ArbitrumMainnetOracleManagerForkTest {

    function upgrade() override(ArbitrumMainnetPerpMarketForkTest, ArbitrumMainnetSynthetixForkTest, ArbitrumMainnetOracleManagerForkTest) public  {
        ArbitrumMainnetPerpMarketForkTest.upgrade();
        ArbitrumMainnetSynthetixForkTest.upgrade();
        ArbitrumMainnetOracleManagerForkTest.upgrade();
    }
    function setUp() public {
        upgrade();
    }

    function test_simple() public {
        //vm.warp(block.timestamp + 365 days);
        //IPerpMarketRouter(PERP_MARKET_PROXY).getAvailableMargin(2);
    }

}