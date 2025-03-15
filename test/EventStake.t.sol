// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/EventStake.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockTicketNFT is ERC721 {
    constructor() ERC721("MockTicket", "TKT") {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}

contract MockERC20 is ERC20 {
    constructor() ERC20("MockToken", "MTK") {
        _mint(msg.sender, 1e18); // Mint initial tokens
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract EventStakeTest is Test {
    EventStake eventStake;
    MockTicketNFT ticketNFT;
    MockERC20 stakeToken;

    address owner = address(1);
    address attendee = address(2);
    uint256 ticketId = 1001;
    uint256 stakeAmount = 1e18; // 1 MTK
    uint256 deadline = block.timestamp + 1 days;

    function setUp() public {
        vm.startPrank(owner);

        // Deploy mock contracts
        ticketNFT = new MockTicketNFT();
        stakeToken = new MockERC20();

        // Deploy EventStake contract
        eventStake = new EventStake(address(ticketNFT), address(stakeToken), deadline);

        // Mint ticket to attendee
        ticketNFT.mint(attendee, ticketId);

        // Mint and approve stake tokens
        stakeToken.mint(attendee, stakeAmount);
        vm.stopPrank();
    }

    function testStake() public {
        vm.startPrank(attendee);

        // Approve and stake
        stakeToken.approve(address(eventStake), stakeAmount);
        eventStake.stake(ticketId, stakeAmount);

        // Check stake mapping
        (address staker, uint256 amount, bool claimed) = eventStake.stakes(ticketId);
        assertEq(staker, attendee);
        assertEq(amount, stakeAmount);
        assertFalse(claimed);

        vm.stopPrank();
    }

    function testRefundStake() public {
        // Stake first
        testStake();

        // Refund as owner
        vm.prank(owner);
        eventStake.refundStake(ticketId);

        // Check if stake was refunded
        (, , bool claimed) = eventStake.stakes(ticketId);
        assertTrue(claimed);
    }

    function testCannotRefundTwice() public {
        testRefundStake();

        vm.prank(owner);
        vm.expectRevert("Already refunded");
        eventStake.refundStake(ticketId);
    }

    function testWithdrawAfterDeadline() public {
        testStake();

        // Travel past deadline
        vm.warp(deadline + 1);

        vm.prank(attendee);
        eventStake.withdrawAfterDeadline(ticketId);

        (, , bool claimed) = eventStake.stakes(ticketId);
        assertTrue(claimed);
    }

    function testCannotWithdrawBeforeDeadline() public {
        testStake();

        vm.prank(attendee);
        vm.expectRevert("Deadline not reached");
        eventStake.withdrawAfterDeadline(ticketId);
    }
}
