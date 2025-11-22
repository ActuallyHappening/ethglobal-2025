use crate::addr::Address;

fn main(address: pub Address, amount: pub u256, whitelist: [Address; 1], max_amount: u256) {
    assert(amount < max_amount);
    assert(whitelist.any(|addr| address == addr));
}

#[test]
fn test_main() {
    // main()

    // Uncomment to make test fail
    // main(1, 1);
}
