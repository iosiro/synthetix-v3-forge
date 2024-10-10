//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;


import {Proxy} from "@synthetixio/main/contracts/Proxy.sol";

// Shared
import {InitialModuleBundle} from "@synthetixio/main/contracts/modules/InitialModuleBundle.sol";
import {AssociatedSystemsModule} from "@synthetixio/main/contracts/modules/associated-systems/AssociatedSystemsModule.sol";

// CoreRouter
import {FeatureFlagModule} from "@synthetixio/main/contracts/modules/core/FeatureFlagModule.sol";
import {AccountModule} from "@synthetixio/main/contracts/modules/core/AccountModule.sol";
import {AssociateDebtModule} from "@synthetixio/main/contracts/modules/core/AssociateDebtModule.sol";
import {CcipReceiverModule} from "@synthetixio/main/contracts/modules/core/CcipReceiverModule.sol";
import {CollateralModule} from "@synthetixio/main/contracts/modules/core/CollateralModule.sol";
import {CollateralConfigurationModule} from "@synthetixio/main/contracts/modules/core/CollateralConfigurationModule.sol";
import {CrossChainUSDModule} from "@synthetixio/main/contracts/modules/core/CrossChainUSDModule.sol";
import {IssueUSDModule} from "@synthetixio/main/contracts/modules/core/IssueUSDModule.sol";
import {LiquidationModule} from "@synthetixio/main/contracts/modules/core/LiquidationModule.sol";
import {MarketCollateralModule} from "@synthetixio/main/contracts/modules/core/MarketCollateralModule.sol";
import {MarketManagerModule} from "@synthetixio/main/contracts/modules/core/MarketManagerModule.sol";
import {PoolConfigurationModule} from "@synthetixio/main/contracts/modules/core/PoolConfigurationModule.sol";
import {PoolModule} from "@synthetixio/main/contracts/modules/core/PoolModule.sol";
import {RewardsManagerModule} from "@synthetixio/main/contracts/modules/core/RewardsManagerModule.sol";
import {UtilsModule} from "@synthetixio/main/contracts/modules/core/UtilsModule.sol";
import {VaultModule} from "@synthetixio/main/contracts/modules/core/VaultModule.sol";

// AccountRouter
import {AccountTokenModule} from "@synthetixio/main/contracts/modules/account/AccountTokenModule.sol";

// USDRouter
import {USDTokenModule} from "@synthetixio/main/contracts/modules/usd/USDTokenModule.sol";


import {CoreRouter, ICoreRouter, CollateralConfiguration} from "src/generated/routers/CoreRouter.g.sol";
import {AccountRouter, IAccountRouter} from "src/generated/routers/AccountRouter.g.sol";
import {USDRouter, IUSDRouter} from "src/generated/routers/USDRouter.g.sol";

import {Test} from "forge-std/Test.sol";

contract ArbitrumMainnetSynthetixForkTest is Test {

    //Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address payable constant internal CORE_PROXY = payable(0xffffffaEff0B96Ea8e4f94b2253f31abdD875847);
    address payable constant internal ACCOUNT_PROXY = payable(0xD935444f5dc75A407ed475C9F387e124911d36C6);
    address payable constant internal USD_PROXY = payable(0xb2F30A7C980f052f02563fb518dcc39e6bf38175);
    //address payable constant OWNER = payable(0xD3DFa13CDc7c133b1700c243f03A8C6Df513A93b);

    function upgrade() virtual public {

        CoreRouter coreRouter = new CoreRouter(CoreRouter.Modules({
            associatedSystemsModule: address(new AssociatedSystemsModule()),
            marketCollateralModule: address(new MarketCollateralModule()),
            rewardsManagerModule: address(new RewardsManagerModule()),
            collateralModule: address(new CollateralModule()),
            issueUSDModule: address(new IssueUSDModule()),
            associateDebtModule: address(new AssociateDebtModule()),
            marketManagerModule: address(new MarketManagerModule()),
            initialModuleBundle: address(new InitialModuleBundle()),
            featureFlagModule: address(new FeatureFlagModule()),
            accountModule: address(new AccountModule()),
            vaultModule: address(new VaultModule()),
            liquidationModule: address(new LiquidationModule()),
            poolModule: address(new PoolModule()),
            utilsModule: address(new UtilsModule()),
            collateralConfigurationModule: address(new CollateralConfigurationModule()),
            ccipReceiverModule: address(new CcipReceiverModule()),
            crossChainUSDModule: address(new CrossChainUSDModule()),
            poolConfigurationModule: address(new PoolConfigurationModule())
        }));

        // [router.AccountRouter]
        AccountRouter accountRouter = new AccountRouter(AccountRouter.Modules({
            accountTokenModule: address(new AccountTokenModule()),
            initialModuleBundle: address(new InitialModuleBundle())
        }));
      
        // [router.USDRouter]
        USDRouter usdRouter = new USDRouter(USDRouter.Modules({
            associatedSystemsModule: address(new AssociatedSystemsModule()),
            uSDTokenModule: address(new USDTokenModule()),
            initialModuleBundle: address(new InitialModuleBundle())
        }));

        vm.prank(ICoreRouter(CORE_PROXY).owner());
        ICoreRouter(CORE_PROXY).upgradeTo(address(coreRouter));
        
        vm.prank(IAccountRouter(ACCOUNT_PROXY).owner());
        IAccountRouter(ACCOUNT_PROXY).upgradeTo(address(accountRouter));
        
        vm.prank(IUSDRouter(USD_PROXY).owner());        
        IUSDRouter(USD_PROXY).upgradeTo(address(usdRouter));
    }
    

}