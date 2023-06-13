//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {SynthetixV3Test} from "test/protocol/synthetix-v3/SynthetixV3Test.t.sol";

import {CollateralConfigurationModule} from "@synthetixio/main/contracts/modules/core/CollateralConfigurationModule.sol";
import {CollateralConfiguration} from "@synthetixio/main/contracts/storage/CollateralConfiguration.sol";
import {CollateralMock} from "@synthetixio/main/contracts/mocks/CollateralMock.sol";
import {AggregatorV3Mock} from "@synthetixio/main/contracts/mocks/AggregatorV3Mock.sol";

contract CollateralConfigurationModuleTest is SynthetixV3Test {
    function setUp() public {
        bootstrap();
    }

    // when the first collateral is added
    function test_addCollateral() public {
        (CollateralMock collateral,, bytes32 oracleNodeId,) = addCollateral("Synthetix Token", "SNX", 400, 200);

        // is well configured
        CollateralConfiguration.Data memory collateralType =
            CollateralConfigurationModule(system.synthetix).getCollateralConfiguration(address(collateral));
        assertEq(collateralType.tokenAddress, address(collateral));
        assertEq(collateralType.oracleNodeId, oracleNodeId);
        assertEq(collateralType.issuanceRatioD18, 400);
        assertEq(collateralType.liquidationRatioD18, 200);
        assertEq(collateralType.depositingEnabled, true);

        // shows in the collateral list
        CollateralConfiguration.Data[] memory collaterals =
            CollateralConfigurationModule(system.synthetix).getCollateralConfigurations(true);

        CollateralConfiguration.Data memory found;
        for (uint256 i = 0; i < collaterals.length; i++) {
            if (collaterals[i].tokenAddress == address(collateral)) {
                found = collaterals[i];
            }
        }

        assertEq(found.tokenAddress, address(collateral));
        assertEq(found.oracleNodeId, oracleNodeId);
        assertEq(found.issuanceRatioD18, 400);
        assertEq(found.liquidationRatioD18, 200);
        assertEq(found.depositingEnabled, true);

        // when a second collateral is added
        (collateral,, oracleNodeId,) = addCollateral("Another Token", "ANT", 400, 200);

        // is well configured
        collateralType = CollateralConfigurationModule(system.synthetix).getCollateralConfiguration(address(collateral));
        assertEq(collateralType.tokenAddress, address(collateral));
        assertEq(collateralType.oracleNodeId, oracleNodeId);
        assertEq(collateralType.issuanceRatioD18, 400);
        assertEq(collateralType.liquidationRatioD18, 200);
        assertEq(collateralType.depositingEnabled, true);

        // shows in the collateral list
        collaterals = CollateralConfigurationModule(system.synthetix).getCollateralConfigurations(true);
        for (uint256 i = 0; i < collaterals.length; i++) {
            if (collaterals[i].tokenAddress == address(collateral)) {
                found = collaterals[i];
            }
        }
        assertEq(found.tokenAddress, address(collateral));
        assertEq(found.oracleNodeId, oracleNodeId);
        assertEq(found.issuanceRatioD18, 400);
        assertEq(found.liquidationRatioD18, 200);
        assertEq(found.depositingEnabled, true);

        // when a regular user attempts to update the second collateral

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("Unauthorized(address)", user1));
        CollateralConfigurationModule(system.synthetix).configureCollateral(
            CollateralConfiguration.Data({
                tokenAddress: address(collateral),
                depositingEnabled: false,
                oracleNodeId: oracleNodeId,
                issuanceRatioD18: 200,
                liquidationRatioD18: 100,
                liquidationRewardD18: 0 ether,
                minDelegationD18: 0 ether
            })
        );
    }
}
