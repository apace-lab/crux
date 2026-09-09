# Shared config for the tabby AFG reproduction scripts. Override any of these via
# the environment; the defaults match the dev machine this was first run on (macOS).
export AFG_ROOT="${AFG_ROOT:-/Users/sanjib/codes/apace_lab/soap_afg_2026/repositories/AFG}"
export TABBY="${TABBY:-/Users/sanjib/codes/apace_lab/tabby}"
export LLVM_SYS_191_PREFIX="${LLVM_SYS_191_PREFIX:-/opt/homebrew/opt/llvm@19}"
export RUST="${RUST:-+1.85.0}"                 # toolchain for tabby + .ll emit (LLVM-19)
export DB="${DB:-/tmp/tabby_build.db}"          # schema-only sqlite for sqlx query! macros
export DATABASE_URL="sqlite://$DB"

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export KIT
export OUT="$KIT/out"
export AFG_BIN="$AFG_ROOT/afg_prototype/target/debug/afg"
export SIGS="$AFG_ROOT/rail-rs/signatures"
export DASH="$AFG_ROOT/afg_prototype/afg-dashboard"
mkdir -p "$OUT"
