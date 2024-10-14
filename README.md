## Synthetix V3 Forge

**This project aims to enable developers and auditors to quickly test the Synthetix V3 ecosystem.**

Synthetix V3 is built using Hardhat and Cannon, which are not optimized for rapid prototyping and testing. Although Cannon's strict package usage allows declarative deployments, it can create a bottleneck during early development and testing. Rebuilding packages and rerunning tests can take several minutes with each change.

This repository uses an adapted Router architecture that leverages `immutable` modules instead of deterministic ones. This allows for the runtime deployment of routers and modules in Forge tests. While the Immutable Router incurs a slight gas overhead, it does not alter the overall architecture of Synthetix V3.


## Getting Started

### Foundry

Make sure all the latest version of `foundry` as been installed. 

```shell
foundryup
```

### cannon-rs

Although the latest version of the Immutable Routers is included in this repository, you'll need to regenerate them if any module interfaces change. To do this, you'll need the cannon-rs Rust binary:

```shell
git clone git@github.com:iosiro/cannon-rs.git && cd cannon-rs

cargo install cannon-rs --path .
``` 

Once installed, regenerate the Immutable Routers using the Router specification TOML file:
```shell
cannon-rs generate immutable-router --toml routers.toml
```

If new modules are added to a router, update the relevant router definition in the `routers.toml` file.

## Testing

### Legacy

The `test/legacy` directory replicates the Hardhat tests from the Synthetix-V3 repository. It includes deployments equivalent to the Cannon TOML files for each package, as well as the necessary bootstrapping functions.

### Fork Testing

The `test/fork` directory simplifies the process of upgrading Synthetix V3 proxies with fork tests. Tests can inherit the relevant contract from `test/fork/networks` and call `upgrade()`. This setup allows easy comparisons of behavior before and after upgrades in forked environments.

```solidity
//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {
    ArbitrumMainnetForkTest,
    ICoreRouter
} from "test/fork/networks/ArbitrumMainnetForkTest.t.sol";

contract ArbitrumMainnetForkTestExample is ArbitrumMainnetForkTest {
    function setUp() override public {}

    function testCreateAccount() public {
        // Existing code        
        ICoreRouter(CORE_PROXY).createAccount();

        // Upgrade all the proxies with Immutable Routers and the current modules
        ArbitrumMainnetForkTest.upgrade();

        // Call new implementation
        ICoreRouter(CORE_PROXY).createAccount();
    }

    function onERC721Received(address, address, uint256, bytes memory) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
```