forge build

# deploy

(forge script script/Counter.s.sol:CounterScript
    --rpc-url garfield_testnet
    --account testnetKey
    --broadcast)

export def verify [contract_address: string] {
	# let $contract_address = "0xdb565779c80982f016a79b02a6cb15d934a417e1"
# let $contract_address = "0x4970Eb4763e1136f68f754d645b042773fF03616"

(cast call $contract_address "number()"
    --rpc-url https://garfield-testnet.zircuit.com)

(cast send $contract_address "setNumber(uint256)" 42
    --rpc-url https://garfield-testnet.zircuit.com
    --account testnetKey)

(cast call $contract_address "number()"
    --rpc-url https://garfield-testnet.zircuit.com)

(forge verify-contract -vvvvv $"($contract_address)" src/Counter.sol:Counter
--chain-id 48898
--verifier sourcify
--verifier-url https://sourcify.dev/server)
}
