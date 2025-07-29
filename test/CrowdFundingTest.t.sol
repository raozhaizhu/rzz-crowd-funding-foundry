// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {CrowdFunding} from "src/CrowdFunding.sol";
import {DeployCrowdFunding} from "script/DeployCrowdFunding.s.sol";

contract CrowdFundingTest is Test {
    DeployCrowdFunding deployer;
    CrowdFunding crowdfunding;
    address owner = address(0x1);
    address donor = address(0x2);

    function setUp() public {
        deployer = new DeployCrowdFunding();
        crowdfunding = deployer.run();
        vm.deal(owner, 10 ether);
        vm.deal(donor, 10 ether);
    }

    function test_CreateCampaign_Success() public {
        vm.prank(owner);
        crowdfunding.createCampaign(owner, "Test Title", "Test Description", block.timestamp + 1 days, 1 ether);
        CrowdFunding.Campaign memory campaign = crowdfunding.getCampaign(0);

        assertEq(campaign.owner, owner);
        assertEq(campaign.title, "Test Title");
        assertEq(campaign.description, "Test Description");
        assertEq(campaign.deadline, block.timestamp + 1 days);
        assertEq(campaign.targetInEther, 1 ether);
    }

    function test_CreateCampaign_RevertIfPastDeadline() public {
        vm.expectRevert(CrowdFunding.CrowdFunding__DeadlineShouldBeInFuture.selector);
        crowdfunding.createCampaign(owner, "T", "D", block.timestamp - 1, 1 ether);
    }

    function test_CreateCampaign_RevertIfTitleTooLong() public {
        string memory longTitle = new string(65);
        vm.expectRevert(CrowdFunding.CrowdFunding__TitleLengthExceeded64Bytes.selector);
        crowdfunding.createCampaign(owner, longTitle, "desc", block.timestamp + 1 days, 1 ether);
    }

    function test_CreateCampaign_RevertIfDescTooLong() public {
        string memory longDesc = new string(257);
        vm.expectRevert(CrowdFunding.CrowdFunding__DescriptionExceeded256Bytes.selector);
        crowdfunding.createCampaign(owner, "title", longDesc, block.timestamp + 1 days, 1 ether);
    }

    function test_DonateToCampaign_Success() public {
        vm.prank(owner);
        crowdfunding.createCampaign(owner, "title", "desc", block.timestamp + 1 days, 1 ether);

        vm.prank(donor);
        crowdfunding.donateToCampaign{value: 0.5 ether}(0);

        (, uint256[] memory donations) = crowdfunding.getDonatorsAndDonations(0);
        assertEq(donations[0], 0.5 ether);
    }

    function test_DonateToCampaign_RevertIfInvalidId() public {
        vm.expectRevert(CrowdFunding.CrowdFunding__idShouldNotBeGreaterThanMaxId.selector);
        vm.prank(donor);
        crowdfunding.donateToCampaign{value: 1 ether}(999);
    }

    function test_GetCampaignsPaginated() public {
        for (uint256 i = 0; i < 5; i++) {
            vm.prank(owner);
            crowdfunding.createCampaign(owner, "t", "d", block.timestamp + 1 days, 1 ether);
        }
        CrowdFunding.Campaign[] memory campaigns = crowdfunding.getCampaignsPaginated(1, 3);
        assertEq(campaigns.length, 3);
    }

    function test_GetCampaignsPaginated_RevertIfOffsetTooLarge() public {
        vm.expectRevert(CrowdFunding.CrowdFunding__offsetOutOfBounds.selector);
        crowdfunding.getCampaignsPaginated(1, 5);
    }

    function test_GetAllCampaigns() public {
        for (uint256 i = 0; i < 2; i++) {
            vm.prank(owner);
            crowdfunding.createCampaign(owner, "t", "d", block.timestamp + 1 days, 1 ether);
        }
        CrowdFunding.Campaign[] memory all = crowdfunding.getAllCampaigns();
        assertEq(all.length, 2);
    }
}
