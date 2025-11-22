use std::str::FromStr;
use ystd::prelude::*;

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
    NumToBytes { num: String },
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
    }

    Ok(())
}
