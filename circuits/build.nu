nargo execute

bb write_vk -b "./target/noir.json" -o ./target --oracle_hash keccak

bb write_solidity_verifier -k $"./target/vk" -o ./target/Verifier.sol

nargo execute --pedantic-solving witness

# bb prove -b $"./target/($name).json" -w ./target/witness.gz --oracle_hash keccak --output_format bytes_and_fields -o ./target
(bb prove -b "./target/noir.json"
	-w ./target/witness.gz
	--oracle_hash keccak
	-o ./target)

# sanity check
bb verify -k ./target/vk -p ./target/proof -i ./target/public_inputs --oracle_hash keccak

# copy smart contract

let $proof_hex = "0x" + (open ./target/proof | encode hex)
let $public_inputs_hex = "0x" + (open ./target/public_inputs | encode hex)

# anvil --code-size-limit=400000

let $deploy_info = (forge create src/Counter:HonkVerifier
  --rpc-url "127.0.0.1:8545"
  --private-key "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
  --broadcast
  --json)

# VERIFIER_ADDRESS=$(echo $DEPLOY_INFO | jq -r '.deployedTo')

# # Call the verifier contract with our proof.
# cast call "$VERIFIER_ADDRESS" "verify(bytes, bytes32[])(bool)" "$PROOF_HEX" "$PUBLIC_INPUTS_HEX"
