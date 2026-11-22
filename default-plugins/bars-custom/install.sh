#!/usr/bin/env bash
# Build bars-custom and install it where the default-custom layout loads it.
#
#   default-plugins/bars-custom/install.sh
#
# The build runs in a memory-capped scope with limited parallelism, so an
# out-of-memory build is killed alone (exit 137) instead of the terminal.
# Override with MEMORY_MAX=8G JOBS=2 install.sh.
#
# Running sessions keep the old plugin; start a new session to load it.
# The permissions in ~/.cache/zellij/permissions.kdl are keyed by the install
# path, so they carry over.

set -euo pipefail

plugin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd "$plugin_dir/../.." && pwd)"
wasm="$repo_dir/target/wasm32-wasip1/release/bars-custom.wasm"
dest_dir="${ZELLIJ_CONFIG_DIR:-$HOME/.config/zellij}/plugins"

cd "$plugin_dir"
systemd-run --user --scope --quiet \
    -p MemoryMax="${MEMORY_MAX:-12G}" -p MemorySwapMax=2G -- \
    env CARGO_BUILD_JOBS="${JOBS:-4}" cargo build --release

mkdir -p "$dest_dir"
install -m 755 "$wasm" "$dest_dir/bars-custom.wasm"
echo "Installed $dest_dir/bars-custom.wasm"
