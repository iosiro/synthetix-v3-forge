import { Test } from "forge-std/Test.sol";

import { PerpsMarketDeployment } from "test/deployments/PerpsMarket.t.sol";

contract PerpsMarketBootstrap is PerpsMarketDeployment  {
    function setUp() public virtual override {
        PerpsMarketDeployment.setUp();
    }


}