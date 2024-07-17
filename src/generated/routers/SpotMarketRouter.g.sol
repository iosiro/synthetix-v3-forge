// SPDX-License-Identifier: UNLICENSEDlt(sig
pragma solidity ^0.8.13;

interface ISpotMarketRouter {
    type Tolerance is uint8;
    type Type is uint8;
    struct Data {
        Type strategyType;
        uint256 settlementDelay;
        uint256 settlementWindowDuration;
        address priceVerificationContract;
        bytes32 feedId;
        string url;
        uint256 settlementReward;
        uint256 priceDeviationTolerance;
        uint256 minimumUsdExchangeAmount;
        uint256 maxRoundingLoss;
        bool disabled;
    }

    function acceptMarketOwnership(uint128 synthMarketId) external;
    function acceptOwnership() external;
    function addSettlementStrategy(uint128 marketId, Data memory strategy) external returns (uint256 strategyId);
    function addToFeatureFlagAllowlist(bytes32 feature, address account) external;
    function buy(uint128 marketId, uint256 usdAmount, uint256 minAmountReceived, address referrer) external returns (uint256 synthAmount, Data memory fees);
    function buyExactIn(uint128 marketId, uint256 usdAmount, uint256 minAmountReceived, address referrer) external returns (uint256 synthAmount, Data memory fees);
    function buyExactOut(uint128 marketId, uint256 synthAmount, uint256 maxUsdAmount, address referrer) external returns (uint256 usdAmountCharged, Data memory fees);
    function cancelOrder(uint128 marketId, uint128 asyncOrderId) external;
    function commitOrder(uint128 marketId, Type orderType, uint256 amountProvided, uint256 settlementStrategyId, uint256 minimumSettlementAmount, address referrer) external returns (Data memory asyncOrderClaim);
    function createSynth(string memory tokenName, string memory tokenSymbol, address synthOwner) external returns (uint128 synthMarketId);
    function getAssociatedSystem(bytes32 id) external view returns (address addr, bytes32 kind);
    function getAsyncOrderClaim(uint128 marketId, uint128 asyncOrderId) external pure returns (Data memory asyncOrderClaim);
    function getCollateralLeverage(uint128 synthMarketId) external view returns (uint256 collateralLeverage);
    function getCustomTransactorFees(uint128 synthMarketId, address transactor) external view returns (uint256 fixedFeeAmount);
    function getDeniers(bytes32 feature) external view returns (address[] memory);
    function getFeatureFlagAllowAll(bytes32 feature) external view returns (bool);
    function getFeatureFlagAllowlist(bytes32 feature) external view returns (address[] memory);
    function getFeatureFlagDenyAll(bytes32 feature) external view returns (bool);
    function getFeeCollector(uint128 synthMarketId) external view returns (address feeCollector);
    function getImplementation() external view returns (address);
    function getMarketFees(uint128 synthMarketId) external view returns (uint256 atomicFixedFee, uint256 asyncFixedFee, int256 wrapFee, int256 unwrapFee);
    function getMarketOwner(uint128 synthMarketId) external view returns (address marketOwner);
    function getMarketSkew(uint128 marketId) external view returns (int256 marketSkew);
    function getMarketSkewScale(uint128 synthMarketId) external view returns (uint256 skewScale);
    function getMarketUtilizationFees(uint128 synthMarketId) external view returns (uint256 utilizationFeeRate);
    function getNominatedMarketOwner(uint128 synthMarketId) external view returns (address marketOwner);
    function getPriceData(uint128 synthMarketId) external view returns (bytes32 buyFeedId, bytes32 sellFeedId, uint256 strictPriceStalenessTolerance);
    function getReferrerShare(uint128 synthMarketId, address referrer) external view returns (uint256 sharePercentage);
    function getSettlementStrategy(uint128 marketId, uint256 strategyId) external view returns (Data memory settlementStrategy);
    function getSynth(uint128 marketId) external view returns (address synthAddress);
    function getSynthImpl(uint128 marketId) external view returns (address implAddress);
    function getWrapper(uint128 marketId) external view returns (address wrapCollateralType, uint256 maxWrappableAmount);
    function initOrUpgradeNft(bytes32 id, string memory name, string memory symbol, string memory uri, address impl) external;
    function initOrUpgradeToken(bytes32 id, string memory name, string memory symbol, uint8 decimals, address impl) external;
    function isFeatureAllowed(bytes32 feature, address account) external view returns (bool);
    function minimumCredit(uint128 marketId) external view returns (uint256 lockedAmount);
    function name(uint128 marketId) external view returns (string memory marketName);
    function nominateMarketOwner(uint128 synthMarketId, address newNominatedOwner) external;
    function nominateNewOwner(address newNominatedOwner) external;
    function nominatedOwner() external view returns (address);
    function owner() external view returns (address);
    function quoteBuyExactIn(uint128 marketId, uint256 usdAmount, Tolerance stalenessTolerance) external view returns (uint256 synthAmount, Data memory fees);
    function quoteBuyExactOut(uint128 marketId, uint256 synthAmount, Tolerance stalenessTolerance) external view returns (uint256 usdAmountCharged, Data memory fees);
    function quoteSellExactIn(uint128 marketId, uint256 synthAmount, Tolerance stalenessTolerance) external view returns (uint256 returnAmount, Data memory fees);
    function quoteSellExactOut(uint128 marketId, uint256 usdAmount, Tolerance stalenessTolerance) external view returns (uint256 synthToBurn, Data memory fees);
    function registerUnmanagedSystem(bytes32 id, address endpoint) external;
    function removeFromFeatureFlagAllowlist(bytes32 feature, address account) external;
    function renounceMarketNomination(uint128 synthMarketId) external;
    function renounceMarketOwnership(uint128 synthMarketId) external;
    function renounceNomination() external;
    function reportedDebt(uint128 marketId) external view returns (uint256 reportedDebtAmount);
    function sell(uint128 marketId, uint256 synthAmount, uint256 minUsdAmount, address referrer) external returns (uint256 usdAmountReceived, Data memory fees);
    function sellExactIn(uint128 marketId, uint256 synthAmount, uint256 minAmountReceived, address referrer) external returns (uint256 returnAmount, Data memory fees);
    function sellExactOut(uint128 marketId, uint256 usdAmount, uint256 maxSynthAmount, address referrer) external returns (uint256 synthToBurn, Data memory fees);
    function setAsyncFixedFee(uint128 synthMarketId, uint256 asyncFixedFee) external;
    function setAtomicFixedFee(uint128 synthMarketId, uint256 atomicFixedFee) external;
    function setCollateralLeverage(uint128 synthMarketId, uint256 collateralLeverage) external;
    function setCustomTransactorFees(uint128 synthMarketId, address transactor, uint256 fixedFeeAmount) external;
    function setDecayRate(uint128 marketId, uint256 rate) external;
    function setDeniers(bytes32 feature, address[] memory deniers) external;
    function setFeatureFlagAllowAll(bytes32 feature, bool allowAll) external;
    function setFeatureFlagDenyAll(bytes32 feature, bool denyAll) external;
    function setFeeCollector(uint128 synthMarketId, address feeCollector) external;
    function setMarketSkewScale(uint128 synthMarketId, uint256 skewScale) external;
    function setMarketUtilizationFees(uint128 synthMarketId, uint256 utilizationFeeRate) external;
    function setSettlementStrategy(uint128 marketId, uint256 strategyId, Data memory strategy) external;
    function setSettlementStrategyEnabled(uint128 marketId, uint256 strategyId, bool enabled) external;
    function setSynthImplementation(address synthImplementation) external;
    function setSynthetix(address synthetix) external;
    function setWrapper(uint128 marketId, address wrapCollateralType, uint256 maxWrappableAmount) external;
    function setWrapperFees(uint128 synthMarketId, int256 wrapFee, int256 unwrapFee) external;
    function settleOrder(uint128 marketId, uint128 asyncOrderId) external returns (uint256 finalOrderAmount, Data memory fees);
    function simulateUpgradeTo(address newImplementation) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool isSupported);
    function unwrap(uint128 marketId, uint256 unwrapAmount, uint256 minAmountReceived) external returns (uint256 returnCollateralAmount, Data memory fees);
    function updatePriceData(uint128 synthMarketId, bytes32 buyFeedId, bytes32 sellFeedId, uint256 strictPriceStalenessTolerance) external;
    function updateReferrerShare(uint128 synthMarketId, address referrer, uint256 sharePercentage) external;
    function upgradeSynthImpl(uint128 marketId) external;
    function upgradeTo(address newImplementation) external;
    function wrap(uint128 marketId, uint256 wrapAmount, uint256 minAmountReceived) external returns (uint256 amountToMint, Data memory fees);
}

contract SpotMarketRouter {
    address constant _CORE_MODULE = 0xa3994A4190CAe45D36D36BAfCAec2c6DA5e729fc;
address constant _SPOT_MARKET_FACTORY_MODULE = 0xA785B5AA0887774A4fD8ec21Dc75bA6173C39084;
address constant _ATOMIC_ORDER_MODULE = 0xC9CD6bE6A966b14d42f4DA0222032b62e34BEB6D;
address constant _ASYNC_ORDER_MODULE = 0xe168464bDfCeDA6A098E780712F4B75ee422FE7a;
address constant _ASYNC_ORDER_SETTLEMENT_MODULE = 0x8F9dDe23612bEa5F523346c17A5Ebd1c40503324;
address constant _ASYNC_ORDER_CONFIGURATION_MODULE = 0x3687812516529805244Bf81A22796FA0fa17fEFe;
address constant _WRAPPER_MODULE = 0x71958cc111027932990eEbF1F537A19c5bef1195;
address constant _MARKET_CONFIGURATION_MODULE = 0x992098C98d149F171ED808D157Df594ba7a450AB;
address constant _FEATURE_FLAG_MODULE = 0xCbf9247bA94C358528344a697E30305303Ba762D;

    error UnknownSelector(bytes4 sel);

    fallback() external payable {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        address implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                if lt(sig, 0x7d632bd2) {
                    if lt(sig, 0x4d4bfbd5) {
                        if lt(sig, 0x3659cfe6) {
                            if lt(sig, 0x298b26bf) {
                                switch sig
                                    case 0x01ffc9a7 { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.supportsInterface()
                                    case 0x025f6120 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setFeeCollector()
                                    case 0x1627540c { result := _CORE_MODULE } // CoreModule.nominateNewOwner()
                                    case 0x1c216a0e { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.acceptMarketOwnership()
                                    case 0x21f7f58f { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setCollateralLeverage()
                                leave
                            }
                                    switch sig
                                        case 0x298b26bf { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.renounceMarketNomination()
                                        case 0x2d22bef9 { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.initOrUpgradeNft()
                                        case 0x2e535d61 { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.createSynth()
                                        case 0x2efaa971 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.getCustomTransactorFees()
                                        case 0x32598e61 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.getMarketFees()
                                    leave
                        }
                                if lt(sig, 0x4138dc53) {
                                    switch sig
                                        case 0x3659cfe6 { result := _CORE_MODULE } // CoreModule.upgradeTo()
                                        case 0x37fb3369 { result := _ATOMIC_ORDER_MODULE } // AtomicOrderModule.buy()
                                        case 0x3d1a60e4 { result := _ATOMIC_ORDER_MODULE } // AtomicOrderModule.sellExactIn()
                                        case 0x3e0c76ca { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.getSynthImpl()
                                        case 0x40a399ef { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getFeatureFlagAllowAll()
                                    leave
                                }
                                        switch sig
                                            case 0x4138dc53 { result := _ASYNC_ORDER_MODULE } // AsyncOrderModule.cancelOrder()
                                            case 0x45f2601c { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setMarketUtilizationFees()
                                            case 0x462b9a2d { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.getPriceData()
                                            case 0x480be91f { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setAtomicFixedFee()
                                            case 0x4ce94d9d { result := _ATOMIC_ORDER_MODULE } // AtomicOrderModule.sellExactOut()
                                        leave
                    }
                            if lt(sig, 0x673a21e5) {
                                if lt(sig, 0x5e52ad6e) {
                                    switch sig
                                        case 0x4d4bfbd5 { result := _ATOMIC_ORDER_MODULE } // AtomicOrderModule.sell()
                                        case 0x5381ce16 { result := _ASYNC_ORDER_MODULE } // AsyncOrderModule.getAsyncOrderClaim()
                                        case 0x53a47bb7 { result := _CORE_MODULE } // CoreModule.nominatedOwner()
                                        case 0x5497eb23 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.getFeeCollector()
                                        case 0x5950864b { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.nominateMarketOwner()
                                    leave
                                }
                                        switch sig
                                            case 0x5e52ad6e { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.setFeatureFlagDenyAll()
                                            case 0x5fdf4e98 { result := _WRAPPER_MODULE } // WrapperModule.getWrapper()
                                            case 0x60988e09 { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.getAssociatedSystem()
                                            case 0x61dcca86 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setAsyncFixedFee()
                                            case 0x6539b1c3 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setWrapperFees()
                                        leave
                            }
                                    if lt(sig, 0x715cb7d2) {
                                        switch sig
                                            case 0x673a21e5 { result := _WRAPPER_MODULE } // WrapperModule.setWrapper()
                                            case 0x687ed93d { result := _ATOMIC_ORDER_MODULE } // AtomicOrderModule.quoteSellExactIn()
                                            case 0x69e0365f { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.getSynth()
                                            case 0x6ad77077 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.updateReferrerShare()
                                            case 0x70d9a0c6 { result := _ATOMIC_ORDER_MODULE } // AtomicOrderModule.quoteBuyExactOut()
                                        leave
                                    }
                                            switch sig
                                                case 0x715cb7d2 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.setDeniers()
                                                case 0x718fe928 { result := _CORE_MODULE } // CoreModule.renounceNomination()
                                                case 0x784dad9e { result := _WRAPPER_MODULE } // WrapperModule.unwrap()
                                                case 0x79ba5097 { result := _CORE_MODULE } // CoreModule.acceptOwnership()
                                                case 0x7cbe2075 { result := _ASYNC_ORDER_CONFIGURATION_MODULE } // AsyncOrderConfigurationModule.setSettlementStrategy()
                                            leave
                }
                        if lt(sig, 0xbd1cdfb5) {
                            if lt(sig, 0xa05ee4f6) {
                                if lt(sig, 0x9444ac48) {
                                    switch sig
                                        case 0x7d632bd2 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.setFeatureFlagAllowAll()
                                        case 0x7f73a891 { result := _ASYNC_ORDER_CONFIGURATION_MODULE } // AsyncOrderConfigurationModule.setSettlementStrategyEnabled()
                                        case 0x8d105571 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.getMarketSkewScale()
                                        case 0x8da5cb5b { result := _CORE_MODULE } // CoreModule.owner()
                                        case 0x911414c6 { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.updatePriceData()
                                    leave
                                }
                                        switch sig
                                            case 0x9444ac48 { result := _ASYNC_ORDER_SETTLEMENT_MODULE } // AsyncOrderSettlementModule.settleOrder()
                                            case 0x95fcd547 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setCustomTransactorFees()
                                            case 0x97b30e6d { result := _ASYNC_ORDER_CONFIGURATION_MODULE } // AsyncOrderConfigurationModule.addSettlementStrategy()
                                            case 0x983220bb { result := _ATOMIC_ORDER_MODULE } // AtomicOrderModule.buyExactOut()
                                            case 0x9a40f8cb { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.setMarketSkewScale()
                                        leave
                            }
                                    if lt(sig, 0xab75d950) {
                                        switch sig
                                            case 0xa05ee4f6 { result := _ATOMIC_ORDER_MODULE } // AtomicOrderModule.getMarketSkew()
                                            case 0xa0778144 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.addToFeatureFlagAllowlist()
                                            case 0xa12d9400 { result := _ATOMIC_ORDER_MODULE } // AtomicOrderModule.buyExactIn()
                                            case 0xa7b8cb9f { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.getMarketOwner()
                                            case 0xaaf10f42 { result := _CORE_MODULE } // CoreModule.getImplementation()
                                        leave
                                    }
                                            switch sig
                                                case 0xab75d950 { result := _ATOMIC_ORDER_MODULE } // AtomicOrderModule.quoteBuyExactIn()
                                                case 0xafe79200 { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.minimumCredit()
                                                case 0xb7746b59 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.removeFromFeatureFlagAllowlist()
                                                case 0xbcae3ea0 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getFeatureFlagDenyAll()
                                                case 0xbcec0d0f { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.reportedDebt()
                                            leave
                        }
                                if lt(sig, 0xd393340e) {
                                    if lt(sig, 0xc99d0cdd) {
                                        switch sig
                                            case 0xbd1cdfb5 { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.renounceMarketOwnership()
                                            case 0xc4b41a2e { result := _ATOMIC_ORDER_MODULE } // AtomicOrderModule.quoteSellExactOut()
                                            case 0xc624440a { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.name()
                                            case 0xc6f79537 { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.initOrUpgradeToken()
                                            case 0xc7f62cda { result := _CORE_MODULE } // CoreModule.simulateUpgradeTo()
                                        leave
                                    }
                                            switch sig
                                                case 0xc99d0cdd { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.upgradeSynthImpl()
                                                case 0xcdfaef0f { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.getCollateralLeverage()
                                                case 0xcf635949 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.isFeatureAllowed()
                                                case 0xd245d983 { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.registerUnmanagedSystem()
                                                case 0xd2a25290 { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.getNominatedMarketOwner()
                                            leave
                                }
                                        if lt(sig, 0xed429cf7) {
                                            switch sig
                                                case 0xd393340e { result := _ASYNC_ORDER_MODULE } // AsyncOrderModule.commitOrder()
                                                case 0xd7ce770c { result := _WRAPPER_MODULE } // WrapperModule.wrap()
                                                case 0xe12c8160 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getFeatureFlagAllowlist()
                                                case 0xec04ceb1 { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.setSynthImplementation()
                                                case 0xec846bac { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.setDecayRate()
                                            leave
                                        }
                                                switch sig
                                                    case 0xed429cf7 { result := _FEATURE_FLAG_MODULE } // FeatureFlagModule.getDeniers()
                                                    case 0xf375f324 { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.getMarketUtilizationFees()
                                                    case 0xf74c377f { result := _ASYNC_ORDER_CONFIGURATION_MODULE } // AsyncOrderConfigurationModule.getSettlementStrategy()
                                                    case 0xfa4b28ed { result := _MARKET_CONFIGURATION_MODULE } // MarketConfigurationModule.getReferrerShare()
                                                    case 0xfec9f9da { result := _SPOT_MARKET_FACTORY_MODULE } // SpotMarketFactoryModule.setSynthetix()
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