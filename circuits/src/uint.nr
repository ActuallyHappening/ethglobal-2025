
// #[derive(PartialOrd, Ord)]
// [1, 0, ...] == 1
// [1, 1, ...] == 256 + 1
pub struct uint256 {
    pub limbs: [u8; 32],
}

impl uint256 {
	pub fn new(limbs: [u8; 32]) -> Self {
		Self { limbs }
	}

	pub fn lt(self, rhs: uint256) -> bool {
		let mut counter_example = false;
		for irev in 0..32 {
			let i = 31 - irev;
			if self.limbs[i] > rhs.limbs[i] {
				counter_example = true;
			}
		}
		counter_example
	}
}

impl uint256 {
	/// 1 ETH
	pub fn eth1() -> Self {
		uint256::new([0u8, 0, 100, 167, 179, 182, 224, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
	}

	/// 0.5 ETH
	pub fn ethp5() -> Self {
		uint256::new([0u8, 0, 178, 211, 89, 91, 240, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
	}
}
