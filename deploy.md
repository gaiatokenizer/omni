# Deploy script

## Deploy NFT
```bash
$source .env
$forge create --legacy --rpc-url $RPC_URL --private-key $PRIVATE_KEY src/omni_item_nft.sol:OmniItem
```

```bash
$forge flatten --output src/omni_item_nft.flattened.sol src/omni_item_nft.sol
```

```bash
$forge verify-contract --chain-id 4 --num-of-optimizations 200 --compiler-version v0.8.13+commit.abaa5c0e 0x5fb397d2b437e0f16d790dc117d2ebbde8a81be6 src/omni_item_nft.flattened.sol:OmniItem $ETHERSCAN_KEY
```

## Deploy Batch
```bash
$source .env
$forge create --legacy --rpc-url $RPC_URL --private-key $PRIVATE_KEY src/omni_batch_erc20.sol:OmniRecycle --constructor-args 0xa59B1372dB4dfd4eaCf595d706993a0A1C74667a 0x7284ee38B6d70E4aA6903e0276cA6Ce74118BD7a "2000222" --etherscan-api-key $ETHERSCAN_KEY --verify
```

```bash
$forge flatten --output src/omni_batch_erc20.flattened.sol src/omni_batch_erc20.sol
```

```bash
$forge verify-contract --chain-id 4 --num-of-optimizations 200 --compiler-version v0.8.13+commit.abaa5c0e 0x5fb397d2b437e0f16d790dc117d2ebbde8a81be6 src/omni_batch_erc20.flattened.sol:OmniRecycle $ETHERSCAN_KEY
```


## Deploy Factory

```bash
$forge flatten --output src/omni_batch_erc20.flattened.sol src/omni_batch_erc20.sol
```

```bash
$source .env
$forge create --legacy --rpc-url $RPC_URL --private-key $PRIVATE_KEY src/omni_batch_erc20.flattened.sol:OmniRecycleFactory --etherscan-api-key $ETHERSCAN_KEY --verify

$forge verify-contract --chain-id 4 --num-of-optimizations 200 --compiler-version v0.8.13+commit.abaa5c0e 0xec622715b9341e8fa9e981b68db36f40aaa130b0 src/omni_batch_erc20.flattened.sol:OmniRecycleFactory $ETHERSCAN_KEY