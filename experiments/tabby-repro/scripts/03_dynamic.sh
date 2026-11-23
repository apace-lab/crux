#!/usr/bin/env bash
# DYNAMIC stage: drive tabby's REAL database code (create_thread_message write,
# list_thread_messages read -- the unscoped cross-user read ACE flagged) as two
# users, and produce a CRUX R4 trace showing the cross-user leak.
#
# The harness must be a member of the tabby cargo workspace (tabby-db uses
# `version.workspace = true`, so it cannot be built from outside). This script
# copies the harness into $TABBY, adds it as a workspace member, runs it, then
# restores $TABBY to its original state. It does NOT leave changes in the checkout.
set -euo pipefail
source "$(dirname "$0")/config.sh"

[ -f "$DB" ] || { echo "run 01_schema_db.sh first (need $DB)"; exit 1; }

HARNESS_DIR="$TABBY/crux_tabby_harness"
BAK="$OUT/Cargo.toml.tabby.bak"

cleanup() {
  [ -f "$BAK" ] && cp "$BAK" "$TABBY/Cargo.toml" && rm -f "$BAK"
  rm -rf "$HARNESS_DIR"
  echo "restored $TABBY (harness removed, Cargo.toml restored)"
}
trap cleanup EXIT

# 1) place the harness as a workspace member
rm -rf "$HARNESS_DIR"
cp -R "$KIT/harness" "$HARNESS_DIR"
# point the harness at this checkout's crux_runtime (single source of truth), so
# the kit is not tied to the placeholder path in harness/Cargo.toml.
sed -i '' "s#^crux_runtime = .*#crux_runtime = { path = \"$CRUX_DIR/crux_runtime\" }#" "$HARNESS_DIR/Cargo.toml"
cp "$TABBY/Cargo.toml" "$BAK"
if ! grep -q 'crux_tabby_harness' "$TABBY/Cargo.toml"; then
  # BSD sed (macOS). Insert the member right after `members = [`.
  sed -i '' 's#members = \[#members = [\n    "crux_tabby_harness",#' "$TABBY/Cargo.toml"
fi

# 2) run it (writes the R4 trace to $OUT/trace.jsonl)
echo "[run] two users through tabby's real tabby-db code"
rm -f "$OUT/trace.jsonl"
( cd "$TABBY" && CRUX_TRACE_PATH="$OUT/trace.jsonl" cargo $RUST run -q -p crux_tabby_harness )

echo
echo "=== CRUX trace ($OUT/trace.jsonl) ==="
cat "$OUT/trace.jsonl"

echo
echo "=== analyze the trace (cross-user leak verification) ==="
echo "run the dashboard to see it in a browser:"
echo "  (cd $DASH && cargo run -- --trace $OUT/trace.jsonl)   # http://127.0.0.1:8090"
