//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {vm} from "test/common/Vm.t.sol";

import {Proxy} from "@synthetixio/legacy-market/contracts/Proxy.sol";
import {LegacyMarket} from "@synthetixio/legacy-market/contracts/LegacyMarket.sol";

import {console} from "forge-std/console.sol";

library LegacyMarketForkTest {
    function upgrade(address LEGACY_MARKET_PROXY) public {
        LegacyMarket legacyMarket = LegacyMarket(LEGACY_MARKET_PROXY);

        vm.prank(legacyMarket.owner());
        LegacyMarket newLegacyMarketImplementation = new LegacyMarket();

        vm.prank(legacyMarket.owner());
        legacyMarket.upgradeTo(address(newLegacyMarketImplementation));
    }
}
