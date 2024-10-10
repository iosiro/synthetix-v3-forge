// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library CcipClient {
    struct Any2EVMMessage {
        bytes32 messageId;
        uint64 sourceChainSelector;
        bytes sender;
        bytes data;
        EVMTokenAmount[] tokenAmounts;
    }
    struct EVMTokenAmount {
        address token;
        uint256 amount;
    }
}

library CollateralConfiguration {
    struct Data {
        bool depositingEnabled;
        uint256 issuanceRatioD18;
        uint256 liquidationRatioD18;
        uint256 liquidationRewardD18;
        bytes32 oracleNodeId;
        address tokenAddress;
        uint256 minDelegationD18;
    }
}

library CollateralLock {
    struct Data {
        uint128 amountD18;
        uint64 lockExpirationTime;
    }
}

library IAccountModule {
    struct AccountPermissions {
        address user;
        bytes32[] permissions;
    }
}

library ILiquidationModule {
    struct LiquidationData {
        uint256 debtLiquidated;
        uint256 collateralLiquidated;
        uint256 amountRewarded;
    }
}

library MarketConfiguration {
    struct Data {
        uint128 marketId;
        uint128 weightD18;
        int128 maxDebtShareValueD18;
    }
}

library PoolCollateralConfiguration {
    struct Data {
        uint256 collateralLimitD18;
        uint256 issuanceRatioD18;
    }
}

interface ICoreRouter {
    function acceptOwnership() external;
    function acceptPoolOwnership(uint128 poolId) external;
    function addApprovedPool(uint128 poolId) external;
    function addToFeatureFlagAllowlist(bytes32 feature, address account) external;
    function associateDebt(uint128 marketId, uint128 poolId, address collateralType, uint128 accountId, uint256 amount) external returns (int256);
    function burnUsd(uint128 accountId, uint128 poolId, address collateralType, uint256 amount) external;
    function ccipReceive(CcipClient.Any2EVMMessage memory message) external;
    function claimPoolRewards(uint128 accountId, uint128 poolId, address collateralType, address distributor) external returns (uint256);
    function claimRewards(uint128 accountId, uint128 poolId, address collateralType, address distributor) external returns (uint256);
    function cleanExpiredLocks(uint128 accountId, address collateralType, uint256 offset, uint256 count) external returns (uint256 cleared, uint256 remainingLockAmountD18);
    function configureChainlinkCrossChain(address ccipRouter, address ccipTokenPool) external;
    function configureCollateral(CollateralConfiguration.Data memory config) external;
    function configureMaximumMarketCollateral(uint128 marketId, address collateralType, uint256 amount) external;
    function configureOracleManager(address oracleManagerAddress) external;
    function createAccount() external returns (uint128 accountId);
    function createAccount(uint128 requestedAccountId) external;
    function createLock(uint128 accountId, address collateralType, uint256 amount, uint64 expireTimestamp) external;
    function createPool(uint128 requestedPoolId, address owner) external;
    function delegateCollateral(uint128 accountId, uint128 poolId, address collateralType, uint256 newCollateralAmountD18, uint256 leverage) external;
    function deposit(uint128 accountId, address collateralType, uint256 tokenAmount) external;
    function depositMarketCollateral(uint128 marketId, address collateralType, uint256 tokenAmount) external;
    function depositMarketUsd(uint128 marketId, address target, uint256 amount) external returns (uint256 feeAmount);
    function distributeDebtToPools(uint128 marketId, uint256 maxIter) external returns (bool);
    function distributeRewards(uint128 poolId, address collateralType, uint256 amount, uint64 start, uint32 duration) external returns (int256);
    function distributeRewardsByOwner(uint128 poolId, address collateralType, address rewardsDistributor, uint256 amount, uint64 start, uint32 duration) external returns (int256);
    function getAccountAvailableCollateral(uint128 accountId, address collateralType) external view returns (uint256);
    function getAccountCollateral(uint128 accountId, address collateralType) external view returns (uint256 totalDeposited, uint256 totalAssigned, uint256 totalLocked);
    function getAccountLastInteraction(uint128 accountId) external view returns (uint256);
    function getAccountOwner(uint128 accountId) external view returns (address);
    function getAccountPermissions(uint128 accountId) external view returns (IAccountModule.AccountPermissions[] memory accountPerms);
    function getAccountTokenAddress() external view returns (address);
    function getApprovedPools() external view returns (uint256[] memory);
    function getAssociatedSystem(bytes32 id) external view returns (address addr, bytes32 kind);
    function getAvailablePoolRewards(uint128 accountId, uint128 poolId, address collateralType, address distributor) external returns (uint256);
    function getAvailableRewards(uint128 accountId, uint128 poolId, address collateralType, address distributor) external returns (uint256);
    function getCollateralConfiguration(address collateralType) external pure returns (CollateralConfiguration.Data memory);
    function getCollateralConfigurations(bool hideDisabled) external view returns (CollateralConfiguration.Data[] memory);
    function getCollateralPrice(address collateralType) external view returns (uint256);
    function getConfig(bytes32 k) external view returns (bytes32 v);
    function getConfigAddress(bytes32 k) external view returns (address v);
    function getConfigUint(bytes32 k) external view returns (uint256 v);
    function getDeniers(bytes32 feature) external view returns (address[] memory);
    function getFeatureFlagAllowAll(bytes32 feature) external view returns (bool);
    function getFeatureFlagAllowlist(bytes32 feature) external view returns (address[] memory);
    function getFeatureFlagDenyAll(bytes32 feature) external view returns (bool);
    function getImplementation() external view returns (address);
    function getLocks(uint128 accountId, address collateralType, uint256 offset, uint256 count) external view returns (CollateralLock.Data[] memory locks);
    function getMarketAddress(uint128 marketId) external view returns (address);
    function getMarketCollateral(uint128 marketId) external view returns (uint256);
    function getMarketCollateralAmount(uint128 marketId, address collateralType) external view returns (uint256 collateralAmountD18);
    function getMarketCollateralValue(uint128 marketId) external view returns (uint256);
    function getMarketDebtPerShare(uint128 marketId) external returns (int256);
    function getMarketFees(uint128, uint256 amount) external view returns (uint256 depositFeeAmount, uint256 withdrawFeeAmount);
    function getMarketMinDelegateTime(uint128 marketId) external view returns (uint32);
    function getMarketNetIssuance(uint128 marketId) external view returns (int128);
    function getMarketPoolDebtDistribution(uint128 marketId, uint128 poolId) external returns (uint256 sharesD18, uint128 totalSharesD18, int128 valuePerShareD27);
    function getMarketPools(uint128 marketId) external returns (uint128[] memory inRangePoolIds, uint128[] memory outRangePoolIds);
    function getMarketReportedDebt(uint128 marketId) external view returns (uint256);
    function getMarketTotalDebt(uint128 marketId) external view returns (int256);
    function getMaximumMarketCollateral(uint128 marketId, address collateralType) external view returns (uint256);
    function getMinLiquidityRatio() external view returns (uint256);
    function getMinLiquidityRatio(uint128 marketId) external view returns (uint256);
    function getNominatedPoolOwner(uint128 poolId) external view returns (address);
    function getOracleManager() external view returns (address);
    function getPoolCollateralConfiguration(uint128 poolId, address collateralType) external view returns (PoolCollateralConfiguration.Data memory config);
    function getPoolCollateralIssuanceRatio(uint128 poolId, address collateral) external view returns (uint256);
    function getPoolConfiguration(uint128 poolId) external view returns (MarketConfiguration.Data[] memory);
    function getPoolName(uint128 poolId) external view returns (string memory poolName);
    function getPoolOwner(uint128 poolId) external view returns (address);
    function getPosition(uint128 accountId, uint128 poolId, address collateralType) external returns (uint256 collateralAmount, uint256 collateralValue, int256 debt, uint256 collateralizationRatio);
    function getPositionCollateral(uint128 accountId, uint128 poolId, address collateralType) external view returns (uint256 amount);
    function getPositionCollateralRatio(uint128 accountId, uint128 poolId, address collateralType) external returns (uint256);
    function getPositionDebt(uint128 accountId, uint128 poolId, address collateralType) external returns (int256 debt);
    function getPreferredPool() external view returns (uint128);
    function getRewardRate(uint128 poolId, address collateralType, address distributor) external view returns (uint256);
    function getTrustedForwarder() external pure returns (address);
    function getUsdToken() external view returns (address);
    function getVaultCollateral(uint128 poolId, address collateralType) external view returns (uint256 amount, uint256 value);
    function getVaultCollateralRatio(uint128 poolId, address collateralType) external returns (uint256);
    function getVaultDebt(uint128 poolId, address collateralType) external returns (int256);
    function getWithdrawableMarketUsd(uint128 marketId) external view returns (uint256);
    function grantPermission(uint128 accountId, bytes32 permission, address user) external;
    function hasPermission(uint128 accountId, bytes32 permission, address user) external view returns (bool);
    function initOrUpgradeNft(bytes32 id, string memory name, string memory symbol, string memory uri, address impl) external;
    function initOrUpgradeToken(bytes32 id, string memory name, string memory symbol, uint8 decimals, address impl) external;
    function isAuthorized(uint128 accountId, bytes32 permission, address user) external view returns (bool);
    function isFeatureAllowed(bytes32 feature, address account) external view returns (bool);
    function isMarketCapacityLocked(uint128 marketId) external view returns (bool);
    function isPositionLiquidatable(uint128 accountId, uint128 poolId, address collateralType) external returns (bool);
    function isTrustedForwarder(address forwarder) external pure returns (bool);
    function isVaultLiquidatable(uint128 poolId, address collateralType) external returns (bool);
    function liquidate(uint128 accountId, uint128 poolId, address collateralType, uint128 liquidateAsAccountId) external returns (ILiquidationModule.LiquidationData memory liquidationData);
    function liquidateVault(uint128 poolId, address collateralType, uint128 liquidateAsAccountId, uint256 maxUsd) external returns (ILiquidationModule.LiquidationData memory liquidationData);
    function mintUsd(uint128 accountId, uint128 poolId, address collateralType, uint256 amount) external;
    function nominateNewOwner(address newNominatedOwner) external;
    function nominatePoolOwner(address nominatedOwner, uint128 poolId) external;
    function nominatedOwner() external view returns (address);
    function notifyAccountTransfer(address to, uint128 accountId) external;
    function owner() external view returns (address);
    function rebalancePool(uint128 poolId, address optionalCollateralType) external;
    function registerMarket(address market) external returns (uint128 marketId);
    function registerRewardsDistributor(uint128 poolId, address collateralType, address distributor) external;
    function registerUnmanagedSystem(bytes32 id, address endpoint) external;
    function removeApprovedPool(uint128 poolId) external;
    function removeFromFeatureFlagAllowlist(bytes32 feature, address account) external;
    function removeRewardsDistributor(uint128 poolId, address collateralType, address distributor) external;
    function renounceNomination() external;
    function renouncePermission(uint128 accountId, bytes32 permission) external;
    function renouncePoolNomination(uint128 poolId) external;
    function renouncePoolOwnership(uint128 poolId) external;
    function revokePermission(uint128 accountId, bytes32 permission, address user) external;
    function revokePoolNomination(uint128 poolId) external;
    function setConfig(bytes32 k, bytes32 v) external;
    function setDeniers(bytes32 feature, address[] memory deniers) external;
    function setFeatureFlagAllowAll(bytes32 feature, bool allowAll) external;
    function setFeatureFlagDenyAll(bytes32 feature, bool denyAll) external;
    function setMarketMinDelegateTime(uint128 marketId, uint32 minDelegateTime) external;
    function setMinLiquidityRatio(uint256 minLiquidityRatio) external;
    function setMinLiquidityRatio(uint128 marketId, uint256 minLiquidityRatio) external;
    function setPoolCollateralConfiguration(uint128 poolId, address collateralType, PoolCollateralConfiguration.Data memory newConfig) external;
    function setPoolCollateralDisabledByDefault(uint128 poolId, bool disabled) external;
    function setPoolConfiguration(uint128 poolId, MarketConfiguration.Data[] memory newMarketConfigurations) external;
    function setPoolName(uint128 poolId, string memory name) external;
    function setPreferredPool(uint128 poolId) external;
    function setSupportedCrossChainNetworks(uint64[] memory supportedNetworks, uint64[] memory ccipSelectors) external returns (uint256 numRegistered);
    function simulateUpgradeTo(address newImplementation) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function transferCrossChain(uint64 destChainId, uint256 amount) external payable returns (uint256 gasTokenUsed);
    function updateRewards(uint128 poolId, address collateralType, uint128 accountId) external returns (uint256[] memory, address[] memory, uint256);
    function upgradeTo(address newImplementation) external;
    function withdraw(uint128 accountId, address collateralType, uint256 tokenAmount) external;
    function withdrawMarketCollateral(uint128 marketId, address collateralType, uint256 tokenAmount) external;
    function withdrawMarketUsd(uint128 marketId, address target, uint256 amount) external returns (uint256 feeAmount);
}

contract CoreRouter {
    address immutable internal _ASSOCIATED_SYSTEMS_MODULE;
    address immutable internal _ISSUE_USDMODULE;
    address immutable internal _COLLATERAL_MODULE;
    address immutable internal _POOL_MODULE;
    address immutable internal _ACCOUNT_MODULE;
    address immutable internal _REWARDS_MANAGER_MODULE;
    address immutable internal _VAULT_MODULE;
    address immutable internal _ASSOCIATE_DEBT_MODULE;
    address immutable internal _CROSS_CHAIN_USDMODULE;
    address immutable internal _MARKET_COLLATERAL_MODULE;
    address immutable internal _CCIP_RECEIVER_MODULE;
    address immutable internal _COLLATERAL_CONFIGURATION_MODULE;
    address immutable internal _UTILS_MODULE;
    address immutable internal _POOL_CONFIGURATION_MODULE;
    address immutable internal _MARKET_MANAGER_MODULE;
    address immutable internal _LIQUIDATION_MODULE;
    address immutable internal _FEATURE_FLAG_MODULE;
    address immutable internal _INITIAL_MODULE_BUNDLE;

    struct Modules {
        address associatedSystemsModule;
        address issueUSDModule;
        address collateralModule;
        address poolModule;
        address accountModule;
        address rewardsManagerModule;
        address vaultModule;
        address associateDebtModule;
        address crossChainUSDModule;
        address marketCollateralModule;
        address ccipReceiverModule;
        address collateralConfigurationModule;
        address utilsModule;
        address poolConfigurationModule;
        address marketManagerModule;
        address liquidationModule;
        address featureFlagModule;
        address initialModuleBundle;
    }

    constructor(Modules memory $) {
        _ASSOCIATED_SYSTEMS_MODULE = $.associatedSystemsModule;
        _ISSUE_USDMODULE = $.issueUSDModule;
        _COLLATERAL_MODULE = $.collateralModule;
        _POOL_MODULE = $.poolModule;
        _ACCOUNT_MODULE = $.accountModule;
        _REWARDS_MANAGER_MODULE = $.rewardsManagerModule;
        _VAULT_MODULE = $.vaultModule;
        _ASSOCIATE_DEBT_MODULE = $.associateDebtModule;
        _CROSS_CHAIN_USDMODULE = $.crossChainUSDModule;
        _MARKET_COLLATERAL_MODULE = $.marketCollateralModule;
        _CCIP_RECEIVER_MODULE = $.ccipReceiverModule;
        _COLLATERAL_CONFIGURATION_MODULE = $.collateralConfigurationModule;
        _UTILS_MODULE = $.utilsModule;
        _POOL_CONFIGURATION_MODULE = $.poolConfigurationModule;
        _MARKET_MANAGER_MODULE = $.marketManagerModule;
        _LIQUIDATION_MODULE = $.liquidationModule;
        _FEATURE_FLAG_MODULE = $.featureFlagModule;
        _INITIAL_MODULE_BUNDLE = $.initialModuleBundle;
    }

    error UnknownSelector(bytes4 sel);

    function findImplementationAddress(bytes32 implementation) internal view returns (address result) {
        if (implementation == 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252) return _ASSOCIATED_SYSTEMS_MODULE;
        if (implementation == 0x0ee17508f70ff04d1df967429cf3e48a25c3393fb8280f0eb687a47267432a10) return _ISSUE_USDMODULE;
        if (implementation == 0xfb55317b42ff15c708ded3036fa17e13455835d28f48eb4a1161f7eb36131b84) return _COLLATERAL_MODULE;
        if (implementation == 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63) return _POOL_MODULE;
        if (implementation == 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97) return _ACCOUNT_MODULE;
        if (implementation == 0xc9e6687d1e56842076df50b114dde00e905e8bd11d86209c52d602d21d389959) return _REWARDS_MANAGER_MODULE;
        if (implementation == 0x96f05ac2ca619e781c735d9ffbef9721b963987bf0176c3762aa3fcd3564e293) return _VAULT_MODULE;
        if (implementation == 0xa63e12e8bb6e563af7bc495445354be8a5238a8023aa4fbaa9556445fa4175ce) return _ASSOCIATE_DEBT_MODULE;
        if (implementation == 0x998d23b15993da38b6b2736be6b65535dff4d29244fe5dc92ba56f5b532ce249) return _CROSS_CHAIN_USDMODULE;
        if (implementation == 0xbf5819b9d5009a6da1beb7169eb0038218c2af0c6b8adc43a1caabdd075d53b7) return _MARKET_COLLATERAL_MODULE;
        if (implementation == 0xdb733e1ba5df49132a98655d23d9aa259bb7f8a0d6ba84b3d3bef5cd58ce8fb7) return _CCIP_RECEIVER_MODULE;
        if (implementation == 0x0068474172de40722e6eab88b0e5c1cc53b5c16809593806d615e599ea81b581) return _COLLATERAL_CONFIGURATION_MODULE;
        if (implementation == 0xef8d3c8ad250455883c6173269ba515637266b803a8393d270f664df6e2c6e80) return _UTILS_MODULE;
        if (implementation == 0xebe07368dc01fbafdae6a99063c723758ec63a852be08716fb7da3afce8c0c3a) return _POOL_CONFIGURATION_MODULE;
        if (implementation == 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42) return _MARKET_MANAGER_MODULE;
        if (implementation == 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208) return _LIQUIDATION_MODULE;
        if (implementation == 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea) return _FEATURE_FLAG_MODULE;
        if (implementation == 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151) return _INITIAL_MODULE_BUNDLE;
    }

    fallback() external payable {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        bytes32 implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                if lt(sig, 0x830e23b5) {
                    if lt(sig, 0x3b390b57) {
                        if lt(sig, 0x198f0aa1) {
                            if lt(sig, 0x11e72a43) {
                                switch sig
                                    case 0x00cd9ef3 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.grantPermission()
                                    case 0x01ffc9a7 { result := 0xef8d3c8ad250455883c6173269ba515637266b803a8393d270f664df6e2c6e80 } // UtilsModule.supportsInterface()
                                    case 0x07003f0a { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.isMarketCapacityLocked()
                                    case 0x078145a8 { result := 0x96f05ac2ca619e781c735d9ffbef9721b963987bf0176c3762aa3fcd3564e293 } // VaultModule.getVaultCollateral()
                                    case 0x0bae9893 { result := 0xfb55317b42ff15c708ded3036fa17e13455835d28f48eb4a1161f7eb36131b84 } // CollateralModule.createLock()
                                    case 0x0dd2395a { result := 0xc9e6687d1e56842076df50b114dde00e905e8bd11d86209c52d602d21d389959 } // RewardsManagerModule.getRewardRate()
                                    case 0x10b0cf76 { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.depositMarketUsd()
                                    case 0x10d52805 { result := 0xef8d3c8ad250455883c6173269ba515637266b803a8393d270f664df6e2c6e80 } // UtilsModule.configureChainlinkCrossChain()
                                    case 0x11aa282d { result := 0xa63e12e8bb6e563af7bc495445354be8a5238a8023aa4fbaa9556445fa4175ce } // AssociateDebtModule.associateDebt()
                                leave
                            }
                            switch sig
                                case 0x11e72a43 { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.setPoolName()
                                case 0x1213d453 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.isAuthorized()
                                case 0x12e1c673 { result := 0xbf5819b9d5009a6da1beb7169eb0038218c2af0c6b8adc43a1caabdd075d53b7 } // MarketCollateralModule.getMaximumMarketCollateral()
                                case 0x140a7cfe { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.withdrawMarketUsd()
                                case 0x150834a3 { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.getMarketCollateral()
                                case 0x1627540c { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.nominateNewOwner()
                                case 0x170c1351 { result := 0xc9e6687d1e56842076df50b114dde00e905e8bd11d86209c52d602d21d389959 } // RewardsManagerModule.registerRewardsDistributor()
                                case 0x183231d7 { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.rebalancePool()
                            leave
                        }
                        if lt(sig, 0x2d22bef9) {
                            switch sig
                                case 0x198f0aa1 { result := 0xfb55317b42ff15c708ded3036fa17e13455835d28f48eb4a1161f7eb36131b84 } // CollateralModule.cleanExpiredLocks()
                                case 0x1b5dccdb { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.getAccountLastInteraction()
                                case 0x1d90e392 { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.setMarketMinDelegateTime()
                                case 0x1eb60770 { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.getWithdrawableMarketUsd()
                                case 0x1f1b33b9 { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.revokePoolNomination()
                                case 0x21f1d9e5 { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.getUsdToken()
                                case 0x25eeea4b { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.getMarketPoolDebtDistribution()
                                case 0x2685f42b { result := 0xc9e6687d1e56842076df50b114dde00e905e8bd11d86209c52d602d21d389959 } // RewardsManagerModule.removeRewardsDistributor()
                                case 0x2a5354d2 { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.isVaultLiquidatable()
                            leave
                        }
                        switch sig
                            case 0x2d22bef9 { result := 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252 } // AssociatedSystemsModule.initOrUpgradeNft()
                            case 0x2fa7bb65 { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.isPositionLiquidatable()
                            case 0x2fb8ff24 { result := 0x96f05ac2ca619e781c735d9ffbef9721b963987bf0176c3762aa3fcd3564e293 } // VaultModule.getVaultDebt()
                            case 0x33cc422b { result := 0x96f05ac2ca619e781c735d9ffbef9721b963987bf0176c3762aa3fcd3564e293 } // VaultModule.getPositionCollateral()
                            case 0x34078a01 { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.setMinLiquidityRatio()
                            case 0x340824d7 { result := 0x998d23b15993da38b6b2736be6b65535dff4d29244fe5dc92ba56f5b532ce249 } // CrossChainUSDModule.transferCrossChain()
                            case 0x3593bbd2 { result := 0x96f05ac2ca619e781c735d9ffbef9721b963987bf0176c3762aa3fcd3564e293 } // VaultModule.getPositionDebt()
                            case 0x3659cfe6 { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.upgradeTo()
                        leave
                    }
                    if lt(sig, 0x60248c55) {
                        if lt(sig, 0x51a40994) {
                            switch sig
                                case 0x3b390b57 { result := 0xebe07368dc01fbafdae6a99063c723758ec63a852be08716fb7da3afce8c0c3a } // PoolConfigurationModule.getPreferredPool()
                                case 0x3e033a06 { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.liquidate()
                                case 0x40a399ef { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.getFeatureFlagAllowAll()
                                case 0x460d2049 { result := 0xc9e6687d1e56842076df50b114dde00e905e8bd11d86209c52d602d21d389959 } // RewardsManagerModule.claimRewards()
                                case 0x47c1c561 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.renouncePermission()
                                case 0x48741626 { result := 0xebe07368dc01fbafdae6a99063c723758ec63a852be08716fb7da3afce8c0c3a } // PoolConfigurationModule.getApprovedPools()
                                case 0x49cd69ec { result := 0xc9e6687d1e56842076df50b114dde00e905e8bd11d86209c52d602d21d389959 } // RewardsManagerModule.distributeRewardsByOwner()
                                case 0x4c6568b1 { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.setPoolCollateralDisabledByDefault()
                                case 0x50f2f49b { result := 0xc9e6687d1e56842076df50b114dde00e905e8bd11d86209c52d602d21d389959 } // RewardsManagerModule.claimPoolRewards()
                            leave
                        }
                        switch sig
                            case 0x51a40994 { result := 0x0068474172de40722e6eab88b0e5c1cc53b5c16809593806d615e599ea81b581 } // CollateralConfigurationModule.getCollateralPrice()
                            case 0x53a47bb7 { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.nominatedOwner()
                            case 0x5424901b { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.getMarketMinDelegateTime()
                            case 0x572b6c05 { result := 0xef8d3c8ad250455883c6173269ba515637266b803a8393d270f664df6e2c6e80 } // UtilsModule.isTrustedForwarder()
                            case 0x5a4aabb1 { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.setPoolCollateralConfiguration()
                            case 0x5a7ff7c5 { result := 0xc9e6687d1e56842076df50b114dde00e905e8bd11d86209c52d602d21d389959 } // RewardsManagerModule.distributeRewards()
                            case 0x5d8c8844 { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.setPoolConfiguration()
                            case 0x5e52ad6e { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.setFeatureFlagDenyAll()
                        leave
                    }
                    if lt(sig, 0x718fe928) {
                        switch sig
                            case 0x60248c55 { result := 0x96f05ac2ca619e781c735d9ffbef9721b963987bf0176c3762aa3fcd3564e293 } // VaultModule.getVaultCollateralRatio()
                            case 0x60988e09 { result := 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252 } // AssociatedSystemsModule.getAssociatedSystem()
                            case 0x6141f7a2 { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.nominatePoolOwner()
                            case 0x644cb0f3 { result := 0x0068474172de40722e6eab88b0e5c1cc53b5c16809593806d615e599ea81b581 } // CollateralConfigurationModule.configureCollateral()
                            case 0x645657d8 { result := 0xc9e6687d1e56842076df50b114dde00e905e8bd11d86209c52d602d21d389959 } // RewardsManagerModule.updateRewards()
                            case 0x6dd5b69d { result := 0xef8d3c8ad250455883c6173269ba515637266b803a8393d270f664df6e2c6e80 } // UtilsModule.getConfig()
                            case 0x6fd5bdce { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.setMinLiquidityRatio()
                            case 0x715cb7d2 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.setDeniers()
                        leave
                    }
                    switch sig
                        case 0x718fe928 { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.renounceNomination()
                        case 0x75bf2444 { result := 0x0068474172de40722e6eab88b0e5c1cc53b5c16809593806d615e599ea81b581 } // CollateralConfigurationModule.getCollateralConfigurations()
                        case 0x79ba5097 { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.acceptOwnership()
                        case 0x7b0532a4 { result := 0x96f05ac2ca619e781c735d9ffbef9721b963987bf0176c3762aa3fcd3564e293 } // VaultModule.delegateCollateral()
                        case 0x7cc14a92 { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.renouncePoolOwnership()
                        case 0x7d632bd2 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.setFeatureFlagAllowAll()
                        case 0x7d8a4140 { result := 0xfb75d6efbdb0632a474557551464395e52426684b8c8c47d571c945a5808c208 } // LiquidationModule.liquidateVault()
                        case 0x7dec8b55 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.notifyAccountTransfer()
                    leave
                }
                if lt(sig, 0xc4b3410e) {
                    if lt(sig, 0xa4e6306b) {
                        if lt(sig, 0x95909ba3) {
                            switch sig
                                case 0x830e23b5 { result := 0xef8d3c8ad250455883c6173269ba515637266b803a8393d270f664df6e2c6e80 } // UtilsModule.setSupportedCrossChainNetworks()
                                case 0x83802968 { result := 0xfb55317b42ff15c708ded3036fa17e13455835d28f48eb4a1161f7eb36131b84 } // CollateralModule.deposit()
                                case 0x84f29b6d { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.getMinLiquidityRatio()
                                case 0x85572ffb { result := 0xdb733e1ba5df49132a98655d23d9aa259bb7f8a0d6ba84b3d3bef5cd58ce8fb7 } // CcipReceiverModule.ccipReceive()
                                case 0x85d99ebc { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.getMarketNetIssuance()
                                case 0x86e3b1cf { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.getMarketReportedDebt()
                                case 0x8d34166b { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.hasPermission()
                                case 0x8da5cb5b { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.owner()
                                case 0x927482ff { result := 0xfb55317b42ff15c708ded3036fa17e13455835d28f48eb4a1161f7eb36131b84 } // CollateralModule.getAccountAvailableCollateral()
                            leave
                        }
                        switch sig
                            case 0x95909ba3 { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.getMarketDebtPerShare()
                            case 0x95997c51 { result := 0xfb55317b42ff15c708ded3036fa17e13455835d28f48eb4a1161f7eb36131b84 } // CollateralModule.withdraw()
                            case 0x9851af01 { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.getNominatedPoolOwner()
                            case 0x9dca362f { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.createAccount()
                            case 0xa0778144 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.addToFeatureFlagAllowlist()
                            case 0xa0c12269 { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.distributeDebtToPools()
                            case 0xa148bf10 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.getAccountTokenAddress()
                            case 0xa3aa8b51 { result := 0xbf5819b9d5009a6da1beb7169eb0038218c2af0c6b8adc43a1caabdd075d53b7 } // MarketCollateralModule.withdrawMarketCollateral()
                        leave
                    }
                    if lt(sig, 0xb7746b59) {
                        switch sig
                            case 0xa4e6306b { result := 0xbf5819b9d5009a6da1beb7169eb0038218c2af0c6b8adc43a1caabdd075d53b7 } // MarketCollateralModule.depositMarketCollateral()
                            case 0xa5d49393 { result := 0xef8d3c8ad250455883c6173269ba515637266b803a8393d270f664df6e2c6e80 } // UtilsModule.configureOracleManager()
                            case 0xa7627288 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.revokePermission()
                            case 0xa796fecd { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.getAccountPermissions()
                            case 0xa79b9ec9 { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.registerMarket()
                            case 0xaa8c6369 { result := 0xfb55317b42ff15c708ded3036fa17e13455835d28f48eb4a1161f7eb36131b84 } // CollateralModule.getLocks()
                            case 0xaaf10f42 { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.getImplementation()
                            case 0xb01ceccd { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.getOracleManager()
                        leave
                    }
                    switch sig
                        case 0xb7746b59 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.removeFromFeatureFlagAllowlist()
                        case 0xb790a1ae { result := 0xebe07368dc01fbafdae6a99063c723758ec63a852be08716fb7da3afce8c0c3a } // PoolConfigurationModule.addApprovedPool()
                        case 0xbaa2a264 { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.getMarketTotalDebt()
                        case 0xbbdd7c5a { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.getPoolOwner()
                        case 0xbcae3ea0 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.getFeatureFlagDenyAll()
                        case 0xbe0b8e6f { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.getMarketPools()
                        case 0xbf60c31d { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.getAccountOwner()
                        case 0xc2b0cf41 { result := 0xbf5819b9d5009a6da1beb7169eb0038218c2af0c6b8adc43a1caabdd075d53b7 } // MarketCollateralModule.getMarketCollateralAmount()
                    leave
                }
                if lt(sig, 0xdc0a5384) {
                    if lt(sig, 0xce1b815f) {
                        switch sig
                            case 0xc4b3410e { result := 0xc9e6687d1e56842076df50b114dde00e905e8bd11d86209c52d602d21d389959 } // RewardsManagerModule.getAvailableRewards()
                            case 0xc4d2aad3 { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.getPoolCollateralIssuanceRatio()
                            case 0xc6f79537 { result := 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252 } // AssociatedSystemsModule.initOrUpgradeToken()
                            case 0xc707a39f { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.acceptPoolOwnership()
                            case 0xc77e51f6 { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.getPoolCollateralConfiguration()
                            case 0xc7f62cda { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.simulateUpgradeTo()
                            case 0xca5bed77 { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.renouncePoolNomination()
                            case 0xcaab529b { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.createPool()
                            case 0xcadb09a5 { result := 0xfa6e4f9d0b597c15a039f6895e4aff81103501d0f8dfee25e41810095a2c8a97 } // AccountModule.createAccount()
                        leave
                    }
                    switch sig
                        case 0xce1b815f { result := 0xef8d3c8ad250455883c6173269ba515637266b803a8393d270f664df6e2c6e80 } // UtilsModule.getTrustedForwarder()
                        case 0xcf635949 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.isFeatureAllowed()
                        case 0xd1fd27b3 { result := 0xef8d3c8ad250455883c6173269ba515637266b803a8393d270f664df6e2c6e80 } // UtilsModule.setConfig()
                        case 0xd24437f1 { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.getMarketAddress()
                        case 0xd245d983 { result := 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252 } // AssociatedSystemsModule.registerUnmanagedSystem()
                        case 0xd3264e43 { result := 0x0ee17508f70ff04d1df967429cf3e48a25c3393fb8280f0eb687a47267432a10 } // IssueUSDModule.burnUsd()
                        case 0xd4f88381 { result := 0xbf5819b9d5009a6da1beb7169eb0038218c2af0c6b8adc43a1caabdd075d53b7 } // MarketCollateralModule.getMarketCollateralValue()
                        case 0xdbdea94c { result := 0xbf5819b9d5009a6da1beb7169eb0038218c2af0c6b8adc43a1caabdd075d53b7 } // MarketCollateralModule.configureMaximumMarketCollateral()
                    leave
                }
                if lt(sig, 0xed429cf7) {
                    switch sig
                        case 0xdc0a5384 { result := 0x96f05ac2ca619e781c735d9ffbef9721b963987bf0176c3762aa3fcd3564e293 } // VaultModule.getPositionCollateralRatio()
                        case 0xdc0b3f52 { result := 0x0068474172de40722e6eab88b0e5c1cc53b5c16809593806d615e599ea81b581 } // CollateralConfigurationModule.getCollateralConfiguration()
                        case 0xdf16a074 { result := 0x0ee17508f70ff04d1df967429cf3e48a25c3393fb8280f0eb687a47267432a10 } // IssueUSDModule.mintUsd()
                        case 0xdfb83437 { result := 0x2dfc433b446bad088f600d3122d8b1f981b7228a0de166c47e010e3040036b42 } // MarketManagerModule.getMarketFees()
                        case 0xe12c8160 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.getFeatureFlagAllowlist()
                        case 0xe1b440d0 { result := 0xebe07368dc01fbafdae6a99063c723758ec63a852be08716fb7da3afce8c0c3a } // PoolConfigurationModule.removeApprovedPool()
                        case 0xe7098c0c { result := 0xebe07368dc01fbafdae6a99063c723758ec63a852be08716fb7da3afce8c0c3a } // PoolConfigurationModule.setPreferredPool()
                        case 0xeaeacda3 { result := 0xc9e6687d1e56842076df50b114dde00e905e8bd11d86209c52d602d21d389959 } // RewardsManagerModule.getAvailablePoolRewards()
                    leave
                }
                switch sig
                    case 0xed429cf7 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.getDeniers()
                    case 0xef45148e { result := 0xfb55317b42ff15c708ded3036fa17e13455835d28f48eb4a1161f7eb36131b84 } // CollateralModule.getAccountCollateral()
                    case 0xefecf137 { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.getPoolConfiguration()
                    case 0xf544d66e { result := 0x96f05ac2ca619e781c735d9ffbef9721b963987bf0176c3762aa3fcd3564e293 } // VaultModule.getPosition()
                    case 0xf86e6f91 { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.getPoolName()
                    case 0xf896503a { result := 0xef8d3c8ad250455883c6173269ba515637266b803a8393d270f664df6e2c6e80 } // UtilsModule.getConfigAddress()
                    case 0xf92bb8c9 { result := 0xef8d3c8ad250455883c6173269ba515637266b803a8393d270f664df6e2c6e80 } // UtilsModule.getConfigUint()
                    case 0xfd85c1f8 { result := 0x31c70f508334c093643f8c2497c016e26746f4d6df2be09bc6dd50bc1b2f6d63 } // PoolModule.getMinLiquidityRatio()
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