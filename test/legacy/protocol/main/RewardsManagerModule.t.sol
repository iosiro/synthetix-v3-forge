// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {Test} from "forge-std/Test.sol";
import {SynthetixLegacyBootstrapWithStakedPool} from "test/legacy/protocol/main/common/SynthetixLegacyBootstrapWithStakedPool.t.sol";
import {CollateralMock} from "@synthetixio/main/contracts/mocks/CollateralMock.sol";
import {RewardDistributorMock} from "@synthetixio/main/contracts/mocks/RewardDistributorMock.sol";
import {ICollateralConfigurationModule, CollateralConfiguration} from "@synthetixio/main/contracts/interfaces/ICollateralConfigurationModule.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract RewardsManagerModuleTest is SynthetixLegacyBootstrapWithStakedPool {
    CollateralMock internal rewardToken;
    CollateralMock internal rewardToken2;
    RewardDistributorMock public rewardDistributor;
    RewardDistributorMock public rewardDistributorPoolLevel;

    uint256 public constant REWARD_AMOUNT = 1000 ether;

    function setUp() public override {
        super.setUp();

        rewardToken = new CollateralMock();
        rewardToken2 = new CollateralMock();

        rewardToken.initialize("Fake Reward", "FAKE", 6);
        rewardToken2.initialize("Fake Reward 2", "FAKE2", 6);

        rewardDistributor = new RewardDistributorMock();
        rewardDistributorPoolLevel = new RewardDistributorMock();

        rewardDistributor.initialize(address(synthetix), address(rewardToken), "Fake Reward Distributor");
        rewardDistributorPoolLevel.initialize(address(synthetix), address(rewardToken), "Fake Pool Level Distributor");

        ICollateralConfigurationModule(address(synthetix)).configureCollateral(
            CollateralConfiguration.Data({
                tokenAddress: address(rewardToken2),
                oracleNodeId: synthetix.getCollateralConfiguration(address(collateral)).oracleNodeId,
                issuanceRatioD18: 5e18,
                liquidationRatioD18: 1.5e18,
                liquidationRewardD18: 20e18,
                minDelegationD18: 20e18,
                depositingEnabled: true
            })
        );

        rewardToken.mint(address(rewardDistributor), REWARD_AMOUNT * 1000);
        rewardToken.mint(address(rewardDistributorPoolLevel), REWARD_AMOUNT * 1000);
        rewardToken2.mint(owner, REWARD_AMOUNT * 1000);

        synthetix.registerRewardsDistributor(poolId, address(collateral), address(rewardDistributor));
        synthetix.registerRewardsDistributor(poolId, address(0), address(rewardDistributorPoolLevel));
        synthetix.registerRewardsDistributor(poolId, address(0), address(rewardDistributor));

        vm.stopPrank();
    }

    function testRegisterRewardsDistributor() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("Unauthorized(address)", user1));
        synthetix.registerRewardsDistributor(poolId, address(collateral), address(rewardDistributor));

        
        vm.expectRevert(abi.encodeWithSignature("InvalidParameter(string,string)", "distributor", "invalid interface"));
        synthetix.registerRewardsDistributor(poolId, address(collateral), owner);
    }

    function testDistributeRewards() public {
        
        // system distributeRewards reverts if is called from other than the distributor
        vm.expectRevert(abi.encodeWithSignature("InvalidParameter(string,string)", "poolId-collateralType-distributor", "reward is not registered"));
        synthetix.distributeRewards(poolId, address(rewardToken), REWARD_AMOUNT, 1, 0);

        // reward is not distributed
        (uint256[] memory rewards,,) = synthetix.updateRewards(poolId, address(rewardToken), accountId);
        assertEq(rewards[0], 0);

        // allows distribution with start time equal to 0
        vm.prank(address(rewardDistributor));
        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, 0, 0);
    }

    function testInstantaneousRewardDistribution() public {
       
        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, 1, 0);

        vm.warp(block.timestamp + 1);

        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, 2, 0);

        vm.warp(block.timestamp + 1);

        // Duplicate distribution
        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, 2, 0);

        vm.warp(block.timestamp + 1);

        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, uint64(block.timestamp + 1 days), 0);

        // Rewards aren't available JIT
        vm.warp(block.timestamp + 1);

        uint256 availableRewards = synthetix.getAvailableRewards(accountId, poolId, address(collateral), address(rewardDistributor));
        assertEq(availableRewards, REWARD_AMOUNT * 3);
    }

    function testFutureInstantaneousRewardDistributions() public {
        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, uint64(block.timestamp + 10), 0);

        vm.warp(block.timestamp + 1);
        
        // distribute one in the past to ensure switching from past to future works
        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, 1, 0);

        vm.warp(block.timestamp + 1);

        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, uint64(block.timestamp + 30), 0);

        // is not distributed future yet
        uint256 availableRewards = synthetix.getAvailableRewards(accountId, poolId, address(collateral), address(rewardDistributor));
        assertEq(availableRewards, REWARD_AMOUNT);

        // has no rate
        uint256 rate = synthetix.getRewardRate(poolId, address(collateral), address(rewardDistributor));
        assertEq(rate, 0);

        // after time passes
        vm.warp(block.timestamp + 30);

        synthetix.updateRewards(poolId, address(collateral), accountId);

        availableRewards = synthetix.getAvailableRewards(accountId, poolId, address(collateral), address(rewardDistributor));
        assertEq(availableRewards, REWARD_AMOUNT * 2);

        rate = synthetix.getRewardRate(poolId, address(collateral), address(rewardDistributor));
        assertEq(rate, 0);
    }

    function testOverTimeDistributionFromThePast() public {
        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, uint64(block.timestamp - 100), 100);

        vm.warp(block.timestamp + 1);

        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, uint64(block.timestamp - 50), 50);

        vm.warp(block.timestamp + 1);

        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, uint64(block.timestamp + 50), 50);

        // is fully distributed
        uint256 availableRewards = synthetix.getAvailableRewards(accountId, poolId, address(collateral), address(rewardDistributor));
        assertEq(availableRewards, REWARD_AMOUNT * 2);
    }

    function testOverTimeDistributionFromInTheFuture() public {
        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, uint64(block.timestamp + 200), 200);

        vm.warp(block.timestamp + 1);

        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, uint64(block.timestamp - 50), 10);

        vm.warp(block.timestamp + 1);

        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, uint64(block.timestamp + 100), 100);

        vm.warp(block.timestamp + 1);

        // does not distribute future
        uint256 availableRewards = synthetix.getAvailableRewards(accountId, poolId, address(collateral), address(rewardDistributor));
        assertEq(availableRewards, REWARD_AMOUNT);

        // after time passes
        vm.warp(block.timestamp + 200);

        availableRewards = synthetix.getAvailableRewards(accountId, poolId, address(collateral), address(rewardDistributor));
        assertEq(availableRewards, REWARD_AMOUNT * 2);
    }

    function testOverTimeDistributionDuring() public {
        uint64 startTime = uint64(block.timestamp);

        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, uint64(startTime - 50), 0);

        vm.warp(block.timestamp + 1);

        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, uint64(startTime - 50), 100);

        // distributes portion of rewards immediately
        uint256 availableRewards = synthetix.getAvailableRewards(accountId, poolId, address(collateral), address(rewardDistributor));
        assertEq(availableRewards, REWARD_AMOUNT + REWARD_AMOUNT * 51 / 100);

        // after time passes
        vm.warp(startTime + 25);

        availableRewards = synthetix.getAvailableRewards(accountId, poolId, address(collateral), address(rewardDistributor));
        assertEq(availableRewards, REWARD_AMOUNT + REWARD_AMOUNT * 75 / 100);
        
        // new distribution
        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT*1000, uint64(block.timestamp - 110), 200);
        vm.warp(block.timestamp + 1);

        // distributes portion of rewards immediately
        availableRewards = synthetix.getAvailableRewards(accountId, poolId, address(collateral), address(rewardDistributor));
        assertEq(availableRewards, REWARD_AMOUNT + REWARD_AMOUNT * 75 / 100 + REWARD_AMOUNT * 1000 * 111 / 200);

        // after more time
        vm.warp(block.timestamp + 100);
        availableRewards = synthetix.getAvailableRewards(accountId, poolId, address(collateral), address(rewardDistributor));
        assertEq(availableRewards, REWARD_AMOUNT * 1001 + REWARD_AMOUNT * 75 / 100);
   
    }

    function testUpdateRewards() public {
        vm.expectRevert(abi.encodeWithSignature("AccountNotFound(uint128)", 276823567823));
        synthetix.updateRewards(poolId, address(collateral), 276823567823);

        vm.prank(address(rewardDistributor));
        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, 1, 0);

        vm.warp(block.timestamp + 1);

        vm.prank(address(rewardDistributor));
        rewardDistributor.distributeRewards(poolId, address(0), REWARD_AMOUNT / 5, 1, 0);

        vm.warp(block.timestamp + 1);

        vm.prank(address(rewardDistributorPoolLevel));
        rewardDistributorPoolLevel.distributeRewards(poolId, address(0), REWARD_AMOUNT / 2, 1, 0);

        vm.warp(block.timestamp + 1);

        (uint256[] memory rewardAmounts, address[] memory distributorAddresses, uint256 poolRewardsCount) = synthetix.updateRewards(poolId, address(collateral), accountId);

        assertEq(rewardAmounts.length, 3);
        assertEq(distributorAddresses.length, 3);
        assertEq(poolRewardsCount, 2);

        assertEq(distributorAddresses[0], address(rewardDistributorPoolLevel));
        assertEq(distributorAddresses[1], address(rewardDistributor));
        assertEq(distributorAddresses[2], address(rewardDistributor));
        assertEq(rewardAmounts[0], REWARD_AMOUNT / 2);
        assertEq(rewardAmounts[1], REWARD_AMOUNT / 5);
        assertEq(rewardAmounts[2], REWARD_AMOUNT);
    }

    function testClaimRewards() public {
        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, 1, 0);
        rewardDistributor.distributeRewards(poolId, address(0), REWARD_AMOUNT, 1, 0);

        rewardDistributorPoolLevel.distributeRewards(poolId, address(0), REWARD_AMOUNT, 1, 0);

        synthetix.updateRewards(poolId, address(collateral), accountId);

        vm.prank(user2);
        vm.expectRevert(abi.encodeWithSignature("PermissionDenied(uint128,bytes32,address)", accountId, bytes32("REWARDS"), user2));
        synthetix.claimRewards(accountId, poolId, address(collateral), address(rewardDistributor));

        vm.prank(user1);
        synthetix.claimRewards(accountId, poolId, address(collateral), address(rewardDistributor));

        vm.prank(user1);
        synthetix.claimPoolRewards(accountId, poolId, address(collateral), address(rewardDistributor));

        assertEq(IERC20(address(rewardToken)).balanceOf(user1), REWARD_AMOUNT * 2);

        uint256 availableRewards = synthetix.getAvailableRewards(accountId, poolId, address(collateral), address(rewardDistributor));
        assertEq(availableRewards, 0);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("InvalidParameter(string,string)", "amount", "Zero amount"));
        synthetix.claimRewards(accountId, poolId, address(collateral), address(rewardDistributor));
    }

    function testRemoveRewardsDistributor() public {
        vm.prank(address(rewardDistributor));
        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, 1, 10);

        vm.prank(address(rewardDistributor));
        rewardDistributor.distributeRewards(poolId, address(0), REWARD_AMOUNT, 1, 10);

        vm.warp(block.timestamp + 1);
        
        synthetix.removeRewardsDistributor(poolId, address(collateral), address(rewardDistributor));
        synthetix.removeRewardsDistributor(poolId, address(0), address(rewardDistributorPoolLevel));

        vm.prank(address(rewardDistributor));
        vm.expectRevert(abi.encodeWithSignature("InvalidParameter(string,string)", "poolId-collateralType-distributor", "reward is not registered"));
        rewardDistributor.distributeRewards(poolId, address(collateral), REWARD_AMOUNT, 1, 0);

        vm.prank(address(rewardDistributorPoolLevel));
        vm.expectRevert(abi.encodeWithSignature("InvalidParameter(string,string)", "poolId-collateralType-distributor", "reward is not registered"));
        rewardDistributorPoolLevel.distributeRewards(poolId, address(0), REWARD_AMOUNT, 1, 0);

        uint256 beforeBalance = IERC20(address(rewardToken)).balanceOf(user1);
        uint256 availableRewards = synthetix.getAvailableRewards(accountId, poolId, address(collateral), address(rewardDistributor));

        vm.prank(user1);
        synthetix.claimRewards(accountId, poolId, address(collateral), address(rewardDistributor));

        uint256 afterBalance = IERC20(address(rewardToken)).balanceOf(user1);
        assertGt(afterBalance, beforeBalance);
        assertEq(availableRewards, afterBalance - beforeBalance);

        synthetix.updateRewards(poolId, address(rewardToken), accountId);
        uint256 afterRewardAmount = synthetix.getAvailableRewards(accountId, poolId, address(collateral), address(rewardDistributor));
        assertEq(afterRewardAmount, 0);

        vm.warp(block.timestamp + 1000);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("InvalidParameter(string,string)", "amount", "Zero amount"));
        synthetix.claimRewards(accountId, poolId, address(collateral), address(rewardDistributor));
        
        vm.expectRevert(abi.encodeWithSignature("InvalidParameter(string,string)", "distributor", "cant be re-registered"));
        synthetix.registerRewardsDistributor(poolId, address(collateral), address(rewardDistributor));
     
        vm.expectRevert(abi.encodeWithSignature("InvalidParameter(string,string)", "distributor", "cant be re-registered"));
        synthetix.registerRewardsDistributor(poolId, address(0), address(rewardDistributorPoolLevel));
    }

    function testDistributeRewardsByOwner() public {
        // reverts if not pool owner
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("Unauthorized(address)", user1));
        synthetix.distributeRewardsByOwner(poolId, address(collateral), address(rewardDistributor), REWARD_AMOUNT, 1, 0);

        // reverts if RD does not exist
        vm.expectRevert(abi.encodeWithSignature("InvalidParameter(string,string)", "poolId-collateralType-distributor", "reward is not registered"));
        synthetix.distributeRewardsByOwner(poolId, address(collateral), user1, REWARD_AMOUNT, 1, 0);
    }
}