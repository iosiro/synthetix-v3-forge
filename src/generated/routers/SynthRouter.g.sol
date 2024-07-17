// SPDX-License-Identifier: UNLICENSEDlt(sig
pragma solidity ^0.8.13;

interface ISynthRouter {
    function acceptOwnership() external;
    function advanceEpoch() external returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address user) external view returns (uint256);
    function burn(address from, uint256 amount) external;
    function decayRate() external view returns (uint256);
    function decimals() external view returns (uint8);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function getImplementation() external view returns (address);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function initialize(string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals) external;
    function isInitialized() external view returns (bool);
    function mint(address to, uint256 amount) external;
    function name() external view returns (string memory);
    function nominateNewOwner(address newNominatedOwner) external;
    function nominatedOwner() external view returns (address);
    function owner() external view returns (address);
    function renounceNomination() external;
    function setAllowance(address from, address spender, uint256 amount) external;
    function setDecayRate(uint256 _rate) external;
    function simulateUpgradeTo(address newImplementation) external;
    function symbol() external view returns (string memory);
    function totalShares() external view returns (uint256);
    function totalSupply() external view returns (uint256 supply);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function upgradeTo(address newImplementation) external;
}

contract SynthRouter {
    address constant _CORE_MODULE = 0xa3994A4190CAe45D36D36BAfCAec2c6DA5e729fc;
address constant _SYNTH_TOKEN_MODULE = 0x5F5deCA8d99b440f235c58Ce25Cbeb0e980bA09F;

    error UnknownSelector(bytes4 sel);

    fallback() external payable {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        address implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                if lt(sig, 0x53a47bb7) {
                    if lt(sig, 0x313ce567) {
                        switch sig
                            case 0x04e7e0b9 { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.setDecayRate()
                            case 0x06fdde03 { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.name()
                            case 0x095ea7b3 { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.approve()
                            case 0x1624f6c6 { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.initialize()
                            case 0x1627540c { result := _CORE_MODULE } // CoreModule.nominateNewOwner()
                            case 0x18160ddd { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.totalSupply()
                            case 0x23b872dd { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.transferFrom()
                        leave
                    }
                            switch sig
                                case 0x313ce567 { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.decimals()
                                case 0x3659cfe6 { result := _CORE_MODULE } // CoreModule.upgradeTo()
                                case 0x392e53cd { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.isInitialized()
                                case 0x39509351 { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.increaseAllowance()
                                case 0x3a98ef39 { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.totalShares()
                                case 0x3cf80e6c { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.advanceEpoch()
                                case 0x40c10f19 { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.mint()
                            leave
                }
                        if lt(sig, 0xa457c2d7) {
                            switch sig
                                case 0x53a47bb7 { result := _CORE_MODULE } // CoreModule.nominatedOwner()
                                case 0x70a08231 { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.balanceOf()
                                case 0x718fe928 { result := _CORE_MODULE } // CoreModule.renounceNomination()
                                case 0x79ba5097 { result := _CORE_MODULE } // CoreModule.acceptOwnership()
                                case 0x8da5cb5b { result := _CORE_MODULE } // CoreModule.owner()
                                case 0x95d89b41 { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.symbol()
                                case 0x9dc29fac { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.burn()
                            leave
                        }
                                switch sig
                                    case 0xa457c2d7 { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.decreaseAllowance()
                                    case 0xa9059cbb { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.transfer()
                                    case 0xa9c1f2f1 { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.decayRate()
                                    case 0xaaf10f42 { result := _CORE_MODULE } // CoreModule.getImplementation()
                                    case 0xc7f62cda { result := _CORE_MODULE } // CoreModule.simulateUpgradeTo()
                                    case 0xda46098c { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.setAllowance()
                                    case 0xdd62ed3e { result := _SYNTH_TOKEN_MODULE } // SynthTokenModule.allowance()
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