mod addr;
use addr::Address;
use std::ops::Mul;
// use std::ops::{Ord, PartialOrd};

// #[derive(PartialOrd, Ord)]
// [1, 0, ...] == 1
// [1, 1, ...] == 9
struct uint256 {
    limbs: [u8; 32],
}

impl uint256 {
	pub fn new(limbs: [u8; 32]) -> Self {
		Self { limbs }
	}

	pub fn lt(self, rhs: uint256) -> bool {
		for irev in 0..32 {
			i = 31 - irev
			if self.limbs[i] > rhs.limbs[i] {
				return true;
			}
		}
		false
	}

	/// 1 ETH
	pub fn eth1() -> Self {
		[0, 0, 100, 167, 179, 182, 224, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	}

	/// 0.5 ETH
	pub fn ethp5() -> Self {
		[0, 0, 178, 211, 89, 91, 240, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	}
}

fn main(address: pub Address, amount: [u8; 32], whitelist: [Address; 1], max_amount: [u8; 32]) {
	let amount = uint256::new(amount);
	let max_amount = uint256::new(max_amount);
    assert(amount.lt(max_amount));
    assert(whitelist.any(|addr| address == addr));
}

#[test]
fn test_main() {
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
