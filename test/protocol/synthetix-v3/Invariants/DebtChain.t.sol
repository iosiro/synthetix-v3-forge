//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {SynthetixV3Test} from "test/protocol/synthetix-v3/SynthetixV3Test.t.sol";

contract DebtChainTest is SynthetixV3Test {
    function setUp() public {
        bootstrapWithMockMarketAndPool();

        targetContract(system.synthetix);
    }

    function invariant_totalUSD() public {
        assertLe(system.snxUSD.totalSupply(), 1000 ether);
    }
}
