//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {PriceConverter} from "../src/PriceConverter.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig newHelperConfig = new HelperConfig();
        address ethusdPriceFeedAddress = newHelperConfig.activeNetworkConfig();
        vm.startBroadcast();
        FundMe fundme = new FundMe(ethusdPriceFeedAddress);
        vm.stopBroadcast();
        return fundme;
    }
}
