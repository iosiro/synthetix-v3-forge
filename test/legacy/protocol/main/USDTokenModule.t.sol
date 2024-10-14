// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {SynthetixLegacyBootstrapWithStakedPool} from
    "test/legacy/protocol/main/common/SynthetixLegacyBootstrapWithStakedPool.t.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IUSDRouter} from "src/generated/routers/USDRouter.g.sol";

contract USDTokenModuleTest is SynthetixLegacyBootstrapWithStakedPool {
    uint256 constant FIFTY_USD = 50e18;
    uint256 constant ONE_HUNDRED_USD = 100e18;

    function setUp() public override {
        super.setUp();

        // Mint some sUSD
        vm.startPrank(user1);
        synthetix.mintUsd(accountId, poolId, address(collateral), ONE_HUNDRED_USD);
        vm.stopPrank();
    }

    function testUSDDeploymentAndRegistration() public view {
        (address addr,) = synthetix.getAssociatedSystem("USDToken");
        assertEq(addr, address(sUSD));
    }

    function testUSDParameters() public view {
        assertEq(sUSD.name(), "Synthetic USD Token v3");
        assertEq(sUSD.symbol(), "sUSD");
        assertEq(sUSD.decimals(), 18);
    }

    function testBurnUnauthorized() public {
        vm.expectRevert(abi.encodeWithSignature("Unauthorized(address)", owner));
        sUSD.burn(ONE_HUNDRED_USD);
    }

    function testBurnSuccessful() public {
        // Configure CCIP (mocking the setup)
        synthetix.configureChainlinkCrossChain(address(0), user1);

        // Withdraw sUSD to staker's wallet
        vm.startPrank(user1);
        synthetix.withdraw(accountId, address(sUSD), FIFTY_USD);

        uint256 usdBalanceBefore = sUSD.balanceOf(user1);

        // Burn 50 sUSD
        sUSD.burn(FIFTY_USD);

        uint256 usdBalanceAfter = sUSD.balanceOf(user1);
        assertEq(usdBalanceAfter, usdBalanceBefore - FIFTY_USD);

        vm.stopPrank();
    }
}
