//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {Vm} from "forge-std/Vm.sol";

Vm constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
