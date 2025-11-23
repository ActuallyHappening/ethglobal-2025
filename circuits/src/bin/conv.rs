use std::str::FromStr;
use ystd::prelude::*;

use alloy_primitives::Address;
use alloy_primitives::ruint::aliases::U256;
use clap::Parser;

#[derive(Parser)]
#[command(version, about, long_about = None)]
struct Cli {
    #[clap(subcommand)]
    command: Conv,
}

#[derive(clap::Subcommand)]
enum Conv {
    /// cargo r --bin conv num-to-bytes $"(500 * 10 ** 15)"
    NumToBytes { num: String },
    /// cargo r --bin conv address-to-bytes 0xA7E34d70B0E77fD5E1364705f727280691fF8B9a
    AddressToBytes { addr: Address },
}

#[tokio::main]
async fn main() -> color_eyre::Result<()> {
    tracing_subscriber::fmt::init();
    color_eyre::install()?;

    let cli = Cli::parse();

    match cli.command {
        Conv::NumToBytes { num } => {
            let num = U256::from_str(&num)?;
            let num = num.as_le_slice();
            info!(?num);
        }
        Conv::AddressToBytes { addr } => {
            let addr = addr.0.0;
            info!(?addr);
        }
    }

    Ok(())
}
