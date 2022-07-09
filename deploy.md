# Deploy script

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


