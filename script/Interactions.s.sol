//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;
import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.02 ether;

    function fundFundMe(address mostRecentlyDeployedFundMe) public {
        FundMe(payable(mostRecentlyDeployedFundMe)).fund{value: SEND_VALUE}();

        console.log("Funded FundMe contract with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployedFundMe = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid); // looks into the broadcast for the particular chain id for particular latesat contract deployment
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployedFundMe);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployedFundMe) public payable {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployedFundMe)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployedFundMe = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid); // looks into the broadcast for the particular chain id for particular latesat contract deployment
        vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployedFundMe);
        vm.stopBroadcast();
    }
}
