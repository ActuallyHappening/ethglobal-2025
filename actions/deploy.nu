# All logic to generate ZK proof given master_params.toml

source ../env.nu

# cd to root of project
const scripts_dir = path self .
cd $scripts_dir
cd ..

do {
	cd contracts

	print "Deploying MasterContract" $env.MASTER_PK $env.ORG_PK

	forge build

	let rpc_url = "localhost:8545"

	(forge script script/Deploy.s.sol:DeployScript
    --rpc-url $rpc_url)

	let output = (
	forge script script/Deploy.s.sol:DeployScript
    --rpc-url $rpc_url
	--broadcast
	)

	# extract string between markers 📡
	let contract_address = $output | split row '📡' | get 1 | str trim
	print "Deployed master contract at: $contract_address"
	# let $contract_address = input "Contract Address: "

	(forge verify-contract -vvvvv $"($contract_address)" src/MasterContract.sol:MasterContract
	--chain-id 48898
	--verifier sourcify
	--verifier-url https://sourcify.dev/server)
}
