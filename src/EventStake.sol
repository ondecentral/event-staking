// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EventStake is Ownable {
    struct Stake {
        address attendee;
        uint256 amount;
        bool claimed;
    }

    IERC721 public ticketNFT; // Optional: Use NFT for ticket verification
    IERC20 public stakeToken; // Optional: Use ERC-20 for staking
    uint256 public deadline;
    
    mapping(uint256 => Stake) public stakes; // ticketId -> Stake

    event Staked(address indexed user, uint256 indexed ticketId, uint256 amount);
    event Refunded(address indexed user, uint256 indexed ticketId);
    event Withdrawn(address indexed user, uint256 indexed ticketId);

    constructor(address _ticketNFT, address _stakeToken, uint256 _deadline) Ownable(msg.sender) {
        ticketNFT = IERC721(_ticketNFT);
        stakeToken = IERC20(_stakeToken);
        deadline = _deadline;
    }

    function stake(uint256 ticketId, uint256 amount) external {
        require(ticketNFT.ownerOf(ticketId) == msg.sender, "Not ticket owner");
        require(stakes[ticketId].amount == 0, "Already staked");

        stakeToken.transferFrom(msg.sender, address(this), amount);
        stakes[ticketId] = Stake(msg.sender, amount, false);

        emit Staked(msg.sender, ticketId, amount);
    }

    function refundStake(uint256 ticketId) external onlyOwner {
        Stake storage stakeData = stakes[ticketId];
        require(stakeData.amount > 0, "No stake found");
        require(!stakeData.claimed, "Already refunded");

        stakeToken.transfer(stakeData.attendee, stakeData.amount);
        stakeData.claimed = true;

        emit Refunded(stakeData.attendee, ticketId);
    }

    function withdrawAfterDeadline(uint256 ticketId) external {
        require(block.timestamp > deadline, "Deadline not reached");
        Stake storage stakeData = stakes[ticketId];
        require(stakeData.attendee == msg.sender, "Not ticket owner");
        require(!stakeData.claimed, "Already processed");

        stakeToken.transfer(stakeData.attendee, stakeData.amount);
        stakeData.claimed = true;

        emit Withdrawn(stakeData.attendee, ticketId);
    }
}
