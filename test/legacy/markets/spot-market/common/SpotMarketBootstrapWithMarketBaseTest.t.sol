//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {BaseLegacyTest} from "test/legacy/common/BaseLegacyTest.t.sol";

import {Cannon} from "test/cannon/Cannon.sol";
import {CannonScript as OracleManager} from "test/cannon/schemas/oracle-manager.cannon.sol";
import {CannonScript as Synthetix} from "test/cannon/schemas/synthetix.cannon.sol";
import {CannonScript as SpotMarket} from "test/cannon/schemas/synth-spot-market.cannon.sol";

import {ISpotMarketRouter} from "src/generated/routers/SpotMarketRouter.g.sol";
import {ICoreRouter} from "src/generated/routers/CoreRouter.g.sol";
import {INodeModule} from "@synthetixio/oracle-manager/contracts/interfaces/INodeModule.sol";

import {MockPythERC7412Wrapper} from "@synthetixio/spot-market/contracts/mocks/MockPythERC7412Wrapper.sol";

contract SpotMarketBootstrapWithMarketBaseTest is BaseLegacyTest {
    ICoreRouter internal coreProxy;
    ISpotMarketRouter internal spotMarketProxy;
    uint128 marketId;

    function setUp() public virtual override {
        OracleManager.deploy();
        Synthetix.deploy();
        SpotMarket.deploy();

        coreProxy = ICoreRouter(Cannon.resolve("synthetix.CoreProxy"));
        spotMarketProxy = ISpotMarketRouter(Cannon.resolve("synthetix-spot-market.SpotMarketProxy"));

        // create price nodes
        (bytes32 oracleNodeId, ) = _createPythNode(address(this), 100);
    }

    function _createPythNode(address owner, uint256 price) internal returns (bytes32 oracleNodeId, address aggregator) {

    }
}