//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;
pragma experimental ABIEncoderV2;

import "./IRewardEscrowV2.sol";

interface ISynthetixBridgeToBase {
    // invoked by the xDomain messenger on L2
    function finalizeEscrowMigration(
        address account,
        uint256 escrowedAmount,
        VestingEntries.VestingEntry[] calldata vestingEntries
    ) external;

    // invoked by the xDomain messenger on L2
    function finalizeRewardDeposit(address from, uint amount) external;

    function finalizeFeePeriodClose(uint snxBackedDebt, uint debtSharesSupply) external;
}
