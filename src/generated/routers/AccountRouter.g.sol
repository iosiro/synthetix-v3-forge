// SPDX-License-Identifier: UNLICENSEDlt(sig
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
    address constant _INITIAL_MODULE_BUNDLE = 0x3c0fC26278e515d9914F56c6F874423D7f1F32fB;
address constant _ACCOUNT_TOKEN_MODULE = 0xe4b68e6de8a34D02b83a15A81EB83AE916f6DdDE;

    error UnknownSelector(bytes4 sel);

    fallback() external payable {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        address implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                if lt(sig, 0x6352211e) {
                    if lt(sig, 0x30176e13) {
                        switch sig
                            case 0x01ffc9a7 { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.supportsInterface()
                            case 0x06fdde03 { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.name()
                            case 0x081812fc { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.getApproved()
                            case 0x095ea7b3 { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.approve()
                            case 0x1627540c { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.nominateNewOwner()
                            case 0x18160ddd { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.totalSupply()
                            case 0x23b872dd { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.transferFrom()
                            case 0x2f745c59 { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.tokenOfOwnerByIndex()
                        leave
                    }
                            switch sig
                                case 0x30176e13 { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.setBaseTokenURI()
                                case 0x3659cfe6 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.upgradeTo()
                                case 0x392e53cd { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.isInitialized()
                                case 0x40c10f19 { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.mint()
                                case 0x42842e0e { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.safeTransferFrom()
                                case 0x42966c68 { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.burn()
                                case 0x4f6ccce7 { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.tokenByIndex()
                                case 0x53a47bb7 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.nominatedOwner()
                            leave
                }
                        if lt(sig, 0xa6487c53) {
                            switch sig
                                case 0x6352211e { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.ownerOf()
                                case 0x70a08231 { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.balanceOf()
                                case 0x718fe928 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.renounceNomination()
                                case 0x79ba5097 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.acceptOwnership()
                                case 0x8832e6e3 { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.safeMint()
                                case 0x8da5cb5b { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.owner()
                                case 0x95d89b41 { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.symbol()
                                case 0xa22cb465 { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.setApprovalForAll()
                            leave
                        }
                                switch sig
                                    case 0xa6487c53 { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.initialize()
                                    case 0xaaf10f42 { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.getImplementation()
                                    case 0xb88d4fde { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.safeTransferFrom()
                                    case 0xc7f62cda { result := _INITIAL_MODULE_BUNDLE } // InitialModuleBundle.simulateUpgradeTo()
                                    case 0xc87b56dd { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.tokenURI()
                                    case 0xe985e9c5 { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.isApprovedForAll()
                                    case 0xff53fac7 { result := _ACCOUNT_TOKEN_MODULE } // AccountTokenModule.setAllowance()
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