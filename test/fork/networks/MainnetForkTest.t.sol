//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {SynthetixForkTest} from "test/fork/deployments/SynthetixForkTest.t.sol";
import {OracleManagerForkTest} from "test/fork/deployments/OracleManagerForkTest.t.sol";
import {PerpMarketForkTest} from "test/fork/deployments/PerpMarketForkTest.t.sol";
import {SpotMarketForkTest} from "test/fork/deployments/SpotMarketForkTest.t.sol";

import {IOracleManagerRouter} from "src/generated/routers/OracleManagerRouter.g.sol";
import {ICoreRouter} from "src/generated/routers/CoreRouter.g.sol";
import {IPerpMarketRouter} from "src/generated/routers/PerpMarketRouter.g.sol";
import {ISpotMarketRouter} from "src/generated/routers/SpotMarketRouter.g.sol";

import {Test} from "forge-std/Test.sol";

contract MainnetForkTest is Test {
    // Sourced from: https://github.com/Synthetixio/v3-contracts/blob/master/1-main/meta.json

    // Proxies
    address payable internal constant ORACLE_MANAGER_PROXY = payable(0x0aaF300E148378489a8A471DD3e9E53E30cb42e3);
    address payable internal constant CORE_PROXY = payable(0xffffffaEff0B96Ea8e4f94b2253f31abdD875847);
    address payable internal constant ACCOUNT_PROXY = payable(0x0E429603D3Cb1DFae4E6F52Add5fE82d96d77Dac);
    address payable internal constant USD_PROXY = payable(0xb2F30A7C980f052f02563fb518dcc39e6bf38175);
    address payable internal constant SPOT_MARKET_PROXY = payable(0x2CD12CcAc6F869650bA88a220b2eb91a937FA5c0);
    address payable internal constant LEGACY_MARKET_PROXY = payable(0x3AcF163B9E6a384D539e10dAc7e11213c638b2f5);

    // Collaterals
    address payable internal constant COLLATERAL_SNX = payable(0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F);

    // Synths
    address payable internal SYNTH_snxUSDe = payable(0x3f3eD1002F55121b8213182f09d4BE544E08B9F9);

    // V2x
    address payable internal constant SYNTHETIX_V2X = payable(0xd711709eFc452152B7ad11DbD01ed4B69c9421B3);
    address payable internal constant SYNTHETIX_V2X_sUSD = payable(0x10A5F7D9D65bCc2734763444D4940a31b109275f);

    // Misc
    address payable internal constant TRUSTED_MULTICALL_FORWARDER = payable(0xE2C5658cC5C448B48141168f3e475dF8f65A1e3e);

    function upgrade() public {
        SynthetixForkTest.upgrade({CORE_PROXY: CORE_PROXY, ACCOUNT_PROXY: ACCOUNT_PROXY, USD_PROXY: USD_PROXY});
        OracleManagerForkTest.upgrade({ORACLE_MANAGER_PROXY: ORACLE_MANAGER_PROXY});
        // PerpMarketForkTest.upgrade({PERP_MARKET_PROXY: PERP_MARKET_PROXY});
        SpotMarketForkTest.upgrade({SPOT_MARKET_PROXY: SPOT_MARKET_PROXY});
    }

    function setUp() public {
        upgrade();
    }
}
