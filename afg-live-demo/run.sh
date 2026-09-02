#!/usr/bin/env bash
# Compile this server to LLVM IR, run AFG's real static analysis + instrumenter
# on it (afg --instrument-only), then run the AFG-instrumented copy live.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"          # afg-live-demo
PROTO="$(cd "$HERE/.." && pwd)"                # afg_prototype
AFG="$PROTO/target/debug/afg"
SIGS="$PROTO/../ll_parser/signatures"
RUNDIR="${RUNDIR:-/tmp/afg_live_demo}"
export LLVM_SYS_191_PREFIX="${LLVM_SYS_191_PREFIX:-/opt/homebrew/opt/llvm@19}"

echo "[0/3] build afg"
( cd "$PROTO" && cargo build --bin afg )

echo "[1/3] compile the server to LLVM IR (with debug info)"
( cd "$HERE" && cargo +1.85.0 rustc --bin afg-live-demo -- \
    --emit=llvm-ir -Cdebuginfo=2 -Ccodegen-units=1 )
LL="$(ls -t "$HERE"/target/debug/deps/afg_live_demo-*.ll | head -1)"
echo "      ll: $LL"

echo "[2/3] AFG static analysis + auto-instrument (producer + instrumenter)"
"$AFG" --instrument-only \
  --llvm-ir "$LL" \
  --project "$HERE" \
  --llm-api "$SIGS/llm_api_functions.json" \
  --ac "$SIGS/ac_functions.json" \
  --run-dir "$RUNDIR"

# Carry the LLM keys into the instrumented copy. The instrument step rebuilds the
# copy from scratch, so copy .env in explicitly (put your key in afg-live-demo/.env).
if [ -f "$HERE/.env" ]; then
  cp "$HERE/.env" "$RUNDIR/instrumented/app/.env"
  echo "      copied .env into the instrumented copy"
else
  echo "      note: no afg-live-demo/.env found -> LLM falls back to canned answers"
fi

echo "[3/3] run the AFG-instrumented server live on http://127.0.0.1:8080"
echo "      (the macros in this copy were inserted by AFG, not by hand)"
cd "$RUNDIR/instrumented/app"
exec cargo +1.85.0 run
