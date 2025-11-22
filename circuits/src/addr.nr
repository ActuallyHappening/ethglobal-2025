#[derive(Eq)]
pub struct Address {
    pub inner: [u8; 20],
}

impl Address {
    pub fn new(inner: [u8; 20]) -> Self {
        Address { inner }
    }
}

impl Address {
	/// 0xA7E34d70B0E77fD5E1364705f727280691fF8B9a
	/// hackathon primary
    pub fn whitelisted() -> Self {
        Address::new([167u8, 227, 77, 112, 176, 231, 127, 213, 225, 54, 71, 5, 247, 39, 40, 6, 145, 255, 139, 154])
    }

    /// hackathon secondary
    /// 0x404a1afd3D17ec2e7bC1b5B52E9E0C7FCEE532B2
    pub fn abitrary() -> Self {
		Address::new([64u8, 74, 26, 253, 61, 23, 236, 46, 123, 193, 181, 181, 46, 158, 12, 127, 206, 229, 50, 178])
    }
}

// impl Address {
//     pub fn from_str(str: pub str<22>) -> Self {
//         // ignores the first
//         let mut inner = [0; 20];
//         for i2 in 1..10 {
//             let i = i2 * 2;
//             inner[i] = str.from_hex_to_uint_slice(i, i + 1);
//         }
//         Address { inner: inner }
//     }
// }
