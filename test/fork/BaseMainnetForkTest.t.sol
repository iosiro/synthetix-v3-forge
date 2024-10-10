//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {ArbitrumMainnetPerpMarketForkTest} from "./ArbitrumMainnetPerpMarketForkTest.t.sol";
import {ArbitrumMainnetSynthetixForkTest} from "./ArbitrumMainnetSynthetixForkTest.t.sol";

contract BaseMainnetForkTest is ArbitrumMainnetPerpMarketForkTest, ArbitrumMainnetSynthetixForkTest {

    function upgrade() override(ArbitrumMainnetPerpMarketForkTest, ArbitrumMainnetSynthetixForkTest) public  {
        ArbitrumMainnetPerpMarketForkTest.upgrade();
        ArbitrumMainnetSynthetixForkTest.upgrade();
    }
    function setUp() public {
        upgrade();
    }

    function test_simple() public {

    }

}