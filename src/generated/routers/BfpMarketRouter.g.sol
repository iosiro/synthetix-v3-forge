// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library IAccountModule {
    struct AccountPermissions {
        address user;
        bytes32[] permissions;
    }
}

library IMarginModule {
    struct ConfiguredCollateral {
        address collateralAddress;
        bytes32 oracleNodeId;
        uint128 maxAllowable;
        uint128 skewScale;
        address rewardDistributor;
    }
}

library IMarketConfigurationModule {
    struct ConfigureByMarketParameters {
        uint128 marketId;
        bytes32 oracleNodeId;
        bytes32 pythPriceFeedId;
        uint128 makerFee;
        uint128 takerFee;
        uint128 maxMarketSize;
        uint128 maxFundingVelocity;
        uint128 skewScale;
        uint128 fundingVelocityClamp;
        uint128 minCreditPercent;
        uint256 minMarginUsd;
        uint256 minMarginRatio;
        uint256 incrementalMarginScalar;
        uint256 maintenanceMarginScalar;
        uint256 maxInitialMarginRatio;
        uint256 liquidationRewardPercent;
        uint128 liquidationLimitScalar;
        uint128 liquidationWindowDuration;
        uint128 liquidationMaxPd;
    }
    struct GlobalMarketConfigureParameters {
        uint64 pythPublishTimeMin;
        uint64 pythPublishTimeMax;
        uint64 minOrderAge;
        uint64 maxOrderAge;
        uint256 minKeeperFeeUsd;
        uint256 maxKeeperFeeUsd;
        uint128 keeperProfitMarginPercent;
        uint128 keeperProfitMarginUsd;
        uint128 keeperSettlementGasUnits;
        uint128 keeperCancellationGasUnits;
        uint128 keeperLiquidationGasUnits;
        uint128 keeperFlagGasUnits;
        uint128 keeperLiquidateMarginGasUnits;
        address keeperLiquidationEndorsed;
        uint128 collateralDiscountScalar;
        uint128 minCollateralDiscount;
        uint128 maxCollateralDiscount;
        uint128 utilizationBreakpointPercent;
        uint128 lowUtilizationSlopePercent;
        uint128 highUtilizationSlopePercent;
    }
}

library IOrderModule {
    struct OrderDigest {
        int128 sizeDelta;
        uint64 commitmentTime;
        uint256 limitPrice;
        uint128 keeperFeeBufferUsd;
        address[] hooks;
        bool isStale;
        bool isReady;
    }
}

library IPerpAccountModule {
    struct AccountDigest {
        DepositedCollateral[] depositedCollaterals;
        uint256 collateralUsd;
        uint128 debtUsd;
        PositionDigest position;
    }
    struct DepositedCollateral {
        address collateralAddress;
        uint256 available;
        uint256 oraclePrice;
    }
    struct PositionDigest {
        uint128 accountId;
        uint128 marketId;
        uint256 remainingMarginUsd;
        uint256 healthFactor;
        uint256 notionalValueUsd;
        int256 pnl;
        int128 accruedFunding;
        uint128 accruedUtilization;
        uint256 entryPythPrice;
        uint256 entryPrice;
        uint256 oraclePrice;
        int128 size;
        uint256 im;
        uint256 mm;
    }
}

library IPerpMarketFactoryModule {
    struct CreatePerpMarketParameters {
        bytes32 name;
        uint32 minDelegateTime;
    }
    struct DepositedCollateral {
        address collateralAddress;
        uint256 available;
    }
    struct MarketDigest {
        DepositedCollateral[] depositedCollaterals;
        bytes32 name;
        int128 skew;
        uint128 size;
        uint256 oraclePrice;
        int128 fundingVelocity;
        int128 fundingRate;
        uint128 utilizationRate;
        uint128 remainingLiquidatableSizeCapacity;
        uint128 lastLiquidationTime;
        uint128 totalTraderDebtUsd;
        uint256 totalCollateralValueUsd;
        int128 debtCorrection;
    }
    struct UtilizationDigest {
        uint128 lastComputedUtilizationRate;
        uint64 lastComputedTimestamp;
        uint128 currentUtilizationRate;
        uint256 utilization;
    }
}

library IPerpRewardDistributorFactoryModule {
    struct CreatePerpRewardDistributorParameters {
        uint128 poolId;
        address[] collateralTypes;
        string name;
        address token;
    }
}

library ISettlementHookModule {
    struct SettlementHookConfigureParameters {
        address[] whitelistedHookAddresses;
        uint32 maxHooksPerOrder;
    }
}

library Margin {
    struct MarginValues {
        uint256 discountedMarginUsd;
        uint256 marginUsd;
        uint256 discountedCollateralUsd;
        uint256 collateralUsd;
    }
}

library PerpMarketConfiguration {
    struct Data {
        bytes32 oracleNodeId;
        bytes32 pythPriceFeedId;
        uint128 makerFee;
        uint128 takerFee;
        uint128 maxMarketSize;
        uint128 maxFundingVelocity;
        uint128 skewScale;
        uint128 fundingVelocityClamp;
        uint128 minCreditPercent;
        uint256 minMarginUsd;
        uint256 minMarginRatio;
        uint256 incrementalMarginScalar;
        uint256 maintenanceMarginScalar;
        uint256 maxInitialMarginRatio;
        uint256 liquidationRewardPercent;
        uint128 liquidationLimitScalar;
        uint128 liquidationWindowDuration;
        uint128 liquidationMaxPd;
    }
    struct GlobalData {
        address pyth;
        bytes32 ethOracleNodeId;
        address rewardDistributorImplementation;
        uint64 pythPublishTimeMin;
        uint64 pythPublishTimeMax;
        uint64 minOrderAge;
        uint64 maxOrderAge;
        uint256 minKeeperFeeUsd;
        uint256 maxKeeperFeeUsd;
        uint128 keeperProfitMarginUsd;
        uint128 keeperProfitMarginPercent;
        uint128 keeperSettlementGasUnits;
        uint128 keeperCancellationGasUnits;
        uint128 keeperLiquidationGasUnits;
        uint128 keeperFlagGasUnits;
        uint128 keeperLiquidateMarginGasUnits;
        address keeperLiquidationEndorsed;
        uint128 collateralDiscountScalar;
        uint128 minCollateralDiscount;
        uint128 maxCollateralDiscount;
        uint128 utilizationBreakpointPercent;
        uint128 lowUtilizationSlopePercent;
        uint128 highUtilizationSlopePercent;
    }
}

interface IBfpMarketRouter {
    function acceptOwnership() external;
    function addToFeatureFlagAllowlist(bytes32 feature, address account) external;
    function cancelOrder(uint128 accountId, uint128 marketId, bytes memory priceUpdateData) external payable;
    function cancelStaleOrder(uint128 accountId, uint128 marketId) external;
    function commitOrder(uint128 accountId, uint128 marketId, int128 sizeDelta, uint256 limitPrice, uint128 keeperFeeBufferUsd, address[] memory hooks, bytes32 trackingCode) external;
    function createAccount() external returns (uint128 accountId);
    function createAccount(uint128 requestedAccountId) external;
    function createMarket(IPerpMarketFactoryModule.CreatePerpMarketParameters memory data) external returns (uint128);
    function createRewardDistributor(IPerpRewardDistributorFactoryModule.CreatePerpRewardDistributorParameters memory data) external returns (address);
    function enableAllFeatures() external;
    function flagPosition(uint128 accountId, uint128 marketId) external;
    function getAccountDigest(uint128 accountId, uint128 marketId) external view returns (IPerpAccountModule.AccountDigest memory);
    function getAccountLastInteraction(uint128 accountId) external view returns (uint256);
    function getAccountOwner(uint128 accountId) external view returns (address);
    function getAccountPermissions(uint128 accountId) external view returns (IAccountModule.AccountPermissions[] memory accountPerms);
    function getAccountTokenAddress() external view returns (address);
    function getActiveMarketIds() external view returns (uint128[] memory);
    function getAssociatedSystem(bytes32 id) external view returns (address addr, bytes32 kind);
    function getDeniers(bytes32 feature) external view returns (address[] memory);
    function getDiscountedCollateralPrice(address collateralAddress, uint256 amount) external view returns (uint256);
    function getEndorsedSplitAccounts() external view returns (address[] memory addresses);
    function getFeatureFlagAllowAll(bytes32 feature) external view returns (bool);
    function getFeatureFlagAllowlist(bytes32 feature) external view returns (address[] memory);
    function getFeatureFlagDenyAll(bytes32 feature) external view returns (bool);
    function getFillPrice(uint128 marketId, int128 size) external view returns (uint256);
    function getHealthFactor(uint128 accountId, uint128 marketId) external view returns (uint256);
    function getImplementation() external view returns (address);
    function getLiquidationFees(uint128 accountId, uint128 marketId) external view returns (uint256 flagKeeperReward, uint256 liqKeeperFee);
    function getLiquidationMarginUsd(uint128 accountId, uint128 marketId, int128 sizeDelta) external view returns (uint256 im, uint256 mm);
    function getMarginCollateralConfiguration() external view returns (IMarginModule.ConfiguredCollateral[] memory);
    function getMarginDigest(uint128 accountId, uint128 marketId) external view returns (Margin.MarginValues memory);
    function getMarginLiquidationOnlyReward(uint128 accountId, uint128 marketId) external view returns (uint256);
    function getMarketConfiguration() external pure returns (PerpMarketConfiguration.GlobalData memory);
    function getMarketConfigurationById(uint128 marketId) external pure returns (PerpMarketConfiguration.Data memory);
    function getMarketDigest(uint128 marketId) external view returns (IPerpMarketFactoryModule.MarketDigest memory);
    function getNetAssetValue(uint128 accountId, uint128 marketId, uint256 oraclePrice) external view returns (uint256);
    function getOraclePrice(uint128 marketId) external view returns (uint256);
    function getOrderDigest(uint128 accountId, uint128 marketId) external view returns (IOrderModule.OrderDigest memory);
    function getOrderFees(uint128 marketId, int128 sizeDelta, uint128 keeperFeeBufferUsd) external view returns (uint256 orderFee, uint256 keeperFee);
    function getPositionDigest(uint128 accountId, uint128 marketId) external view returns (IPerpAccountModule.PositionDigest memory);
    function getRemainingLiquidatableSizeCapacity(uint128 marketId) external view returns (uint128 maxLiquidatableCapacity, uint128 remainingCapacity, uint128 lastLiquidationTimestamp);
    function getSettlementHookConfiguration() external view returns (ISettlementHookModule.SettlementHookConfigureParameters memory);
    function getUtilizationDigest(uint128 marketId) external view returns (IPerpMarketFactoryModule.UtilizationDigest memory);
    function getWithdrawableMargin(uint128 accountId, uint128 marketId) external view returns (uint256);
    function grantPermission(uint128 accountId, bytes32 permission, address user) external;
    function hasPermission(uint128 accountId, bytes32 permission, address user) external view returns (bool);
    function initOrUpgradeNft(bytes32 id, string memory name, string memory symbol, string memory uri, address impl) external;
    function initOrUpgradeToken(bytes32 id, string memory name, string memory symbol, uint8 decimals, address impl) external;
    function isAuthorized(uint128 accountId, bytes32 permission, address user) external view returns (bool);
    function isEndorsedForSplitAccount(address addr) external view returns (bool);
    function isFeatureAllowed(bytes32 feature, address account) external view returns (bool);
    function isMarginLiquidatable(uint128 accountId, uint128 marketId) external view returns (bool);
    function isPositionLiquidatable(uint128 accountId, uint128 marketId) external view returns (bool);
    function isSettlementHookWhitelisted(address hook) external view returns (bool);
    function liquidateMarginOnly(uint128 accountId, uint128 marketId) external;
    function liquidatePosition(uint128 accountId, uint128 marketId) external;
    function mergeAccounts(uint128 fromId, uint128 toId, uint128 marketId) external;
    function minimumCredit(uint128 marketId) external view returns (uint256);
    function modifyCollateral(uint128 accountId, uint128 marketId, address collateralAddress, int256 amountDelta) external;
    function name(uint128) external pure returns (string memory);
    function nominateNewOwner(address newNominatedOwner) external;
    function nominatedOwner() external view returns (address);
    function notifyAccountTransfer(address to, uint128 accountId) external;
    function owner() external view returns (address);
    function payDebt(uint128 accountId, uint128 marketId, uint128 amount) external;
    function recomputeFunding(uint128 marketId) external;
    function recomputeUtilization(uint128 marketId) external;
    function registerUnmanagedSystem(bytes32 id, address endpoint) external;
    function removeFromFeatureFlagAllowlist(bytes32 feature, address account) external;
    function renounceNomination() external;
    function renouncePermission(uint128 accountId, bytes32 permission) external;
    function reportedDebt(uint128 marketId) external view returns (uint256);
    function revokePermission(uint128 accountId, bytes32 permission, address user) external;
    function setCollateralMaxAllowable(address collateralAddress, uint128 maxAllowable) external;
    function setDeniers(bytes32 feature, address[] memory deniers) external;
    function setEndorsedSplitAccounts(address[] memory addresses) external;
    function setEthOracleNodeId(bytes32 ethOracleNodeId) external;
    function setFeatureFlagAllowAll(bytes32 feature, bool allowAll) external;
    function setFeatureFlagDenyAll(bytes32 feature, bool denyAll) external;
    function setMarginCollateralConfiguration(address[] memory collateralAddresses, bytes32[] memory oracleNodeIds, uint128[] memory maxAllowables, uint128[] memory skewScales, address[] memory rewardDistributors) external;
    function setMarketConfiguration(IMarketConfigurationModule.GlobalMarketConfigureParameters memory data) external;
    function setMarketConfigurationById(IMarketConfigurationModule.ConfigureByMarketParameters memory data) external;
    function setMinDelegationTime(uint128 marketId, uint32 minDelegationTime) external;
    function setPyth(address pyth) external;
    function setRewardDistributorImplementation(address implementation) external;
    function setSettlementHookConfiguration(ISettlementHookModule.SettlementHookConfigureParameters memory data) external;
    function settleOrder(uint128 accountId, uint128 marketId, bytes memory priceUpdateData) external payable;
    function simulateUpgradeTo(address newImplementation) external;
    function splitAccount(uint128 fromId, uint128 toId, uint128 marketId, uint128 proportion) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function suspendAllFeatures() external;
    function upgradeTo(address newImplementation) external;
    function withdrawAllCollateral(uint128 accountId, uint128 marketId) external;
}

contract BfpMarketRouter {
    address immutable internal _ACCOUNT_MODULE;
    address immutable internal _ASSOCIATED_SYSTEMS_MODULE;
    address immutable internal _CORE_MODULE;
    address immutable internal _FEATURE_FLAG_MODULE;
    address immutable internal _LIQUIDATION_MODULE;
    address immutable internal _MARGIN_MODULE;
    address immutable internal _MARKET_CONFIGURATION_MODULE;
    address immutable internal _ORDER_MODULE;
    address immutable internal _PERP_ACCOUNT_MODULE;
    address immutable internal _PERP_MARKET_FACTORY_MODULE;
    address immutable internal _PERP_REWARD_DISTRIBUTOR_FACTORY_MODULE;
    address immutable internal _SETTLEMENT_HOOK_MODULE;
    address immutable internal _SPLIT_ACCOUNT_CONFIGURATION_MODULE;

    struct Modules {
        address accountModule;
        address associatedSystemsModule;
        address coreModule;
        address featureFlagModule;
        address liquidationModule;
        address marginModule;
        address marketConfigurationModule;
        address orderModule;
        address perpAccountModule;
        address perpMarketFactoryModule;
        address perpRewardDistributorFactoryModule;
        address settlementHookModule;
        address splitAccountConfigurationModule;
    }

    constructor(Modules memory $) {
        _ACCOUNT_MODULE = $.accountModule;
        _ASSOCIATED_SYSTEMS_MODULE = $.associatedSystemsModule;
        _CORE_MODULE = $.coreModule;
        _FEATURE_FLAG_MODULE = $.featureFlagModule;
        _LIQUIDATION_MODULE = $.liquidationModule;
        _MARGIN_MODULE = $.marginModule;
        _MARKET_CONFIGURATION_MODULE = $.marketConfigurationModule;
        _ORDER_MODULE = $.orderModule;
        _PERP_ACCOUNT_MODULE = $.perpAccountModule;
        _PERP_MARKET_FACTORY_MODULE = $.perpMarketFactoryModule;
        _PERP_REWARD_DISTRIBUTOR_FACTORY_MODULE = $.perpRewardDistributorFactoryModule;
        _SETTLEMENT_HOOK_MODULE = $.settlementHookModule;
        _SPLIT_ACCOUNT_CONFIGURATION_MODULE = $.splitAccountConfigurationModule;
    }

    error UnknownSelector(bytes4 sel);

    function findImplementationAddress(bytes32 implementation) internal view returns (address result) {
        if (implementation == 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97) return _ACCOUNT_MODULE;
        if (implementation == 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252) return _ASSOCIATED_SYSTEMS_MODULE;
        if (implementation == 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936) return _CORE_MODULE;
        if (implementation == 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea) return _FEATURE_FLAG_MODULE;
        if (implementation == 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208) return _LIQUIDATION_MODULE;
        if (implementation == 0x82dbcf236236acc8e56d37e9053f2a3227e4f5a4579cd2362676bb0f49280e3a) return _MARGIN_MODULE;
        if (implementation == 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6) return _MARKET_CONFIGURATION_MODULE;
        if (implementation == 0xaa94eeded57ff6cf4ecc99b7622ade7ef7cb5d3321ea23f7aa1f63becd8cf0a3) return _ORDER_MODULE;
        if (implementation == 0x3dcfeb2d2037f712a3140b99c65bf597b3f79fb22a0a7774b35f23c3262d328f) return _PERP_ACCOUNT_MODULE;
        if (implementation == 0x5ec54847c6592a92c56cd991fcf9ce6abc3edc0e172facac97c46639bc19ea81) return _PERP_MARKET_FACTORY_MODULE;
        if (implementation == 0x35131247b8b2ea0e609eb61c20764de5807e32e31b656f47b5908a7692102a29) return _PERP_REWARD_DISTRIBUTOR_FACTORY_MODULE;
        if (implementation == 0x4472a81e618e59f4f32a9859e9953443929a2aae9af41e88597b0d4028b90f8b) return _SETTLEMENT_HOOK_MODULE;
        if (implementation == 0xe9953e7ee8a6b56a791d37ae602a31d1d8e6f9ce06fd3378fb1397ed1b3fc13c) return _SPLIT_ACCOUNT_CONFIGURATION_MODULE;
    }

    fallback() external payable {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        bytes32 implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                if lt(sig, 0x9a6c5c2f) {
                    if lt(sig, 0x5bd25bf3) {
                        if lt(sig, 0x2d22bef9) {
                            if lt(sig, 0x13e8e727) {
                                switch sig
                                    case 0x00cd9ef3 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.grantPermission()
                                    case 0x01ffc9a7 { result := 0x5ec54847c6592a92c56cd991fcf9ce6abc3edc0e172facac97c46639bc19ea81 } // PerpMarketFactoryModule.supportsInterface()
                                    case 0x068b4b8c { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.isMarginLiquidatable()
                                    case 0x0b1b152e { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setMarketConfigurationById()
                                    case 0x1091f354 { result := 0x3dcfeb2d2037f712a3140b99c65bf597b3f79fb22a0a7774b35f23c3262d328f } // PerpAccountModule.mergeAccounts()
                                    case 0x1213d453 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.isAuthorized()
                                leave
                            }
                            switch sig
                                case 0x13e8e727 { result := 0x5ec54847c6592a92c56cd991fcf9ce6abc3edc0e172facac97c46639bc19ea81 } // PerpMarketFactoryModule.recomputeFunding()
                                case 0x1627540c { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.nominateNewOwner()
                                case 0x1b5dccdb { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.getAccountLastInteraction()
                                case 0x20b85720 { result := 0x35131247b8b2ea0e609eb61c20764de5807e32e31b656f47b5908a7692102a29 } // PerpRewardDistributorFactoryModule.createRewardDistributor()
                                case 0x27994e41 { result := 0x82dbcf236236acc8e56d37e9053f2a3227e4f5a4579cd2362676bb0f49280e3a } // MarginModule.getWithdrawableMargin()
                                case 0x28870e38 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setMinDelegationTime()
                            leave
                        }
                        if lt(sig, 0x39694c30) {
                            switch sig
                                case 0x2d22bef9 { result := 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252 } // AssociatedSystemsModule.initOrUpgradeNft()
                                case 0x2e2634fe { result := 0x82dbcf236236acc8e56d37e9053f2a3227e4f5a4579cd2362676bb0f49280e3a } // MarginModule.payDebt()
                                case 0x31e13b8a { result := 0xaa94eeded57ff6cf4ecc99b7622ade7ef7cb5d3321ea23f7aa1f63becd8cf0a3 } // OrderModule.commitOrder()
                                case 0x330553d6 { result := 0x4472a81e618e59f4f32a9859e9953443929a2aae9af41e88597b0d4028b90f8b } // SettlementHookModule.isSettlementHookWhitelisted()
                                case 0x3659cfe6 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.upgradeTo()
                                case 0x385b1ffa { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.suspendAllFeatures()
                            leave
                        }
                        switch sig
                            case 0x39694c30 { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.flagPosition()
                            case 0x3c85f5cf { result := 0x3dcfeb2d2037f712a3140b99c65bf597b3f79fb22a0a7774b35f23c3262d328f } // PerpAccountModule.splitAccount()
                            case 0x40a399ef { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.getFeatureFlagAllowAll()
                            case 0x47c1c561 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.renouncePermission()
                            case 0x4a347188 { result := 0x5ec54847c6592a92c56cd991fcf9ce6abc3edc0e172facac97c46639bc19ea81 } // PerpMarketFactoryModule.getMarketDigest()
                            case 0x53a47bb7 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.nominatedOwner()
                        leave
                    }
                    if lt(sig, 0x776fe959) {
                        if lt(sig, 0x6655f0fa) {
                            switch sig
                                case 0x5bd25bf3 { result := 0x3dcfeb2d2037f712a3140b99c65bf597b3f79fb22a0a7774b35f23c3262d328f } // PerpAccountModule.getPositionDigest()
                                case 0x5e52ad6e { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.setFeatureFlagDenyAll()
                                case 0x60988e09 { result := 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252 } // AssociatedSystemsModule.getAssociatedSystem()
                                case 0x60e186de { result := 0xaa94eeded57ff6cf4ecc99b7622ade7ef7cb5d3321ea23f7aa1f63becd8cf0a3 } // OrderModule.getOrderDigest()
                                case 0x643ae9d8 { result := 0xaa94eeded57ff6cf4ecc99b7622ade7ef7cb5d3321ea23f7aa1f63becd8cf0a3 } // OrderModule.getFillPrice()
                                case 0x65202fc0 { result := 0x82dbcf236236acc8e56d37e9053f2a3227e4f5a4579cd2362676bb0f49280e3a } // MarginModule.getNetAssetValue()
                            leave
                        }
                        switch sig
                            case 0x6655f0fa { result := 0x5ec54847c6592a92c56cd991fcf9ce6abc3edc0e172facac97c46639bc19ea81 } // PerpMarketFactoryModule.recomputeUtilization()
                            case 0x6c6f5e90 { result := 0xaa94eeded57ff6cf4ecc99b7622ade7ef7cb5d3321ea23f7aa1f63becd8cf0a3 } // OrderModule.settleOrder()
                            case 0x6d79056b { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.liquidateMarginOnly()
                            case 0x712a5c5b { result := 0x82dbcf236236acc8e56d37e9053f2a3227e4f5a4579cd2362676bb0f49280e3a } // MarginModule.setCollateralMaxAllowable()
                            case 0x715cb7d2 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.setDeniers()
                            case 0x718fe928 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.renounceNomination()
                        leave
                    }
                    if lt(sig, 0x8d34166b) {
                        switch sig
                            case 0x776fe959 { result := 0x5ec54847c6592a92c56cd991fcf9ce6abc3edc0e172facac97c46639bc19ea81 } // PerpMarketFactoryModule.createMarket()
                            case 0x79ba5097 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.acceptOwnership()
                            case 0x7d632bd2 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.setFeatureFlagAllowAll()
                            case 0x7dec8b55 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.notifyAccountTransfer()
                            case 0x82df5396 { result := 0xe9953e7ee8a6b56a791d37ae602a31d1d8e6f9ce06fd3378fb1397ed1b3fc13c } // SplitAccountConfigurationModule.isEndorsedForSplitAccount()
                            case 0x86967310 { result := 0x82dbcf236236acc8e56d37e9053f2a3227e4f5a4579cd2362676bb0f49280e3a } // MarginModule.getMarginCollateralConfiguration()
                        leave
                    }
                    switch sig
                        case 0x8d34166b { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.hasPermission()
                        case 0x8da5cb5b { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.owner()
                        case 0x920f2351 { result := 0xaa94eeded57ff6cf4ecc99b7622ade7ef7cb5d3321ea23f7aa1f63becd8cf0a3 } // OrderModule.getOrderFees()
                        case 0x93fe1bdd { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getMarketConfigurationById()
                        case 0x98f40e27 { result := 0x5ec54847c6592a92c56cd991fcf9ce6abc3edc0e172facac97c46639bc19ea81 } // PerpMarketFactoryModule.setEthOracleNodeId()
                    leave
                }
                if lt(sig, 0xc2c4f8ea) {
                    if lt(sig, 0xae70ab13) {
                        if lt(sig, 0xa148bf10) {
                            switch sig
                                case 0x9a6c5c2f { result := 0xaa94eeded57ff6cf4ecc99b7622ade7ef7cb5d3321ea23f7aa1f63becd8cf0a3 } // OrderModule.cancelStaleOrder()
                                case 0x9ac78e11 { result := 0xe9953e7ee8a6b56a791d37ae602a31d1d8e6f9ce06fd3378fb1397ed1b3fc13c } // SplitAccountConfigurationModule.setEndorsedSplitAccounts()
                                case 0x9dca362f { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.createAccount()
                                case 0x9ea636cf { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.getHealthFactor()
                                case 0x9fc7440b { result := 0x82dbcf236236acc8e56d37e9053f2a3227e4f5a4579cd2362676bb0f49280e3a } // MarginModule.withdrawAllCollateral()
                                case 0xa0778144 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.addToFeatureFlagAllowlist()
                            leave
                        }
                        switch sig
                            case 0xa148bf10 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.getAccountTokenAddress()
                            case 0xa2643e75 { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.getRemainingLiquidatableSizeCapacity()
                            case 0xa7627288 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.revokePermission()
                            case 0xa796fecd { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.getAccountPermissions()
                            case 0xa8ef3b26 { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.isPositionLiquidatable()
                            case 0xaaf10f42 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.getImplementation()
                        leave
                    }
                    if lt(sig, 0xbcec0d0f) {
                        switch sig
                            case 0xae70ab13 { result := 0x82dbcf236236acc8e56d37e9053f2a3227e4f5a4579cd2362676bb0f49280e3a } // MarginModule.getMarginLiquidationOnlyReward()
                            case 0xaf56690c { result := 0x82dbcf236236acc8e56d37e9053f2a3227e4f5a4579cd2362676bb0f49280e3a } // MarginModule.getMarginDigest()
                            case 0xafe79200 { result := 0x5ec54847c6592a92c56cd991fcf9ce6abc3edc0e172facac97c46639bc19ea81 } // PerpMarketFactoryModule.minimumCredit()
                            case 0xb4ebc992 { result := 0x82dbcf236236acc8e56d37e9053f2a3227e4f5a4579cd2362676bb0f49280e3a } // MarginModule.modifyCollateral()
                            case 0xb7746b59 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.removeFromFeatureFlagAllowlist()
                            case 0xbcae3ea0 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.getFeatureFlagDenyAll()
                        leave
                    }
                    switch sig
                        case 0xbcec0d0f { result := 0x5ec54847c6592a92c56cd991fcf9ce6abc3edc0e172facac97c46639bc19ea81 } // PerpMarketFactoryModule.reportedDebt()
                        case 0xbd243ff3 { result := 0x5ec54847c6592a92c56cd991fcf9ce6abc3edc0e172facac97c46639bc19ea81 } // PerpMarketFactoryModule.getActiveMarketIds()
                        case 0xbf60c31d { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.getAccountOwner()
                        case 0xc1a930ae { result := 0xaa94eeded57ff6cf4ecc99b7622ade7ef7cb5d3321ea23f7aa1f63becd8cf0a3 } // OrderModule.getOraclePrice()
                        case 0xc25c1bd2 { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.getLiquidationFees()
                    leave
                }
                if lt(sig, 0xe12c8160) {
                    if lt(sig, 0xc7f62cda) {
                        switch sig
                            case 0xc2c4f8ea { result := 0xe9953e7ee8a6b56a791d37ae602a31d1d8e6f9ce06fd3378fb1397ed1b3fc13c } // SplitAccountConfigurationModule.getEndorsedSplitAccounts()
                            case 0xc3789905 { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.getLiquidationMarginUsd()
                            case 0xc3845079 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.enableAllFeatures()
                            case 0xc624440a { result := 0x5ec54847c6592a92c56cd991fcf9ce6abc3edc0e172facac97c46639bc19ea81 } // PerpMarketFactoryModule.name()
                            case 0xc6427bd1 { result := 0x82dbcf236236acc8e56d37e9053f2a3227e4f5a4579cd2362676bb0f49280e3a } // MarginModule.setMarginCollateralConfiguration()
                            case 0xc6f79537 { result := 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252 } // AssociatedSystemsModule.initOrUpgradeToken()
                        leave
                    }
                    switch sig
                        case 0xc7f62cda { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.simulateUpgradeTo()
                        case 0xcadb09a5 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.createAccount()
                        case 0xcf635949 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.isFeatureAllowed()
                        case 0xd1a8cb18 { result := 0x5ec54847c6592a92c56cd991fcf9ce6abc3edc0e172facac97c46639bc19ea81 } // PerpMarketFactoryModule.getUtilizationDigest()
                        case 0xd245d983 { result := 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252 } // AssociatedSystemsModule.registerUnmanagedSystem()
                        case 0xdba734f0 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getMarketConfiguration()
                    leave
                }
                if lt(sig, 0xf13a6c9c) {
                    switch sig
                        case 0xe12c8160 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.getFeatureFlagAllowlist()
                        case 0xe787f63c { result := 0xaa94eeded57ff6cf4ecc99b7622ade7ef7cb5d3321ea23f7aa1f63becd8cf0a3 } // OrderModule.cancelOrder()
                        case 0xeacefda8 { result := 0x4472a81e618e59f4f32a9859e9953443929a2aae9af41e88597b0d4028b90f8b } // SettlementHookModule.getSettlementHookConfiguration()
                        case 0xed3b52a4 { result := 0x5ec54847c6592a92c56cd991fcf9ce6abc3edc0e172facac97c46639bc19ea81 } // PerpMarketFactoryModule.setRewardDistributorImplementation()
                        case 0xed429cf7 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.getDeniers()
                        case 0xee22fd6f { result := 0x5ec54847c6592a92c56cd991fcf9ce6abc3edc0e172facac97c46639bc19ea81 } // PerpMarketFactoryModule.setPyth()
                    leave
                }
                switch sig
                    case 0xf13a6c9c { result := 0x4472a81e618e59f4f32a9859e9953443929a2aae9af41e88597b0d4028b90f8b } // SettlementHookModule.setSettlementHookConfiguration()
                    case 0xf2606b7b { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setMarketConfiguration()
                    case 0xfa3e6484 { result := 0x3dcfeb2d2037f712a3140b99c65bf597b3f79fb22a0a7774b35f23c3262d328f } // PerpAccountModule.getAccountDigest()
                    case 0xfb617017 { result := 0x82dbcf236236acc8e56d37e9053f2a3227e4f5a4579cd2362676bb0f49280e3a } // MarginModule.getDiscountedCollateralPrice()
                    case 0xfb8ddda5 { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.liquidatePosition()
                leave
            }

            implementation := findImplementation(sig32)
        }

        address implementation_address = findImplementationAddress(implementation);

        if (implementation_address == address(0)) {
            revert UnknownSelector(sig4);
        }

        // Delegatecall to the implementation contract
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation_address, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}