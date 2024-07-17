// SPDX-License-Identifier: UNLICENSEDlt(sig
pragma solidity ^0.8.13;

interface ICoreRouter {
    struct AccountPermissions {
        address user;
        bytes32[] permissions;
    }
    struct Any2EVMMessage {
        bytes32 messageId;
        uint64 sourceChainSelector;
        bytes sender;
        bytes data;
        EVMTokenAmount[] tokenAmounts;
    }
    struct Data {
        bool depositingEnabled;
        uint256 issuanceRatioD18;
        uint256 liquidationRatioD18;
        uint256 liquidationRewardD18;
        bytes32 oracleNodeId;
        address tokenAddress;
        uint256 minDelegationD18;
    }
    struct EVMTokenAmount {
        address token;
        uint256 amount;
    }
    struct LiquidationData {
        uint256 debtLiquidated;
        uint256 collateralLiquidated;
        uint256 amountRewarded;
    }

    function acceptOwnership() external;
    function acceptPoolOwnership(uint128 poolId) external;
    function addApprovedPool(uint128 poolId) external;
    function addToFeatureFlagAllowlist(bytes32 feature, address account) external;
    function associateDebt(uint128 marketId, uint128 poolId, address collateralType, uint128 accountId, uint256 amount) external returns (int256);
    function burnUsd(uint128 accountId, uint128 poolId, address collateralType, uint256 amount) external;
    function ccipReceive(Any2EVMMessage memory message) external;
    function claimRewards(uint128 accountId, uint128 poolId, address collateralType, address distributor) external returns (uint256);
    function cleanExpiredLocks(uint128 accountId, address collateralType, uint256 offset, uint256 count) external returns (uint256 cleared);
    function configureChainlinkCrossChain(address ccipRouter, address ccipTokenPool) external;
    function configureCollateral(Data memory config) external;
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
    function distributeRewards(uint128 poolId, address collateralType, uint256 amount, uint64 start, uint32 duration) external;
    function distributeRewardsByOwner(uint128 poolId, address collateralType, address rewardsDistributor, uint256 amount, uint64 start, uint32 duration) external;
    function getAccountAvailableCollateral(uint128 accountId, address collateralType) external view returns (uint256);
    function getAccountCollateral(uint128 accountId, address collateralType) external view returns (uint256 totalDeposited, uint256 totalAssigned, uint256 totalLocked);
    function getAccountLastInteraction(uint128 accountId) external view returns (uint256);
    function getAccountOwner(uint128 accountId) external view returns (address);
    function getAccountPermissions(uint128 accountId) external view returns (AccountPermissions[] memory accountPerms);
    function getAccountTokenAddress() external view returns (address);
    function getApprovedPools() external view returns (uint256[] memory);
    function getAssociatedSystem(bytes32 id) external view returns (address addr, bytes32 kind);
    function getAvailableRewards(uint128 accountId, uint128 poolId, address collateralType, address distributor) external view returns (uint256);
    function getCollateralConfiguration(address collateralType) external pure returns (Data memory);
    function getCollateralConfigurations(bool hideDisabled) external view returns (Data[] memory);
    function getCollateralPrice(address collateralType) external view returns (uint256);
    function getConfig(bytes32 k) external view returns (bytes32 v);
    function getConfigAddress(bytes32 k) external view returns (address v);
    function getConfigUint(bytes32 k) external view returns (uint256 v);
    function getDeniers(bytes32 feature) external view returns (address[] memory);
    function getFeatureFlagAllowAll(bytes32 feature) external view returns (bool);
    function getFeatureFlagAllowlist(bytes32 feature) external view returns (address[] memory);
    function getFeatureFlagDenyAll(bytes32 feature) external view returns (bool);
    function getImplementation() external view returns (address);
    function getLocks(uint128 accountId, address collateralType, uint256 offset, uint256 count) external view returns (Data[] memory locks);
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
    function getMinLiquidityRatio(uint128 marketId) external view returns (uint256);
    function getMinLiquidityRatio() external view returns (uint256);
    function getNominatedPoolOwner(uint128 poolId) external view returns (address);
    function getOracleManager() external view returns (address);
    function getPoolCollateralConfiguration(uint128 poolId, address collateralType) external view returns (Data memory config);
    function getPoolCollateralIssuanceRatio(uint128 poolId, address collateral) external view returns (uint256);
    function getPoolConfiguration(uint128 poolId) external view returns (Data[] memory);
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
    function liquidate(uint128 accountId, uint128 poolId, address collateralType, uint128 liquidateAsAccountId) external returns (LiquidationData memory liquidationData);
    function liquidateVault(uint128 poolId, address collateralType, uint128 liquidateAsAccountId, uint256 maxUsd) external returns (LiquidationData memory liquidationData);
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
    function setMinLiquidityRatio(uint128 marketId, uint256 minLiquidityRatio) external;
    function setMinLiquidityRatio(uint256 minLiquidityRatio) external;
    function setPoolCollateralConfiguration(uint128 poolId, address collateralType, Data memory newConfig) external;
    function setPoolCollateralDisabledByDefault(uint128 poolId, bool disabled) external;
    function setPoolConfiguration(uint128 poolId, Data[] memory newMarketConfigurations) external;
    function setPoolName(uint128 poolId, string memory name) external;
    function setPreferredPool(uint128 poolId) external;
    function setSupportedCrossChainNetworks(uint64[] memory supportedNetworks, uint64[] memory ccipSelectors) external returns (uint256 numRegistered);
    function simulateUpgradeTo(address newImplementation) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function transferCrossChain(uint64 destChainId, uint256 amount) external payable returns (uint256 gasTokenUsed);
    function updateRewards(uint128 poolId, address collateralType, uint128 accountId) external returns (uint256[] memory, address[] memory);
    function upgradeTo(address newImplementation) external;
    function withdraw(uint128 accountId, address collateralType, uint256 tokenAmount) external;
    function withdrawMarketCollateral(uint128 marketId, address collateralType, uint256 tokenAmount) external;
    function withdrawMarketUsd(uint128 marketId, address target, uint256 amount) external returns (uint256 feeAmount);
}

contract CoreRouter {
    address constant _INITIAL_MODULE_BUNDLE = 0x3c0fC26278e515d9914F56c6F874423D7f1F32fB;
address constant _FEATURE_FLAG_MODULE = 0x878C51BB466203457C91876b26C287aA49048DbF;
address constant _ACCOUNT_MODULE = 0xB5F0F8CD36C2841011f98a37d8ACD2cfCF782357;
address constant _ASSOCIATE_DEBT_MODULE = 0x35F3e328B8BA7102e1cce674eF25da4cf9330882;
address constant _ASSOCIATED_SYSTEMS_MODULE = 0x5CF939598A1606FE16363Be283A6A0Fc13f3fE83;
address constant _CCIP_RECEIVER_MODULE = 0x46B6DA70fFB6B570AE01Bc651DFF6d13Ba241222;
address constant _COLLATERAL_MODULE = 0x4a99caE38C8e50eD415DFb616A30F25f5FE62BDd;
address constant _COLLATERAL_CONFIGURATION_MODULE = 0x8bbDB4A93f5Bc2853EDE0900E8196d795BF348D6;
address constant _CROSS_CHAIN_USDMODULE = 0xD4a17510703ca1ba69E3a6B41440a33451A2ADF1;
address constant _ISSUE_USDMODULE = 0xef626b524527C38130371e860487DD88Cc2D8d54;
address constant _LIQUIDATION_MODULE = 0x73173c1AF8c57C29a2a16A648a6dF115Fb754546;
address constant _MARKET_COLLATERAL_MODULE = 0x9B7C68d97B458643A200816D489B4aA9cB6B096c;
address constant _MARKET_MANAGER_MODULE = 0xa6f5bd3156108624CB091CBd9b9d2e4dfe848467;
address constant _POOL_CONFIGURATION_MODULE = 0x6a8f83fe9B68Ab81Cc8622d0B4D488762b0Dba06;
address constant _POOL_MODULE = 0xe33F92a8E8dc3437d51d1b80e0E89877fF0b5b1B;
address constant _REWARDS_MANAGER_MODULE = 0xf8e79639C8C59F04385f138CE3f36298A479377d;
address constant _UTILS_MODULE = 0xa1dAfe15441fF2164A7F41f67cfc86C386d98B66;
address constant _VAULT_MODULE = 0x52d9B1c95cb6643F265e749Cabe8AdE8E67C0c62;

    error UnknownSelector(bytes4 sel);

    fallback() external payable {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        address implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                if lt(sig, 0x830e23b5) {
                    if lt(sig, 0x3659cfe6) {
                        if lt(sig, 0x198f0aa1) {
                            if lt(sig, 0x11e72a43) {
                                switch sig
                                    case 0x00cd9ef3 { result := _ACCOUNT_MODULE } // AccountModule.grantPermission()
                                    case 0x01ffc9a7 { result := _UTILS_MODULE } // UtilsModule.supportsInterface()
                                    case 0x07003f0a { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.isMarketCapacityLocked()
                                    case 0x078145a8 { result := _VAULT_MODULE } // VaultModule.getVaultCollateral()
                                    case 0x0bae9893 { result := _COLLATERAL_MODULE } // CollateralModule.createLock()
                                    case 0x0dd2395a { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.getRewardRate()
                                    case 0x10b0cf76 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.depositMarketUsd()
                                    case 0x10d52805 { result := _UTILS_MODULE } // UtilsModule.configureChainlinkCrossChain()
                                    case 0x11aa282d { result := _ASSOCIATE_DEBT_MODULE } // AssociateDebtModule.associateDebt()
                                leave
                            }
                                    switch sig
                                        case 0x11e72a43 { result := _POOL_MODULE } // PoolModule.setPoolName()
                                        case 0x1213d453 { result := _ACCOUNT_MODULE } // AccountModule.isAuthorized()
                                        case 0x12e1c673 { result := _MARKET_COLLATERAL_MODULE } // MarketCollateralModule.getMaximumMarketCollateral()
                                        case 0x140a7cfe { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.withdrawMarketUsd()
                                        case 0x150834a3 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketCollateral()
                                        case 0x1627540c { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.nominateNewOwner()
                                        case 0x170c1351 { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.registerRewardsDistributor()
                                        case 0x183231d7 { result := _POOL_MODULE } // PoolModule.rebalancePool()
                                    leave
                        }
                                if lt(sig, 0x2a5354d2) {
                                    switch sig
                                        case 0x198f0aa1 { result := _COLLATERAL_MODULE } // CollateralModule.cleanExpiredLocks()
                                        case 0x1b5dccdb { result := _ACCOUNT_MODULE } // AccountModule.getAccountLastInteraction()
                                        case 0x1d90e392 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.setMarketMinDelegateTime()
                                        case 0x1eb60770 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getWithdrawableMarketUsd()
                                        case 0x1f1b33b9 { result := _POOL_MODULE } // PoolModule.revokePoolNomination()
                                        case 0x21f1d9e5 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getUsdToken()
                                        case 0x25eeea4b { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketPoolDebtDistribution()
                                        case 0x2685f42b { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.removeRewardsDistributor()
                                    leave
                                }
                                        switch sig
                                            case 0x2a5354d2 { result := _LIQUIDATION_MODULE } // LiquidationModule.isVaultLiquidatable()
                                            case 0x2d22bef9 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.initOrUpgradeNft()
                                            case 0x2fa7bb65 { result := _LIQUIDATION_MODULE } // LiquidationModule.isPositionLiquidatable()
                                            case 0x2fb8ff24 { result := _VAULT_MODULE } // VaultModule.getVaultDebt()
                                            case 0x33cc422b { result := _VAULT_MODULE } // VaultModule.getPositionCollateral()
                                            case 0x34078a01 { result := _POOL_MODULE } // PoolModule.setMinLiquidityRatio()
                                            case 0x340824d7 { result := _CROSS_CHAIN_USDMODULE } // CrossChainUSDModule.transferCrossChain()
                                            case 0x3593bbd2 { result := _VAULT_MODULE } // VaultModule.getPositionDebt()
                                        leave
                    }
                            if lt(sig, 0x60248c55) {
                                if lt(sig, 0x51a40994) {
                                    switch sig
                                        case 0x3659cfe6 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.upgradeTo()
                                        case 0x3b390b57 { result := _POOL_CONFIGURATION_MODULE } // PoolConfigurationModule.getPreferredPool()
                                        case 0x3e033a06 { result := _LIQUIDATION_MODULE } // LiquidationModule.liquidate()
                                        case 0x40a399ef { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getFeatureFlagAllowAll()
                                        case 0x460d2049 { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.claimRewards()
                                        case 0x47c1c561 { result := _ACCOUNT_MODULE } // AccountModule.renouncePermission()
                                        case 0x48741626 { result := _POOL_CONFIGURATION_MODULE } // PoolConfigurationModule.getApprovedPools()
                                        case 0x49cd69ec { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.distributeRewardsByOwner()
                                        case 0x4c6568b1 { result := _POOL_MODULE } // PoolModule.setPoolCollateralDisabledByDefault()
                                    leave
                                }
                                        switch sig
                                            case 0x51a40994 { result := _COLLATERAL_CONFIGURATION_MODULE } // CollateralConfigurationModule.getCollateralPrice()
                                            case 0x53a47bb7 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.nominatedOwner()
                                            case 0x5424901b { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketMinDelegateTime()
                                            case 0x572b6c05 { result := _UTILS_MODULE } // UtilsModule.isTrustedForwarder()
                                            case 0x5a4aabb1 { result := _POOL_MODULE } // PoolModule.setPoolCollateralConfiguration()
                                            case 0x5a7ff7c5 { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.distributeRewards()
                                            case 0x5d8c8844 { result := _POOL_MODULE } // PoolModule.setPoolConfiguration()
                                            case 0x5e52ad6e { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.setFeatureFlagDenyAll()
                                        leave
                            }
                                    if lt(sig, 0x718fe928) {
                                        switch sig
                                            case 0x60248c55 { result := _VAULT_MODULE } // VaultModule.getVaultCollateralRatio()
                                            case 0x60988e09 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.getAssociatedSystem()
                                            case 0x6141f7a2 { result := _POOL_MODULE } // PoolModule.nominatePoolOwner()
                                            case 0x644cb0f3 { result := _COLLATERAL_CONFIGURATION_MODULE } // CollateralConfigurationModule.configureCollateral()
                                            case 0x645657d8 { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.updateRewards()
                                            case 0x6dd5b69d { result := _UTILS_MODULE } // UtilsModule.getConfig()
                                            case 0x6fd5bdce { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.setMinLiquidityRatio()
                                            case 0x715cb7d2 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.setDeniers()
                                        leave
                                    }
                                            switch sig
                                                case 0x718fe928 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.renounceNomination()
                                                case 0x75bf2444 { result := _COLLATERAL_CONFIGURATION_MODULE } // CollateralConfigurationModule.getCollateralConfigurations()
                                                case 0x79ba5097 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.acceptOwnership()
                                                case 0x7b0532a4 { result := _VAULT_MODULE } // VaultModule.delegateCollateral()
                                                case 0x7cc14a92 { result := _POOL_MODULE } // PoolModule.renouncePoolOwnership()
                                                case 0x7d632bd2 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.setFeatureFlagAllowAll()
                                                case 0x7d8a4140 { result := _LIQUIDATION_MODULE } // LiquidationModule.liquidateVault()
                                                case 0x7dec8b55 { result := _ACCOUNT_MODULE } // AccountModule.notifyAccountTransfer()
                                            leave
                }
                        if lt(sig, 0xc4b3410e) {
                            if lt(sig, 0xa4e6306b) {
                                if lt(sig, 0x95909ba3) {
                                    switch sig
                                        case 0x830e23b5 { result := _UTILS_MODULE } // UtilsModule.setSupportedCrossChainNetworks()
                                        case 0x83802968 { result := _COLLATERAL_MODULE } // CollateralModule.deposit()
                                        case 0x84f29b6d { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMinLiquidityRatio()
                                        case 0x85572ffb { result := _CCIP_RECEIVER_MODULE } // CcipReceiverModule.ccipReceive()
                                        case 0x85d99ebc { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketNetIssuance()
                                        case 0x86e3b1cf { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketReportedDebt()
                                        case 0x8d34166b { result := _ACCOUNT_MODULE } // AccountModule.hasPermission()
                                        case 0x8da5cb5b { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.owner()
                                        case 0x927482ff { result := _COLLATERAL_MODULE } // CollateralModule.getAccountAvailableCollateral()
                                    leave
                                }
                                        switch sig
                                            case 0x95909ba3 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketDebtPerShare()
                                            case 0x95997c51 { result := _COLLATERAL_MODULE } // CollateralModule.withdraw()
                                            case 0x9851af01 { result := _POOL_MODULE } // PoolModule.getNominatedPoolOwner()
                                            case 0x9dca362f { result := _ACCOUNT_MODULE } // AccountModule.createAccount()
                                            case 0xa0778144 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.addToFeatureFlagAllowlist()
                                            case 0xa0c12269 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.distributeDebtToPools()
                                            case 0xa148bf10 { result := _ACCOUNT_MODULE } // AccountModule.getAccountTokenAddress()
                                            case 0xa3aa8b51 { result := _MARKET_COLLATERAL_MODULE } // MarketCollateralModule.withdrawMarketCollateral()
                                        leave
                            }
                                    if lt(sig, 0xb7746b59) {
                                        switch sig
                                            case 0xa4e6306b { result := _MARKET_COLLATERAL_MODULE } // MarketCollateralModule.depositMarketCollateral()
                                            case 0xa5d49393 { result := _UTILS_MODULE } // UtilsModule.configureOracleManager()
                                            case 0xa7627288 { result := _ACCOUNT_MODULE } // AccountModule.revokePermission()
                                            case 0xa796fecd { result := _ACCOUNT_MODULE } // AccountModule.getAccountPermissions()
                                            case 0xa79b9ec9 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.registerMarket()
                                            case 0xaa8c6369 { result := _COLLATERAL_MODULE } // CollateralModule.getLocks()
                                            case 0xaaf10f42 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.getImplementation()
                                            case 0xb01ceccd { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getOracleManager()
                                        leave
                                    }
                                            switch sig
                                                case 0xb7746b59 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.removeFromFeatureFlagAllowlist()
                                                case 0xb790a1ae { result := _POOL_CONFIGURATION_MODULE } // PoolConfigurationModule.addApprovedPool()
                                                case 0xbaa2a264 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketTotalDebt()
                                                case 0xbbdd7c5a { result := _POOL_MODULE } // PoolModule.getPoolOwner()
                                                case 0xbcae3ea0 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getFeatureFlagDenyAll()
                                                case 0xbe0b8e6f { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketPools()
                                                case 0xbf60c31d { result := _ACCOUNT_MODULE } // AccountModule.getAccountOwner()
                                                case 0xc2b0cf41 { result := _MARKET_COLLATERAL_MODULE } // MarketCollateralModule.getMarketCollateralAmount()
                                            leave
                        }
                                if lt(sig, 0xdbdea94c) {
                                    if lt(sig, 0xcadb09a5) {
                                        switch sig
                                            case 0xc4b3410e { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.getAvailableRewards()
                                            case 0xc4d2aad3 { result := _POOL_MODULE } // PoolModule.getPoolCollateralIssuanceRatio()
                                            case 0xc6f79537 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.initOrUpgradeToken()
                                            case 0xc707a39f { result := _POOL_MODULE } // PoolModule.acceptPoolOwnership()
                                            case 0xc77e51f6 { result := _POOL_MODULE } // PoolModule.getPoolCollateralConfiguration()
                                            case 0xc7f62cda { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.simulateUpgradeTo()
                                            case 0xca5bed77 { result := _POOL_MODULE } // PoolModule.renouncePoolNomination()
                                            case 0xcaab529b { result := _POOL_MODULE } // PoolModule.createPool()
                                        leave
                                    }
                                            switch sig
                                                case 0xcadb09a5 { result := _ACCOUNT_MODULE } // AccountModule.createAccount()
                                                case 0xce1b815f { result := _UTILS_MODULE } // UtilsModule.getTrustedForwarder()
                                                case 0xcf635949 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.isFeatureAllowed()
                                                case 0xd1fd27b3 { result := _UTILS_MODULE } // UtilsModule.setConfig()
                                                case 0xd24437f1 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketAddress()
                                                case 0xd245d983 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.registerUnmanagedSystem()
                                                case 0xd3264e43 { result := _ISSUE_USDMODULE } // IssueUSDModule.burnUsd()
                                                case 0xd4f88381 { result := _MARKET_COLLATERAL_MODULE } // MarketCollateralModule.getMarketCollateralValue()
                                            leave
                                }
                                        if lt(sig, 0xed429cf7) {
                                            switch sig
                                                case 0xdbdea94c { result := _MARKET_COLLATERAL_MODULE } // MarketCollateralModule.configureMaximumMarketCollateral()
                                                case 0xdc0a5384 { result := _VAULT_MODULE } // VaultModule.getPositionCollateralRatio()
                                                case 0xdc0b3f52 { result := _COLLATERAL_CONFIGURATION_MODULE } // CollateralConfigurationModule.getCollateralConfiguration()
                                                case 0xdf16a074 { result := _ISSUE_USDMODULE } // IssueUSDModule.mintUsd()
                                                case 0xdfb83437 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketFees()
                                                case 0xe12c8160 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getFeatureFlagAllowlist()
                                                case 0xe1b440d0 { result := _POOL_CONFIGURATION_MODULE } // PoolConfigurationModule.removeApprovedPool()
                                                case 0xe7098c0c { result := _POOL_CONFIGURATION_MODULE } // PoolConfigurationModule.setPreferredPool()
                                            leave
                                        }
                                                switch sig
                                                    case 0xed429cf7 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getDeniers()
                                                    case 0xef45148e { result := _COLLATERAL_MODULE } // CollateralModule.getAccountCollateral()
                                                    case 0xefecf137 { result := _POOL_MODULE } // PoolModule.getPoolConfiguration()
                                                    case 0xf544d66e { result := _VAULT_MODULE } // VaultModule.getPosition()
                                                    case 0xf86e6f91 { result := _POOL_MODULE } // PoolModule.getPoolName()
                                                    case 0xf896503a { result := _UTILS_MODULE } // UtilsModule.getConfigAddress()
                                                    case 0xf92bb8c9 { result := _UTILS_MODULE } // UtilsModule.getConfigUint()
                                                    case 0xfd85c1f8 { result := _POOL_MODULE } // PoolModule.getMinLiquidityRatio()
                                                leave
            }

            implementation := findImplementation(sig32)
        }

        if (implementation == address(0)) {
            revert UnknownSelector(sig4);
        }

        // Delegatecall to the implementation contract
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
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