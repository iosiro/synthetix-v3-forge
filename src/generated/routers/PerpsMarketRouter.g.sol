//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------
// GENERATED CODE - do not edit manually!!
// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------

contract PerpsMarketRouter {
    error UnknownSelector(bytes4 sel);

    address private constant _ACCOUNT_MODULE = 0xD32BcDE9E27517EE5aeA19C5486d7344eF55E2AF;
    address private constant _ASSOCIATED_SYSTEMS_MODULE = 0x672bC529c434d69385148f21ce3eC008D55Bcc70;
    address private constant _CORE_MODULE = 0x9f460b3542A27428dc3c6083a488Af76e5Ab2203;
    address private constant _PERPS_MARKET_FACTORY_MODULE = 0xD432391786CB766861bEed83b73b6616efd010a5;
    address private constant _PERPS_ACCOUNT_MODULE = 0xdEC523a04D6024413014a23CB3FA190cF052cC64;
    address private constant _PERPS_MARKET_MODULE = 0x892de68268e05D3EA2aE770c9c0Ce8BE4BEA525A;
    address private constant _ATOMIC_ORDER_MODULE = 0x69a637c5623b3294f287C98863e6AE88a01219C0;
    address private constant _ASYNC_ORDER_MODULE = 0x521effFCbE8aa3F61D396D65eecD431C6065b418;
    address private constant _FEATURE_FLAG_MODULE = 0x220c405bd4494a24C7B45a5aCD322Aaf4854Fef1;
    address private constant _LIMIT_ORDER_MODULE = 0xB0A8Baa72a4de5bccAF925822C51B2f87E6218d2;
    address private constant _LIQUIDATION_MODULE = 0x1d9d84fEa7e2b5B0Cb6470Ed0a2FB5F4FA791894;
    address private constant _MARKET_CONFIGURATION_MODULE = 0x4B8425b675294d86BC3034981d85C7330c0E3515;
    address private constant _GLOBAL_PERPS_MARKET_MODULE = 0x200c93d3c13e92a0d739bA89eC1C5c800AA8630c;

    fallback() external payable {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        address implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                if lt(sig,0x8c522f20) {
                    if lt(sig,0x3b217f67) {
                        if lt(sig,0x1c216a0e) {
                            if lt(sig,0x117f1264) {
                                switch sig
                                case 0x00cd9ef3 { result := _ACCOUNT_MODULE } // AccountModule.grantPermission()
                                case 0x01ffc9a7 { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.supportsInterface()
                                case 0x048577de { result := _LIQUIDATION_MODULE } // LiquidationModule.liquidate()
                                case 0x0a7dad2d { result := _PERPS_ACCOUNT_MODULE } // PerpsAccountModule.getAvailableMargin()
                                case 0x0b7f4b2d { result := _GLOBAL_PERPS_MARKET_MODULE } // GlobalPerpsMarketModule.getLiquidationRewardGuards()
                                case 0x0e7cace9 { result := _PERPS_MARKET_MODULE } // PerpsMarketModule.maxOpenInterest()
                                leave
                            }
                            switch sig
                            case 0x117f1264 { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.symbol()
                            case 0x1213d453 { result := _ACCOUNT_MODULE } // AccountModule.isAuthorized()
                            case 0x1627540c { result := _CORE_MODULE } // CoreModule.nominateNewOwner()
                            case 0x1b5dccdb { result := _ACCOUNT_MODULE } // AccountModule.getAccountLastInteraction()
                            case 0x1b68d8fa { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.getFundingParameters()
                            leave
                        }
                        if lt(sig,0x2d22bef9) {
                            switch sig
                            case 0x1c216a0e { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.acceptMarketOwnership()
                            case 0x1d6d458c { result := _LIQUIDATION_MODULE } // LiquidationModule.liquidateFlagged()
                            case 0x22a73967 { result := _PERPS_ACCOUNT_MODULE } // PerpsAccountModule.getOpenPosition()
                            case 0x25e5409e { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setLiquidationParameters()
                            case 0x266a9eee { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.getLockedOiPercent()
                            case 0x2b267635 { result := _PERPS_MARKET_MODULE } // PerpsMarketModule.size()
                            leave
                        }
                        switch sig
                        case 0x2d22bef9 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.initOrUpgradeNft()
                        case 0x2d73137b { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.updatePriceData()
                        case 0x2daf43bc { result := _PERPS_ACCOUNT_MODULE } // PerpsAccountModule.totalAccountOpenInterest()
                        case 0x2f1e7e43 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setLockedOiPercent()
                        case 0x3659cfe6 { result := _CORE_MODULE } // CoreModule.upgradeTo()
                        leave
                    }
                    if lt(sig,0x60988e09) {
                        if lt(sig,0x4ff68ae2) {
                            switch sig
                            case 0x3b217f67 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.getMaxMarketValue()
                            case 0x40a399ef { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getFeatureFlagAllowAll()
                            case 0x4138dc53 { result := _ASYNC_ORDER_MODULE } // AsyncOrderModule.cancelOrder()
                            case 0x41c2e8bd { result := _PERPS_MARKET_MODULE } // PerpsMarketModule.getMarketSummary()
                            case 0x47c1c561 { result := _ACCOUNT_MODULE } // AccountModule.renouncePermission()
                            case 0x4f778fb4 { result := _PERPS_MARKET_MODULE } // PerpsMarketModule.indexPrice()
                            leave
                        }
                        switch sig
                        case 0x4ff68ae2 { result := _GLOBAL_PERPS_MARKET_MODULE } // GlobalPerpsMarketModule.getMaxCollateralAmount()
                        case 0x5381ce16 { result := _PERPS_ACCOUNT_MODULE } // PerpsAccountModule.getAsyncOrderClaim()
                        case 0x53a47bb7 { result := _CORE_MODULE } // CoreModule.nominatedOwner()
                        case 0x5950864b { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.nominateMarketOwner()
                        case 0x5e52ad6e { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.setFeatureFlagDenyAll()
                        leave
                    }
                    if lt(sig,0x7d632bd2) {
                        switch sig
                        case 0x60988e09 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.getAssociatedSystem()
                        case 0x6aba84a7 { result := _GLOBAL_PERPS_MARKET_MODULE } // GlobalPerpsMarketModule.setSynthDeductionPriority()
                        case 0x6cded665 { result := _GLOBAL_PERPS_MARKET_MODULE } // GlobalPerpsMarketModule.setMaxCollateralAmount()
                        case 0x715cb7d2 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.setDeniers()
                        case 0x718fe928 { result := _CORE_MODULE } // CoreModule.renounceNomination()
                        case 0x79ba5097 { result := _CORE_MODULE } // CoreModule.acceptOwnership()
                        leave
                    }
                    switch sig
                    case 0x7d632bd2 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.setFeatureFlagAllowAll()
                    case 0x7dec8b55 { result := _ACCOUNT_MODULE } // AccountModule.notifyAccountTransfer()
                    case 0x7f73a891 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setSettlementStrategyEnabled()
                    case 0x83a7db27 { result := _PERPS_MARKET_MODULE } // PerpsMarketModule.skew()
                    case 0x8a0345c6 { result := _ASYNC_ORDER_MODULE } // AsyncOrderModule.settlePythOrder()
                    leave
                }
                if lt(sig,0xc2382277) {
                    if lt(sig,0xaac23e8c) {
                        if lt(sig,0xa0778144) {
                            switch sig
                            case 0x8c522f20 { result := _PERPS_MARKET_MODULE } // PerpsMarketModule.fillPrice()
                            case 0x8d34166b { result := _ACCOUNT_MODULE } // AccountModule.hasPermission()
                            case 0x8da5cb5b { result := _CORE_MODULE } // CoreModule.owner()
                            case 0x92d48a4e { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.setSpotMarket()
                            case 0x9cfe1d40 { result := _ASYNC_ORDER_MODULE } // AsyncOrderModule.getOrder()
                            case 0x9dca362f { result := _ACCOUNT_MODULE } // AccountModule.createAccount()
                            leave
                        }
                        switch sig
                        case 0xa0778144 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.addToFeatureFlagAllowlist()
                        case 0xa148bf10 { result := _ACCOUNT_MODULE } // AccountModule.getAccountTokenAddress()
                        case 0xa7627288 { result := _ACCOUNT_MODULE } // AccountModule.revokePermission()
                        case 0xa796fecd { result := _ACCOUNT_MODULE } // AccountModule.getAccountPermissions()
                        case 0xa7b8cb9f { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.getMarketOwner()
                        leave
                    }
                    if lt(sig,0xb7746b59) {
                        switch sig
                        case 0xaac23e8c { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.getOrderFees()
                        case 0xaaf10f42 { result := _CORE_MODULE } // CoreModule.getImplementation()
                        case 0xaaf5eb68 { result := _ASYNC_ORDER_MODULE } // AsyncOrderModule.PRECISION()
                        case 0xafe79200 { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.minimumCredit()
                        case 0xb46ce155 { result := _ASYNC_ORDER_MODULE } // AsyncOrderModule.settle()
                        case 0xb568ae42 { result := _PERPS_ACCOUNT_MODULE } // PerpsAccountModule.totalCollateralValue()
                        leave
                    }
                    switch sig
                    case 0xb7746b59 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.removeFromFeatureFlagAllowlist()
                    case 0xbb58672c { result := _PERPS_ACCOUNT_MODULE } // PerpsAccountModule.modifyCollateral()
                    case 0xbcae3ea0 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getFeatureFlagDenyAll()
                    case 0xbcec0d0f { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.reportedDebt()
                    case 0xbf60c31d { result := _ACCOUNT_MODULE } // AccountModule.getAccountOwner()
                    leave
                }
                if lt(sig,0xdd661eea) {
                    if lt(sig,0xd245d983) {
                        switch sig
                        case 0xc2382277 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setFundingParameters()
                        case 0xc624440a { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.name()
                        case 0xc6f79537 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.initOrUpgradeToken()
                        case 0xc7f62cda { result := _CORE_MODULE } // CoreModule.simulateUpgradeTo()
                        case 0xcadb09a5 { result := _ACCOUNT_MODULE } // AccountModule.createAccount()
                        case 0xcf635949 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.isFeatureAllowed()
                        leave
                    }
                    switch sig
                    case 0xd245d983 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.registerUnmanagedSystem()
                    case 0xd435b2a2 { result := _PERPS_MARKET_MODULE } // PerpsMarketModule.currentFundingRate()
                    case 0xd743cbaa { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.createMarket()
                    case 0xda91187c { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.addSettlementStrategy()
                    case 0xdbc593a9 { result := _GLOBAL_PERPS_MARKET_MODULE } // GlobalPerpsMarketModule.setLiquidationRewardGuards()
                    leave
                }
                if lt(sig,0xf74c377f) {
                    switch sig
                    case 0xdd661eea { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setMaxMarketValue()
                    case 0xe0633cc9 { result := _ASYNC_ORDER_MODULE } // AsyncOrderModule.commitOrder()
                    case 0xe12c8160 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getFeatureFlagAllowlist()
                    case 0xed429cf7 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getDeniers()
                    case 0xf265db02 { result := _PERPS_MARKET_MODULE } // PerpsMarketModule.currentFundingVelocity()
                    leave
                }
                switch sig
                case 0xf74c377f { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.getSettlementStrategy()
                case 0xf842fa86 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setOrderFees()
                case 0xf94363a6 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.getLiquidationParameters()
                case 0xfea84a3f { result := _GLOBAL_PERPS_MARKET_MODULE } // GlobalPerpsMarketModule.getSynthDeductionPriority()
                case 0xfec9f9da { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.setSynthetix()
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