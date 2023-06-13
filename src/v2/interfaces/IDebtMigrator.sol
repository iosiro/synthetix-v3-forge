//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;
pragma experimental ABIEncoderV2;

interface IDebtMigrator {
    function finalizeDebtMigration(
        address account,
        uint debtSharesMigrated,
        uint escrowMigrated,
        uint liquidSnxMigrated,
        bytes calldata debtPayload
    ) external;
}
