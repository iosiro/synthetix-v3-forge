// SPDX-License-Identifier: UNLICENSED
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
    address immutable internal _CORE_MODULE;
    address immutable internal _SYNTH_TOKEN_MODULE;

    struct Modules {
        address coreModule;
        address synthTokenModule;
    }

    constructor(Modules memory $) {
        _CORE_MODULE = $.coreModule;
        _SYNTH_TOKEN_MODULE = $.synthTokenModule;
    }

    error UnknownSelector(bytes4 sel);

    function findImplementationAddress(bytes32 implementation) internal view returns (address result) {
        if (implementation == 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936) return _CORE_MODULE;
        if (implementation == 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824) return _SYNTH_TOKEN_MODULE;
    }

    fallback() external payable {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        bytes32 implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                if lt(sig, 0x53a47bb7) {
                    if lt(sig, 0x313ce567) {
                        switch sig
                            case 0x04e7e0b9 { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.setDecayRate()
                            case 0x06fdde03 { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.name()
                            case 0x095ea7b3 { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.approve()
                            case 0x1624f6c6 { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.initialize()
                            case 0x1627540c { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.nominateNewOwner()
                            case 0x18160ddd { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.totalSupply()
                            case 0x23b872dd { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.transferFrom()
                        leave
                    }
                    switch sig
                        case 0x313ce567 { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.decimals()
                        case 0x3659cfe6 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.upgradeTo()
                        case 0x392e53cd { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.isInitialized()
                        case 0x39509351 { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.increaseAllowance()
                        case 0x3a98ef39 { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.totalShares()
                        case 0x3cf80e6c { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.advanceEpoch()
                        case 0x40c10f19 { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.mint()
                    leave
                }
                if lt(sig, 0xa457c2d7) {
                    switch sig
                        case 0x53a47bb7 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.nominatedOwner()
                        case 0x70a08231 { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.balanceOf()
                        case 0x718fe928 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.renounceNomination()
                        case 0x79ba5097 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.acceptOwnership()
                        case 0x8da5cb5b { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.owner()
                        case 0x95d89b41 { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.symbol()
                        case 0x9dc29fac { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.burn()
                    leave
                }
                switch sig
                    case 0xa457c2d7 { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.decreaseAllowance()
                    case 0xa9059cbb { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.transfer()
                    case 0xa9c1f2f1 { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.decayRate()
                    case 0xaaf10f42 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.getImplementation()
                    case 0xc7f62cda { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.simulateUpgradeTo()
                    case 0xda46098c { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.setAllowance()
                    case 0xdd62ed3e { result := 0x1aa36159ff3c1869c6bf4a1240c7a840db55a2a6c82aa268d24444f8ea20c824 } // SynthTokenModule.allowance()
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