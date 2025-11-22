use alloy_primitives::Address;

fn main() -> color_eyre::Result<()> {
    let mut rl = rustyline::DefaultEditor::new()?;

    let addr = rl.readline("Address: ")?;
    let addr = Address::parse_checksummed(addr, None)?;
    let addr = addr.0.0;
    // [64, ...]
    let addr = format!("{:?}", addr);

    println!("Addr: {:?}", addr);

    Ok(())
}
