//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------
// GENERATED CODE - do not edit manually!!
// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------
address constant _ACCOUNT_MODULE = 0xB940591Ab54fd21B8E9344050b4A75501FF082a5;
address constant _ASSOCIATED_SYSTEMS_MODULE = 0xFDc417E2D2183f6631d950CA38Dea4E50ec0F17A;
address constant _CORE_MODULE = 0xf6aC4f1c485401946C058837ca9C50E9Cc4f3F7B;
address constant _PERPS_MARKET_FACTORY_MODULE = 0xFf8Cd24AbE6e61eca2c68FB7B35C8A6b5fF3243D;
address constant _PERPS_ACCOUNT_MODULE = 0x74c2B10f5C55BB6f2414C1Df9E88D3836259E573;
address constant _ATOMIC_ORDER_MODULE = 0xAC2bddb8715BBbfB0d4541Fb3c58fcfD105Adf8b;
address constant _ASYNC_ORDER_MODULE = 0xE57481Dca1E6f8b1D11C471a3a8a37Bc96eFb495;
address constant _COLLATERAL_MODULE = 0x7B622960f7EF7b3d3591444939DCF07D2FB07290;
address constant _FEATURE_FLAG_MODULE = 0x4aC08ea84DceCD474D2078426225B2D52646058C;
address constant _LIMIT_ORDER_MODULE = 0xE4deb68F9f536c9e4168D40D7e00249b8EF2e6B9;
address constant _LIQUIDATION_MODULE = 0x8c2dA5B7Ab7dB83A7E7D011521e882D38cDb859b;
address constant _MARKET_CONFIGURATION_MODULE = 0x82198Cf14557610662B00e44C6382A0BE67e0EE1;
address constant _GLOBAL_PERPS_MARKET_MODULE = 0x5A54a4989123275F2406F158532E737343286DDb;

contract PerpsMarketRouter {
    error UnknownSelector(bytes4 sel);

    

    

    fallback() external payable {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        address implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                                if lt(sig,0x8da5cb5b) {
                    if lt(sig,0x3b217f67) {
                        if lt(sig,0x1b68d8fa) {
                            if lt(sig,0x11dfb368) {
                                switch sig
                                case 0x00cd9ef3 { result := _ACCOUNT_MODULE } // AccountModule.grantPermission()
                                case 0x01ffc9a7 { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.supportsInterface()
                                case 0x048577de { result := _LIQUIDATION_MODULE } // LiquidationModule.liquidate()
                                case 0x0b7f4b2d { result := _GLOBAL_PERPS_MARKET_MODULE } // GlobalPerpsMarketModule.getLiquidationRewardGuards()
                                case 0x117f1264 { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.symbol()
                                leave
                            }
                            switch sig
                            case 0x11dfb368 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.addSettlementStrategy()
                            case 0x1213d453 { result := _ACCOUNT_MODULE } // AccountModule.isAuthorized()
                            case 0x1450ce39 { result := _GLOBAL_PERPS_MARKET_MODULE } // GlobalPerpsMarketModule.setMaxCollateralForSynthMarketId()
                            case 0x1627540c { result := _CORE_MODULE } // CoreModule.nominateNewOwner()
                            case 0x1b5dccdb { result := _ACCOUNT_MODULE } // AccountModule.getAccountLastInteraction()
                            leave
                        }
                        if lt(sig,0x2d22bef9) {
                            switch sig
                            case 0x1b68d8fa { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.getFundingParameters()
                            case 0x1c216a0e { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.acceptMarketOwnership()
                            case 0x1d6d458c { result := _LIQUIDATION_MODULE } // LiquidationModule.liquidateFlagged()
                            case 0x22a73967 { result := _PERPS_ACCOUNT_MODULE } // PerpsAccountModule.getOpenPosition()
                            case 0x266a9eee { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.getLockedOiPercent()
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
                    if lt(sig,0x6cded665) {
                        if lt(sig,0x589fc978) {
                            switch sig
                            case 0x3b217f67 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.getMaxMarketValue()
                            case 0x40a399ef { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getFeatureFlagAllowAll()
                            case 0x47c1c561 { result := _ACCOUNT_MODULE } // AccountModule.renouncePermission()
                            case 0x5381ce16 { result := _PERPS_ACCOUNT_MODULE } // PerpsAccountModule.getAsyncOrderClaim()
                            case 0x53a47bb7 { result := _CORE_MODULE } // CoreModule.nominatedOwner()
                            leave
                        }
                        switch sig
                        case 0x589fc978 { result := _GLOBAL_PERPS_MARKET_MODULE } // GlobalPerpsMarketModule.getMaxCollateralAmountsForSynthMarket()
                        case 0x5950864b { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.nominateMarketOwner()
                        case 0x5e52ad6e { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.setFeatureFlagDenyAll()
                        case 0x60988e09 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.getAssociatedSystem()
                        case 0x6aba84a7 { result := _GLOBAL_PERPS_MARKET_MODULE } // GlobalPerpsMarketModule.setSynthDeductionPriority()
                        leave
                    }
                    switch sig
                    case 0x6cded665 { result := _COLLATERAL_MODULE } // CollateralModule.setMaxCollateralAmount()
                    case 0x715cb7d2 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.setDeniers()
                    case 0x718fe928 { result := _CORE_MODULE } // CoreModule.renounceNomination()
                    case 0x79ba5097 { result := _CORE_MODULE } // CoreModule.acceptOwnership()
                    case 0x7d632bd2 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.setFeatureFlagAllowAll()
                    case 0x7dec8b55 { result := _ACCOUNT_MODULE } // AccountModule.notifyAccountTransfer()
                    case 0x7f73a891 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setSettlementStrategyEnabled()
                    case 0x8a0345c6 { result := _ASYNC_ORDER_MODULE } // AsyncOrderModule.settlePythOrder()
                    case 0x8d34166b { result := _ACCOUNT_MODULE } // AccountModule.hasPermission()
                    leave
                }
                if lt(sig,0xbf60c31d) {
                    if lt(sig,0xaaf5eb68) {
                        if lt(sig,0xa7627288) {
                            switch sig
                            case 0x8da5cb5b { result := _CORE_MODULE } // CoreModule.owner()
                            case 0x92d48a4e { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.setSpotMarket()
                            case 0x9dca362f { result := _ACCOUNT_MODULE } // AccountModule.createAccount()
                            case 0xa0778144 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.addToFeatureFlagAllowlist()
                            case 0xa148bf10 { result := _ACCOUNT_MODULE } // AccountModule.getAccountTokenAddress()
                            leave
                        }
                        switch sig
                        case 0xa7627288 { result := _ACCOUNT_MODULE } // AccountModule.revokePermission()
                        case 0xa796fecd { result := _ACCOUNT_MODULE } // AccountModule.getAccountPermissions()
                        case 0xa7b8cb9f { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.getMarketOwner()
                        case 0xaac23e8c { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.getOrderFees()
                        case 0xaaf10f42 { result := _CORE_MODULE } // CoreModule.getImplementation()
                        leave
                    }
                    switch sig
                    case 0xaaf5eb68 { result := _ASYNC_ORDER_MODULE } // AsyncOrderModule.PRECISION()
                    case 0xafe79200 { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.minimumCredit()
                    case 0xb46ce155 { result := _ASYNC_ORDER_MODULE } // AsyncOrderModule.settle()
                    case 0xb568ae42 { result := _PERPS_ACCOUNT_MODULE } // PerpsAccountModule.totalCollateralValue()
                    case 0xb7746b59 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.removeFromFeatureFlagAllowlist()
                    case 0xbb58672c { result := _PERPS_ACCOUNT_MODULE } // PerpsAccountModule.modifyCollateral()
                    case 0xbcae3ea0 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getFeatureFlagDenyAll()
                    case 0xbcec0d0f { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.reportedDebt()
                    case 0xbf609d36 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setLiquidationParameters()
                    leave
                }
                if lt(sig,0xdd661eea) {
                    if lt(sig,0xcadb09a5) {
                        switch sig
                        case 0xbf60c31d { result := _ACCOUNT_MODULE } // AccountModule.getAccountOwner()
                        case 0xc2382277 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setFundingParameters()
                        case 0xc624440a { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.name()
                        case 0xc6f79537 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.initOrUpgradeToken()
                        case 0xc7f62cda { result := _CORE_MODULE } // CoreModule.simulateUpgradeTo()
                        leave
                    }
                    switch sig
                    case 0xcadb09a5 { result := _ACCOUNT_MODULE } // AccountModule.createAccount()
                    case 0xcf635949 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.isFeatureAllowed()
                    case 0xd245d983 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.registerUnmanagedSystem()
                    case 0xd743cbaa { result := _PERPS_MARKET_FACTORY_MODULE } // PerpsMarketFactoryModule.createMarket()
                    case 0xdbc593a9 { result := _GLOBAL_PERPS_MARKET_MODULE } // GlobalPerpsMarketModule.setLiquidationRewardGuards()
                    leave
                }
                switch sig
                case 0xdd661eea { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setMaxMarketValue()
                case 0xe12c8160 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getFeatureFlagAllowlist()
                case 0xed429cf7 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getDeniers()
                case 0xf3462390 { result := _ASYNC_ORDER_MODULE } // AsyncOrderModule.commitOrder()
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
