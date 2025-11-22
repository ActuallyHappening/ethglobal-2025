use alloy_primitives::Address;
use clap::Parser;
use ystd::prelude::*;

#[derive(Parser)]
#[command(version, about, long_about = None)]
struct Cli {
    #[arg()]
    master_params_toml: Utf8PathBuf,
}

struct Params {
    whitelist: Vec<Address>,
    max_amount: f64,
}

#[tokio::main]
async fn main() -> color_eyre::Result<()> {
    tracing_subscriber::fmt::init();
    color_eyre::install()?;

    let cli = Cli::parse();
    
    

    Ok(())
}
