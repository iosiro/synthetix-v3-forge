//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {IOracleManagerRouter} from "src/generated/routers/OracleManagerRouter.g.sol";
import {ICoreRouter} from "src/generated/routers/CoreRouter.g.sol";
import {IAccountRouter} from "src/generated/routers/AccountRouter.g.sol";
import {IUSDRouter} from "src/generated/routers/USDRouter.g.sol";

import {
    ICollateralConfigurationModule,
    CollateralConfiguration
} from "@synthetixio/main/contracts/interfaces/ICollateralConfigurationModule.sol";
import {IFeatureFlagModule} from "@synthetixio/core-modules/contracts/interfaces/IFeatureFlagModule.sol";
import {IPoolModule} from "@synthetixio/main/contracts/interfaces/IPoolModule.sol";
import {ICollateralModule} from "@synthetixio/main/contracts/interfaces/ICollateralModule.sol";

import {INodeModule, NodeDefinition} from "@synthetixio/oracle-manager/contracts/interfaces/INodeModule.sol";
import {MarketConfiguration} from "@synthetixio/main/contracts/interfaces/IPoolModule.sol";

import {AggregatorV3Mock} from "@synthetixio/main/contracts/mocks/AggregatorV3Mock.sol";
import {CollateralMock} from "@synthetixio/main/contracts/mocks/CollateralMock.sol";
import {MockMarket} from "@synthetixio/main/contracts/mocks/MockMarket.sol";

import {Cannon} from "test/legacy/cannon/Cannon.sol";
import {CannonScript as OracleManager} from "test/legacy/cannon/schemas/oracle-manager.cannon.sol";
import {CannonScript as Synthetix} from "test/legacy/cannon/schemas/synthetix.cannon.sol";

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import "./SynthetixLegacyTestBase.t.sol";

contract SynthetixLegacyBootstrapWithStakedPool is SynthetixLegacyTestBase {
    bytes32 internal oracleNodeId;
    AggregatorV3Mock internal aggregator;
    uint128 internal accountId;
    uint128 internal poolId;
    IERC20 internal collateral;

    function setUp() public virtual override {
        super.setUp();

        synthetix.addToFeatureFlagAllowlist("createPool", address(this));

        CollateralMock mock = new CollateralMock();
        mock.initialize("Mock", "MOCK", 18);
        collateral = IERC20(address(mock));

        (oracleNodeId, aggregator) = createOracleNode(1 ether);
        ICollateralConfigurationModule(address(synthetix)).configureCollateral(
            CollateralConfiguration.Data({
                tokenAddress: address(collateral),
                depositingEnabled: true,
                oracleNodeId: oracleNodeId,
                issuanceRatioD18: 5 ether,
                liquidationRatioD18: 1.5 ether,
                liquidationRewardD18: 20 ether,
                minDelegationD18: 20 ether
            })
        );

        poolId = 1;
        IPoolModule(address(synthetix)).createPool(poolId, address(this));

        mock.mint(user1, 1_000_000 ether);

        vm.startPrank(user1);
        accountId = synthetix.createAccount();
        collateral.approve(address(synthetix), 10_000 ether);
        ICollateralModule(address(synthetix)).deposit(accountId, address(collateral), 1000 ether);
        synthetix.delegateCollateral(accountId, poolId, address(collateral), 1000 ether, 1 ether);
        vm.stopPrank();

        collateral = IERC20(address(mock));
    }
}
