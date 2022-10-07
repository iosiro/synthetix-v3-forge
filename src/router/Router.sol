//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./Modules.sol";
// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------
// GENERATED CODE - do not edit manually!!
// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------



contract Router {
    error UnknownSelector(bytes4 sel);



    fallback() external payable {
        _forward();
    }

    receive() external payable {
        _forward();
    }

    function _forward() internal {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        address implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                if lt(sig,0x84ea613b) {
                    if lt(sig,0x48741626) {
                        if lt(sig,0x35eb2824) {
                            if lt(sig,0x20c32bfe) {
                                switch sig
                                case 0x08cb4b07 { result := _UTILS_MODULE } // UtilsModule.mintInitialSystemToken()
                                case 0x0f76f489 { result := _POOL_MODULE } // PoolModule.getPoolName()
                                case 0x15b6abac { result := _POOL_CONFIGURATION_MODULE } // PoolConfigurationModule.removeApprovedPool()
                                case 0x1627540c { result := _OWNER_MODULE } // OwnerModule.nominateNewOwner()
                                case 0x1783af9a { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketCollateral()
                                case 0x1e22493d { result := _COLLATERAL_MODULE } // CollateralModule.getAccountAvailableCollateral()
                                leave
                            }
                            switch sig
                            case 0x20c32bfe { result := _POOL_MODULE } // PoolModule.setPoolName()
                            case 0x28e70c4e { result := _VAULT_MODULE } // VaultModule.getPosition()
                            case 0x2aefd998 { result := _VAULT_MODULE } // VaultModule.getPositionCollateralizationRatio()
                            case 0x2d22bef9 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.initOrUpgradeNft()
                            case 0x2e80a326 { result := _VAULT_MODULE } // VaultModule.burnUsd()
                            case 0x34078a01 { result := _POOL_MODULE } // PoolModule.setMinLiquidityRatio()
                            leave
                        }
                        if lt(sig,0x3d3395dc) {
                            switch sig
                            case 0x35eb2824 { result := _OWNER_MODULE } // OwnerModule.isOwnerModuleInitialized()
                            case 0x3659cfe6 { result := _UPGRADE_MODULE } // UpgradeModule.upgradeTo()
                            case 0x37cea612 { result := _POOL_MODULE } // PoolModule.renouncePoolOwnership()
                            case 0x3a9a1b39 { result := _REWARD_DISTRIBUTOR_MODULE } // RewardDistributorModule.setRewardAllocation()
                            case 0x3ab64a5e { result := _ACCOUNT_MODULE } // AccountModule.renouncePermission()
                            case 0x3b390b57 { result := _POOL_CONFIGURATION_MODULE } // PoolConfigurationModule.getPreferredPool()
                            leave
                        }
                        switch sig
                        case 0x3d3395dc { result := _POOL_CONFIGURATION_MODULE } // PoolConfigurationModule.setPreferredPool()
                        case 0x3d771826 { result := _LIQUIDATIONS_MODULE } // LiquidationsModule.isLiquidatable()
                        case 0x3f1f6f8e { result := _ACCOUNT_MODULE } // AccountModule.getAccountPermissions()
                        case 0x46860545 { result := _VAULT_MODULE } // VaultModule.getPositionDebt()
                        case 0x46f75858 { result := _POOL_MODULE } // PoolModule.acceptPoolOwnership()
                        leave
                    }
                    if lt(sig,0x624bd96d) {
                        if lt(sig,0x54149c43) {
                            switch sig
                            case 0x48741626 { result := _POOL_CONFIGURATION_MODULE } // PoolConfigurationModule.getApprovedPools()
                            case 0x4892da8d { result := _REWARD_DISTRIBUTOR_MODULE } // RewardDistributorModule.payout()
                            case 0x51339377 { result := _COLLATERAL_MODULE } // CollateralModule.getAccountCollateral()
                            case 0x52113e05 { result := _POOL_MODULE } // PoolModule.nominatePoolOwner()
                            case 0x525a20dc { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.withdrawUsd()
                            case 0x53a47bb7 { result := _OWNER_MODULE } // OwnerModule.nominatedOwner()
                            leave
                        }
                        switch sig
                        case 0x54149c43 { result := _MARKET_COLLATERAL_MODULE } // MarketCollateralModule.getMaximumMarketCollateral()
                        case 0x5631d33f { result := _ACCOUNT_RBACMIXIN_MODULE_MOCK } // AccountRBACMixinModuleMock.mockAccountRBACMixinDeposit()
                        case 0x5ddaa1ed { result := _VAULT_MODULE } // VaultModule.getVaultDebt()
                        case 0x5ed250dc { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.getAvailableRewards()
                        case 0x60988e09 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.getAssociatedSystem()
                        leave
                    }
                    if lt(sig,0x75bf2444) {
                        switch sig
                        case 0x624bd96d { result := _OWNER_MODULE } // OwnerModule.initializeOwnerModule()
                        case 0x6e34b4e4 { result := _POOL_MODULE } // PoolModule.getPoolOwner()
                        case 0x6e4d44e2 { result := _MARKET_COLLATERAL_MODULE } // MarketCollateralModule.getMarketCollateralAmount()
                        case 0x6ede9268 { result := _ACCOUNT_RBACMIXIN_MODULE_MOCK } // AccountRBACMixinModuleMock.mockAccountRBACMixinGetDepositMock()
                        case 0x718fe928 { result := _OWNER_MODULE } // OwnerModule.renounceNomination()
                        case 0x7525b135 { result := _VAULT_MODULE } // VaultModule.getVaultCollateral()
                        leave
                    }
                    switch sig
                    case 0x75bf2444 { result := _COLLATERAL_MODULE } // CollateralModule.getCollateralConfigurations()
                    case 0x7914d333 { result := _POOL_MODULE } // PoolModule.createPool()
                    case 0x79ba5097 { result := _OWNER_MODULE } // OwnerModule.acceptOwnership()
                    case 0x7ca84745 { result := _VAULT_MODULE } // VaultModule.mintUsd()
                    case 0x7deaa3ad { result := _MARKET_COLLATERAL_MODULE } // MarketCollateralModule.depositMarketCollateral()
                    leave
                }
                if lt(sig,0xbfdee804) {
                    if lt(sig,0xa79b9ec9) {
                        if lt(sig,0x99897b0f) {
                            switch sig
                            case 0x84ea613b { result := _ACCOUNT_RBACMIXIN_MODULE_MOCK } // AccountRBACMixinModuleMock.mockAccountRBACMixinMint()
                            case 0x8921991a { result := _POOL_MODULE } // PoolModule.setPoolConfiguration()
                            case 0x8d92cb6c { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.depositUsd()
                            case 0x8da5cb5b { result := _OWNER_MODULE } // OwnerModule.owner()
                            case 0x94b2073b { result := _POOL_MODULE } // PoolModule.getPoolConfiguration()
                            case 0x97904e42 { result := _COLLATERAL_MODULE } // CollateralModule.getCollateralValue()
                            leave
                        }
                        switch sig
                        case 0x99897b0f { result := _ACCOUNT_MODULE } // AccountModule.grantPermission()
                        case 0x99ea56b0 { result := _COLLATERAL_MODULE } // CollateralModule.withdrawCollateral()
                        case 0x9cbbb824 { result := _COLLATERAL_MODULE } // CollateralModule.configureCollateral()
                        case 0x9d9df569 { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.claimRewards()
                        case 0xa148bf10 { result := _ACCOUNT_MODULE } // AccountModule.getAccountTokenAddress()
                        case 0xa46e4db4 { result := _VAULT_MODULE } // VaultModule.getPositionCollateral()
                        leave
                    }
                    if lt(sig,0xb48773ac) {
                        switch sig
                        case 0xa79b9ec9 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.registerMarket()
                        case 0xa7d65764 { result := _ACCOUNT_MODULE } // AccountModule.hasPermission()
                        case 0xaaf10f42 { result := _UPGRADE_MODULE } // UpgradeModule.getImplementation()
                        case 0xac9650d8 { result := _MULTICALL_MODULE } // MulticallModule.multicall()
                        case 0xae5cf824 { result := _ACCOUNT_MODULE } // AccountModule.getAccountOwner()
                        case 0xb13c37d2 { result := _VAULT_MODULE } // VaultModule.delegateCollateral()
                        leave
                    }
                    switch sig
                    case 0xb48773ac { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketReportedDebt()
                    case 0xb6ab6a85 { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.getCurrentRewardAccumulation()
                    case 0xb6ee9177 { result := _ACCOUNT_MODULE } // AccountModule.notifyAccountTransfer()
                    case 0xbbb85864 { result := _POOL_MODULE } // PoolModule.getNominatedPoolOwner()
                    case 0xbd0e17f9 { result := _POOL_MODULE } // PoolModule.renouncePoolNomination()
                    leave
                }
                if lt(sig,0xddf0974d) {
                    if lt(sig,0xcc0098ab) {
                        switch sig
                        case 0xbfdee804 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketDebtPerShare()
                        case 0xc6f79537 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.initOrUpgradeToken()
                        case 0xc701f2ea { result := _REWARDS_MANAGER_MODULE } // RewardsManagerModule.distributeRewards()
                        case 0xc7f62cda { result := _UPGRADE_MODULE } // UpgradeModule.simulateUpgradeTo()
                        case 0xcab13915 { result := _ACCOUNT_MODULE } // AccountModule.createAccount()
                        case 0xcae89df0 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketIssuance()
                        leave
                    }
                    switch sig
                    case 0xcc0098ab { result := _POOL_CONFIGURATION_MODULE } // PoolConfigurationModule.addApprovedPool()
                    case 0xd222d65c { result := _VAULT_MODULE } // VaultModule.getVaultCollateralRatio()
                    case 0xd245d983 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.registerUnmanagedSystem()
                    case 0xdc0b3f52 { result := _COLLATERAL_MODULE } // CollateralModule.getCollateralConfiguration()
                    case 0xdd9651ff { result := _LIQUIDATIONS_MODULE } // LiquidationsModule.liquidateVault()
                    leave
                }
                if lt(sig,0xf354a339) {
                    switch sig
                    case 0xddf0974d { result := _ACCOUNT_RBACMIXIN_MODULE_MOCK } // AccountRBACMixinModuleMock.mockAccountRBACMixinGetMintMock()
                    case 0xe326b5e6 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getMarketTotalBalance()
                    case 0xebea51b4 { result := _COLLATERAL_MODULE } // CollateralModule.depositCollateral()
                    case 0xec9d525b { result := _MARKET_COLLATERAL_MODULE } // MarketCollateralModule.withdrawMarketCollateral()
                    case 0xeede3ad0 { result := _MARKET_MANAGER_MODULE } // MarketManagerModule.getWithdrawableUsd()
                    case 0xefd70871 { result := _ACCOUNT_MODULE } // AccountModule.revokePermission()
                    leave
                }
                switch sig
                case 0xf354a339 { result := _LIQUIDATIONS_MODULE } // LiquidationsModule.liquidate()
                case 0xf623e194 { result := _MARKET_COLLATERAL_MODULE } // MarketCollateralModule.configureMaximumMarketCollateral()
                case 0xfb03d62e { result := _REWARD_DISTRIBUTOR_MODULE } // RewardDistributorModule.getRewardAllocation()
                case 0xfc4b181d { result := _ACCOUNT_MODULE } // AccountModule.isAuthorized()
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

contract TokenRouter {
    error UnknownSelector(bytes4 sel);

    fallback() external payable {
        _forward();
    }

    receive() external payable {
        _forward();
    }

    function _forward() internal {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        address implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                if lt(sig,0x718fe928) {
                    switch sig
                    case 0x1627540c { result := _OWNER_MODULE } // OwnerModule.nominateNewOwner()
                    case 0x35eb2824 { result := _OWNER_MODULE } // OwnerModule.isOwnerModuleInitialized()
                    case 0x3659cfe6 { result := _UPGRADE_MODULE } // UpgradeModule.upgradeTo()
                    case 0x53a47bb7 { result := _OWNER_MODULE } // OwnerModule.nominatedOwner()
                    case 0x624bd96d { result := _OWNER_MODULE } // OwnerModule.initializeOwnerModule()
                    leave
                }
                switch sig
                case 0x718fe928 { result := _OWNER_MODULE } // OwnerModule.renounceNomination()
                case 0x79ba5097 { result := _OWNER_MODULE } // OwnerModule.acceptOwnership()
                case 0x8da5cb5b { result := _OWNER_MODULE } // OwnerModule.owner()
                case 0xaaf10f42 { result := _UPGRADE_MODULE } // UpgradeModule.getImplementation()
                case 0xc7f62cda { result := _UPGRADE_MODULE } // UpgradeModule.simulateUpgradeTo()
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