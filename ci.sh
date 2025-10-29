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

cargo batch \
    --- check --release --manifest-path host/Cargo.toml --no-default-features --features peripheral \
    --- check --release --manifest-path host/Cargo.toml --no-default-features --features central \
    --- check --release --manifest-path host/Cargo.toml --no-default-features --features central,scan \
    --- check --release --manifest-path host/Cargo.toml --no-default-features --features central,peripheral \
    --- check --release --manifest-path host/Cargo.toml --no-default-features --features central,peripheral,defmt \
    --- check --release --manifest-path host/Cargo.toml --no-default-features --features gatt,peripheral \
    --- check --release --manifest-path host/Cargo.toml --no-default-features --features gatt,central \
    --- check --release --manifest-path host/Cargo.toml --no-default-features --features gatt,peripheral,central,scan \
    --- check --release --manifest-path host/Cargo.toml --no-default-features --features gatt,peripheral,central,scan,security \
    --- check --release --manifest-path host/Cargo.toml --no-default-features --features gatt,peripheral,central,scan,controller-host-flow-control \
    --- check --release --manifest-path host/Cargo.toml --no-default-features --features gatt,peripheral,central,scan,controller-host-flow-control,connection-metrics,channel-metrics \
    --- check --release --manifest-path host/Cargo.toml --no-default-features --features gatt,peripheral,central,scan,controller-host-flow-control,connection-metrics,channel-metrics,l2cap-sdu-reassembly-optimization \
    --- check --release --manifest-path host/Cargo.toml --no-default-features --features gatt,peripheral,central,scan,controller-host-flow-control,connection-metrics,channel-metrics,l2cap-sdu-reassembly-optimization,connection-params-update \
    --- check --release --manifest-path bt-hci-linux/Cargo.toml \
    --- check --release --manifest-path examples/nrf52/Cargo.toml --target thumbv7em-none-eabihf --features nrf52840 \
    --- check --release --manifest-path examples/nrf52/Cargo.toml --target thumbv7em-none-eabihf --features nrf52840,security \
    --- check --release --manifest-path examples/nrf52/Cargo.toml --target thumbv7em-none-eabihf --features nrf52833 --artifact-dir tests/nrf52 \
    --- check --release --manifest-path examples/nrf52/Cargo.toml --target thumbv7em-none-eabihf --features nrf52832 \
    --- check --release --manifest-path examples/esp32/Cargo.toml --target riscv32imc-unknown-none-elf --features esp32c3 --artifact-dir tests/esp32 \
    --- check --release --manifest-path examples/serial-hci/Cargo.toml \
    --- check --release --manifest-path examples/linux/Cargo.toml \
    --- check --release --manifest-path examples/linux/Cargo.toml --features security \
    --- check --release --manifest-path examples/tests/Cargo.toml \
    --- check --release --manifest-path benchmarks/nrf-sdc/Cargo.toml --target thumbv7em-none-eabihf --features nrf52840 \
    --- check --release --manifest-path examples/rp-pico-w/Cargo.toml --target thumbv6m-none-eabi --features skip-cyw43-firmware \
    --- check --release --manifest-path examples/rp-pico-2-w/Cargo.toml --target thumbv8m.main-none-eabihf --features skip-cyw43-firmware
#    --- check --release --manifest-path examples/apache-nimble/Cargo.toml --target thumbv7em-none-eabihf
    #
    # NOTE! Later 'cargo' can do 'check --locked' but 'cargo-batch' doesn't allow it!
    #       >> error: unexpected argument '--locked' found
    #
    #     This might be one reason to move from 'cargo-batch' to regular, line-wise 'cargo'.

set -x
cargo fmt --check --manifest-path ./host/Cargo.toml
cargo clippy --manifest-path ./host/Cargo.toml --features gatt,peripheral,central
cargo test --release --locked --manifest-path ./host/Cargo.toml --lib -- --nocapture
cargo test --release --locked --manifest-path ./host/Cargo.toml --no-run -- --nocapture
cargo test --release --locked --manifest-path ./examples/tests/Cargo.toml --no-run -- --nocapture
  #
  # by running also tests '--release', we better utilize the cache (down by ___GB), saving run time in the process (___ m,s)
