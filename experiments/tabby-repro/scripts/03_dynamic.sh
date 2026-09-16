#!/usr/bin/env bash
# DYNAMIC stage: drive tabby's REAL database code (create_thread_message write,
# list_thread_messages read -- the unscoped cross-user read AFG flagged) as two
# users, and produce an AFG trace showing the cross-user overlap + leak.
#
# The harness must be a member of the tabby cargo workspace (tabby-db uses
# `version.workspace = true`, so it cannot be built from outside). This script
# copies the harness into $TABBY, adds it as a workspace member, runs it, then
# restores $TABBY to its original state. It does NOT leave changes in the checkout.
set -euo pipefail
source "$(dirname "$0")/config.sh"

[ -f "$DB" ] || { echo "run 01_schema_db.sh first (need $DB)"; exit 1; }

HARNESS_DIR="$TABBY/afg_tabby_harness"
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
# point the harness at this AFG_ROOT's afg_runtime (single source of truth), so
# the kit is not tied to the absolute path baked into harness/Cargo.toml.
sed -i '' "s#^afg_runtime = .*#afg_runtime = { path = \"$AFG_ROOT/afg_prototype/afg_runtime\" }#" "$HARNESS_DIR/Cargo.toml"
cp "$TABBY/Cargo.toml" "$BAK"
if ! grep -q 'afg_tabby_harness' "$TABBY/Cargo.toml"; then
  # BSD sed (macOS). Insert the member right after `members = [`.
  sed -i '' 's#members = \[#members = [\n    "afg_tabby_harness",#' "$TABBY/Cargo.toml"
fi

# 2) run it (writes the AFG trace to $OUT/trace.jsonl)
echo "[run] two users through tabby's real tabby-db code"
rm -f "$OUT/trace.jsonl"
( cd "$TABBY" && AFG_TRACE_PATH="$OUT/trace.jsonl" cargo $RUST run -q -p afg_tabby_harness )

echo
echo "=== AFG trace ($OUT/trace.jsonl) ==="
cat "$OUT/trace.jsonl"

echo
echo "=== analyze the trace (cross-user overlap) ==="
echo "run the dashboard to see it in a browser:"
echo "  (cd $DASH && cargo run -- --trace $OUT/trace.jsonl)   # http://127.0.0.1:8090"
