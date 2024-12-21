// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearnToEarnStreaming {
    address public owner;
    uint256 public contentPrice = 1 ether; // Price per content in Wei
    
    struct Content {
        uint256 id;
        address creator;
        string title;
        string url;
        uint256 rewardPool;
    }

    struct User {
        uint256 earnedRewards;
        mapping(uint256 => bool) completedContent;
    }

    uint256 private contentCounter;
    mapping(uint256 => Content) public contents;
    mapping(address => User) public users;

    event ContentCreated(uint256 indexed id, address indexed creator, string title);
    event ContentCompleted(address indexed user, uint256 indexed contentId, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createContent(string memory title, string memory url, uint256 rewardPool) external payable {
        require(msg.value == rewardPool, "Reward pool must match the sent value");

        contentCounter++;
        contents[contentCounter] = Content({
            id: contentCounter,
            creator: msg.sender,
            title: title,
            url: url,
            rewardPool: rewardPool
        });

        emit ContentCreated(contentCounter, msg.sender, title);
    }

    function completeContent(uint256 contentId) external {
        Content storage content = contents[contentId];
        require(content.rewardPool > 0, "Content reward pool is empty");
        require(!users[msg.sender].completedContent[contentId], "Content already completed");

        uint256 reward = content.rewardPool / 10; // 10% of the reward pool as reward
        content.rewardPool -= reward;

        users[msg.sender].earnedRewards += reward;
        users[msg.sender].completedContent[contentId] = true;

        emit ContentCompleted(msg.sender, contentId, reward);
    }

    function withdrawRewards() external {
        uint256 rewards = users[msg.sender].earnedRewards;
        require(rewards > 0, "No rewards to withdraw");

        users[msg.sender].earnedRewards = 0;
        payable(msg.sender).transfer(rewards);
    }

    function updateContentPrice(uint256 newPrice) external onlyOwner {
        contentPrice = newPrice;
    }

    function withdrawBalance() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}
