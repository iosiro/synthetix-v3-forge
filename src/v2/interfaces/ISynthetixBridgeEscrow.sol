//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

interface ISynthetixBridgeEscrow {
    function approveBridge(
        address _token,
        address _bridge,
        uint256 _amount
    ) external;
}
