//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "./IERC20.sol";

// https://docs.synthetix.io/contracts/source/interfaces/iwrapperfactory
interface IWrapperFactory {
    function isWrapper(address possibleWrapper) external view returns (bool);

    function createWrapper(
        IERC20 token,
        bytes32 currencyKey,
        bytes32 synthContractName
    ) external returns (address);

    function distributeFees() external;
}
