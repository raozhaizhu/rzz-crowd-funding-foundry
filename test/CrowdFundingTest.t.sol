// SPDX-License-Identifier: MIT

import {Test} from "forge-std/Test.sol";
import {CrowdFunding} from "../src/CrowdFunding.sol";
import {DeployCrowdFunding} from "../script/DeployCrowdFunding.s.sol";

pragma solidity ^0.8.26;

contract CrowdFundingTest is Test {
    CrowdFunding public contractInstance;
    DeployCrowdFunding public deployer;
    function setUp() public {
        deployer = new DeployCrowdFunding();
        contractInstance = deployer.run();

    }

    function testExample() public {
        // Add your test logic here
    }
}