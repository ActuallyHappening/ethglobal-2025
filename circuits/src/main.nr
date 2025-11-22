mod addr;
use addr::Address;

mod uint;
use uint::uint256;


fn main(address: pub [u8; 20], amount: [u8; 32], whitelist: [[u8; 20]; 1], max_amount: [u8; 32]) {
	let amount = uint256::new(amount);
	let max_amount = uint256::new(max_amount);
    assert(amount.lt(max_amount));
    assert(whitelist.any(|addr| address == addr));
}

#[test]
fn test_main() {
	main(Address::whitelisted().inner, uint256::ethp5().limbs, [Address::whitelisted().inner], uint256::eth1().limbs)
    // main(
    //     // Address::from_str("0x404a1afd3D17ec2e7bC1b5B52E9E0C7FCEE532B2"),
    //     Address::new([
    //         64u8, 74, 26, 253, 61, 23, 236, 46, 123, 193, 181, 181, 46, 158, 12, 127, 206, 229, 50,
    //         178,
    //     ]),
    //     gwei(500), // 0.5 ETH
    //     [Address::new([
    //         64u8, 74, 26, 253, 61, 23, 236, 46, 123, 193, 181, 181, 46, 158, 12, 127, 206, 229, 50,
    //         178,
    //     ])],
    //     gwei(1000), // 1 ETH
    // )

    // Uncomment to make test fail
    // main(1, 1);
}
