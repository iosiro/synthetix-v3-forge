//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {CollateralMock} from "@synthetixio/main/contracts/mocks/CollateralMock.sol";
import {AggregatorV3Mock} from "@synthetixio/main/contracts/mocks/AggregatorV3Mock.sol";
import {ICollateralConfigurationModule, CollateralConfiguration} from "@synthetixio/main/contracts/interfaces/ICollateralConfigurationModule.sol";

import {SynthetixLegacyTestBase} from "test/legacy/protocol/main/common/SynthetixLegacyTestBase.t.sol";

contract CollateralConfigurationModuleTest is SynthetixLegacyTestBase {
    

    function setUp() public override {
        super.setUp();
    }


    // when the first collateral is added
    function test_addCollateral() public {
        (CollateralMock collateral,, bytes32 oracleNodeId,) = addCollateral("Synthetix Token", "SNX", 4 ether, 2 ether);

        // is well configured
        _assertCollateralTypeEq(
            ICollateralConfigurationModule(address(synthetix)).getCollateralConfiguration(address(collateral)),
            CollateralConfiguration.Data({
                tokenAddress: address(collateral),
                oracleNodeId: oracleNodeId,
                issuanceRatioD18: 4 ether,
                liquidationRatioD18: 2 ether,
                depositingEnabled: true,
                liquidationRewardD18: 0 ether,
                minDelegationD18: 0 ether
            })
        );

        // shows in the collateral list
        assertTrue(_verifyCollateralListed(address(collateral), true));


        // when a second collateral is added
        (CollateralMock collateral2,, bytes32 oracleNodeId2,) = addCollateral("Another Token", "ANT", 4 ether, 2 ether);

        // is well configured
        _assertCollateralTypeEq(
            ICollateralConfigurationModule(address(synthetix)).getCollateralConfiguration(address(collateral2)),
            CollateralConfiguration.Data({
                tokenAddress: address(collateral2),
                oracleNodeId: oracleNodeId2,
                issuanceRatioD18: 4 ether,
                liquidationRatioD18: 2 ether,
                depositingEnabled: true,
                liquidationRewardD18: 0 ether,
                minDelegationD18: 0 ether
            })
        );

        // shows in the collateral list
        assertTrue(_verifyCollateralListed(address(collateral2), true));

        // when the second collateral is update
        ICollateralConfigurationModule(address(synthetix)).configureCollateral(
            CollateralConfiguration.Data({
                tokenAddress: address(collateral2),
                depositingEnabled: true,
                oracleNodeId: oracleNodeId,
                issuanceRatioD18: 3 ether,
                liquidationRatioD18: 2.5 ether,
                liquidationRewardD18: 0 ether,
                minDelegationD18: 0 ether
            })
        );

        // when a regular user attempts to update the second collateral
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("Unauthorized(address)", user1));
        ICollateralConfigurationModule(address(synthetix)).configureCollateral(
            CollateralConfiguration.Data({
                tokenAddress: address(collateral2),
                depositingEnabled: false,
                oracleNodeId: oracleNodeId2,
                issuanceRatioD18: 2 ether,
                liquidationRatioD18: 1 ether,
                liquidationRewardD18: 0 ether,
                minDelegationD18: 0 ether
            })
        );

        // when the second collateral is updated
        ICollateralConfigurationModule(address(synthetix)).configureCollateral(
            CollateralConfiguration.Data({
                tokenAddress: address(collateral2),
                depositingEnabled: true,
                oracleNodeId: oracleNodeId2,
                issuanceRatioD18: 3 ether,
                liquidationRatioD18: 2.5 ether,
                liquidationRewardD18: 0 ether,
                minDelegationD18: 0 ether
            })
        );

        // is well configured
        _assertCollateralTypeEq(
            ICollateralConfigurationModule(address(synthetix)).getCollateralConfiguration(address(collateral2)),
            CollateralConfiguration.Data({
                tokenAddress: address(collateral2),
                oracleNodeId: oracleNodeId2,
                issuanceRatioD18: 3 ether,
                liquidationRatioD18: 2.5 ether,
                depositingEnabled: true,
                liquidationRewardD18: 0 ether,
                minDelegationD18: 0 ether
            })
        );

        // when the second collateral is disabled
        ICollateralConfigurationModule(address(synthetix)).configureCollateral(
            CollateralConfiguration.Data({
                tokenAddress: address(collateral2),
                depositingEnabled: false,
                oracleNodeId: oracleNodeId2,
                issuanceRatioD18: 3 ether,
                liquidationRatioD18: 2.5 ether,
                liquidationRewardD18: 0 ether,
                minDelegationD18: 0 ether
            })
        );

        // is well configured
        _assertCollateralTypeEq(
            ICollateralConfigurationModule(address(synthetix)).getCollateralConfiguration(address(collateral2)),
            CollateralConfiguration.Data({
                tokenAddress: address(collateral2),
                oracleNodeId: oracleNodeId2,
                issuanceRatioD18: 3 ether,
                liquidationRatioD18: 2.5 ether,
                depositingEnabled: false,
                liquidationRewardD18: 0 ether,
                minDelegationD18: 0 ether
            })
        );

        // should not be filtered
        assertTrue(_verifyCollateralListed(address(collateral2), false));

        // should be filtered
        assertFalse(_verifyCollateralListed(address(collateral2), true));

    }

    function  _verifyCollateralListed(address collateral, bool hideDisabled) private view returns (bool found) {
        CollateralConfiguration.Data[] memory collaterals =
            ICollateralConfigurationModule(address(synthetix)).getCollateralConfigurations(hideDisabled);

        for (uint256 i = 0; i < collaterals.length; i++) {
            if (collaterals[i].tokenAddress == collateral) {
               return true;
            }
        }
    }

    function _assertCollateralTypeEq(CollateralConfiguration.Data memory a, CollateralConfiguration.Data memory b) private pure {
        assertEq(a.tokenAddress, b.tokenAddress);
        assertEq(a.oracleNodeId, b.oracleNodeId);
        assertEq(a.issuanceRatioD18, b.issuanceRatioD18);
        assertEq(a.liquidationRatioD18, b.liquidationRatioD18);
        assertEq(a.depositingEnabled, b.depositingEnabled);
        assertEq(a.liquidationRewardD18, b.liquidationRewardD18);
        assertEq(a.minDelegationD18, b.minDelegationD18);
    }

}