// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library NodeDefinition {
    type NodeType is uint8;
    struct Data {
        NodeType nodeType;
        bytes parameters;
        bytes32[] parents;
    }
}

library NodeOutput {
    struct Data {
        int256 price;
        uint256 timestamp;
        uint256 __slotAvailableForFutureUse1;
        uint256 __slotAvailableForFutureUse2;
    }
}

interface IOracleManagerRouter {
    function acceptOwnership() external;
    function getImplementation() external view returns (address);
    function getNode(bytes32 nodeId) external pure returns (NodeDefinition.Data memory node);
    function getNodeId(NodeDefinition.NodeType nodeType, bytes memory parameters, bytes32[] memory parents) external pure returns (bytes32 nodeId);
    function nominateNewOwner(address newNominatedOwner) external;
    function nominatedOwner() external view returns (address);
    function owner() external view returns (address);
    function process(bytes32 nodeId) external view returns (NodeOutput.Data memory node);
    function processManyWithManyRuntime(bytes32[] memory nodeIds, bytes32[][] memory runtimeKeys, bytes32[][] memory runtimeValues) external view returns (NodeOutput.Data[] memory nodes);
    function processManyWithRuntime(bytes32[] memory nodeIds, bytes32[] memory runtimeKeys, bytes32[] memory runtimeValues) external view returns (NodeOutput.Data[] memory nodes);
    function processWithRuntime(bytes32 nodeId, bytes32[] memory runtimeKeys, bytes32[] memory runtimeValues) external view returns (NodeOutput.Data memory node);
    function registerNode(NodeDefinition.NodeType nodeType, bytes memory parameters, bytes32[] memory parents) external returns (bytes32 nodeId);
    function renounceNomination() external;
    function simulateUpgradeTo(address newImplementation) external;
    function upgradeTo(address newImplementation) external;
}

contract OracleManagerRouter {
    address immutable internal _NODE_MODULE;
    address immutable internal _CORE_MODULE;

    struct Modules {
        address nodeModule;
        address coreModule;
    }

    constructor(Modules memory $) {
        _NODE_MODULE = $.nodeModule;
        _CORE_MODULE = $.coreModule;
    }

    error UnknownSelector(bytes4 sel);

    function findImplementationAddress(bytes32 implementation) internal view returns (address result) {
        if (implementation == 0x791d80463336abffbe645eeab28553a6357a4eb160b9c3b9a79da8e952720e09) return _NODE_MODULE;
        if (implementation == 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936) return _CORE_MODULE;
    }

    fallback() external payable {
        // Lookup table: Function selector => implementation contract
        bytes4 sig4 = msg.sig;
        bytes32 implementation;

        assembly {
            let sig32 := shr(224, sig4)

            function findImplementation(sig) -> result {
                if lt(sig, 0x79ba5097) {
                    switch sig
                        case 0x05d73a25 { result := 0x791d80463336abffbe645eeab28553a6357a4eb160b9c3b9a79da8e952720e09 } // NodeModule.processManyWithRuntime()
                        case 0x1627540c { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.nominateNewOwner()
                        case 0x2a952b2d { result := 0x791d80463336abffbe645eeab28553a6357a4eb160b9c3b9a79da8e952720e09 } // NodeModule.process()
                        case 0x3659cfe6 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.upgradeTo()
                        case 0x50c946fe { result := 0x791d80463336abffbe645eeab28553a6357a4eb160b9c3b9a79da8e952720e09 } // NodeModule.getNode()
                        case 0x53a47bb7 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.nominatedOwner()
                        case 0x625ca21c { result := 0x791d80463336abffbe645eeab28553a6357a4eb160b9c3b9a79da8e952720e09 } // NodeModule.getNodeId()
                        case 0x718fe928 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.renounceNomination()
                    leave
                }
                switch sig
                    case 0x79ba5097 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.acceptOwnership()
                    case 0x8461e0d9 { result := 0x791d80463336abffbe645eeab28553a6357a4eb160b9c3b9a79da8e952720e09 } // NodeModule.processManyWithManyRuntime()
                    case 0x8da5cb5b { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.owner()
                    case 0xaaf10f42 { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.getImplementation()
                    case 0xc7f62cda { result := 0x4244fcb9e04b991a1f0644ba7d86c296f089ca67c187f14cda4939cff7f6d936 } // CoreModule.simulateUpgradeTo()
                    case 0xdaa250be { result := 0x791d80463336abffbe645eeab28553a6357a4eb160b9c3b9a79da8e952720e09 } // NodeModule.processWithRuntime()
                    case 0xdeba1b98 { result := 0x791d80463336abffbe645eeab28553a6357a4eb160b9c3b9a79da8e952720e09 } // NodeModule.registerNode()
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