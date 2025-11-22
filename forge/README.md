```nu
forge build
forge test
forge fmt
forge snapshot
anvil
```

```nu
# deploy

(forge script script/Counter.s.sol:CounterScript
    --rpc-url garfield_testnet
    --account testnetKey
    --broadcast)

let $contract_address = "0xdb565779c80982f016a79b02a6cb15d934a417e1"

(cast call $contract_address "number()"
    --rpc-url https://garfield-testnet.zircuit.com)

(cast send $contract_address "setNumber(uint256)" 42
    --rpc-url https://garfield-testnet.zircuit.com
    --account testnetKey)

(forge verify-contract $contract_address <SOURCE_FILE>:<CONTRACT_NAME>
--chain-id 48898
--verifier sourcify
--verifier-url https://sourcify.dev/server)
```
