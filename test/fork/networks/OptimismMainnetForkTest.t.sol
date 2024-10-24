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

contract ArbitrumMainnetForkTest is Test {
    // Sourced from: https://github.com/Synthetixio/v3-contracts/blob/master/10-main/meta.json

    // Proxies
    address payable internal constant ORACLE_MANAGER_PROXY = payable(0x0aaF300E148378489a8A471DD3e9E53E30cb42e3);
    address payable internal constant CORE_PROXY = payable(0xffffffaEff0B96Ea8e4f94b2253f31abdD875847);
    address payable internal constant ACCOUNT_PROXY = payable(0x0E429603D3Cb1DFae4E6F52Add5fE82d96d77Dac);
    address payable internal constant USD_PROXY = payable(0xb2F30A7C980f052f02563fb518dcc39e6bf38175);
    address payable internal constant PERP_MARKET_PROXY = payable(0xd762960c31210Cf1bDf75b06A5192d395EEDC659);
    address payable internal constant PERP_ACCOUNT_PROXY = payable(0xcb68b813210aFa0373F076239Ad4803f8809e8cf);
    address payable internal constant SPOT_MARKET_PROXY = payable(0x38908Ee087D7db73A1Bd1ecab9AAb8E8c9C74595);

    // Collaterals
    address payable internal constant COLLATERAL_ARB = payable(0x912CE59144191C1204E64559FE8253a0e49E6548);
    address payable internal constant COLLATERAL_USDC = payable(0xaf88d065e77c8cC2239327C5EDb3A432268e5831);
    address payable internal constant COLLATERAL_WETH = payable(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    address payable internal constant COLLATERAL_USDE = payable(0x5d3a1Ff2b6BAb83b63cd9AD0787074081a52ef34);
    address payable internal constant COLLATERAL_TBTC = payable(0x6c84a8f1c29108F47a79964b5Fe888D4f4D0dE40);
    address payable internal constant COLLATERAL_SETH = payable(0x3Ec3FedA50b718b5A9ff387F93EeA7841D795B1E);
    address payable internal constant COLLATERAL_STBTC = payable(0xFA86aB03412Ab63Fea238d43D1E839c4F7A80232);
    address payable internal constant COLLATERAL_SOL = payable(0xb74Da9FE2F96B9E0a5f4A3cf0b92dd2bEC617124);
    address payable internal constant COLLATERAL_SWSOL = payable(0x7301a8DBd293b85A06726aE12E433a829ba3B871);
    address payable internal constant COLLATERAL_SUSDE = payable(0xE3eE09c200584228F7C45d50E12BcC3fb65c19Ca);
    address payable internal constant COLLATERAL_WEETH = payable(0x35751007a407ca6FEFfE80b3cB397736D2cf4dbe);
    address payable internal constant COLLATERAL_WSTETH = payable(0x5979D7b546E38E414F7E9822514be443A4800529);
    address payable internal constant COLLATERAL_SUSDE_1 = payable(0x211Cc4DD073734dA055fbF44a2b4667d5E5fE5d2);

    // Synths
    address payable internal SYNTH_USDC = payable(0xE81Be4495f138FAE5846d21AC2cA822BEf452365);
    address payable internal SYNTH_ETH = payable(0x3Ec3FedA50b718b5A9ff387F93EeA7841D795B1E);
    address payable internal SYNTH_USDe = payable(0xE3eE09c200584228F7C45d50E12BcC3fb65c19Ca);
    address payable internal SYNTH_TBTC = payable(0xFA86aB03412Ab63Fea238d43D1E839c4F7A80232);
    address payable internal SYNTH_WSOL = payable(0x7301a8DBd293b85A06726aE12E433a829ba3B871);

    // Misc
    address payable internal PYTH_ERC7412_WRAPPER = payable(0x7b118596be900f3c0feB2f23758d9798965B72a3);
    address payable internal constant TRUSTED_MULTICALL_FORWARDER = payable(0xE2C5658cC5C448B48141168f3e475dF8f65A1e3e);

    function upgrade() public {
        SynthetixForkTest.upgrade({CORE_PROXY: CORE_PROXY, ACCOUNT_PROXY: ACCOUNT_PROXY, USD_PROXY: USD_PROXY});
        OracleManagerForkTest.upgrade({ORACLE_MANAGER_PROXY: ORACLE_MANAGER_PROXY});
        PerpMarketForkTest.upgrade({PERP_MARKET_PROXY: PERP_MARKET_PROXY, CORE_PROXY: CORE_PROXY});
        SpotMarketForkTest.upgrade({SPOT_MARKET_PROXY: SPOT_MARKET_PROXY});
    }

    function setUp() public {
        upgrade();
    }
}
