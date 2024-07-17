// SPDX-License-Identifier: UNLICENSEDlt(sig
pragma solidity ^0.8.13;

interface IUSDRouter {
    function acceptOwnership() external;
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address owner) external view returns (uint256);
    function burn(uint256 amount) external;
    function burn(address target, uint256 amount) external;
    function burnWithAllowance(address from, address spender, uint256 amount) external;
    function decimals() external view returns (uint8);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function getAssociatedSystem(bytes32 id) external view returns (address addr, bytes32 kind);
    function getImplementation() external view returns (address);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function initOrUpgradeNft(bytes32 id, string memory name, string memory symbol, string memory uri, address impl) external;
    function initOrUpgradeToken(bytes32 id, string memory name, string memory symbol, uint8 decimals, address impl) external;
    function initialize(string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals) external;
    function isInitialized() external view returns (bool);
    function mint(address target, uint256 amount) external;
    function name() external view returns (string memory);
    function nominateNewOwner(address newNominatedOwner) external;
    function nominatedOwner() external view returns (address);
    function owner() external view returns (address);
    function registerUnmanagedSystem(bytes32 id, address endpoint) external;
    function renounceNomination() external;
    function setAllowance(address from, address spender, uint256 amount) external;
    function simulateUpgradeTo(address newImplementation) external;
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function upgradeTo(address newImplementation) external;
}

contract USDRouter {
    address constant _INITIAL_MODULE_BUNDLE = 0x3c0fC26278e515d9914F56c6F874423D7f1F32fB;
address constant _ASSOCIATED_SYSTEMS_MODULE = 0x5CF939598A1606FE16363Be283A6A0Fc13f3fE83;
address constant _USDTOKEN_MODULE = 0x8927a0D8b6CF891dAcC703740A7Aba8Bb30125C2;

    error UnknownSelector(bytes4 sel);

    fallback() external payable {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        address implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                if lt(sig, 0x70a08231) {
                    if lt(sig, 0x3659cfe6) {
                        switch sig
                            case 0x06fdde03 { result := _USDTOKEN_MODULE } // USDTokenModule.name()
                            case 0x095ea7b3 { result := _USDTOKEN_MODULE } // USDTokenModule.approve()
                            case 0x1624f6c6 { result := _USDTOKEN_MODULE } // USDTokenModule.initialize()
                            case 0x1627540c { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.nominateNewOwner()
                            case 0x18160ddd { result := _USDTOKEN_MODULE } // USDTokenModule.totalSupply()
                            case 0x23b872dd { result := _USDTOKEN_MODULE } // USDTokenModule.transferFrom()
                            case 0x2d22bef9 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.initOrUpgradeNft()
                            case 0x313ce567 { result := _USDTOKEN_MODULE } // USDTokenModule.decimals()
                        leave
                    }
                            switch sig
                                case 0x3659cfe6 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.upgradeTo()
                                case 0x392e53cd { result := _USDTOKEN_MODULE } // USDTokenModule.isInitialized()
                                case 0x39509351 { result := _USDTOKEN_MODULE } // USDTokenModule.increaseAllowance()
                                case 0x40c10f19 { result := _USDTOKEN_MODULE } // USDTokenModule.mint()
                                case 0x42966c68 { result := _USDTOKEN_MODULE } // USDTokenModule.burn()
                                case 0x53a47bb7 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.nominatedOwner()
                                case 0x60988e09 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.getAssociatedSystem()
                            leave
                }
                        if lt(sig, 0xaaa15fd1) {
                            switch sig
                                case 0x70a08231 { result := _USDTOKEN_MODULE } // USDTokenModule.balanceOf()
                                case 0x718fe928 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.renounceNomination()
                                case 0x79ba5097 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.acceptOwnership()
                                case 0x8da5cb5b { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.owner()
                                case 0x95d89b41 { result := _USDTOKEN_MODULE } // USDTokenModule.symbol()
                                case 0x9dc29fac { result := _USDTOKEN_MODULE } // USDTokenModule.burn()
                                case 0xa457c2d7 { result := _USDTOKEN_MODULE } // USDTokenModule.decreaseAllowance()
                                case 0xa9059cbb { result := _USDTOKEN_MODULE } // USDTokenModule.transfer()
                            leave
                        }
                                switch sig
                                    case 0xaaa15fd1 { result := _USDTOKEN_MODULE } // USDTokenModule.burnWithAllowance()
                                    case 0xaaf10f42 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.getImplementation()
                                    case 0xc6f79537 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.initOrUpgradeToken()
                                    case 0xc7f62cda { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.simulateUpgradeTo()
                                    case 0xd245d983 { result := _ASSOCIATED_SYSTEMS_MODULE } // AssociatedSystemsModule.registerUnmanagedSystem()
                                    case 0xda46098c { result := _USDTOKEN_MODULE } // USDTokenModule.setAllowance()
                                    case 0xdd62ed3e { result := _USDTOKEN_MODULE } // USDTokenModule.allowance()
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