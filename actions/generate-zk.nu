
const actions_dir = path self .
let project_root = $actions_dir | path dirname
cd $project_root

do {
	cd circuits

	nargo build

	rm ./target/vk ./target/vk_hash
	bb write_vk -b "./target/noir.json" -o ./target --oracle_hash keccak

	rm ./target/Verifier.sol
	bb write_solidity_verifier -k $"./target/vk" -o ./target/Verifier.sol
}

cp circuits/target/Verifier.sol contracts/src/from-circuits/Verifier.sol

# nargo execute --pedantic-solving witness

# # bb prove -b $"./target/($name).json" -w ./target/witness.gz --oracle_hash keccak --output_format bytes_and_fields -o ./target
# (bb prove -b "./target/noir.json"
# 	-w ./target/witness.gz
# 	--oracle_hash keccak
# 	-o ./target)

# # sanity check
# bb verify -k ./target/vk -p ./target/proof -i ./target/public_inputs --oracle_hash keccak

# copy smart contract
# cp ./target/Verifier.sol ../contracts/src/from-circuits/Verifier.sol
