// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library AsyncOrder {
    struct Data {
        uint256 commitmentTime;
        OrderCommitmentRequest request;
    }
    struct OrderCommitmentRequest {
        uint128 marketId;
        uint128 accountId;
        int128 sizeDelta;
        uint128 settlementStrategyId;
        uint256 acceptablePrice;
        bytes32 trackingCode;
        address referrer;
    }
}

library IAccountModule {
    struct AccountPermissions {
        address user;
        bytes32[] permissions;
    }
}

library IPerpsMarketModule {
    struct MarketSummary {
        int256 skew;
        uint256 size;
        uint256 maxOpenInterest;
        int256 currentFundingRate;
        int256 currentFundingVelocity;
        uint256 indexPrice;
    }
}

library SettlementStrategy {
    type Type is uint8;
    struct Data {
        Type strategyType;
        uint256 settlementDelay;
        uint256 settlementWindowDuration;
        address priceVerificationContract;
        bytes32 feedId;
        uint256 settlementReward;
        bool disabled;
        uint256 commitmentPriceDelay;
    }
}

interface IPerpMarketRouter {
    function acceptOwnership() external;
    function addSettlementStrategy(uint128 marketId, SettlementStrategy.Data memory strategy) external returns (uint256 strategyId);
    function addToFeatureFlagAllowlist(bytes32 feature, address account) external;
    function canLiquidate(uint128 accountId) external view returns (bool isEligible);
    function canLiquidateMarginOnly(uint128 accountId) external view returns (bool isEligible);
    function cancelOrder(uint128 accountId) external;
    function commitOrder(AsyncOrder.OrderCommitmentRequest memory commitment) external returns (AsyncOrder.Data memory retOrder, uint256 fees);
    function computeOrderFees(uint128 marketId, int128 sizeDelta) external view returns (uint256 orderFees, uint256 fillPrice);
    function computeOrderFeesWithPrice(uint128 marketId, int128 sizeDelta, uint256 price) external view returns (uint256 orderFees, uint256 fillPrice);
    function createAccount() external returns (uint128 accountId);
    function createAccount(uint128 requestedAccountId) external;
    function createMarket(uint128 requestedMarketId, string memory marketName, string memory marketSymbol) external returns (uint128);
    function currentFundingRate(uint128 marketId) external view returns (int256);
    function currentFundingVelocity(uint128 marketId) external view returns (int256);
    function debt(uint128 accountId) external view returns (uint256 accountDebt);
    function fillPrice(uint128 marketId, int128 orderSize, uint256 price) external view returns (uint256);
    function flaggedAccounts() external view returns (uint256[] memory accountIds);
    function getAccountCollateralIds(uint128 accountId) external view returns (uint256[] memory);
    function getAccountLastInteraction(uint128 accountId) external view returns (uint256);
    function getAccountOpenPositions(uint128 accountId) external view returns (uint256[] memory);
    function getAccountOwner(uint128 accountId) external view returns (address);
    function getAccountPermissions(uint128 accountId) external view returns (IAccountModule.AccountPermissions[] memory accountPerms);
    function getAccountTokenAddress() external view returns (address);
    function getAssociatedSystem(bytes32 id) external view returns (address addr, bytes32 kind);
    function getAvailableMargin(uint128 accountId) external view returns (int256 availableMargin);
    function getCollateralAmount(uint128 accountId, uint128 collateralId) external view returns (uint256);
    function getCollateralConfiguration(uint128 collateralId) external view returns (uint256 maxCollateralAmount);
    function getCollateralConfigurationFull(uint128 collateralId) external view returns (uint256 maxCollateralAmount, uint256 upperLimitDiscount, uint256 lowerLimitDiscount, uint256 discountScalar);
    function getCollateralLiquidateRewardRatio() external view returns (uint128 collateralLiquidateRewardRatioD18);
    function getDeniers(bytes32 feature) external view returns (address[] memory);
    function getFeatureFlagAllowAll(bytes32 feature) external view returns (bool);
    function getFeatureFlagAllowlist(bytes32 feature) external view returns (address[] memory);
    function getFeatureFlagDenyAll(bytes32 feature) external view returns (bool);
    function getFeeCollector() external view returns (address feeCollector);
    function getFundingParameters(uint128 marketId) external view returns (uint256 skewScale, uint256 maxFundingVelocity);
    function getImplementation() external view returns (address);
    function getInterestRateParameters() external view returns (uint128 lowUtilizationInterestRateGradient, uint128 interestRateGradientBreakpoint, uint128 highUtilizationInterestRateGradient);
    function getKeeperCostNodeId() external view returns (bytes32 keeperCostNodeId);
    function getKeeperRewardGuards() external view returns (uint256 minKeeperRewardUsd, uint256 minKeeperProfitRatioD18, uint256 maxKeeperRewardUsd, uint256 maxKeeperScalingRatioD18);
    function getLiquidationParameters(uint128 marketId) external view returns (uint256 initialMarginRatioD18, uint256 minimumInitialMarginRatioD18, uint256 maintenanceMarginScalarD18, uint256 flagRewardRatioD18, uint256 minimumPositionMargin);
    function getLockedOiRatio(uint128 marketId) external view returns (uint256);
    function getMarketSummary(uint128 marketId) external view returns (IPerpsMarketModule.MarketSummary memory summary);
    function getMarkets() external view returns (uint256[] memory marketIds);
    function getMaxLiquidationParameters(uint128 marketId) external view returns (uint256 maxLiquidationLimitAccumulationMultiplier, uint256 maxSecondsInLiquidationWindow, uint256 maxLiquidationPd, address endorsedLiquidator);
    function getMaxMarketSize(uint128 marketId) external view returns (uint256 maxMarketSize);
    function getMaxMarketValue(uint128 marketId) external view returns (uint256 maxMarketValue);
    function getOpenPosition(uint128 accountId, uint128 marketId) external view returns (int256 totalPnl, int256 accruedFunding, int128 positionSize, uint256 owedInterest);
    function getOpenPositionSize(uint128 accountId, uint128 marketId) external view returns (int128 positionSize);
    function getOrder(uint128 accountId) external view returns (AsyncOrder.Data memory order);
    function getOrderFees(uint128 marketId) external view returns (uint256 makerFee, uint256 takerFee);
    function getPerAccountCaps() external view returns (uint128 maxPositionsPerAccount, uint128 maxCollateralsPerAccount);
    function getPriceData(uint128 perpsMarketId) external view returns (bytes32 feedId, uint256 strictStalenessTolerance);
    function getReferrerShare(address referrer) external view returns (uint256 shareRatioD18);
    function getRegisteredDistributor(uint128 collateralId) external view returns (address distributor, address[] memory poolDelegatedCollateralTypes);
    function getRequiredMargins(uint128 accountId) external view returns (uint256 requiredInitialMargin, uint256 requiredMaintenanceMargin, uint256 maxLiquidationReward);
    function getSettlementRewardCost(uint128 marketId, uint128 settlementStrategyId) external view returns (uint256);
    function getSettlementStrategy(uint128 marketId, uint256 strategyId) external view returns (SettlementStrategy.Data memory settlementStrategy);
    function getSupportedCollaterals() external view returns (uint256[] memory supportedCollaterals);
    function getWithdrawableMargin(uint128 accountId) external view returns (int256 withdrawableMargin);
    function globalCollateralValue(uint128 collateralId) external view returns (uint256 collateralValue);
    function grantPermission(uint128 accountId, bytes32 permission, address user) external;
    function hasPermission(uint128 accountId, bytes32 permission, address user) external view returns (bool);
    function indexPrice(uint128 marketId) external view returns (uint256);
    function initOrUpgradeNft(bytes32 id, string memory name, string memory symbol, string memory uri, address impl) external;
    function initOrUpgradeToken(bytes32 id, string memory name, string memory symbol, uint8 decimals, address impl) external;
    function initializeFactory(address synthetix, address spotMarket) external returns (uint128);
    function interestRate() external view returns (uint128);
    function isAuthorized(uint128 accountId, bytes32 permission, address user) external view returns (bool);
    function isFeatureAllowed(bytes32 feature, address account) external view returns (bool);
    function isRegistered(address distributor) external view returns (bool);
    function liquidate(uint128 accountId) external returns (uint256 liquidationReward);
    function liquidateFlagged(uint256 maxNumberOfAccounts) external returns (uint256 liquidationReward);
    function liquidateFlaggedAccounts(uint128[] memory accountIds) external returns (uint256 liquidationReward);
    function liquidateMarginOnly(uint128 accountId) external returns (uint256 liquidationReward);
    function liquidationCapacity(uint128 marketId) external view returns (uint256 capacity, uint256 maxLiquidationInWindow, uint256 latestLiquidationTimestamp);
    function maxOpenInterest(uint128 marketId) external view returns (uint256);
    function metadata(uint128 marketId) external view returns (string memory name, string memory symbol);
    function minimumCredit(uint128 perpsMarketId) external view returns (uint256);
    function modifyCollateral(uint128 accountId, uint128 collateralId, int256 amountDelta) external;
    function name(uint128 perpsMarketId) external view returns (string memory);
    function nominateNewOwner(address newNominatedOwner) external;
    function nominatedOwner() external view returns (address);
    function notifyAccountTransfer(address to, uint128 accountId) external;
    function owner() external view returns (address);
    function payDebt(uint128 accountId, uint256 amount) external;
    function registerDistributor(address token, address distributor, uint128 collateralId, address[] memory poolDelegatedCollateralTypes) external;
    function registerUnmanagedSystem(bytes32 id, address endpoint) external;
    function removeFromFeatureFlagAllowlist(bytes32 feature, address account) external;
    function renounceNomination() external;
    function renouncePermission(uint128 accountId, bytes32 permission) external;
    function reportedDebt(uint128 perpsMarketId) external view returns (uint256);
    function requiredMarginForOrder(uint128 accountId, uint128 marketId, int128 sizeDelta) external view returns (uint256 requiredMargin);
    function requiredMarginForOrderWithPrice(uint128 accountId, uint128 marketId, int128 sizeDelta, uint256 price) external view returns (uint256 requiredMargin);
    function revokePermission(uint128 accountId, bytes32 permission, address user) external;
    function setCollateralConfiguration(uint128 collateralId, uint256 maxCollateralAmount, uint256 upperLimitDiscount, uint256 lowerLimitDiscount, uint256 discountScalar) external;
    function setCollateralLiquidateRewardRatio(uint128 collateralLiquidateRewardRatioD18) external;
    function setDeniers(bytes32 feature, address[] memory deniers) external;
    function setFeatureFlagAllowAll(bytes32 feature, bool allowAll) external;
    function setFeatureFlagDenyAll(bytes32 feature, bool denyAll) external;
    function setFeeCollector(address feeCollector) external;
    function setFundingParameters(uint128 marketId, uint256 skewScale, uint256 maxFundingVelocity) external;
    function setInterestRateParameters(uint128 lowUtilizationInterestRateGradient, uint128 interestRateGradientBreakpoint, uint128 highUtilizationInterestRateGradient) external;
    function setKeeperRewardGuards(uint256 minKeeperRewardUsd, uint256 minKeeperProfitRatioD18, uint256 maxKeeperRewardUsd, uint256 maxKeeperScalingRatioD18) external;
    function setLiquidationParameters(uint128 marketId, uint256 initialMarginRatioD18, uint256 minimumInitialMarginRatioD18, uint256 maintenanceMarginScalarD18, uint256 flagRewardRatioD18, uint256 minimumPositionMargin) external;
    function setLockedOiRatio(uint128 marketId, uint256 lockedOiRatioD18) external;
    function setMaxLiquidationParameters(uint128 marketId, uint256 maxLiquidationLimitAccumulationMultiplier, uint256 maxSecondsInLiquidationWindow, uint256 maxLiquidationPd, address endorsedLiquidator) external;
    function setMaxMarketSize(uint128 marketId, uint256 maxMarketSize) external;
    function setMaxMarketValue(uint128 marketId, uint256 maxMarketValue) external;
    function setOrderFees(uint128 marketId, uint256 makerFeeRatio, uint256 takerFeeRatio) external;
    function setPerAccountCaps(uint128 maxPositionsPerAccount, uint128 maxCollateralsPerAccount) external;
    function setPerpsMarketName(string memory marketName) external;
    function setSettlementStrategy(uint128 marketId, uint256 strategyId, SettlementStrategy.Data memory strategy) external;
    function setSettlementStrategyEnabled(uint128 marketId, uint256 strategyId, bool enabled) external;
    function settleOrder(uint128 accountId) external;
    function simulateUpgradeTo(address newImplementation) external;
    function size(uint128 marketId) external view returns (uint256);
    function skew(uint128 marketId) external view returns (int256);
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function totalAccountOpenInterest(uint128 accountId) external view returns (uint256);
    function totalCollateralValue(uint128 accountId) external view returns (uint256);
    function totalGlobalCollateralValue() external view returns (uint256 totalCollateralValue);
    function updateInterestRate() external;
    function updateKeeperCostNodeId(bytes32 keeperCostNodeId) external;
    function updatePriceData(uint128 perpsMarketId, bytes32 feedId, uint256 strictStalenessTolerance) external;
    function updateReferrerShare(address referrer, uint256 shareRatioD18) external;
    function upgradeTo(address newImplementation) external;
    function utilizationRate() external view returns (uint256 rate, uint256 delegatedCollateral, uint256 lockedCredit);
}

contract PerpMarketRouter {
    address immutable internal _GLOBAL_PERPS_MARKET_MODULE;
    address immutable internal _PERPS_MARKET_FACTORY_MODULE;
    address immutable internal _ASYNC_ORDER_SETTLEMENT_PYTH_MODULE;
    address immutable internal _LIQUIDATION_MODULE;
    address immutable internal _PERPS_MARKET_MODULE;
    address immutable internal _MARKET_CONFIGURATION_MODULE;
    address immutable internal _FEATURE_FLAG_MODULE;
    address immutable internal _ASSOCIATED_SYSTEMS_MODULE;
    address immutable internal _ASYNC_ORDER_MODULE;
    address immutable internal _ASYNC_ORDER_CANCEL_MODULE;
    address immutable internal _CORE_MODULE;
    address immutable internal _PERPS_ACCOUNT_MODULE;
    address immutable internal _COLLATERAL_CONFIGURATION_MODULE;
    address immutable internal _ACCOUNT_MODULE;

    struct Modules {
        address globalPerpsMarketModule;
        address perpsMarketFactoryModule;
        address asyncOrderSettlementPythModule;
        address liquidationModule;
        address perpsMarketModule;
        address marketConfigurationModule;
        address featureFlagModule;
        address associatedSystemsModule;
        address asyncOrderModule;
        address asyncOrderCancelModule;
        address coreModule;
        address perpsAccountModule;
        address collateralConfigurationModule;
        address accountModule;
    }

    constructor(Modules memory $) {
        _GLOBAL_PERPS_MARKET_MODULE = $.globalPerpsMarketModule;
        _PERPS_MARKET_FACTORY_MODULE = $.perpsMarketFactoryModule;
        _ASYNC_ORDER_SETTLEMENT_PYTH_MODULE = $.asyncOrderSettlementPythModule;
        _LIQUIDATION_MODULE = $.liquidationModule;
        _PERPS_MARKET_MODULE = $.perpsMarketModule;
        _MARKET_CONFIGURATION_MODULE = $.marketConfigurationModule;
        _FEATURE_FLAG_MODULE = $.featureFlagModule;
        _ASSOCIATED_SYSTEMS_MODULE = $.associatedSystemsModule;
        _ASYNC_ORDER_MODULE = $.asyncOrderModule;
        _ASYNC_ORDER_CANCEL_MODULE = $.asyncOrderCancelModule;
        _CORE_MODULE = $.coreModule;
        _PERPS_ACCOUNT_MODULE = $.perpsAccountModule;
        _COLLATERAL_CONFIGURATION_MODULE = $.collateralConfigurationModule;
        _ACCOUNT_MODULE = $.accountModule;
    }

    error UnknownSelector(bytes4 sel);

    function findImplementationAddress(bytes32 implementation) internal view returns (address result) {
        if (implementation == 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156) return _GLOBAL_PERPS_MARKET_MODULE;
        if (implementation == 0x1b204be02d43f4ba05c3744fe2894f5653a6e6c323bda300cd978d8a0d8ea1a7) return _PERPS_MARKET_FACTORY_MODULE;
        if (implementation == 0xffa2091df3a834ca57985e8013cfdfa5512cf4b3b09a9b8626b2d51d7e25367f) return _ASYNC_ORDER_SETTLEMENT_PYTH_MODULE;
        if (implementation == 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208) return _LIQUIDATION_MODULE;
        if (implementation == 0x9f77233679168ade073a42beccd9047f69d846035f7eecf87d12840952d05f80) return _PERPS_MARKET_MODULE;
        if (implementation == 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6) return _MARKET_CONFIGURATION_MODULE;
        if (implementation == 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea) return _FEATURE_FLAG_MODULE;
        if (implementation == 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252) return _ASSOCIATED_SYSTEMS_MODULE;
        if (implementation == 0x8f148827f540e87584ef6bd7c48c363b0b2c36d4f0bf423491684ab341a105db) return _ASYNC_ORDER_MODULE;
        if (implementation == 0xee901a7913a90f50615960470da1eb4899327234923a1ab4dc67bcf4cde05b72) return _ASYNC_ORDER_CANCEL_MODULE;
        if (implementation == 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936) return _CORE_MODULE;
        if (implementation == 0x17d02a4c5868feaaf7887ea108c34c940940ed03eb0ee738524532f957ed3972) return _PERPS_ACCOUNT_MODULE;
        if (implementation == 0x0068474172de40722e6eab88b0e5c1cc53b5c16809593806d615e599ea81b581) return _COLLATERAL_CONFIGURATION_MODULE;
        if (implementation == 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97) return _ACCOUNT_MODULE;
    }

    fallback() external payable {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        bytes32 implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                if lt(sig, 0x7f73a891) {
                    if lt(sig, 0x3ce80659) {
                        if lt(sig, 0x1b5dccdb) {
                            if lt(sig, 0x0706067b) {
                                switch sig
                                    case 0x00cd9ef3 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.grantPermission()
                                    case 0x01ffc9a7 { result := 0x1b204be02d43f4ba05c3744fe2894f5653a6e6c323bda300cd978d8a0d8ea1a7 } // PerpsMarketFactoryModule.supportsInterface()
                                    case 0x033723d9 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setLockedOiRatio()
                                    case 0x048577de { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.liquidate()
                                    case 0x04aa363e { result := 0x17d02a4c5868feaaf7887ea108c34c940940ed03eb0ee738524532f957ed3972 } // PerpsAccountModule.getWithdrawableMargin()
                                    case 0x05db8a69 { result := 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156 } // GlobalPerpsMarketModule.getSupportedCollaterals()
                                    case 0x065ddfaa { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.canLiquidateMarginOnly()
                                    case 0x06e4ba89 { result := 0x8f148827f540e87584ef6bd7c48c363b0b2c36d4f0bf423491684ab341a105db } // AsyncOrderModule.computeOrderFeesWithPrice()
                                leave
                            }
                            switch sig
                                case 0x0706067b { result := 0x17d02a4c5868feaaf7887ea108c34c940940ed03eb0ee738524532f957ed3972 } // PerpsAccountModule.payDebt()
                                case 0x0a7dad2d { result := 0x17d02a4c5868feaaf7887ea108c34c940940ed03eb0ee738524532f957ed3972 } // PerpsAccountModule.getAvailableMargin()
                                case 0x0e7cace9 { result := 0x9f77233679168ade073a42beccd9047f69d846035f7eecf87d12840952d05f80 } // PerpsMarketModule.maxOpenInterest()
                                case 0x117d4128 { result := 0x8f148827f540e87584ef6bd7c48c363b0b2c36d4f0bf423491684ab341a105db } // AsyncOrderModule.getOrder()
                                case 0x1213d453 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.isAuthorized()
                                case 0x12fde4b7 { result := 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156 } // GlobalPerpsMarketModule.getFeeCollector()
                                case 0x1627540c { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.nominateNewOwner()
                                case 0x19a99bf5 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getMaxMarketSize()
                            leave
                        }
                        if lt(sig, 0x2d22bef9) {
                            switch sig
                                case 0x1b5dccdb { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.getAccountLastInteraction()
                                case 0x1b68d8fa { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getFundingParameters()
                                case 0x1f4653bb { result := 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156 } // GlobalPerpsMarketModule.getKeeperCostNodeId()
                                case 0x22a73967 { result := 0x17d02a4c5868feaaf7887ea108c34c940940ed03eb0ee738524532f957ed3972 } // PerpsAccountModule.getOpenPosition()
                                case 0x25e5409e { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setLiquidationParameters()
                                case 0x26641806 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setSettlementStrategy()
                                case 0x26e77e84 { result := 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156 } // GlobalPerpsMarketModule.getKeeperRewardGuards()
                                case 0x2b267635 { result := 0x9f77233679168ade073a42beccd9047f69d846035f7eecf87d12840952d05f80 } // PerpsMarketModule.size()
                            leave
                        }
                        switch sig
                            case 0x2d22bef9 { result := 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252 } // AssociatedSystemsModule.initOrUpgradeNft()
                            case 0x2daf43bc { result := 0x17d02a4c5868feaaf7887ea108c34c940940ed03eb0ee738524532f957ed3972 } // PerpsAccountModule.totalAccountOpenInterest()
                            case 0x31edc046 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getLockedOiRatio()
                            case 0x35254238 { result := 0x17d02a4c5868feaaf7887ea108c34c940940ed03eb0ee738524532f957ed3972 } // PerpsAccountModule.getAccountOpenPositions()
                            case 0x3659cfe6 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.upgradeTo()
                            case 0x3b217f67 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getMaxMarketValue()
                            case 0x3bef7df4 { result := 0x1b204be02d43f4ba05c3744fe2894f5653a6e6c323bda300cd978d8a0d8ea1a7 } // PerpsMarketFactoryModule.initializeFactory()
                            case 0x3c0f0753 { result := 0x17d02a4c5868feaaf7887ea108c34c940940ed03eb0ee738524532f957ed3972 } // PerpsAccountModule.getRequiredMargins()
                        leave
                    }
                    if lt(sig, 0x60988e09) {
                        if lt(sig, 0x5443e33e) {
                            switch sig
                                case 0x3ce80659 { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.liquidateFlaggedAccounts()
                                case 0x404a68aa { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setMaxMarketSize()
                                case 0x40a399ef { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.getFeatureFlagAllowAll()
                                case 0x41c2e8bd { result := 0x9f77233679168ade073a42beccd9047f69d846035f7eecf87d12840952d05f80 } // PerpsMarketModule.getMarketSummary()
                                case 0x462b9a2d { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getPriceData()
                                case 0x47c1c561 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.renouncePermission()
                                case 0x4f778fb4 { result := 0x9f77233679168ade073a42beccd9047f69d846035f7eecf87d12840952d05f80 } // PerpsMarketModule.indexPrice()
                                case 0x53a47bb7 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.nominatedOwner()
                            leave
                        }
                        switch sig
                            case 0x5443e33e { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getMaxLiquidationParameters()
                            case 0x55576c59 { result := 0x1b204be02d43f4ba05c3744fe2894f5653a6e6c323bda300cd978d8a0d8ea1a7 } // PerpsMarketFactoryModule.setPerpsMarketName()
                            case 0x59e1f8c1 { result := 0x0068474172de40722e6eab88b0e5c1cc53b5c16809593806d615e599ea81b581 } // CollateralConfigurationModule.getCollateralLiquidateRewardRatio()
                            case 0x5a55b582 { result := 0x0068474172de40722e6eab88b0e5c1cc53b5c16809593806d615e599ea81b581 } // CollateralConfigurationModule.getRegisteredDistributor()
                            case 0x5a6a77bf { result := 0x8f148827f540e87584ef6bd7c48c363b0b2c36d4f0bf423491684ab341a105db } // AsyncOrderModule.requiredMarginForOrderWithPrice()
                            case 0x5dbd5c9b { result := 0x17d02a4c5868feaaf7887ea108c34c940940ed03eb0ee738524532f957ed3972 } // PerpsAccountModule.getCollateralAmount()
                            case 0x5e52ad6e { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.setFeatureFlagDenyAll()
                            case 0x6097fcda { result := 0x0068474172de40722e6eab88b0e5c1cc53b5c16809593806d615e599ea81b581 } // CollateralConfigurationModule.getCollateralConfigurationFull()
                        leave
                    }
                    if lt(sig, 0x74d745fc) {
                        switch sig
                            case 0x60988e09 { result := 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252 } // AssociatedSystemsModule.getAssociatedSystem()
                            case 0x65c5a0fe { result := 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156 } // GlobalPerpsMarketModule.totalGlobalCollateralValue()
                            case 0x6809fb4d { result := 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156 } // GlobalPerpsMarketModule.updateReferrerShare()
                            case 0x6aa08501 { result := 0x0068474172de40722e6eab88b0e5c1cc53b5c16809593806d615e599ea81b581 } // CollateralConfigurationModule.setCollateralConfiguration()
                            case 0x6c321c8a { result := 0x1b204be02d43f4ba05c3744fe2894f5653a6e6c323bda300cd978d8a0d8ea1a7 } // PerpsMarketFactoryModule.utilizationRate()
                            case 0x6fa1b1a0 { result := 0x17d02a4c5868feaaf7887ea108c34c940940ed03eb0ee738524532f957ed3972 } // PerpsAccountModule.getOpenPositionSize()
                            case 0x715cb7d2 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.setDeniers()
                            case 0x718fe928 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.renounceNomination()
                        leave
                    }
                    switch sig
                        case 0x74d745fc { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.addSettlementStrategy()
                        case 0x774f7b07 { result := 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156 } // GlobalPerpsMarketModule.getPerAccountCaps()
                        case 0x77bedbcc { result := 0x0068474172de40722e6eab88b0e5c1cc53b5c16809593806d615e599ea81b581 } // CollateralConfigurationModule.setCollateralLiquidateRewardRatio()
                        case 0x79ba5097 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.acceptOwnership()
                        case 0x7c3a00fd { result := 0x1b204be02d43f4ba05c3744fe2894f5653a6e6c323bda300cd978d8a0d8ea1a7 } // PerpsMarketFactoryModule.interestRate()
                        case 0x7d632bd2 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.setFeatureFlagAllowAll()
                        case 0x7dec8b55 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.notifyAccountTransfer()
                        case 0x7e947ea4 { result := 0x1b204be02d43f4ba05c3744fe2894f5653a6e6c323bda300cd978d8a0d8ea1a7 } // PerpsMarketFactoryModule.createMarket()
                    leave
                }
                if lt(sig, 0xc2382277) {
                    if lt(sig, 0xa796fecd) {
                        if lt(sig, 0x9b922bba) {
                            switch sig
                                case 0x7f73a891 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setSettlementStrategyEnabled()
                                case 0x83a7db27 { result := 0x9f77233679168ade073a42beccd9047f69d846035f7eecf87d12840952d05f80 } // PerpsMarketModule.skew()
                                case 0x852806dc { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.liquidateMarginOnly()
                                case 0x8d34166b { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.hasPermission()
                                case 0x8da5cb5b { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.owner()
                                case 0x96e9f7a0 { result := 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156 } // GlobalPerpsMarketModule.setKeeperRewardGuards()
                                case 0x9734ba0f { result := 0x17d02a4c5868feaaf7887ea108c34c940940ed03eb0ee738524532f957ed3972 } // PerpsAccountModule.getAccountCollateralIds()
                                case 0x98ef15a2 { result := 0x8f148827f540e87584ef6bd7c48c363b0b2c36d4f0bf423491684ab341a105db } // AsyncOrderModule.computeOrderFees()
                            leave
                        }
                        switch sig
                            case 0x9b922bba { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.canLiquidate()
                            case 0x9dca362f { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.createAccount()
                            case 0x9f978860 { result := 0x8f148827f540e87584ef6bd7c48c363b0b2c36d4f0bf423491684ab341a105db } // AsyncOrderModule.commitOrder()
                            case 0xa0778144 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.addToFeatureFlagAllowlist()
                            case 0xa148bf10 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.getAccountTokenAddress()
                            case 0xa42dce80 { result := 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156 } // GlobalPerpsMarketModule.setFeeCollector()
                            case 0xa7627288 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.revokePermission()
                            case 0xa788d01f { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.flaggedAccounts()
                        leave
                    }
                    if lt(sig, 0xb7746b59) {
                        switch sig
                            case 0xa796fecd { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.getAccountPermissions()
                            case 0xaac23e8c { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getOrderFees()
                            case 0xaaf10f42 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.getImplementation()
                            case 0xac53c5ae { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.liquidateFlagged()
                            case 0xafe79200 { result := 0x1b204be02d43f4ba05c3744fe2894f5653a6e6c323bda300cd978d8a0d8ea1a7 } // PerpsMarketFactoryModule.minimumCredit()
                            case 0xb4ed6320 { result := 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156 } // GlobalPerpsMarketModule.getInterestRateParameters()
                            case 0xb568ae42 { result := 0x17d02a4c5868feaaf7887ea108c34c940940ed03eb0ee738524532f957ed3972 } // PerpsAccountModule.totalCollateralValue()
                            case 0xb5848488 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.updatePriceData()
                        leave
                    }
                    switch sig
                        case 0xb7746b59 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.removeFromFeatureFlagAllowlist()
                        case 0xb8830a25 { result := 0x8f148827f540e87584ef6bd7c48c363b0b2c36d4f0bf423491684ab341a105db } // AsyncOrderModule.requiredMarginForOrder()
                        case 0xbb36f896 { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.liquidationCapacity()
                        case 0xbb58672c { result := 0x17d02a4c5868feaaf7887ea108c34c940940ed03eb0ee738524532f957ed3972 } // PerpsAccountModule.modifyCollateral()
                        case 0xbcae3ea0 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.getFeatureFlagDenyAll()
                        case 0xbcec0d0f { result := 0x1b204be02d43f4ba05c3744fe2894f5653a6e6c323bda300cd978d8a0d8ea1a7 } // PerpsMarketFactoryModule.reportedDebt()
                        case 0xbe0cbb59 { result := 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156 } // GlobalPerpsMarketModule.setInterestRateParameters()
                        case 0xbf60c31d { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.getAccountOwner()
                    leave
                }
                if lt(sig, 0xe12c8160) {
                    if lt(sig, 0xcafdefbc) {
                        switch sig
                            case 0xc2382277 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setFundingParameters()
                            case 0xc3c5a547 { result := 0x0068474172de40722e6eab88b0e5c1cc53b5c16809593806d615e599ea81b581 } // CollateralConfigurationModule.isRegistered()
                            case 0xc624440a { result := 0x1b204be02d43f4ba05c3744fe2894f5653a6e6c323bda300cd978d8a0d8ea1a7 } // PerpsMarketFactoryModule.name()
                            case 0xc6f79537 { result := 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252 } // AssociatedSystemsModule.initOrUpgradeToken()
                            case 0xc7f62cda { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.simulateUpgradeTo()
                            case 0xc7f8a94f { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setMaxLiquidationParameters()
                            case 0xcadb09a5 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.createAccount()
                            case 0xcae77b70 { result := 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156 } // GlobalPerpsMarketModule.getReferrerShare()
                        leave
                    }
                    switch sig
                        case 0xcafdefbc { result := 0x17d02a4c5868feaaf7887ea108c34c940940ed03eb0ee738524532f957ed3972 } // PerpsAccountModule.debt()
                        case 0xce76756f { result := 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156 } // GlobalPerpsMarketModule.updateInterestRate()
                        case 0xcf635949 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.isFeatureAllowed()
                        case 0xd245d983 { result := 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252 } // AssociatedSystemsModule.registerUnmanagedSystem()
                        case 0xd435b2a2 { result := 0x9f77233679168ade073a42beccd9047f69d846035f7eecf87d12840952d05f80 } // PerpsMarketModule.currentFundingRate()
                        case 0xdbc91396 { result := 0xee901a7913a90f50615960470da1eb4899327234923a1ab4dc67bcf4cde05b72 } // AsyncOrderCancelModule.cancelOrder()
                        case 0xdd661eea { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setMaxMarketValue()
                        case 0xdeff90ef { result := 0x9f77233679168ade073a42beccd9047f69d846035f7eecf87d12840952d05f80 } // PerpsMarketModule.fillPrice()
                    leave
                }
                if lt(sig, 0xf5322087) {
                    switch sig
                        case 0xe12c8160 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.getFeatureFlagAllowlist()
                        case 0xe3bc36bf { result := 0x9f77233679168ade073a42beccd9047f69d846035f7eecf87d12840952d05f80 } // PerpsMarketModule.metadata()
                        case 0xe53427e7 { result := 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156 } // GlobalPerpsMarketModule.globalCollateralValue()
                        case 0xec2c9016 { result := 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156 } // GlobalPerpsMarketModule.getMarkets()
                        case 0xec5dedfc { result := 0x0068474172de40722e6eab88b0e5c1cc53b5c16809593806d615e599ea81b581 } // CollateralConfigurationModule.registerDistributor()
                        case 0xecfebba2 { result := 0x8f148827f540e87584ef6bd7c48c363b0b2c36d4f0bf423491684ab341a105db } // AsyncOrderModule.getSettlementRewardCost()
                        case 0xed429cf7 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.getDeniers()
                        case 0xf265db02 { result := 0x9f77233679168ade073a42beccd9047f69d846035f7eecf87d12840952d05f80 } // PerpsMarketModule.currentFundingVelocity()
                    leave
                }
                switch sig
                    case 0xf5322087 { result := 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156 } // GlobalPerpsMarketModule.updateKeeperCostNodeId()
                    case 0xf74c377f { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getSettlementStrategy()
                    case 0xf842fa86 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setOrderFees()
                    case 0xf89648fb { result := 0xffa2091df3a834ca57985e8013cfdfa5512cf4b3b09a9b8626b2d51d7e25367f } // AsyncOrderSettlementPythModule.settleOrder()
                    case 0xf94363a6 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getLiquidationParameters()
                    case 0xfa0e70a7 { result := 0x50160bf7a047817ef95e7328bccff7a81006266ee5be06323768fa64266e8156 } // GlobalPerpsMarketModule.setPerAccountCaps()
                    case 0xfd51558e { result := 0x0068474172de40722e6eab88b0e5c1cc53b5c16809593806d615e599ea81b581 } // CollateralConfigurationModule.getCollateralConfiguration()
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