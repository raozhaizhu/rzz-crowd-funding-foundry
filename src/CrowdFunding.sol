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
    /* -------------------------------------------------------------------------- */
    /*                                  Errors                                    */
    /* -------------------------------------------------------------------------- */
    error CrowdFunding__DeadlineShouldBeInFuture();
    error CrowdFunding__CampaignExceededDeadLine();
    error CrowdFunding__TitleLengthExceeded64Bytes();
    error CrowdFunding__DescriptionExceeded256Bytes();
    error CrowdFunding__idShouldNotBeGreaterOrEqualToMaxId();
    error CrowdFunding__TransferFailed();
    error CrowdFunding__offsetOutOfBounds();
    /* -------------------------------------------------------------------------- */
    /*                                  Type Declarations                         */
    /* -------------------------------------------------------------------------- */
    /**
     * @dev deadline 死线需要校验时间,不能比当前还早
     * @dev The deadline must be validated and cannot be earlier than the current time
     * @dev title 这里string类型要控制长度
     * @dev The title string length should be limited in 64bytes
     * @dev description 这里string类型要控制长度
     * @dev The description string length should be limited in 256bytes
     * @dev donations donators 这里直接存动态数组而不是mapping,避免太过复杂
     * @dev donations and donators are stored as dynamic arrays instead of mappings to avoid complexity
     */

    struct Campaign {
        address owner;
        uint256 deadline;
        uint256 targetInEthWei;
        uint256 amountCollectedInEthWei;
        string title;
        string description;
        string heroImageCID;
        uint256[] donations;
        address[] donators;
    }

    /* -------------------------------------------------------------------------- */
    /*                                  State Variables                           */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice 用于存储所有活动
     * @notice ir stores all campaigns
     */
    mapping(uint256 => Campaign) private sCampaigns;
    /**
     * @notice 记录当前id,也就是目前的最大id
     * @notice it records current id number, it's also the biggest id for now
     * @notice 此ID仅在创建合同时使用，创建后自动递增（创建前不关联任何活动）
     * @notice this ID is used for contract creation and auto-increments afterwards
     *         (not associated with any campaign before creation)
     */
    uint256 public sIdOfCampaign;

    /* -------------------------------------------------------------------------- */
    /*                                  Events                                    */
    /* -------------------------------------------------------------------------- */
    event CrowdFundingCreated(uint256 indexed idOfCampaign);

    /* -------------------------------------------------------------------------- */
    /*                                  Modifiers                                 */
    /* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                  Functions                                 */
    /* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                  Constructor                               */
    /* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                  Receive Function                          */
    /* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                  Fallback Function                         */
    /* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                  External Functions                        */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice 该函数用于创建活动
     * @notice this function creates a new campaign
     *
     * @dev 创建成功后emit一个事件:CrowdFundingCreated,方便前端调用
     * @dev after creating a new campaign successfully, emit an event for frontend interaction
     */
    function createCampaign(
        address _owner,
        string memory _title,
        string memory _description,
        string memory _heroImageCID,
        uint256 _deadline,
        uint256 _targetInEthWei
    ) public {
        _deadlineShouldBeInFuture(_deadline);
        _titleLengthCantExceeded64Bytes(_title);
        _descriptionCantExceeded256Bytes(_description);

        Campaign storage campaign = sCampaigns[sIdOfCampaign];

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.heroImageCID = _heroImageCID;
        campaign.deadline = _deadline;
        campaign.targetInEthWei = _targetInEthWei;

        sIdOfCampaign++;

        emit CrowdFundingCreated(uint256(sIdOfCampaign - 1));
    }
    /**
     * @notice 该函数用于捐献金额给指定活动
     * @notice this function allows donating to a specific campaign
     * @param  _id 查询id需要小于当前最大id,否则不能查询
     * @param  _id The campaign id must be less than current max id
     * @dev 转账失败的情况下要revert一个错误CrowdFunding__TransferFailed
     * @dev Reverts with CrowdFunding__TransferFailed if transfer fails
     */

    function donateToCampaign(uint256 _id) external payable {
        _idShouldNotBeGreaterOrEqualToMaxId(_id);

        uint256 amount = msg.value;

        Campaign storage campaign = sCampaigns[_id];

        _deadlineShouldBeInFuture(campaign.deadline);

        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        (bool sent,) = payable(campaign.owner).call{value: amount}("");
        if (!sent) {
            revert CrowdFunding__TransferFailed();
        }

        campaign.amountCollectedInEthWei += amount;
    }

    /* -------------------------------------------------------------------------- */
    /*                                Public Functions                            */
    /* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Internal Functions                          */
    /* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Private Functions                           */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice 该函数用于检测id是否超过最大值
     * @notice checks if the param id greater or equal to the current maximum id(sIdOfCampaign)
     */
    function _idShouldNotBeGreaterOrEqualToMaxId(uint256 _id) private view {
        if (_id >= sIdOfCampaign) {
            revert CrowdFunding__idShouldNotBeGreaterOrEqualToMaxId();
        }
    }

    /**
     * @notice 该函数用于检测死线是否位于未来
     * @notice checks if the deadline is set to a future timestamp
     */
    function _deadlineShouldBeInFuture(uint256 _deadline) private view {
        if (_deadline <= block.timestamp) {
            revert CrowdFunding__DeadlineShouldBeInFuture();
        }
    }

    /**
     * @notice 该函数用于检测title是否超过64bytes
     * @notice checks if the title length exceeds 64 bytes
     * @dev 我们不希望用户输入过多内容
     * @dev we want to prevent excessively long titles
     */
    function _titleLengthCantExceeded64Bytes(string memory _title) private pure {
        if (bytes(_title).length > 64) {
            revert CrowdFunding__TitleLengthExceeded64Bytes();
        }
    }

    /**
     * @notice 该函数用于检测description是否超过256bytes
     * @notice checks if the description length exceeds 256 bytes
     * @dev 我们不希望用户输入过多内容
     * @dev we want to prevent excessively long descriptions
     */
    function _descriptionCantExceeded256Bytes(string memory _description) private pure {
        if (bytes(_description).length > 256) {
            revert CrowdFunding__DescriptionExceeded256Bytes();
        }
    }

    /* -------------------------------------------------------------------------- */
    /*                                  View & Pure Functions                     */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice 该函数用于返回（单个）活动当前的捐献者和捐献金额信息
     * @notice returns the donators and donation amounts for a single campaign
     *
     * @return sCampaigns[_id].donators 返回对应的捐献者 returns the corresponding donators
     * @return sCampaigns[_id].donations 返回对应的捐献金额 returns the corresponding donations
     */
    function getDonatorsAndDonations(uint256 _id) public view returns (address[] memory, uint256[] memory) {
        _idShouldNotBeGreaterOrEqualToMaxId(_id);
        return (sCampaigns[_id].donators, sCampaigns[_id].donations);
    }

    /**
     * @notice 该函数用于返回（单个）活动的所有信息
     * @notice returns all information of a single campaign
     *
     * @return sCampaigns[_id] 对应的活动 returns the corresponding campaign
     * @dev struct内存在多个动态数组，该函数返回单个campaign，减少读取压力
     * @dev returns a single campaign to reduce read pressure since it contains dynamic arrays
     */
    function getCampaign(uint256 _id) public view returns (Campaign memory) {
        _idShouldNotBeGreaterOrEqualToMaxId(_id);
        return sCampaigns[_id];
    }

    /**
     * @notice 该函数用于返回（多个）活动的所有信息
     * @notice returns all information of multiple campaigns
     * @param offset 跳过的活动数目
     * @param offset number of campaigns to skip
     * @param limit 限制的最大查询数量，超过的话只返回最大数量
     * @param limit number of campaigns to limit
     * @return campaigns 对应的活动 returns corresponding campaign
     * @dev 优化查询，增加分页查询和返回限制，以减少读取压力
     * @dev returns limited number of campaigns to reduce read pressure since it contains dynamic arrays
     */
    function getCampaignsPaginated(uint256 offset, uint256 limit) public view returns (Campaign[] memory) {
        if (offset > sIdOfCampaign) revert CrowdFunding__offsetOutOfBounds();

        uint256 remaining = sIdOfCampaign - offset;
        // 增减返回限制，减少压力
        uint256 size = remaining < limit ? remaining : limit;

        Campaign[] memory campaigns = new Campaign[](size);

        for (uint256 i = 0; i < size; i++) {
            campaigns[i] = sCampaigns[offset + i];
        }

        return campaigns;
    }

    /**
     * @notice 该函数用于返回所有活动的所有信息
     * @notice returns all information of all campaigns
     * @return allCampaigns 合同内的所有活动 all campaigns in the contract
     * @dev 要是数据小，或者就想一次性返回全部，那就直接跑全部返回吧
     * @dev if data is small, or frontend wants all at once, try this and return all campaigns
     */
    function getAllCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](sIdOfCampaign);
        for (uint256 i = 0; i < sIdOfCampaign; i++) {
            Campaign storage item = sCampaigns[i];
            allCampaigns[i] = item;
        }

        return allCampaigns;
    }
}
