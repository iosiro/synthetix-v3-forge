// SPDX-License-Identifier: UNLICENSED
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
    address immutable internal _ASSOCIATED_SYSTEMS_MODULE;
    address immutable internal _INITIAL_MODULE_BUNDLE;
    address immutable internal _USDTOKEN_MODULE;

    struct Modules {
        address associatedSystemsModule;
        address initialModuleBundle;
        address uSDTokenModule;
    }

    constructor(Modules memory $) {
        _ASSOCIATED_SYSTEMS_MODULE = $.associatedSystemsModule;
        _INITIAL_MODULE_BUNDLE = $.initialModuleBundle;
        _USDTOKEN_MODULE = $.uSDTokenModule;
    }

    error UnknownSelector(bytes4 sel);

    function findImplementationAddress(bytes32 implementation) internal view returns (address result) {
        if (implementation == 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252) return _ASSOCIATED_SYSTEMS_MODULE;
        if (implementation == 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151) return _INITIAL_MODULE_BUNDLE;
        if (implementation == 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03) return _USDTOKEN_MODULE;
    }

    fallback() external payable {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        bytes32 implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                if lt(sig, 0x70a08231) {
                    if lt(sig, 0x3659cfe6) {
                        switch sig
                            case 0x06fdde03 { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.name()
                            case 0x095ea7b3 { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.approve()
                            case 0x1624f6c6 { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.initialize()
                            case 0x1627540c { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.nominateNewOwner()
                            case 0x18160ddd { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.totalSupply()
                            case 0x23b872dd { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.transferFrom()
                            case 0x2d22bef9 { result := 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252 } // AssociatedSystemsModule.initOrUpgradeNft()
                            case 0x313ce567 { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.decimals()
                        leave
                    }
                    switch sig
                        case 0x3659cfe6 { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.upgradeTo()
                        case 0x392e53cd { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.isInitialized()
                        case 0x39509351 { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.increaseAllowance()
                        case 0x40c10f19 { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.mint()
                        case 0x42966c68 { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.burn()
                        case 0x53a47bb7 { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.nominatedOwner()
                        case 0x60988e09 { result := 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252 } // AssociatedSystemsModule.getAssociatedSystem()
                    leave
                }
                if lt(sig, 0xaaa15fd1) {
                    switch sig
                        case 0x70a08231 { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.balanceOf()
                        case 0x718fe928 { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.renounceNomination()
                        case 0x79ba5097 { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.acceptOwnership()
                        case 0x8da5cb5b { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.owner()
                        case 0x95d89b41 { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.symbol()
                        case 0x9dc29fac { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.burn()
                        case 0xa457c2d7 { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.decreaseAllowance()
                        case 0xa9059cbb { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.transfer()
                    leave
                }
                switch sig
                    case 0xaaa15fd1 { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.burnWithAllowance()
                    case 0xaaf10f42 { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.getImplementation()
                    case 0xc6f79537 { result := 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252 } // AssociatedSystemsModule.initOrUpgradeToken()
                    case 0xc7f62cda { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.simulateUpgradeTo()
                    case 0xd245d983 { result := 0x50df6d567ac8fa7c6e470909cc5f9ff73ab1ae21a4df8de212e92de61d533252 } // AssociatedSystemsModule.registerUnmanagedSystem()
                    case 0xda46098c { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.setAllowance()
                    case 0xdd62ed3e { result := 0x3bdfbf77e8b823a700315dec9df53561a103263784a9f9232591409213e5cd03 } // USDTokenModule.allowance()
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