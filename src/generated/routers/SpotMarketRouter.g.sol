// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library AsyncOrderClaim {
    struct Data {
        uint128 id;
        address owner;
        Transaction.Type orderType;
        uint256 amountEscrowed;
        uint256 settlementStrategyId;
        uint256 commitmentTime;
        uint256 minimumSettlementAmount;
        uint256 settledAt;
        address referrer;
    }
}

library OrderFees {
    struct Data {
        uint256 fixedFees;
        uint256 utilizationFees;
        int256 skewFees;
        int256 wrapperFees;
    }
}

library Price {
    type Tolerance is uint8;
}

library SettlementStrategy {
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
}

library Transaction {
    type Type is uint8;
}

interface ISpotMarketRouter {
    function acceptMarketOwnership(uint128 synthMarketId) external;
    function acceptOwnership() external;
    function addSettlementStrategy(uint128 marketId, SettlementStrategy.Data memory strategy) external returns (uint256 strategyId);
    function addToFeatureFlagAllowlist(bytes32 feature, address account) external;
    function buy(uint128 marketId, uint256 usdAmount, uint256 minAmountReceived, address referrer) external returns (uint256 synthAmount, OrderFees.Data memory fees);
    function buyExactIn(uint128 marketId, uint256 usdAmount, uint256 minAmountReceived, address referrer) external returns (uint256 synthAmount, OrderFees.Data memory fees);
    function buyExactOut(uint128 marketId, uint256 synthAmount, uint256 maxUsdAmount, address referrer) external returns (uint256 usdAmountCharged, OrderFees.Data memory fees);
    function cancelOrder(uint128 marketId, uint128 asyncOrderId) external;
    function commitOrder(uint128 marketId, Transaction.Type orderType, uint256 amountProvided, uint256 settlementStrategyId, uint256 minimumSettlementAmount, address referrer) external returns (AsyncOrderClaim.Data memory asyncOrderClaim);
    function createSynth(string memory tokenName, string memory tokenSymbol, address synthOwner) external returns (uint128 synthMarketId);
    function getAssociatedSystem(bytes32 id) external view returns (address addr, bytes32 kind);
    function getAsyncOrderClaim(uint128 marketId, uint128 asyncOrderId) external pure returns (AsyncOrderClaim.Data memory asyncOrderClaim);
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
    function getSettlementStrategy(uint128 marketId, uint256 strategyId) external view returns (SettlementStrategy.Data memory settlementStrategy);
    function getSynth(uint128 marketId) external view returns (address synthAddress);
    function getSynthImpl(uint128 marketId) external view returns (address implAddress);
    function getWrapper(uint128 marketId) external view returns (address wrapCollateralType, uint256 maxWrappableAmount);
    function indexPrice(uint128 marketId, uint128 transactionType, Price.Tolerance priceTolerance) external view returns (uint256 price);
    function initOrUpgradeNft(bytes32 id, string memory name, string memory symbol, string memory uri, address impl) external;
    function initOrUpgradeToken(bytes32 id, string memory name, string memory symbol, uint8 decimals, address impl) external;
    function isFeatureAllowed(bytes32 feature, address account) external view returns (bool);
    function minimumCredit(uint128 marketId) external view returns (uint256 lockedAmount);
    function name(uint128 marketId) external view returns (string memory marketName);
    function nominateMarketOwner(uint128 synthMarketId, address newNominatedOwner) external;
    function nominateNewOwner(address newNominatedOwner) external;
    function nominatedOwner() external view returns (address);
    function owner() external view returns (address);
    function quoteBuyExactIn(uint128 marketId, uint256 usdAmount, Price.Tolerance stalenessTolerance) external view returns (uint256 synthAmount, OrderFees.Data memory fees);
    function quoteBuyExactOut(uint128 marketId, uint256 synthAmount, Price.Tolerance stalenessTolerance) external view returns (uint256 usdAmountCharged, OrderFees.Data memory fees);
    function quoteSellExactIn(uint128 marketId, uint256 synthAmount, Price.Tolerance stalenessTolerance) external view returns (uint256 returnAmount, OrderFees.Data memory fees);
    function quoteSellExactOut(uint128 marketId, uint256 usdAmount, Price.Tolerance stalenessTolerance) external view returns (uint256 synthToBurn, OrderFees.Data memory fees);
    function registerUnmanagedSystem(bytes32 id, address endpoint) external;
    function removeFromFeatureFlagAllowlist(bytes32 feature, address account) external;
    function renounceMarketNomination(uint128 synthMarketId) external;
    function renounceMarketOwnership(uint128 synthMarketId) external;
    function renounceNomination() external;
    function reportedDebt(uint128 marketId) external view returns (uint256 reportedDebtAmount);
    function sell(uint128 marketId, uint256 synthAmount, uint256 minUsdAmount, address referrer) external returns (uint256 usdAmountReceived, OrderFees.Data memory fees);
    function sellExactIn(uint128 marketId, uint256 synthAmount, uint256 minAmountReceived, address referrer) external returns (uint256 returnAmount, OrderFees.Data memory fees);
    function sellExactOut(uint128 marketId, uint256 usdAmount, uint256 maxSynthAmount, address referrer) external returns (uint256 synthToBurn, OrderFees.Data memory fees);
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
    function setSettlementStrategy(uint128 marketId, uint256 strategyId, SettlementStrategy.Data memory strategy) external;
    function setSettlementStrategyEnabled(uint128 marketId, uint256 strategyId, bool enabled) external;
    function setSynthImplementation(address synthImplementation) external;
    function setSynthetix(address synthetix) external;
    function setWrapper(uint128 marketId, address wrapCollateralType, uint256 maxWrappableAmount) external;
    function setWrapperFees(uint128 synthMarketId, int256 wrapFee, int256 unwrapFee) external;
    function settleOrder(uint128 marketId, uint128 asyncOrderId) external returns (uint256 finalOrderAmount, OrderFees.Data memory fees);
    function simulateUpgradeTo(address newImplementation) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool isSupported);
    function unwrap(uint128 marketId, uint256 unwrapAmount, uint256 minAmountReceived) external returns (uint256 returnCollateralAmount, OrderFees.Data memory fees);
    function updatePriceData(uint128 synthMarketId, bytes32 buyFeedId, bytes32 sellFeedId, uint256 strictPriceStalenessTolerance) external;
    function updateReferrerShare(uint128 synthMarketId, address referrer, uint256 sharePercentage) external;
    function upgradeSynthImpl(uint128 marketId) external;
    function upgradeTo(address newImplementation) external;
    function wrap(uint128 marketId, uint256 wrapAmount, uint256 minAmountReceived) external returns (uint256 amountToMint, OrderFees.Data memory fees);
}

contract SpotMarketRouter {
    address immutable internal _ATOMIC_ORDER_MODULE;
    address immutable internal _CORE_MODULE;
    address immutable internal _FEATURE_FLAG_MODULE;
    address immutable internal _ASYNC_ORDER_MODULE;
    address immutable internal _SPOT_MARKET_FACTORY_MODULE;
    address immutable internal _ASYNC_ORDER_CONFIGURATION_MODULE;
    address immutable internal _MARKET_CONFIGURATION_MODULE;
    address immutable internal _ASYNC_ORDER_SETTLEMENT_MODULE;
    address immutable internal _WRAPPER_MODULE;

    struct Modules {
        address atomicOrderModule;
        address coreModule;
        address featureFlagModule;
        address asyncOrderModule;
        address spotMarketFactoryModule;
        address asyncOrderConfigurationModule;
        address marketConfigurationModule;
        address asyncOrderSettlementModule;
        address wrapperModule;
    }

    constructor(Modules memory $) {
        _ATOMIC_ORDER_MODULE = $.atomicOrderModule;
        _CORE_MODULE = $.coreModule;
        _FEATURE_FLAG_MODULE = $.featureFlagModule;
        _ASYNC_ORDER_MODULE = $.asyncOrderModule;
        _SPOT_MARKET_FACTORY_MODULE = $.spotMarketFactoryModule;
        _ASYNC_ORDER_CONFIGURATION_MODULE = $.asyncOrderConfigurationModule;
        _MARKET_CONFIGURATION_MODULE = $.marketConfigurationModule;
        _ASYNC_ORDER_SETTLEMENT_MODULE = $.asyncOrderSettlementModule;
        _WRAPPER_MODULE = $.wrapperModule;
    }

    error UnknownSelector(bytes4 sel);

    function findImplementationAddress(bytes32 implementation) internal view returns (address result) {
        if (implementation == 0xde7d1ad505493870cc86eeab9b0b11ca0eb5dcd69617b8e0431678b80c0b6933) return _ATOMIC_ORDER_MODULE;
        if (implementation == 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936) return _CORE_MODULE;
        if (implementation == 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea) return _FEATURE_FLAG_MODULE;
        if (implementation == 0x8f148827f540e87584ef6bd7c48c363b0b2c36d4f0bf423491684ab341a105db) return _ASYNC_ORDER_MODULE;
        if (implementation == 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542) return _SPOT_MARKET_FACTORY_MODULE;
        if (implementation == 0x0db28d5b05a22ab2c1e910f8739121781d3917f8e0a197158108af1a2933a9a5) return _ASYNC_ORDER_CONFIGURATION_MODULE;
        if (implementation == 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6) return _MARKET_CONFIGURATION_MODULE;
        if (implementation == 0xa3a7966d1c4efdb6956fe90c1394d0003853cfbfaec26f965e0f01691d56589d) return _ASYNC_ORDER_SETTLEMENT_MODULE;
        if (implementation == 0x393e993f00835277fdea9710cd0e6170a7897e06036c685b3d416125bfaf402a) return _WRAPPER_MODULE;
    }

    fallback() external payable {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        bytes32 implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                if lt(sig, 0x7f73a891) {
                    if lt(sig, 0x5381ce16) {
                        if lt(sig, 0x37fb3369) {
                            if lt(sig, 0x2d22bef9) {
                                switch sig
                                    case 0x01ffc9a7 { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.supportsInterface()
                                    case 0x025f6120 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setFeeCollector()
                                    case 0x1627540c { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.nominateNewOwner()
                                    case 0x1c216a0e { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.acceptMarketOwnership()
                                    case 0x21f7f58f { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setCollateralLeverage()
                                    case 0x298b26bf { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.renounceMarketNomination()
                                leave
                            }
                            switch sig
                                case 0x2d22bef9 { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.initOrUpgradeNft()
                                case 0x2e535d61 { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.createSynth()
                                case 0x2efaa971 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getCustomTransactorFees()
                                case 0x32598e61 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getMarketFees()
                                case 0x3659cfe6 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.upgradeTo()
                            leave
                        }
                        if lt(sig, 0x45f2601c) {
                            switch sig
                                case 0x37fb3369 { result := 0xde7d1ad505493870cc86eeab9b0b11ca0eb5dcd69617b8e0431678b80c0b6933 } // AtomicOrderModule.buy()
                                case 0x3d1a60e4 { result := 0xde7d1ad505493870cc86eeab9b0b11ca0eb5dcd69617b8e0431678b80c0b6933 } // AtomicOrderModule.sellExactIn()
                                case 0x3e0c76ca { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.getSynthImpl()
                                case 0x40a399ef { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.getFeatureFlagAllowAll()
                                case 0x4138dc53 { result := 0x8f148827f540e87584ef6bd7c48c363b0b2c36d4f0bf423491684ab341a105db } // AsyncOrderModule.cancelOrder()
                            leave
                        }
                        switch sig
                            case 0x45f2601c { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setMarketUtilizationFees()
                            case 0x462b9a2d { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.getPriceData()
                            case 0x480be91f { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setAtomicFixedFee()
                            case 0x4ce94d9d { result := 0xde7d1ad505493870cc86eeab9b0b11ca0eb5dcd69617b8e0431678b80c0b6933 } // AtomicOrderModule.sellExactOut()
                            case 0x4d4bfbd5 { result := 0xde7d1ad505493870cc86eeab9b0b11ca0eb5dcd69617b8e0431678b80c0b6933 } // AtomicOrderModule.sell()
                        leave
                    }
                    if lt(sig, 0x687ed93d) {
                        if lt(sig, 0x5fdf4e98) {
                            switch sig
                                case 0x5381ce16 { result := 0x8f148827f540e87584ef6bd7c48c363b0b2c36d4f0bf423491684ab341a105db } // AsyncOrderModule.getAsyncOrderClaim()
                                case 0x53a47bb7 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.nominatedOwner()
                                case 0x5497eb23 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getFeeCollector()
                                case 0x5950864b { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.nominateMarketOwner()
                                case 0x5e52ad6e { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.setFeatureFlagDenyAll()
                            leave
                        }
                        switch sig
                            case 0x5fdf4e98 { result := 0x393e993f00835277fdea9710cd0e6170a7897e06036c685b3d416125bfaf402a } // WrapperModule.getWrapper()
                            case 0x60988e09 { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.getAssociatedSystem()
                            case 0x61dcca86 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setAsyncFixedFee()
                            case 0x6539b1c3 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setWrapperFees()
                            case 0x673a21e5 { result := 0x393e993f00835277fdea9710cd0e6170a7897e06036c685b3d416125bfaf402a } // WrapperModule.setWrapper()
                        leave
                    }
                    if lt(sig, 0x718fe928) {
                        switch sig
                            case 0x687ed93d { result := 0xde7d1ad505493870cc86eeab9b0b11ca0eb5dcd69617b8e0431678b80c0b6933 } // AtomicOrderModule.quoteSellExactIn()
                            case 0x69e0365f { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.getSynth()
                            case 0x6ad77077 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.updateReferrerShare()
                            case 0x70d9a0c6 { result := 0xde7d1ad505493870cc86eeab9b0b11ca0eb5dcd69617b8e0431678b80c0b6933 } // AtomicOrderModule.quoteBuyExactOut()
                            case 0x715cb7d2 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.setDeniers()
                        leave
                    }
                    switch sig
                        case 0x718fe928 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.renounceNomination()
                        case 0x784dad9e { result := 0x393e993f00835277fdea9710cd0e6170a7897e06036c685b3d416125bfaf402a } // WrapperModule.unwrap()
                        case 0x79ba5097 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.acceptOwnership()
                        case 0x7cbe2075 { result := 0x0db28d5b05a22ab2c1e910f8739121781d3917f8e0a197158108af1a2933a9a5 } // AsyncOrderConfigurationModule.setSettlementStrategy()
                        case 0x7d632bd2 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.setFeatureFlagAllowAll()
                    leave
                }
                if lt(sig, 0xc4b41a2e) {
                    if lt(sig, 0xa0778144) {
                        if lt(sig, 0x95fcd547) {
                            switch sig
                                case 0x7f73a891 { result := 0x0db28d5b05a22ab2c1e910f8739121781d3917f8e0a197158108af1a2933a9a5 } // AsyncOrderConfigurationModule.setSettlementStrategyEnabled()
                                case 0x8d105571 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getMarketSkewScale()
                                case 0x8da5cb5b { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.owner()
                                case 0x911414c6 { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.updatePriceData()
                                case 0x9444ac48 { result := 0xa3a7966d1c4efdb6956fe90c1394d0003853cfbfaec26f965e0f01691d56589d } // AsyncOrderSettlementModule.settleOrder()
                            leave
                        }
                        switch sig
                            case 0x95fcd547 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setCustomTransactorFees()
                            case 0x97b30e6d { result := 0x0db28d5b05a22ab2c1e910f8739121781d3917f8e0a197158108af1a2933a9a5 } // AsyncOrderConfigurationModule.addSettlementStrategy()
                            case 0x983220bb { result := 0xde7d1ad505493870cc86eeab9b0b11ca0eb5dcd69617b8e0431678b80c0b6933 } // AtomicOrderModule.buyExactOut()
                            case 0x9a40f8cb { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.setMarketSkewScale()
                            case 0xa05ee4f6 { result := 0xde7d1ad505493870cc86eeab9b0b11ca0eb5dcd69617b8e0431678b80c0b6933 } // AtomicOrderModule.getMarketSkew()
                        leave
                    }
                    if lt(sig, 0xafe79200) {
                        switch sig
                            case 0xa0778144 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.addToFeatureFlagAllowlist()
                            case 0xa12d9400 { result := 0xde7d1ad505493870cc86eeab9b0b11ca0eb5dcd69617b8e0431678b80c0b6933 } // AtomicOrderModule.buyExactIn()
                            case 0xa7b8cb9f { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.getMarketOwner()
                            case 0xaaf10f42 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.getImplementation()
                            case 0xab75d950 { result := 0xde7d1ad505493870cc86eeab9b0b11ca0eb5dcd69617b8e0431678b80c0b6933 } // AtomicOrderModule.quoteBuyExactIn()
                        leave
                    }
                    switch sig
                        case 0xafe79200 { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.minimumCredit()
                        case 0xb7746b59 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.removeFromFeatureFlagAllowlist()
                        case 0xbcae3ea0 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.getFeatureFlagDenyAll()
                        case 0xbcec0d0f { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.reportedDebt()
                        case 0xbd1cdfb5 { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.renounceMarketOwnership()
                    leave
                }
                if lt(sig, 0xd7ce770c) {
                    if lt(sig, 0xcdfaef0f) {
                        switch sig
                            case 0xc4b41a2e { result := 0xde7d1ad505493870cc86eeab9b0b11ca0eb5dcd69617b8e0431678b80c0b6933 } // AtomicOrderModule.quoteSellExactOut()
                            case 0xc624440a { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.name()
                            case 0xc6f79537 { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.initOrUpgradeToken()
                            case 0xc7f62cda { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.simulateUpgradeTo()
                            case 0xc99d0cdd { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.upgradeSynthImpl()
                        leave
                    }
                    switch sig
                        case 0xcdfaef0f { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getCollateralLeverage()
                        case 0xcf635949 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.isFeatureAllowed()
                        case 0xd245d983 { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.registerUnmanagedSystem()
                        case 0xd2a25290 { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.getNominatedMarketOwner()
                        case 0xd393340e { result := 0x8f148827f540e87584ef6bd7c48c363b0b2c36d4f0bf423491684ab341a105db } // AsyncOrderModule.commitOrder()
                    leave
                }
                if lt(sig, 0xed429cf7) {
                    switch sig
                        case 0xd7ce770c { result := 0x393e993f00835277fdea9710cd0e6170a7897e06036c685b3d416125bfaf402a } // WrapperModule.wrap()
                        case 0xe12c8160 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.getFeatureFlagAllowlist()
                        case 0xe450d1f2 { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.indexPrice()
                        case 0xec04ceb1 { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.setSynthImplementation()
                        case 0xec846bac { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.setDecayRate()
                    leave
                }
                switch sig
                    case 0xed429cf7 { result := 0x5317c086691248dec850380eef0d638878e899191f21032d9502a33d2aa8c9ea } // FeatureFlagModule.getDeniers()
                    case 0xf375f324 { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getMarketUtilizationFees()
                    case 0xf74c377f { result := 0x0db28d5b05a22ab2c1e910f8739121781d3917f8e0a197158108af1a2933a9a5 } // AsyncOrderConfigurationModule.getSettlementStrategy()
                    case 0xfa4b28ed { result := 0xc3ab802765cbabcb67fead9f797aca74ccc7c83a658bfa9ead661bd3d896cbd6 } // MarketConfigurationModule.getReferrerShare()
                    case 0xfec9f9da { result := 0xe93ec5e8c0e0174f239b7136e06936120a6b4e2c568c55b0c9167177af9f4542 } // SpotMarketFactoryModule.setSynthetix()
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