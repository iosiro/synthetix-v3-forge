//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------
// GENERATED CODE - do not edit manually!!
// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------
address constant _LEGACY_MARKET = 0x6fa2CaA730a32Bda27c6bfc722Eacb0034C7971A;

contract LegacyMarketRouter {
    error UnknownSelector(bytes4 sel);

    

    

    fallback() external payable {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        address implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                                if lt(sig,0x8da5cb5b) {
                    if lt(sig,0x5e6b0840) {
                        switch sig
                        case 0x01208837 { result := _LEGACY_MARKET } // LegacyMarket.registerMarket()
                        case 0x01ffc9a7 { result := _LEGACY_MARKET } // LegacyMarket.supportsInterface()
                        case 0x150b7a02 { result := _LEGACY_MARKET } // LegacyMarket.onERC721Received()
                        case 0x1627540c { result := _LEGACY_MARKET } // LegacyMarket.nominateNewOwner()
                        case 0x1c9e4e52 { result := _LEGACY_MARKET } // LegacyMarket.setPauseStablecoinConversion()
                        case 0x3659cfe6 { result := _LEGACY_MARKET } // LegacyMarket.upgradeTo()
                        case 0x53a47bb7 { result := _LEGACY_MARKET } // LegacyMarket.nominatedOwner()
                        leave
                    }
                    switch sig
                    case 0x5e6b0840 { result := _LEGACY_MARKET } // LegacyMarket.v2xResolver()
                    case 0x6ed71ede { result := _LEGACY_MARKET } // LegacyMarket.marketId()
                    case 0x718fe928 { result := _LEGACY_MARKET } // LegacyMarket.renounceNomination()
                    case 0x79ba5097 { result := _LEGACY_MARKET } // LegacyMarket.acceptOwnership()
                    case 0x8a228dcf { result := _LEGACY_MARKET } // LegacyMarket.setSystemAddresses()
                    case 0x8ae687af { result := _LEGACY_MARKET } // LegacyMarket.setPauseMigration()
                    leave
                }
                if lt(sig,0xc624440a) {
                    switch sig
                    case 0x8da5cb5b { result := _LEGACY_MARKET } // LegacyMarket.owner()
                    case 0xaaf10f42 { result := _LEGACY_MARKET } // LegacyMarket.getImplementation()
                    case 0xac700e63 { result := _LEGACY_MARKET } // LegacyMarket.pauseMigration()
                    case 0xafe79200 { result := _LEGACY_MARKET } // LegacyMarket.minimumCredit()
                    case 0xbcca753f { result := _LEGACY_MARKET } // LegacyMarket.migrate()
                    case 0xbcec0d0f { result := _LEGACY_MARKET } // LegacyMarket.reportedDebt()
                    leave
                }
                switch sig
                case 0xc624440a { result := _LEGACY_MARKET } // LegacyMarket.name()
                case 0xc7f62cda { result := _LEGACY_MARKET } // LegacyMarket.simulateUpgradeTo()
                case 0xe18fc05f { result := _LEGACY_MARKET } // LegacyMarket.migrateOnBehalf()
                case 0xe63875b6 { result := _LEGACY_MARKET } // LegacyMarket.v3System()
                case 0xf2e07dd3 { result := _LEGACY_MARKET } // LegacyMarket.convertUSD()
                case 0xf65448e5 { result := _LEGACY_MARKET } // LegacyMarket.pauseStablecoinConversion()
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
