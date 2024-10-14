//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {
    ArbitrumMainnetForkTest,
    ICoreRouter
} from "test/fork/networks/ArbitrumMainnetForkTest.t.sol";



contract DynamicRouterBenchmarkTest is ArbitrumMainnetForkTest {
    function setUp() override public {}

    function testCreateAccount() public {
        ICoreRouter(CORE_PROXY).createAccount();
        
        ICoreRouter(CORE_PROXY).createAccount();

        ArbitrumMainnetForkTest.upgrade();

        ICoreRouter(CORE_PROXY).createAccount();

        ICoreRouter(CORE_PROXY).createAccount();
    }

    function testGetPoolOwner() public {
        ICoreRouter(CORE_PROXY).getPoolOwner(1);

        ICoreRouter(CORE_PROXY).getPoolOwner(1);

        ArbitrumMainnetForkTest.upgrade();

        ICoreRouter(CORE_PROXY).getPoolOwner(1);

        ICoreRouter(CORE_PROXY).getPoolOwner(1);
    }

    function onERC721Received(address, address, uint256, bytes memory) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}