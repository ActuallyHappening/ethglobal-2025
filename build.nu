# Deploy contracts/MasterContract.sol

do {
	cd contracts

	print "Deploying MasterContract"
	(
	forge script script/MasterContract.s.sol:MasterScript
    --rpc-url garfield_testnet
    --account testnetKey
	--broadcast
	)

	let $contract_address = input "Contract Address: "

	(forge verify-contract -vvvvv $"($contract_address)" src/MasterContract.sol:MasterContract
	--chain-id 48898
	--verifier sourcify
	--verifier-url https://sourcify.dev/server)
}
