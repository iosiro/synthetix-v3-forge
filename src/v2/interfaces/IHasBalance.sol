//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

// https://docs.synthetix.io/contracts/source/interfaces/ihasbalance
interface IHasBalance {
    // Views
    function balanceOf(address account) external view returns (uint);
}
