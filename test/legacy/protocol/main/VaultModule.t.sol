//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {SynthetixLegacyBootstrapWithStakedPool} from "test/legacy/protocol/main/common/SynthetixLegacyBootstrapWithStakedPool.t.sol";

import {IAccountModule} from "@synthetixio/main/contracts/interfaces/IAccountModule.sol";
import {ICollateralConfigurationModule, CollateralConfiguration} from "@synthetixio/main/contracts/interfaces/ICollateralConfigurationModule.sol";
import {MarketConfiguration} from "@synthetixio/main/contracts/interfaces/IPoolModule.sol";
import {IVaultModule} from "@synthetixio/main/contracts/interfaces/IVaultModule.sol";

import {AggregatorV3Mock} from "@synthetixio/main/contracts/mocks/AggregatorV3Mock.sol";
import {CollateralMock} from "@synthetixio/main/contracts/mocks/CollateralMock.sol";
import {MockMarket} from "@synthetixio/main/contracts/mocks/MockMarket.sol";

contract VaultModuleTest is SynthetixLegacyBootstrapWithStakedPool {   
    
    MockMarket internal market;
    uint128 internal marketId;

    function setUp() public override {
        super.setUp();
    }

    function test_vault_withdraw() as_user(user1) public {
        // deposit collateral
        synthetix.delegateCollateral(accountId, poolId, address(collateral), 0 ether, 1 ether);

        synthetix.withdraw(accountId, address(collateral), 1000 ether);

        // verify account state
        verifyAccountState(accountId, poolId, 0 ether, 0);
    }

    function test_freshVault() public {
        // create empty vault
        uint128 _poolId = 209372;
        synthetix.createPool(_poolId, address(this));

        // returns 0 debt
        assertEq(synthetix.getVaultDebt(_poolId, address(collateral)), 0);

        // returns 0 collateral
        (uint256 amount,) = synthetix.getVaultCollateral(_poolId, address(collateral));
        assertEq(amount, 0);

        // returns 0 collateral ratio
        assertEq(synthetix.getVaultCollateralRatio(_poolId, address(collateral)), 0);
    }

    function test_delegateCollateral() public {
        // after bootstrap have correct amounts
        verifyAccountState(accountId, poolId, 1000 ether, 0);

        // has max cratio
        assertEq(
            synthetix.getPositionCollateralRatio(accountId, poolId, address(collateral)),
            type(uint256).max,
            "max cratio"
        );

        // after bootstrap liquidity is delegated all the way back to the market
        assertEq(synthetix.getMarketCollateral(marketId), 0);

        // verifies permission for account
        vm.prank(user2);
        vm.expectRevert(
            abi.encodeWithSignature("PermissionDenied(uint128,bytes32,address)", accountId, bytes32("DELEGATE"), user2)
        );
        synthetix.delegateCollateral(accountId, poolId, address(collateral), 2_000 ether, 1 ether);

        // verifies leverage
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("InvalidLeverage(uint256)", 1.1 ether));
        synthetix.delegateCollateral(accountId, poolId, address(collateral), 2_000 ether, 1.1 ether);

        // fails when trying to delegate less than minDelegation amount
        uint256 delegateAmount = uint256(1_000 ether) / 51;
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("InsufficientDelegation(uint256)", 20 ether));
        synthetix.delegateCollateral(
            accountId, poolId, address(collateral), delegateAmount, 1 ether
        );

        // fails when new collateral amount equals current collateral amount
        delegateAmount = 1_000 ether;
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("InvalidCollateralAmount()"));
        synthetix.delegateCollateral(
            accountId, poolId, address(collateral), delegateAmount, 1 ether
        );

        // fails when pool does not exist
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("PoolNotFound(uint128)", 42));
        synthetix.delegateCollateral(accountId, 42, address(collateral), delegateAmount, 1 ether);

        //
        bytes memory data = abi.encodeWithSelector(
            IVaultModule.delegateCollateral.selector, accountId, 42, address(collateral), delegateAmount / 50, 1 ether
        );
        this.verifyUsesFeatureFlag(address(synthetix), address(synthetix), data, "delegateCollateral");
    }

    function test_whenCollateralIsDisabled() public {
        uint128 fakePoolId = 93729028;

        synthetix.createPool(fakePoolId, address(this));

        // disable collateral
        CollateralConfiguration.Data memory config =
            ICollateralConfigurationModule(address(synthetix)).getCollateralConfiguration(address(collateral));

        config.depositingEnabled = false;
        ICollateralConfigurationModule(address(synthetix)).configureCollateral(config);

        // fails when trying to open delegation position with disabled collateral
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature("CollateralDepositDisabled(address)", address(collateral))
        );
        synthetix.delegateCollateral(
            accountId,
            fakePoolId,
            address(collateral),
            25 ether,
            1 ether
        );

        // user1 has expected initial position
        verifyAccountState(accountId, poolId, 1000 ether, 0);
    }

    function verifyAccountState(
        uint128 _accountId,
        uint128 _poolId,
        uint256 collateralAmount,
        int256 debt,
        string memory err
    ) internal {
        uint256 amount = synthetix.getPositionCollateral(_accountId, _poolId, address(collateral));
        assertEq(amount, collateralAmount, string(abi.encodePacked("collateral amount:", err)));
        assertEq(
            synthetix.getPositionDebt(_accountId, _poolId, address(collateral)),
            debt,
            string(abi.encodePacked("debt:", err))
        );
        assertEq(
            synthetix.getPositionCollateralRatio(_accountId, _poolId, address(collateral)),
            expectedCollateralRatio(collateralAmount, debt),
            string(abi.encodePacked("collateral ratio:", err))
        );
    }

    function verifyAccountState(uint128 _accountId, uint128 _poolId, uint256 collateralAmount, int256 debt) internal {
        verifyAccountState(_accountId, _poolId, collateralAmount, debt, "");
    }

   

    function expectedCollateralRatio(uint256 value, int256 debt) internal pure returns (uint256) {
        if (debt == 0) {
            return type(uint256).max;
        }

        return value * 1e18 / uint256(debt);
    }
}