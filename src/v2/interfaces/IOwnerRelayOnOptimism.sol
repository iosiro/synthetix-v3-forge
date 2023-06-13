//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;
pragma experimental ABIEncoderV2;

interface IOwnerRelayOnOptimism {
    function finalizeRelay(address target, bytes calldata payload) external;

    function finalizeRelayBatch(address[] calldata target, bytes[] calldata payloads) external;
}
