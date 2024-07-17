//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {IOracleManagerRouter} from "src/generated/routers/OracleManagerRouter.g.sol";
import {ICoreRouter} from "src/generated/routers/CoreRouter.g.sol";
import {IAccountRouter} from "src/generated/routers/AccountRouter.g.sol";
import {IUSDRouter} from "src/generated/routers/USDRouter.g.sol";

import {ICollateralConfigurationModule, CollateralConfiguration} from "@synthetixio/main/contracts/interfaces/ICollateralConfigurationModule.sol";
import {IFeatureFlagModule} from "@synthetixio/core-modules/contracts/interfaces/IFeatureFlagModule.sol";
import {IPoolModule} from "@synthetixio/main/contracts/interfaces/IPoolModule.sol";
import {ICollateralModule} from "@synthetixio/main/contracts/interfaces/ICollateralModule.sol";

import {INodeModule, NodeDefinition} from "@synthetixio/oracle-manager/contracts/interfaces/INodeModule.sol";
import {MarketConfiguration} from "@synthetixio/main/contracts/interfaces/IPoolModule.sol";


import {AggregatorV3Mock} from "@synthetixio/main/contracts/mocks/AggregatorV3Mock.sol";
import {CollateralMock} from "@synthetixio/main/contracts/mocks/CollateralMock.sol";
import {MockMarket} from "@synthetixio/main/contracts/mocks/MockMarket.sol";

import {Cannon} from "test/cannon/Cannon.sol";
import {CannonScript as OracleManager} from "test/cannon/schemas/oracle-manager.cannon.sol";
import {CannonScript as Synthetix} from "test/cannon/schemas/synthetix.cannon.sol";

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {BaseLegacyTest} from "test/legacy/common/BaseLegacyTest.t.sol";

contract SynthetixLegacyTestBase is BaseLegacyTest {
    IOracleManagerRouter internal oracleManager;
    ICoreRouter internal synthetix;
    IAccountRouter internal account;
    IUSDRouter internal sUSD;
    IERC20 internal snx;


    function setUp() public virtual override {
        OracleManager.deploy();
        Synthetix.deploy();
        
        oracleManager = IOracleManagerRouter(Cannon.resolve("oracle-manager.Proxy"));
        synthetix = ICoreRouter(Cannon.resolve("synthetix.CoreProxy"));
        sUSD = IUSDRouter(Cannon.resolve("synthetix.USDProxy"));
        account = IAccountRouter(Cannon.resolve("synthetix.AccountProxy"));
    }

    function addCollateral(bytes32 tokenName, bytes32 tokenSymbol, uint256 issuanceRatio, uint256 liquidationRatio)
        internal
        returns (CollateralMock collateral, AggregatorV3Mock aggregator, bytes32 oracleNodeId, uint256 collateralPrice)
    {
        collateralPrice = 1;

        collateral = new CollateralMock();
        collateral.initialize(string(abi.encodePacked(tokenName)), string(abi.encodePacked(tokenSymbol)), 6);

        (oracleNodeId, aggregator) = createOracleNode(collateralPrice);

        ICollateralConfigurationModule(address(synthetix)).configureCollateral(
            CollateralConfiguration.Data({
                tokenAddress: address(collateral),
                depositingEnabled: true,
                oracleNodeId: oracleNodeId,
                issuanceRatioD18: issuanceRatio,
                liquidationRatioD18: liquidationRatio,
                liquidationRewardD18: 0 ether,
                minDelegationD18: 0 ether
            })
        );
    }

    function createOracleNode(uint256 price) internal returns (bytes32 nodeId, AggregatorV3Mock aggregator) {
        aggregator = new AggregatorV3Mock();
        aggregator.mockSetCurrentPrice(price);
        bytes32[] memory parents;
        nodeId = INodeModule(address(oracleManager)).registerNode(
            NodeDefinition.NodeType.CHAINLINK, abi.encode(address(aggregator), 0, 18), parents
        );
    }

    function verifyUsesFeatureFlag(address featureModule, address target, bytes memory data, bytes32 flag)
        external
    {
        // disable feature
        IFeatureFlagModule(featureModule).setFeatureFlagDenyAll(flag, true);

        // it fails with feature unavailable
        vm.expectRevert(abi.encodeWithSignature("FeatureUnavailable(bytes32)", flag));
        (bool success,) = target.call(data);
        assert(success);

        // enable feature
        IFeatureFlagModule(featureModule).setFeatureFlagDenyAll(flag, false);
    }

    function bootstrapWithStakedPool() internal returns(uint128 accountId, uint128 poolId, IERC20 collateral, bytes32 oracleNodeId, AggregatorV3Mock aggregator) {
        synthetix.addToFeatureFlagAllowlist("createPool", address(this));

        CollateralMock mock = new CollateralMock();

        (oracleNodeId, aggregator) = createOracleNode(1);
        ICollateralConfigurationModule(address(synthetix)).configureCollateral(
            CollateralConfiguration.Data({
                tokenAddress: address(collateral),
                depositingEnabled: true,
                oracleNodeId: oracleNodeId,
                issuanceRatioD18: 4 ether,
                liquidationRatioD18: 2 ether,
                liquidationRewardD18: 0 ether,
                minDelegationD18: 0 ether
            })
        );

        poolId = 1;
        IPoolModule(address(synthetix)).createPool(poolId, address(this));

        mock.mint(address(this), 1_000_000 ether);

        vm.startPrank(address(user1));
        accountId = synthetix.createAccount();
        collateral.approve(address(synthetix), 10_000 ether);
        ICollateralModule(address(synthetix)).deposit(accountId, address(collateral), 1000 ether);
        synthetix.delegateCollateral(accountId, poolId, address(collateral), 1000 ether, 1 ether);
        vm.stopPrank();

        collateral = IERC20(address(mock));
    }
}