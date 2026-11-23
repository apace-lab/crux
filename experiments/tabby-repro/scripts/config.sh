# Shared config for the Tabby CRUX reproduction scripts. Override any of these via
# the environment; by default CRUX_ROOT resolves relative to this script's repo.
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export KIT
DEFAULT_ROOT="$(cd "$KIT/../../.." && pwd)"
export CRUX_ROOT="${CRUX_ROOT:-$DEFAULT_ROOT}"
export CRUX_DIR="${CRUX_DIR:-$(cd "$KIT/../.." && pwd)}"
export TABBY="${TABBY:-$CRUX_ROOT/../tabby}"
export LLVM_SYS_191_PREFIX="${LLVM_SYS_191_PREFIX:-/opt/homebrew/opt/llvm@19}"
export RUST="${RUST:-+1.85.0}"                 # toolchain for tabby + .ll emit (LLVM-19)
export DB="${DB:-/tmp/tabby_build.db}"          # schema-only sqlite for sqlx query! macros
export DATABASE_URL="sqlite://$DB"

export OUT="$KIT/out"
export CRUX_BIN="$CRUX_DIR/target/debug/crux"
export SIGS="$CRUX_ROOT/rail-rs/signatures"
export DASH="$CRUX_DIR/crux_dashboard"
mkdir -p "$OUT"
