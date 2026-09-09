#!/usr/bin/env bash
# Build a schema-only SQLite database from tabby's migrations, so sqlx's
# compile-time query! macros can typecheck (no live server / Postgres needed).
set -euo pipefail
source "$(dirname "$0")/config.sh"

command -v sqlite3 >/dev/null || { echo "need the sqlite3 CLI"; exit 1; }
rm -f "$DB"
n=0
for f in $(ls "$TABBY"/ee/tabby-db/migrations/*.up.sql | sort); do
  sqlite3 "$DB" < "$f" || { echo "FAILED migration: $f"; exit 1; }
  n=$((n+1))
done
tables=$(sqlite3 "$DB" "SELECT count(*) FROM sqlite_master WHERE type='table';")
echo "applied $n up-migrations -> $DB ($tables tables)"
echo "DATABASE_URL=$DATABASE_URL"
