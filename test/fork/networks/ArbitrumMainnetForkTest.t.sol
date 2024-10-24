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
    // Sourced from: https://github.com/Synthetixio/v3-contracts/blob/master/42161-main/meta.json

    // Proxies
    address payable internal constant ORACLE_MANAGER_PROXY = payable(0x0aaF300E148378489a8A471DD3e9E53E30cb42e3);
    address payable internal constant CORE_PROXY = payable(0xffffffaEff0B96Ea8e4f94b2253f31abdD875847);
    address payable internal constant ACCOUNT_PROXY = payable(0x0E429603D3Cb1DFae4E6F52Add5fE82d96d77Dac);
    address payable internal constant USD_PROXY = payable(0xb2F30A7C980f052f02563fb518dcc39e6bf38175);
    address payable internal constant PERP_MARKET_PROXY = payable(0xd762960c31210Cf1bDf75b06A5192d395EEDC659);
    address payable internal constant PERP_ACCOUNT_PROXY = payable(0xD935444f5dc75A407ed475C9F387e124911d36C6);
    address payable internal constant SPOT_MARKET_PROXY = payable(0xa65538A6B9A8442854dEcB6E3F85782C60757D60);

    // Collaterals
    address payable internal constant COLLATERAL_SNX = payable(0x8700dAec35aF8Ff88c16BdF0418774CB3D7599B4);
    address payable internal constant COLLATERAL_WETH = payable(0x4200000000000000000000000000000000000006);

    // Synths
    address payable internal SYNTH_ETH = payable(0x08b2A7e830258F28c9c04501447a8bc83DCE42bE);

    // Misc
    address payable internal constant TRUSTED_MULTICALL_FORWARDER = payable(0xE2C5658cC5C448B48141168f3e475dF8f65A1e3e);

    function upgrade() public {
        SynthetixForkTest.upgrade({CORE_PROXY: CORE_PROXY, ACCOUNT_PROXY: ACCOUNT_PROXY, USD_PROXY: USD_PROXY});
        OracleManagerForkTest.upgrade({ORACLE_MANAGER_PROXY: ORACLE_MANAGER_PROXY});
        PerpMarketForkTest.upgrade({PERP_MARKET_PROXY: PERP_MARKET_PROXY, CORE_PROXY: CORE_PROXY});
        SpotMarketForkTest.upgrade({SPOT_MARKET_PROXY: SPOT_MARKET_PROXY});
    }

    function setUp() virtual public {
        upgrade();
    }
}
