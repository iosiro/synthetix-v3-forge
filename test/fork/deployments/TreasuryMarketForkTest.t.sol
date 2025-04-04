//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {vm} from "test/common/Vm.t.sol";

import {SynthetixTreasuryProxy} from "@synthetixio/treasury-market/contracts/SynthetixTreasuryProxy.sol";
import {TreasuryMarket} from "@synthetixio/treasury-market/contracts/TreasuryMarket.sol";

import {console} from "forge-std/console.sol";

library TreasuryMarketForkTest {
    function upgrade(address TREASURY_MARKET_PROXY) public {
        TreasuryMarket treasuryMarket = TreasuryMarket(TREASURY_MARKET_PROXY);

        vm.prank(treasuryMarket.owner());
        TreasuryMarket newTreasuryMarketImplementation = new TreasuryMarket(
            treasuryMarket.v3System(),
            treasuryMarket.oracleManager(),
            treasuryMarket.treasury(),
            treasuryMarket.poolId(),
            treasuryMarket.collateralToken()
        );

        vm.prank(treasuryMarket.owner());
        treasuryMarket.upgradeTo(address(newTreasuryMarketImplementation));
    }
}
