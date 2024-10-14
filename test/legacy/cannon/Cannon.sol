//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

library Cannon {
    error KeyNotFound(string key);

    struct Data {
        mapping(bytes32 => address) registry;
    }

    function load() internal pure returns (Data storage data) {
        bytes32 s = keccak256(abi.encode("io.cannon.Registry"));
        assembly {
            data.slot := s
        }
    }

    function resolve(bytes memory key) internal view returns (address payable) {
        address result = load().registry[keccak256(key)];
        if (result == address(0)) {
            revert KeyNotFound(string(key));
        }
        return payable(result);
    }

    function register(bytes memory key, address value) internal {
        load().registry[keccak256(key)] = value;
    }
}
