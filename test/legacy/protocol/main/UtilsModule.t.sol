// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {SynthetixLegacyTestBase} from "test/legacy/protocol/main/common/SynthetixLegacyTestBase.t.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract UtilsModuleTest is SynthetixLegacyTestBase {

    function setUp() public override {
        super.setUp();
    }

    function testRegisterCcipOnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("Unauthorized(address)", user1));
        synthetix.configureChainlinkCrossChain(address(0), address(0));
    }

    function testRegisterCcipSuccess() public {
        address mockCcipAddress = address(0x123);
        vm.prank(owner);
        synthetix.configureChainlinkCrossChain(mockCcipAddress, mockCcipAddress);
        
        (address addr,) = sUSD.getAssociatedSystem("ccipChainlinkSend");

        assertEq(
            addr,
            mockCcipAddress,
            "ccipChainlinkSend not set correctly"
        );

        (addr,) = sUSD.getAssociatedSystem("ccipChainlinkRecv");

        assertEq(
            addr,
            mockCcipAddress,
            "ccipChainlinkRecv not set correctly"
        );

        (addr,) = sUSD.getAssociatedSystem("ccipChainlinkTokenPool");

        assertEq(
            addr,
            mockCcipAddress,
            "ccipChainlinkTokenPool not set correctly"
        );
    }

    function testConfigureOracleManagerOnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("Unauthorized(address)", user1));
        synthetix.configureOracleManager(address(0));
    }

    function testConfigureOracleManagerSuccess() public {
        address mockOracleManager = address(0x456);
        synthetix.configureOracleManager(mockOracleManager);

        assertEq(
            synthetix.getOracleManager(),
            mockOracleManager,
            "Oracle manager not set correctly"
        );
    }

    function testSetConfigOnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("Unauthorized(address)", user1));
        synthetix.setConfig(bytes32(0), bytes32(0));
    }

    function testSetConfigSuccess() public {
        bytes32 key = "wohoo";
        bytes32 value = "foo";
        synthetix.setConfig(key, value);

        assertEq(
            synthetix.getConfig(key),
            value,
            "Config not set correctly"
        );
    }
}
