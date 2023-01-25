//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------
// GENERATED CODE - do not edit manually!!
// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------

contract CoreRouter {
    error UnknownSelector(bytes4 sel);

    address private constant _INITIAL_MODULE_BUNDLE = 0x5c19Dccd13387AED2a92B95dA156670C3B5718dB;
    address private constant _FEATURE_FLAG_MODULE = 0x6302C1B51DCC3025500CcB979e899Aa787faD6f1;
    address private constant _ACCOUNT_MODULE = 0xB8453950C11C7764670e10c76d530296bbaCeE67;
    address private constant _ASSOCIATE_DEBT_MODULE = 0xB66904A613A5d109c61dDf477769cd9A04E9D438;
    address private constant _ASSOCIATED_SYSTEMS_MODULE = 0x8036281e73449f0817fCf1d9a510c9940aeEF381;
    address private constant _COLLATERAL_MODULE = 0x15e867569fFB34BbB2922B10Fd9EfA22AE8f0686;
    address private constant _COLLATERAL_CONFIGURATION_MODULE = 0xdFFa6DbA3c8Bbe1ee10300F41Bf9dBa1E66A9EE3;
    address private constant _ISSUE_USDMODULE = 0xC07e95315839B3980802926EeD6A4AAD9a5ae23b;
    address private constant _LIQUIDATION_MODULE = 0x9B7b893b5cD0630e0C31171e9ef355c74d428Ab2;
    address private constant _MARKET_COLLATERAL_MODULE = 0x9222Ee42849D602872894f8dC7FB22B4bd958575;
    address private constant _MARKET_MANAGER_MODULE = 0xc7eC4d029E0514Aa63CCd1DDA426CA5E3097a490;
    address private constant _MULTICALL_MODULE = 0xb61926f01cAD38f51236F861dABcC59626F2078d;
    address private constant _POOL_CONFIGURATION_MODULE = 0x460474b96c406312084be26C542b0A4532334692;
    address private constant _POOL_MODULE = 0x740c23CA8F62c91B25952449cA784Fabe49082Fb;
    address private constant _REWARDS_MANAGER_MODULE = 0xFa4c34e3123d40445E7EB2B8bf2088fF9148036D;
    address private constant _UTILS_MODULE = 0x0984a6141D902B7eD65164B5143d577a744437f6;
    address private constant _VAULT_MODULE = 0xCed8e058286Fb69f356B09F594db79E60ab9B4a0;
    
    fallback() external payable {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        address implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                if lt(sig,0x85d99ebc) {
                    if lt(sig,0x35eb2824) {
                        if lt(sig,0x170c1351) {
                            if lt(sig,0x11e72a43) {
                                switch sig
                                case 0x00cd9ef3 { result := _ACCOUNT_MODULE } // AccountModule.grantPermission()
                                case 0x07003f0a { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.isMarketCapacityLocked()
                                case 0x078145a8 { result := _VAULT_MODULE } // VaultModule.getVaultCollateral()
                                case 0x0bae9893 { result := _COLLATERAL_MODULE } // CollateralModule.createLock()
                                case 0x0dd2395a { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.getRewardRate()
                                case 0x10b0cf76 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.depositMarketUsd()
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
                            leave
                        }
                        if lt(sig,0x2d22bef9) {
                            switch sig
                            case 0x170c1351 { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.registerRewardsDistributor()
                            case 0x198f0aa1 { result := _COLLATERAL_MODULE } // CollateralModule.cleanExpiredLocks()
                            case 0x1eb60770 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getWithdrawableMarketUsd()
                            case 0x1f1b33b9 { result := _POOL_MODULE } // PoolModule.revokePoolNomination()
                            case 0x2685f42b { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.removeRewardsDistributor()
                            case 0x2a5354d2 { result := _LIQUIDATION_MODULE } // LiquidationModule.isVaultLiquidatable()
                            leave
                        }
                        switch sig
                        case 0x2d22bef9 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.initOrUpgradeNft()
                        case 0x2fa7bb65 { result := _LIQUIDATION_MODULE } // LiquidationModule.isPositionLiquidatable()
                        case 0x2fb8ff24 { result := _VAULT_MODULE } // VaultModule.getVaultDebt()
                        case 0x33cc422b { result := _VAULT_MODULE } // VaultModule.getPositionCollateral()
                        case 0x34078a01 { result := _POOL_MODULE } // PoolModule.setMinLiquidityRatio()
                        case 0x3593bbd2 { result := _VAULT_MODULE } // VaultModule.getPositionDebt()
                        leave
                    }
                    if lt(sig,0x60988e09) {
                        if lt(sig,0x48741626) {
                            switch sig
                            case 0x35eb2824 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.isOwnerModuleInitialized()
                            case 0x3659cfe6 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.upgradeTo()
                            case 0x3b390b57 { result := _POOL_CONFIGURATION_MODULE } // PoolConfigurationModule.getPreferredPool()
                            case 0x3e033a06 { result := _LIQUIDATION_MODULE } // LiquidationModule.liquidate()
                            case 0x40a399ef { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getFeatureFlagAllowAll()
                            case 0x460d2049 { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.claimRewards()
                            case 0x47c1c561 { result := _ACCOUNT_MODULE } // AccountModule.renouncePermission()
                            leave
                        }
                        switch sig
                        case 0x48741626 { result := _POOL_CONFIGURATION_MODULE } // PoolConfigurationModule.getApprovedPools()
                        case 0x51a40994 { result := _COLLATERAL_CONFIGURATION_MODULE } // CollateralConfigurationModule.getCollateralPrice()
                        case 0x53a47bb7 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.nominatedOwner()
                        case 0x5a7ff7c5 { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.distributeRewards()
                        case 0x5d8c8844 { result := _POOL_MODULE } // PoolModule.setPoolConfiguration()
                        case 0x60248c55 { result := _VAULT_MODULE } // VaultModule.getVaultCollateralRatio()
                        leave
                    }
                    if lt(sig,0x79ba5097) {
                        switch sig
                        case 0x60988e09 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.getAssociatedSystem()
                        case 0x6141f7a2 { result := _POOL_MODULE } // PoolModule.nominatePoolOwner()
                        case 0x624bd96d { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.initializeOwnerModule()
                        case 0x644cb0f3 { result := _COLLATERAL_CONFIGURATION_MODULE } // CollateralConfigurationModule.configureCollateral()
                        case 0x718fe928 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.renounceNomination()
                        case 0x75bf2444 { result := _COLLATERAL_CONFIGURATION_MODULE } // CollateralConfigurationModule.getCollateralConfigurations()
                        leave
                    }
                    switch sig
                    case 0x79ba5097 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.acceptOwnership()
                    case 0x7b0532a4 { result := _VAULT_MODULE } // VaultModule.delegateCollateral()
                    case 0x7d632bd2 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.setFeatureFlagAllowAll()
                    case 0x7d8a4140 { result := _LIQUIDATION_MODULE } // LiquidationModule.liquidateVault()
                    case 0x7dec8b55 { result := _ACCOUNT_MODULE } // AccountModule.notifyAccountTransfer()
                    case 0x83802968 { result := _COLLATERAL_MODULE } // CollateralModule.deposit()
                    leave
                }
                if lt(sig,0xc2b0cf41) {
                    if lt(sig,0xa5d49393) {
                        if lt(sig,0x9851af01) {
                            switch sig
                            case 0x85d99ebc { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketNetIssuance()
                            case 0x86e3b1cf { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketReportedDebt()
                            case 0x8d34166b { result := _ACCOUNT_MODULE } // AccountModule.hasPermission()
                            case 0x8da5cb5b { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.owner()
                            case 0x927482ff { result := _COLLATERAL_MODULE } // CollateralModule.getAccountAvailableCollateral()
                            case 0x95909ba3 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketDebtPerShare()
                            case 0x95997c51 { result := _COLLATERAL_MODULE } // CollateralModule.withdraw()
                            leave
                        }
                        switch sig
                        case 0x9851af01 { result := _POOL_MODULE } // PoolModule.getNominatedPoolOwner()
                        case 0xa0778144 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.addToFeatureFlagAllowlist()
                        case 0xa0c12269 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.distributeDebtToPools()
                        case 0xa148bf10 { result := _ACCOUNT_MODULE } // AccountModule.getAccountTokenAddress()
                        case 0xa3aa8b51 { result := _MARKET_COLLATERAL_MODULE } // MarketCollateralModule.withdrawMarketCollateral()
                        case 0xa4e6306b { result := _MARKET_COLLATERAL_MODULE } // MarketCollateralModule.depositMarketCollateral()
                        leave
                    }
                    if lt(sig,0xac9650d8) {
                        switch sig
                        case 0xa5d49393 { result := _UTILS_MODULE } // UtilsModule.configureOracleManager()
                        case 0xa64d491a { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.getClaimableRewards()
                        case 0xa7627288 { result := _ACCOUNT_MODULE } // AccountModule.revokePermission()
                        case 0xa796fecd { result := _ACCOUNT_MODULE } // AccountModule.getAccountPermissions()
                        case 0xa79b9ec9 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.registerMarket()
                        case 0xaaf10f42 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.getImplementation()
                        leave
                    }
                    switch sig
                    case 0xac9650d8 { result := _MULTICALL_MODULE } // MulticallModule.multicall()
                    case 0xb7746b59 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.removeFromFeatureFlagAllowlist()
                    case 0xb790a1ae { result := _POOL_CONFIGURATION_MODULE } // PoolConfigurationModule.addApprovedPool()
                    case 0xbaa2a264 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketTotalDebt()
                    case 0xbbdd7c5a { result := _POOL_MODULE } // PoolModule.getPoolOwner()
                    case 0xbf60c31d { result := _ACCOUNT_MODULE } // AccountModule.getAccountOwner()
                    leave
                }
                if lt(sig,0xdc0b3f52) {
                    if lt(sig,0xcadb09a5) {
                        switch sig
                        case 0xc2b0cf41 { result := _MARKET_COLLATERAL_MODULE } // MarketCollateralModule.getMarketCollateralAmount()
                        case 0xc6f79537 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.initOrUpgradeToken()
                        case 0xc707a39f { result := _POOL_MODULE } // PoolModule.acceptPoolOwnership()
                        case 0xc7f62cda { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.simulateUpgradeTo()
                        case 0xca5bed77 { result := _POOL_MODULE } // PoolModule.renouncePoolNomination()
                        case 0xcaab529b { result := _POOL_MODULE } // PoolModule.createPool()
                        leave
                    }
                    switch sig
                    case 0xcadb09a5 { result := _ACCOUNT_MODULE } // AccountModule.createAccount()
                    case 0xcf635949 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.isFeatureAllowed()
                    case 0xd245d983 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.registerUnmanagedSystem()
                    case 0xd3264e43 { result := _ISSUE_USDMODULE } // IssueUSDModule.burnUsd()
                    case 0xd4f88381 { result := _MARKET_COLLATERAL_MODULE } // MarketCollateralModule.getMarketCollateralValue()
                    case 0xdbdea94c { result := _MARKET_COLLATERAL_MODULE } // MarketCollateralModule.configureMaximumMarketCollateral()
                    leave
                }
                if lt(sig,0xef45148e) {
                    switch sig
                    case 0xdc0b3f52 { result := _COLLATERAL_CONFIGURATION_MODULE } // CollateralConfigurationModule.getCollateralConfiguration()
                    case 0xdf16a074 { result := _ISSUE_USDMODULE } // IssueUSDModule.mintUsd()
                    case 0xdf6ec54a { result := _UTILS_MODULE } // UtilsModule.registerCcip()
                    case 0xe12c8160 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getFeatureFlagAllowlist()
                    case 0xe1b440d0 { result := _POOL_CONFIGURATION_MODULE } // PoolConfigurationModule.removeApprovedPool()
                    case 0xe7098c0c { result := _POOL_CONFIGURATION_MODULE } // PoolConfigurationModule.setPreferredPool()
                    leave
                }
                switch sig
                case 0xef45148e { result := _COLLATERAL_MODULE } // CollateralModule.getAccountCollateral()
                case 0xefecf137 { result := _POOL_MODULE } // PoolModule.getPoolConfiguration()
                case 0xf08c9b5f { result := _VAULT_MODULE } // VaultModule.getPositionCollateralizationRatio()
                case 0xf544d66e { result := _VAULT_MODULE } // VaultModule.getPosition()
                case 0xf86e6f91 { result := _POOL_MODULE } // PoolModule.getPoolName()
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
