// SPDX-License-Identifier: MIT

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {CrowdFunding} from "../src/CrowdFunding.sol";

pragma solidity ^0.8.26;

contract DeployCrowdFunding is Script {
    function run() external returns (CrowdFunding) {
        vm.startBroadcast();
        CrowdFunding constract = new CrowdFunding();
        console2.log(" contract address", address(constract));
        vm.stopBroadcast();
        return constract;
    }
}