//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./Modules.sol";
// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------
// GENERATED CODE - do not edit manually!!
// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------

contract SNXTokenRouter {
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
                if lt(sig,0x624bd96d) {
                    if lt(sig,0x313ce567) {
                        switch sig
                        case 0x06fdde03 { result := _SNXTOKEN_MODULE } // SNXTokenModule.name()
                        case 0x095ea7b3 { result := _SNXTOKEN_MODULE } // SNXTokenModule.approve()
                        case 0x1624f6c6 { result := _SNXTOKEN_MODULE } // SNXTokenModule.initialize()
                        case 0x1627540c { result := _OWNER_MODULE } // OwnerModule.nominateNewOwner()
                        case 0x18160ddd { result := _SNXTOKEN_MODULE } // SNXTokenModule.totalSupply()
                        case 0x23b872dd { result := _SNXTOKEN_MODULE } // SNXTokenModule.transferFrom()
                        leave
                    }
                    switch sig
                    case 0x313ce567 { result := _SNXTOKEN_MODULE } // SNXTokenModule.decimals()
                    case 0x35eb2824 { result := _OWNER_MODULE } // OwnerModule.isOwnerModuleInitialized()
                    case 0x3659cfe6 { result := _UPGRADE_MODULE } // UpgradeModule.upgradeTo()
                    case 0x392e53cd { result := _SNXTOKEN_MODULE } // SNXTokenModule.isInitialized()
                    case 0x40c10f19 { result := _SNXTOKEN_MODULE } // SNXTokenModule.mint()
                    case 0x53a47bb7 { result := _OWNER_MODULE } // OwnerModule.nominatedOwner()
                    leave
                }
                if lt(sig,0x9dc29fac) {
                    switch sig
                    case 0x624bd96d { result := _OWNER_MODULE } // OwnerModule.initializeOwnerModule()
                    case 0x70a08231 { result := _SNXTOKEN_MODULE } // SNXTokenModule.balanceOf()
                    case 0x718fe928 { result := _OWNER_MODULE } // OwnerModule.renounceNomination()
                    case 0x79ba5097 { result := _OWNER_MODULE } // OwnerModule.acceptOwnership()
                    case 0x8da5cb5b { result := _OWNER_MODULE } // OwnerModule.owner()
                    case 0x95d89b41 { result := _SNXTOKEN_MODULE } // SNXTokenModule.symbol()
                    leave
                }
                switch sig
                case 0x9dc29fac { result := _SNXTOKEN_MODULE } // SNXTokenModule.burn()
                case 0xa9059cbb { result := _SNXTOKEN_MODULE } // SNXTokenModule.transfer()
                case 0xaaf10f42 { result := _UPGRADE_MODULE } // UpgradeModule.getImplementation()
                case 0xc7f62cda { result := _UPGRADE_MODULE } // UpgradeModule.simulateUpgradeTo()
                case 0xda46098c { result := _SNXTOKEN_MODULE } // SNXTokenModule.setAllowance()
                case 0xdd62ed3e { result := _SNXTOKEN_MODULE } // SNXTokenModule.allowance()
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
