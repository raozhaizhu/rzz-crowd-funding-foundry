// SPDX-License-Identifier: MIT

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {CrowdFunding} from "../src/CrowdFunding.sol";

pragma solidity ^0.8.20;

contract DeployCrowdFunding is Script {
    function run() external returns (CrowdFunding) {
        vm.startBroadcast();
        CrowdFunding crowdFunding = new CrowdFunding();
        console2.log(" contract address", address(crowdFunding));
        vm.stopBroadcast();
        return crowdFunding;
    }
}
