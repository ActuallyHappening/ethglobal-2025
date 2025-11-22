# All logic to generate ZK proof given master_params.toml

source ../env.nu

# cd to root of project
const scripts_dir = path self .
cd $scripts_dir
cd ..



do {
	cd contracts

	print "Deploying MasterContract"
	(
	forge script script/MasterContract.s.sol:MasterScript
    --rpc-url garfield_testnet
    --private-key $env.MASTER_PK
    # --account testnetKey
	--broadcast
	)

	let $contract_address = input "Contract Address: "

	(forge verify-contract -vvvvv $"($contract_address)" src/MasterContract.sol:MasterContract
	--chain-id 48898
	--verifier sourcify
	--verifier-url https://sourcify.dev/server)
}
