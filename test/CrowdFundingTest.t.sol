// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {CrowdFunding} from "src/CrowdFunding.sol";
// import {console} from "forge-std/console.sol";
import {DeployCrowdFunding} from "script/DeployCrowdFunding.s.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract RejectEther {
    fallback() external payable {
        revert("Rejected");
    }
}

contract CrowdFundingTest is Test {
    DeployCrowdFunding deployer;
    CrowdFunding crowdFunding;
    address owner = address(0x1);
    address donor = address(0x2);

    string public constant DEFAULT_CID = "bafkreies4pvdtbu53z2f3rio7rl5jbszxpwfbuthnke62b3qpakqg5x34i";

    function setUp() public {
        deployer = new DeployCrowdFunding();
        crowdFunding = deployer.run();
        vm.deal(owner, 10 ether);
        vm.deal(donor, 10 ether);
    }

    function test_CreateCampaign_Success() public {
        //setUp
        vm.prank(owner);
        crowdFunding.createCampaign(
            owner, "Test Title", "Test Description", DEFAULT_CID, block.timestamp + 1 days, 1 ether
        );
        //execution
        CrowdFunding.Campaign memory campaign = crowdFunding.getCampaign(0);
        // console.log("deadline:", campaign.deadline);
        // console.log("targetInEthWei:", campaign.targetInEthWei);
        // console.log("*** owner:", owner, "***");
        //assert
        assertEq(campaign.owner, owner);
        assertEq(campaign.title, "Test Title");
        assertEq(campaign.description, "Test Description");
        assertEq(campaign.heroImageCID, DEFAULT_CID);
        assertEq(campaign.deadline, block.timestamp + 1 days);
        assertEq(campaign.targetInEthWei, 1 ether);
    }

    function test_CreateCampaign_RevertIfPastDeadline() public {
        //setUp//execution//assert
        vm.expectRevert(CrowdFunding.CrowdFunding__DeadlineShouldBeInFuture.selector);
        crowdFunding.createCampaign(owner, "T", "D", DEFAULT_CID, block.timestamp - 1, 1 ether);
    }

    function test_CreateCampaign_RevertIfTitleTooLong() public {
        //setUp
        string memory longTitle = new string(65);
        //execution//assert
        vm.expectRevert(CrowdFunding.CrowdFunding__TitleLengthExceeded64Bytes.selector);
        crowdFunding.createCampaign(owner, longTitle, "desc", DEFAULT_CID, block.timestamp + 1 days, 1 ether);
    }

    function test_CreateCampaign_RevertIfDescTooLong() public {
        string memory longDesc = new string(257);
        vm.expectRevert(CrowdFunding.CrowdFunding__DescriptionExceeded256Bytes.selector);
        crowdFunding.createCampaign(owner, "title", longDesc, DEFAULT_CID, block.timestamp + 1 days, 1 ether);
    }

    function test_DonateToCampaign_Success() public {
        //setUp
        vm.prank(owner);
        crowdFunding.createCampaign(owner, "title", "desc", DEFAULT_CID, block.timestamp + 1 days, 1 ether);
        //execution
        vm.prank(donor);
        crowdFunding.donateToCampaign{value: 0.5 ether}(0);
        (address[] memory donators, uint256[] memory donations) = crowdFunding.getDonatorsAndDonations(0);
        // console.log("*** donators:", donators[0], "***");
        // console.log("*** donations:", donations[0], "***");
        //assert
        assertEq(donators[0], donor);
        assertEq(donations[0], 0.5 ether);
    }

    function test_DonateToCampaign_RevertIfTransferFailed() public {
        //setUp
        RejectEther rejectContract = new RejectEther();
        vm.prank(address(rejectContract));
        crowdFunding.createCampaign(
            address(rejectContract), "title", "desc", DEFAULT_CID, block.timestamp + 1 days, 1 ether
        );
        //execution//assert
        vm.prank(donor);
        vm.expectRevert(CrowdFunding.CrowdFunding__TransferFailed.selector);
        crowdFunding.donateToCampaign{value: 1 ether}(0);
    }

    function test_DonateToCampaign_RevertIfInvalidId() public {
        //setUp//execution//assert
        vm.expectRevert(CrowdFunding.CrowdFunding__idShouldNotBeGreaterOrEqualToMaxId.selector);
        vm.prank(donor);
        crowdFunding.donateToCampaign{value: 1 ether}(0);
    }

    function test_DonateToCampaign_RevertIfDeadlineIsntInFuture() public {
        //setUp
        vm.prank(owner);
        crowdFunding.createCampaign(owner, "t", "d", DEFAULT_CID, block.timestamp + 1 days, 1 ether);
        vm.warp(block.timestamp + 2 days);
        //execution
        //assert
        vm.expectRevert(CrowdFunding.CrowdFunding__DeadlineShouldBeInFuture.selector);
        vm.prank(donor);
        crowdFunding.donateToCampaign{value: 1 ether}(0);
    }

    function test_DonateToCampaign_RevertIfInvalidIdAgain() public {
        //setup
        vm.prank(owner);
        crowdFunding.createCampaign(owner, "t", "d", DEFAULT_CID, block.timestamp + 1 days, 1 ether);
        //execution
        vm.expectRevert(CrowdFunding.CrowdFunding__idShouldNotBeGreaterOrEqualToMaxId.selector);
        crowdFunding.getCampaign(1);
    }

    function test_GetSingleCampaign() public {
        //setUp
        vm.prank(owner);
        crowdFunding.createCampaign(owner, "title", "desc", DEFAULT_CID, block.timestamp + 1 days, 1 ether);

        address[] memory emptyDonators;
        uint256[] memory emptyDonations;
        CrowdFunding.Campaign memory expected = CrowdFunding.Campaign({
            owner: owner,
            title: "title",
            description: "desc",
            heroImageCID: DEFAULT_CID,
            deadline: block.timestamp + 1 days,
            targetInEthWei: 1 ether,
            amountCollectedInEthWei: 0,
            donators: emptyDonators,
            donations: emptyDonations
        });
        //execution
        CrowdFunding.Campaign memory actual = crowdFunding.getCampaign(0);
        //assert
        assertEq(actual.owner, expected.owner);
        assertEq(actual.title, expected.title);
        assertEq(actual.description, expected.description);
        assertEq(actual.deadline, expected.deadline);
        assertEq(actual.targetInEthWei, expected.targetInEthWei);
        assertEq(actual.amountCollectedInEthWei, expected.amountCollectedInEthWei);
    }

    function test_GetCampaignsPaginated() public {
        //setUp
        for (uint256 i = 0; i < 5; i++) {
            vm.prank(owner);
            crowdFunding.createCampaign(owner, Strings.toString(i), "d", DEFAULT_CID, block.timestamp + 1 days, 1 ether);
        }
        //execution
        CrowdFunding.Campaign[] memory campaigns = crowdFunding.getCampaignsPaginated(1, 3);
        //assert
        assertEq(campaigns.length, 3);
        assertEq(campaigns[0].title, "1");
        assertEq(campaigns[1].title, "2");
        assertEq(campaigns[2].title, "3");
    }

    function test_GetCampaignsPaginated_RevertIfOffsetTooLarge() public {
        //setUp
        for (uint256 i = 0; i < 1; i++) {
            vm.prank(owner);
            crowdFunding.createCampaign(owner, Strings.toString(i), "d", DEFAULT_CID, block.timestamp + 1 days, 1 ether);
        }
        //execution//assert
        vm.expectRevert(CrowdFunding.CrowdFunding__offsetOutOfBounds.selector);
        crowdFunding.getCampaignsPaginated(2, 1);
    }

    function test_GetCampaignsPaginated_IfExceedLimit() public {
        //setUp
        for (uint256 i = 0; i < 1; i++) {
            vm.prank(owner);
            crowdFunding.createCampaign(owner, Strings.toString(i), "d", DEFAULT_CID, block.timestamp + 1 days, 1 ether);
        }
        //execution
        CrowdFunding.Campaign[] memory campaigns = crowdFunding.getCampaignsPaginated(0, 2);
        //assert
        assertEq(campaigns.length, 1);
    }

    function test_GetAllCampaigns() public {
        //setUp
        for (uint256 i = 0; i < 2; i++) {
            vm.prank(owner);
            crowdFunding.createCampaign(owner, "t", "d", DEFAULT_CID, block.timestamp + 1 days, 1 ether);
        }
        //execution
        CrowdFunding.Campaign[] memory all = crowdFunding.getAllCampaigns();
        //assert
        assertEq(all.length, 2);
    }
}
