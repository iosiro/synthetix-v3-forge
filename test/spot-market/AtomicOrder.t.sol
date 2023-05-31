//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import { SpotMarketBootstrap} from "./Bootstrap.t.sol";

import "test/deployments/Modules.t.sol";

import "forge-std/console2.sol";

contract AtomicOrderTests is SpotMarketBootstrap {
    function setUp() public override virtual {
        super.setUp();
    }

    function testBasicBuy() public {
        uint128 accountId = tradersInfo[address(this)].accountId;
        uint128 spotMarketId = tokenInfo["sETH"].spotMarketId;
       
        IssueUSDModule(synthetixV3).mintUsd(accountId, 1, address(tokenInfo["ETH"].token), 1000 ether);
        
        // Create a buy order
        snxUSD.approve(address(spotMarkets), 500 ether);
        AtomicOrderModule(spotMarkets).buyExactIn(spotMarketId, 500 ether, 0.25 ether, address(this));        

        // Check that the order was filled
        assertGe(tokenInfo["sETH"].token.balanceOf(address(this)), 0.24 ether);

        tokenInfo["sETH"].aggregator.mockSetCurrentPrice(4000 ether);
        snxUSD.approve(address(synthetixV3), 500 ether);
        IssueUSDModule(synthetixV3).burnUsd(accountId, 1, address(tokenInfo["ETH"].token), 1 ether);

        console2.log("ETH VaultDebt", VaultModule(synthetixV3).getVaultDebt(1, address(tokenInfo["ETH"].token)));
        console2.log("BTC VaultDebt", VaultModule(synthetixV3).getVaultDebt(1, address(tokenInfo["BTC"].token)));
        console2.log("LINK VaultDebt", VaultModule(synthetixV3).getVaultDebt(1, address(tokenInfo["LINK"].token)));


    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}