//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "./IPerpsV2MarketBaseTypes.sol";

interface IPerpsV2MarketLiquidate {
    /* ========== FUNCTION INTERFACE ========== */

    /* ---------- Market Operations ---------- */

    function flagPosition(address account) external;

    function liquidatePosition(address account) external;

    function forceLiquidatePosition(address account) external;
}
