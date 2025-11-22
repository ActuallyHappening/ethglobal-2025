pub struct Address {
    inner: [u8; 20],
}

impl std::ops::Eq for Address {
    fn eq(self, rhs: Address) -> bool {
        let mut isEqual = true;
        for i in 0..19 {
            if self[i] != rhs[i] {
                isEqual = false
            }
        }
        isEqual
    }
}
