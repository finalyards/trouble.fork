#!/bin/bash

set -eo pipefail

if ! command -v cargo-batch &> /dev/null; then
    mkdir -p $HOME/.cargo/bin
    curl -L https://github.com/embassy-rs/cargo-batch/releases/download/batch-0.6.0/cargo-batch > $HOME/.cargo/bin/cargo-batch
    chmod +x $HOME/.cargo/bin/cargo-batch
fi

export RUSTFLAGS=-Dwarnings
export DEFMT_LOG=trace
export CARGO_NET_GIT_FETCH_WITH_CLI=true
if [[ -z "${CARGO_TARGET_DIR}" ]]; then
    export CARGO_TARGET_DIR=target_ci
fi

cargo check --release --locked --manifest-path host/Cargo.toml --no-default-features --features peripheral
cargo check --release --locked --manifest-path host/Cargo.toml --no-default-features --features central
cargo check --release --locked --manifest-path host/Cargo.toml --no-default-features --features central,scan
cargo check --release --locked --manifest-path host/Cargo.toml --no-default-features --features central,peripheral
cargo check --release --locked --manifest-path host/Cargo.toml --no-default-features --features central,peripheral,defmt
cargo check --release --locked --manifest-path host/Cargo.toml --no-default-features --features gatt,peripheral
cargo check --release --locked --manifest-path host/Cargo.toml --no-default-features --features gatt,central
cargo check --release --locked --manifest-path host/Cargo.toml --no-default-features --features gatt,peripheral,central,scan
cargo check --release --locked --manifest-path host/Cargo.toml --no-default-features --features gatt,peripheral,central,scan,security
cargo check --release --locked --manifest-path host/Cargo.toml --no-default-features --features gatt,peripheral,central,scan,controller-host-flow-control
cargo check --release --locked --manifest-path host/Cargo.toml --no-default-features --features gatt,peripheral,central,scan,controller-host-flow-control,connection-metrics,channel-metrics
cargo check --release --locked --manifest-path host/Cargo.toml --no-default-features --features gatt,peripheral,central,scan,controller-host-flow-control,connection-metrics,channel-metrics,l2cap-sdu-reassembly-optimization
cargo check --release --locked --manifest-path host/Cargo.toml --no-default-features --features gatt,peripheral,central,scan,controller-host-flow-control,connection-metrics,channel-metrics,l2cap-sdu-reassembly-optimization,connection-params-update
#cargo check --release --locked --manifest-path bt-hci-linux/Cargo.toml   # cannot be built '--locked'; gets checked via 'examples/linux'
cargo check --release --locked --manifest-path examples/nrf52/Cargo.toml --target thumbv7em-none-eabihf --features nrf52840
cargo check --release --locked --manifest-path examples/nrf52/Cargo.toml --target thumbv7em-none-eabihf --features nrf52840,security
cargo check --release --locked --manifest-path examples/nrf52/Cargo.toml --target thumbv7em-none-eabihf --features nrf52833
cargo check --release --locked --manifest-path examples/nrf52/Cargo.toml --target thumbv7em-none-eabihf --features nrf52832
cargo check --release --locked --manifest-path examples/esp32/Cargo.toml --target riscv32imc-unknown-none-elf --features esp32c3
cargo check --release --locked --manifest-path examples/serial-hci/Cargo.toml
cargo check --release --locked --manifest-path examples/linux/Cargo.toml
cargo check --release --locked --manifest-path examples/linux/Cargo.toml --features security
#cargo check --release --locked --manifest-path examples/tests/Cargo.toml   # no need to build; tests are run
cargo check --release --locked --manifest-path benchmarks/nrf-sdc/Cargo.toml --target thumbv7em-none-eabihf --features nrf52840
cargo check --release --locked --manifest-path examples/rp-pico-w/Cargo.toml --target thumbv6m-none-eabi --features skip-cyw43-firmware
cargo check --release --locked --manifest-path examples/rp-pico-2-w/Cargo.toml --target thumbv8m.main-none-eabihf --features skip-cyw43-firmware
# cargo check --release --locked --manifest-path examples/apache-nimble/Cargo.toml --target thumbv7em-none-eabihf

set -x
cargo fmt --check --manifest-path ./host/Cargo.toml
cargo clippy --manifest-path ./host/Cargo.toml --features gatt,peripheral,central
cargo test --release --locked --manifest-path ./host/Cargo.toml --lib -- --nocapture
cargo test --release --locked --manifest-path ./host/Cargo.toml --no-run -- --nocapture
cargo test --release --locked --manifest-path ./examples/tests/Cargo.toml --no-run -- --nocapture
  #
  # by running also tests '--release', we better utilize the cache (no or very small 'target_ci/debug')
