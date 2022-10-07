// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { SynthetixV3Test } from "./bootstrap/SynthetixV3Test.t.sol";

contract BasicTest is SynthetixV3Test {
    function setUp() public {
        _bootstrapWithMarket();
    }

    function testBasic() public {}
}
