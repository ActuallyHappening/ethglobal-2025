use std::string;

#[derive(Eq)]
pub struct Address {
    inner: [u8; 20],
}

// impl std::ops::Eq for Address {
//     fn eq(self, rhs: Address) -> bool {
//         let mut isEqual = true;
//         for i in 0..19 {
//             if self.inner[i] != rhs.inner[i] {
//                 isEqual = false
//             }
//         }
//         isEqual
//     }
// }

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
