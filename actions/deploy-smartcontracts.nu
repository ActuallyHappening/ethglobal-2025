# All logic to generate ZK proof given master_params.toml

source ../env.nu

# cd to root of project
const scripts_dir = path self .
cd $scripts_dir
cd ..

# let local = (input "Local? (Y/n): ") != "n"
let local = false

do {
	cd contracts

	print "Deploying MasterContract" $env.MASTER_PK $env.ORG_PK

	forge build

	# let rpc_url = if $local { "localhost:8545" } else { "garfield_testnet" }
	let rpc_url = "amoy_testnet"

	# Uncomment for better debugging
	# forge script script/Deploy.s.sol:DeployScript --rpc-url $rpc_url

	let output = (
		forge script script/Deploy.s.sol:DeployScript
	    --rpc-url $rpc_url
		--broadcast
	)

	# extract string between markers 📡
	let master_addr = $output | split row '📡' | get 1 | str trim
	print $"Deployed master contract at: ($master_addr)"
	let eip7702_addr = $output | split row '🛝' | get 1 | str trim
	print $"Deployed eip7702 contract at: ($eip7702_addr)"

	if not $local {
		(forge verify-contract -vvvvv $"($master_addr)" src/MasterContract.sol:MasterContract
		--chain-id 80002
		--verifier sourcify
		--verifier-url https://sourcify.dev/server)

		(forge verify-contract -vvvvv $"($eip7702_addr)" src/EIP7702.sol:EIP7702
		--chain-id 80002
		--verifier sourcify
		--verifier-url https://sourcify.dev/server)

		# print $"Verified master contract: https://explorer.garfield-testnet.zircuit.com/address/($master_addr)"
		# print $"Verified EIP7702 contract: https://explorer.garfield-testnet.zircuit.com/address/($eip7702_addr)"
		print $"Verified master contract: https://amoy.polygonscan.com/address/($master_addr)"
		print $"Verified EIP7702 contract: https://amoy.polygonscan.com/address/($eip7702_addr)"
	}
}
