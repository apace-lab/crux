#!/usr/bin/env bash
# STATIC stage: emit tabby-webserver LLVM IR (rustc 1.85 -> LLVM 19) and run the
# AFG producer to find the MUMP instrumentation sites (auth + LLM + data-access).
set -euo pipefail
source "$(dirname "$0")/config.sh"

[ -f "$DB" ] || { echo "run 01_schema_db.sh first (need $DB)"; exit 1; }
[ -x "$AFG_BIN" ] || { echo "afg binary not built at $AFG_BIN; build it: (cd $AFG_ROOT/afg_prototype && LLVM_SYS_191_PREFIX=$LLVM_SYS_191_PREFIX cargo build --bin afg)"; exit 1; }

echo "[1/2] emit tabby-webserver LLVM IR (this is large, ~380M, a few minutes)"
( cd "$TABBY" && cargo $RUST rustc -p tabby-webserver --lib -- \
    --emit=llvm-ir -Cdebuginfo=1 -Ccodegen-units=1 )
LL="$(ls -t "$TABBY"/target/debug/deps/tabby_webserver-*.ll | head -1)"
echo "      ll: $LL ($(du -h "$LL" | cut -f1))"

echo "[2/2] AFG producer (static-only). AFG_APP_CRATE lets it analyze a lib crate."
AFG_APP_CRATE=tabby_webserver "$AFG_BIN" --static-only \
  --llvm-ir "$LL" \
  --project "$TABBY" \
  --llm-api "$SIGS/llm_api_functions.json" \
  --ac "$SIGS/ac_functions.json" \
  --data-access "$SIGS/data_access_functions.json" \
  --run-dir "$OUT/static" 2>&1 | tee "$OUT/static.log" | grep -E "seeded|semantic points|instrumentation sites" || true

echo
echo "=== matched sites by symbol ==="
grep -E "hit function" "$OUT/static.log" | sed -E 's/.*hit function = //; s/ through strategy.*//' | sort | uniq -c | sort -rn
echo
echo "plan JSON: $OUT/static/static/instrumentation.json"
echo "Expected: ~2 auth, ~4 llm-access, ~105 data-access (jsonwebtoken::decode @ jwt.rs,"
echo "async_openai messages, and sqlx Query::execute / QueryAs::fetch_* on the thread store)."
