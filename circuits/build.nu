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
cp ./target/Verifier.sol ../contracts/from-circuits/Verifier.sol