// SPDX-License-Identifier: MIT

// ─────────────────────────────────────
// Version
pragma solidity ^0.8.20;

// ─────────────────────────────────────
// Imports
// import "@openzeppelin/contracts/...";

// ─────────────────────────────────────
// Interfaces, Libraries, Contracts

contract CrowdFunding {
    // ─────────────────────────────────────
    // Errors
    error CrowdFunding__DeadlineShouldBeInFuture();
    error CrowdFunding__TitleAndDescriptionLengthCantExceed64();
    // ─────────────────────────────────────
    // Type Declarations
    /**
     * @dev address占用20bytes，占1个slot
     * @dev 将uint256排在一起，连续使用3个slot
     * @dev string作为动态类型本身就要单独占据slot,应对长度做限制
     * @dev uint和address的动态数组放后面，不打散结构
     */
    struct Campaign {
        address owner;
        uint256 deadline;
        uint256 targetInEther;
        uint256 amountCollectedInEther;
        string title;
        string description;
        uint256[] donations;
        address[] donators;
    }

    // ─────────────────────────────────────
    // State Variables
    mapping(uint256 => Campaign) public s_campaigns;
    uint256 public s_idOfCampaign;

    // ─────────────────────────────────────
    // Events
    event CrowdFundingCreated(uint256 indexed idOfCampaign);

    // ─────────────────────────────────────
    // Modifiers

    // ─────────────────────────────────────
    // Functions

    // Constructor
    constructor() {}

    // Receive Function

    // Fallback Function

    // External Functions
    function createCampaign(
        address _owner,
        string memory _title,
        string memory _description,
        uint256 _deadline,
        uint256 _targetInEther
    ) public {
        if (_deadline <= block.timestamp)
            revert CrowdFunding__DeadlineShouldBeInFuture();
        if (bytes(_title).length > 64 || bytes(_description).length > 64)
            revert CrowdFunding__TitleAndDescriptionLengthCantExceed64();

        Campaign storage campaign = s_campaigns[s_idOfCampaign];

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.deadline = _deadline;
        campaign.targetInEther = _targetInEther;

        campaign.amountCollectedInEther = 0;

        s_idOfCampaign++;

        emit CrowdFundingCreated(uint256(s_idOfCampaign - 1));
    }

    function donateToCampaign(uint256 _id) external payable {
        uint256 amount = msg.value;

        Campaign storage campaign = s_campaigns[_id];
        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        (bool sent, ) = payable(campaign.owner).call{value: amount}("");

        if (sent) {
            campaign.amountCollectedInEther += amount;
        }
    }

    // Public Functions
    function getDonators(
        uint256 _id
    ) public view returns (address[] memory, uint256[] memory) {
        return (s_campaigns[_id].donators, s_campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](s_idOfCampaign);
        for (uint i = 0; i < s_idOfCampaign; i++) {
            Campaign storage item = s_campaigns[i];
            allCampaigns[i] = item;
        }

        return allCampaigns;
    }
    // Internal Functions

    // Private Functions

    // View & Pure Functions
}
