//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {SynthetixForkTest} from "./SynthetixForkTest.t.sol";
import {OracleManagerForkTest} from "./OracleManagerForkTest.t.sol";
import {PerpMarketForkTest} from "./PerpMarketForkTest.t.sol";

import {IPerpMarketRouter} from "src/generated/routers/PerpMarketRouter.g.sol";
import {ICoreRouter} from "src/generated/routers/CoreRouter.g.sol";
import { RevertUtil } from "@synthetixio/core-contracts/contracts/utils/RevertUtil.sol";

import { Test } from "forge-std/Test.sol";

contract ArbitrumMainnetForkTest is Test{
    
    address payable constant internal ORACLE_MANAGER_PROXY = payable(0x0aaF300E148378489a8A471DD3e9E53E30cb42e3);
    address payable constant internal CORE_PROXY = payable(0xffffffaEff0B96Ea8e4f94b2253f31abdD875847);
    address payable constant internal ACCOUNT_PROXY = payable(0xD935444f5dc75A407ed475C9F387e124911d36C6);
    address payable constant internal USD_PROXY = payable(0xb2F30A7C980f052f02563fb518dcc39e6bf38175);
    address payable constant internal PERP_MARKET_PROXY = payable(0xd762960c31210Cf1bDf75b06A5192d395EEDC659);


    function upgrade() public  {
        SynthetixForkTest.upgrade({
            CORE_PROXY: CORE_PROXY,
            ACCOUNT_PROXY: ACCOUNT_PROXY,
            USD_PROXY: USD_PROXY
        });
        OracleManagerForkTest.upgrade({
            ORACLE_MANAGER_PROXY: ORACLE_MANAGER_PROXY
        });
        PerpMarketForkTest.upgrade({
            PERP_MARKET_PROXY: PERP_MARKET_PROXY
        });
    }
    function setUp() public {
        upgrade();
    }

    function test_simple() public {
        vm.warp(block.timestamp + 365 days);
        IPerpMarketRouter(PERP_MARKET_PROXY).getAvailableMargin(2);
    }

    function testProcessManyWithManyRuntimeReverts() external {
        //Toggle bypass modifier on and off
        uint128 runAsAccountId = 2;
        vm.expectPartialRevert(RevertUtil.Errors.selector);
        IPerpMarketRouter(PERP_MARKET_PROXY).liquidate(runAsAccountId);
    }

    function test_rebalancePoolWorks() public {
        ICoreRouter(CORE_PROXY).rebalancePool(1, address(0));
    }

}