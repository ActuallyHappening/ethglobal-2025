mod addr;
use dep::bignum::U256;
use addr::Address;
use std::ops::Mul;

type uint256 = U256;
// use dep::bignum::BigNum;
// use dep::bignum::fields::U256::U256Params;

// // Define (compile-time) BigNum type
// // number of limbs, number of bits of modulus, parameter set
// // implement the BigNum trait for the custom bignum type
// #[derive_bignum(3, 257, quote {U256_PARAMS})]
// pub struct U256 {
//     limbs: [u128; 3],
// }

fn main(address: pub Address, amount: pub uint256, whitelist: [Address; 1], max_amount: uint256) {
    assert(amount < max_amount);
    assert(whitelist.any(|addr| address == addr));
}

fn gwei(amount: u64) -> uint256 {
    // 0x404a1afd3D17ec2e7bC1b5B52E9E0C7FCEE532B2
    let mut num = uint256::from(amount as Field);
    for _ in 0..15 {
        num = num.mul(num);
    }
    num
}

#[test]
fn test_main() {
    main(
        // Address::from_str("0x404a1afd3D17ec2e7bC1b5B52E9E0C7FCEE532B2"),
        Address::new([
            64u8, 74, 26, 253, 61, 23, 236, 46, 123, 193, 181, 181, 46, 158, 12, 127, 206, 229, 50,
            178,
        ]),
        gwei(500), // 0.5 ETH
        [Address::new([
            64u8, 74, 26, 253, 61, 23, 236, 46, 123, 193, 181, 181, 46, 158, 12, 127, 206, 229, 50,
            178,
        ])],
        gwei(1000), // 1 ETH
    )

    // Uncomment to make test fail
    // main(1, 1);
}
