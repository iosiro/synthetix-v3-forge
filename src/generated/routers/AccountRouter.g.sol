// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAccountRouter {
    function acceptOwnership() external;
    function approve(address to, uint256 tokenId) external;
    function balanceOf(address holder) external view returns (uint256 balance);
    function burn(uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function getImplementation() external view returns (address);
    function initialize(string memory tokenName, string memory tokenSymbol, string memory uri) external;
    function isApprovedForAll(address holder, address operator) external view returns (bool);
    function isInitialized() external view returns (bool);
    function mint(address to, uint256 tokenId) external;
    function name() external view returns (string memory);
    function nominateNewOwner(address newNominatedOwner) external;
    function nominatedOwner() external view returns (address);
    function owner() external view returns (address);
    function ownerOf(uint256 tokenId) external view returns (address);
    function renounceNomination() external;
    function safeMint(address to, uint256 tokenId, bytes memory data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) external;
    function setAllowance(uint256 tokenId, address spender) external;
    function setApprovalForAll(address operator, bool approved) external;
    function setBaseTokenURI(string memory uri) external;
    function simulateUpgradeTo(address newImplementation) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function symbol() external view returns (string memory);
    function tokenByIndex(uint256 index) external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function upgradeTo(address newImplementation) external;
}

contract AccountRouter {
    address immutable internal _ACCOUNT_TOKEN_MODULE;
    address immutable internal _INITIAL_MODULE_BUNDLE;

    struct Modules {
        address accountTokenModule;
        address initialModuleBundle;
    }

    constructor(Modules memory $) {
        _ACCOUNT_TOKEN_MODULE = $.accountTokenModule;
        _INITIAL_MODULE_BUNDLE = $.initialModuleBundle;
    }

    error UnknownSelector(bytes4 sel);

    function findImplementationAddress(bytes32 implementation) internal view returns (address result) {
        if (implementation == 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2) return _ACCOUNT_TOKEN_MODULE;
        if (implementation == 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151) return _INITIAL_MODULE_BUNDLE;
    }

    fallback() external payable {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        bytes32 implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                if lt(sig, 0x6352211e) {
                    if lt(sig, 0x30176e13) {
                        switch sig
                            case 0x01ffc9a7 { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.supportsInterface()
                            case 0x06fdde03 { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.name()
                            case 0x081812fc { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.getApproved()
                            case 0x095ea7b3 { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.approve()
                            case 0x1627540c { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.nominateNewOwner()
                            case 0x18160ddd { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.totalSupply()
                            case 0x23b872dd { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.transferFrom()
                            case 0x2f745c59 { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.tokenOfOwnerByIndex()
                        leave
                    }
                    switch sig
                        case 0x30176e13 { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.setBaseTokenURI()
                        case 0x3659cfe6 { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.upgradeTo()
                        case 0x392e53cd { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.isInitialized()
                        case 0x40c10f19 { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.mint()
                        case 0x42842e0e { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.safeTransferFrom()
                        case 0x42966c68 { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.burn()
                        case 0x4f6ccce7 { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.tokenByIndex()
                        case 0x53a47bb7 { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.nominatedOwner()
                    leave
                }
                if lt(sig, 0xa6487c53) {
                    switch sig
                        case 0x6352211e { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.ownerOf()
                        case 0x70a08231 { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.balanceOf()
                        case 0x718fe928 { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.renounceNomination()
                        case 0x79ba5097 { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.acceptOwnership()
                        case 0x8832e6e3 { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.safeMint()
                        case 0x8da5cb5b { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.owner()
                        case 0x95d89b41 { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.symbol()
                        case 0xa22cb465 { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.setApprovalForAll()
                    leave
                }
                switch sig
                    case 0xa6487c53 { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.initialize()
                    case 0xaaf10f42 { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.getImplementation()
                    case 0xb88d4fde { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.safeTransferFrom()
                    case 0xc7f62cda { result := 0x65ed98bc6e8636d3e31c70259bddf83fd475024400983114ea42279adf1fd151 } // InitialModuleBundle.simulateUpgradeTo()
                    case 0xc87b56dd { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.tokenURI()
                    case 0xe985e9c5 { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.isApprovedForAll()
                    case 0xff53fac7 { result := 0x585879950e2055e5922ecb7ccfc605d6f4f232e4893f0aab75b6d17850fc4ce2 } // AccountTokenModule.setAllowance()
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