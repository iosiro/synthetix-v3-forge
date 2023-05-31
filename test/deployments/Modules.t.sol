//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import { NodeModule } from "@synthetixio/oracle-manager/contracts/modules/NodeModule.sol";
import { CoreModule } from "@synthetixio/oracle-manager/contracts/modules/CoreModule.sol";

import { InitialModuleBundle } from "@synthetixio/main/contracts/modules/InitialModuleBundle.sol";
import { FeatureFlagModule } from "@synthetixio/main/contracts/modules/core/FeatureFlagModule.sol";
import { AccountModule } from "@synthetixio/main/contracts/modules/core/AccountModule.sol";
import { AssociateDebtModule } from "@synthetixio/main/contracts/modules/core/AssociateDebtModule.sol";
import { AssociatedSystemsModule } from "@synthetixio/main/contracts/modules/associated-systems/AssociatedSystemsModule.sol";
import { CollateralModule } from "@synthetixio/main/contracts/modules/core/CollateralModule.sol";
import { CollateralConfigurationModule } from "@synthetixio/main/contracts/modules/core/CollateralConfigurationModule.sol";
import { IssueUSDModule } from "@synthetixio/main/contracts/modules/core/IssueUSDModule.sol";
import { LiquidationModule } from "@synthetixio/main/contracts/modules/core/LiquidationModule.sol";
import { MarketCollateralModule } from "@synthetixio/main/contracts/modules/core/MarketCollateralModule.sol";
import { MarketManagerModule } from "@synthetixio/main/contracts/modules/core/MarketManagerModule.sol";
import { MulticallModule } from "@synthetixio/main/contracts/modules/core/MulticallModule.sol";
import { PoolConfigurationModule } from "@synthetixio/main/contracts/modules/core/PoolConfigurationModule.sol";
import { PoolModule } from "@synthetixio/main/contracts/modules/core/PoolModule.sol";
import { RewardsManagerModule } from "@synthetixio/main/contracts/modules/core/RewardsManagerModule.sol";
import { UtilsModule } from "@synthetixio/main/contracts/modules/core/UtilsModule.sol";
import { VaultModule } from "@synthetixio/main/contracts/modules/core/VaultModule.sol";
import { AccountTokenModule } from "@synthetixio/main/contracts/modules/account/AccountTokenModule.sol";
import { USDTokenModule } from "@synthetixio/main/contracts/modules/usd/USDTokenModule.sol";

import { SpotMarketFactoryModule, ISynthetixSystem } from "@synthetixio/spot-market/contracts/modules/SpotMarketFactoryModule.sol";
import { AtomicOrderModule } from "@synthetixio/spot-market/contracts/modules/AtomicOrderModule.sol";
import { AsyncOrderModule } from "@synthetixio/spot-market/contracts/modules/AsyncOrderModule.sol";
import { AsyncOrderSettlementModule } from "@synthetixio/spot-market/contracts/modules/AsyncOrderSettlementModule.sol";
import { AsyncOrderConfigurationModule } from "@synthetixio/spot-market/contracts/modules/AsyncOrderConfigurationModule.sol";
import { WrapperModule } from "@synthetixio/spot-market/contracts/modules/WrapperModule.sol";
import { MarketConfigurationModule } from "@synthetixio/spot-market/contracts/modules/MarketConfigurationModule.sol";
import { SynthTokenModule } from "@synthetixio/spot-market/contracts/modules/token/SynthTokenModule.sol";
