// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SynthetixV3Test, IERC20, CollateralMock, AggregatorV3Mock, NodeDefinition, CollateralConfiguration} from "./bootstrap/SynthetixV3Test.t.sol";

import "forge-std/console2.sol";

contract BasicTest is SynthetixV3Test {
    function setUp() public {
        _bootstrapWithMarket();
    }

    
}
