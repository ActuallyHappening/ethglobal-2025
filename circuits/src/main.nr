use crate::addr::Address;

type uint256 = dep::bignum::U256;

fn main(address: pub Address, amount: pub uint256, whitelist: [Address; 1], max_amount: uint256) {
    assert(amount < max_amount);
    assert(whitelist.any(|addr| address == addr));
}

fn gwei(amount: u64) {
    // 0x404a1afd3D17ec2e7bC1b5B52E9E0C7FCEE532B2
    uint256::from(amount).__pow(uint256::from(15))
}

#[test]
fn test_main() {
    main(
        Address::from_str("0x404a1afd3D17ec2e7bC1b5B52E9E0C7FCEE532B2"),
        gwei(500), // 0.5 ETH
        [Address::from_str("0x404a1afd3D17ec2e7bC1b5B52E9E0C7FCEE532B2")],
        gwei(1000), // 1 ETH
    )

    // Uncomment to make test fail
    // main(1, 1);
}
