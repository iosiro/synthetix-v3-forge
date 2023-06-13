//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "./IExchangeRates.sol";

// https://docs.synthetix.io/contracts/source/interfaces/IExchangeCircuitBreaker
interface IExchangeCircuitBreaker {
    // Views

    function exchangeRates() external view returns (IExchangeRates);

    function rateWithInvalid(bytes32 currencyKey) external view returns (uint, bool);

    function rateWithBreakCircuit(bytes32 currencyKey) external returns (uint lastValidRate, bool circuitBroken);
}
