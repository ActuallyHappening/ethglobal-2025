#[derive(Eq)]
pub struct Address {
    inner: [u8; 20],
}

impl Address {
    pub fn new(inner: [u8; 20]) -> Self {
        Address { inner }
    }
}

impl Address {
    pub fn whitelisted() -> Self {
        Address::new([
            64, 74, 26, 253, 61, 23, 236, 46, 123, 193, 181, 181, 46, 158, 12, 127, 206, 229, 50,
            178,
        ])
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
