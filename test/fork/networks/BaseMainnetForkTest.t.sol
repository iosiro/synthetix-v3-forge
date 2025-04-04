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

contract BaseMainnetForkTest is Test {
    // Sourced from: https://github.com/Synthetixio/v3-contracts/blob/master/8453-andromeda/meta.json

    // Proxies
    address payable internal constant ORACLE_MANAGER_PROXY = payable(0x3d07CBC5Cb9376A67E76C0655Fe239dDa8E2B264);
    address payable internal constant CORE_PROXY = payable(0x32C222A9A159782aFD7529c87FA34b96CA72C696);
    address payable internal constant ACCOUNT_PROXY = payable(0x63f4Dd0434BEB5baeCD27F3778a909278d8cf5b8);
    address payable internal constant USD_PROXY = payable(0x09d51516F38980035153a554c26Df3C6f51a23C3);
    address payable internal constant PERP_MARKET_PROXY = payable(0x0A2AF931eFFd34b81ebcc57E3d3c9B1E1dE1C9Ce);
    address payable internal constant PERP_ACCOUNT_PROXY = payable(0xcb68b813210aFa0373F076239Ad4803f8809e8cf);
    address payable internal constant SPOT_MARKET_PROXY = payable(0x18141523403e2595D31b22604AcB8Fc06a4CaA61);

    // Collaterals
    address payable internal constant COLLATERAL_USDC = payable(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);
    address payable internal constant COLLATERAL_stataUSDC = payable(0x4EA71A20e655794051D1eE8b6e4A3269B13ccaCc);
    address payable internal constant COLLATERAL_cbBTC = payable(0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf);
    address payable internal constant COLLATERAL_cbETH = payable(0x2Ae3F1Ec7F1F5012CFEab0185bfc7aa3cf0DEc22);
    address payable internal constant COLLATERAL_WETH = payable(0x4200000000000000000000000000000000000006);
    address payable internal constant COLLATERAL_wstETH = payable(0xc1CBa3fCea344f92D9239c08C0568f6F2F0ee452);

    // Synths
    address payable internal SYNTH_USDC = payable(0xC74eA762cF06c9151cE074E6a569a5945b6302E7);
    address payable internal SYNTH_stataUSDC = payable(0x729Ef31D86d31440ecBF49f27F7cD7c16c6616d2);
    address payable internal constant SYNTH_cbBTC = payable(0xEDE1d04C864EeEC40393ED4cb454B85A5ABD071C);
    address payable internal constant SYNTH_cbETH = payable(0xc302f3f74ec19d0917C7F19Bca6775f7000a292a);
    address payable internal constant SYNTH_WETH = payable(0xFA24Be208408F20395914Ba82Def333d987E0080);
    address payable internal constant SYNTH_wstETH = payable(0x3526D453D1Edb105E4e2b8448760fC501050d976);

    // Misc
    address payable internal constant TRUSTED_MULTICALL_FORWARDER = payable(0xE2C5658cC5C448B48141168f3e475dF8f65A1e3e);
    address payable internal PYTH_ERC7412_WRAPPER = payable(0x9Cb0B428632fc7dC56FDf453aEd890BA55B1953a);

    function upgrade() public {
        SynthetixForkTest.upgrade({CORE_PROXY: CORE_PROXY, ACCOUNT_PROXY: ACCOUNT_PROXY, USD_PROXY: USD_PROXY});
        OracleManagerForkTest.upgrade({ORACLE_MANAGER_PROXY: ORACLE_MANAGER_PROXY});
        PerpMarketForkTest.upgrade({PERP_MARKET_PROXY: PERP_MARKET_PROXY});
        SpotMarketForkTest.upgrade({SPOT_MARKET_PROXY: SPOT_MARKET_PROXY});
    }

    function setUp() public virtual {
        upgrade();
    }
}
