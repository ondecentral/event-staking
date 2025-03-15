// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/EventStake.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Stake Token", "STK") {
        _mint(msg.sender, 1000000 * 10**18); // Mint 1M tokens
    }
}

contract MockERC721 is ERC721 {
    uint256 private _tokenIdCounter;

    constructor() ERC721("Event Ticket", "TCKT") {}

    function mint(address to) public {
        _tokenIdCounter++;
        _safeMint(to, _tokenIdCounter);
    }
}

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy mock tokens
        MockERC20 stakeToken = new MockERC20();
        MockERC721 ticketNFT = new MockERC721();

        // Mint some test NFTs
        for(uint i = 0; i < 5; i++) {
            ticketNFT.mint(vm.addr(deployerPrivateKey));
        }

        // Set deadline to 30 days from now
        uint256 deadline = block.timestamp + 30 days;

        // Deploy EventStake contract
        EventStake eventStake = new EventStake(
            address(ticketNFT),
            address(stakeToken),
            deadline
        );

        // Log the deployed addresses
        console.log("Deployed contracts:");
        console.log("Stake Token (ERC20):", address(stakeToken));
        console.log("Ticket NFT (ERC721):", address(ticketNFT));
        console.log("EventStake:", address(eventStake));

        vm.stopBroadcast();
    }
}
