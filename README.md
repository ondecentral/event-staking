# Event Staking

To deploy your contract to Lisk, you'll just need:

* Your private key from your wallet (MetaMask) - Must include "0x" prefix
* Some test LSK tokens from the Lisk Sepolia testnet faucet
* Then you can deploy using

```zsh
source .env
forge script script/Deploy.s.sol:DeployScript --rpc-url lisk_testnet --broadcast --verifier blockscout --verify
```

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

### How to use forge while developing

```zsh
forge build
forge test
```



## Usage

Deployed Contracts on Lisk Sepolia

1. Stake Token (ERC20): 0x5feE5A1e9224c93EFEE8583834371383e7948378
2. Ticket NFT (ERC721): 0xEaf2d6Ee4690754cd84cfe2eE4824a7d513C6DB8
3. EventStake: 0xa8C07684b9F54BE695a931662f705250b241F75b


### Build

```shell
$ forge build
```



### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

This enhanced deployment script:

1. Deploys mock ERC20 (Stake Token) and ERC721 (Event Ticket) contracts
2. Mints 1 million stake tokens to the deployer
3. Mints 5 test NFT tickets to the deployer
4. Deploys the EventStake contract with the token addresses
5. Logs all deployed contract addresses

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
