#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# PROJECT-SPECIFIC EXAMPLE — adapt before use, do not copy blind.
# Sanitized for this snapshot: `myco` stands in for a real package scope, database
# user/name, and Docker container name (`MYCO_FULL` for the escape-hatch env var).
# A shell-safe placeholder is used deliberately — `<company>` would parse as a
# redirection and break the script. The measured timings below are this project's.
# Kept here because the *pattern* is the reusable part: a PreToolUse(Bash) guard
# that parses the command positionally (so `git commit -m "...test:integration"`
# is not denied), refuses concurrent or over-broad test runs, and redirects the
# full suite at a RAM-backed database.
# ─────────────────────────────────────────────────────────────────────────────
# PreToolUse(Bash) guard for the apps/api integration lane.
#
# Three independent protections, cheapest first:
#   1. collision  — refuse a second concurrent run (they deadlock on the shared DB)
#   2. scope      — refuse a bare full-suite run; require a spec pattern
#   3. fast DB    — redirect at the RAM-backed Postgres on :5433
#
# Escape hatch: prefix the command with MYCO_FULL=1 to run the whole suite.
# Nothing here modifies the repo.

set -euo pipefail

command -v jq >/dev/null 2>&1 || {
  echo "guard-integration-tests: jq not found; refusing to evaluate." >&2
  exit 2
}

INPUT=$(cat)
CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT")
[ -n "$CMD" ] || exit 0

# Only care about the apps/api integration lane, and only when `pnpm` is in
# COMMAND POSITION. A naive substring match denies `echo "... test:integration"`
# and `git commit -m "... test:integration"` — the same false-positive the repo's
# own guard-test-commands.sh solves with a positional parser.
is_integration_run() {
  local seg first
  # Split on the shell operators that start a new command.
  while IFS= read -r seg; do
    # Strip leading env assignments (FOO=bar pnpm ...).
    while [[ "$seg" =~ ^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+(.*)$ ]]; do
      seg="${BASH_REMATCH[1]}"
    done
    first=$(awk '{print $1}' <<<"$seg")
    [ "$(basename "${first:-}")" = "pnpm" ] || continue
    grep -qE '@myco/api' <<<"$seg" || continue
    grep -qE '(^|[[:space:]])test:integration([[:space:]]|$)' <<<"$seg" || continue
    return 0
  done < <(sed -E 's/(\|\||&&|;|\||&)/\n/g' <<<"$CMD")
  return 1
}
is_integration_run || exit 0

deny() {
  jq -nc --arg r "$1" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}

# --- 1. collision guard -------------------------------------------------
# Two suites against one myco_test block each other: TRUNCATE holds
# ACCESS EXCLUSIVE while the other run's INSERT waits on it. Observed live.
if pgrep -f 'jest\.js --config test/integration/jest-integration\.config\.ts' >/dev/null 2>&1; then
  deny "An apps/api integration run is ALREADY in progress.

Two runs share one myco_test database and block each other on TRUNCATE
(ACCESS EXCLUSIVE) vs INSERT — the run appears to hang, then times out.

Wait for it, or kill it first:
  pkill -f 'jest.js --config test/integration/jest-integration.config.ts'"
fi

# --- 2. scope guard -----------------------------------------------------
# Measured 2026-08-12: full suite = 88 spec files / 1191 tests / 588s. A single
# spec is ~5s. That is the ~115x that makes this the whole point of the hook.
IS_FULL=0
grep -qE '(^|[[:space:]])MYCO_FULL=1([[:space:]]|$)' <<<"$CMD" && IS_FULL=1

if [ "$IS_FULL" = 0 ]; then
  # Anything after the `--` separator counts as a pattern.
  # A spec pattern can only appear after a `--` separator. No separator at all
  # => bare full-suite run. (Checking this first matters: without it, the tail
  # of the command itself gets mistaken for a pattern.)
  PATTERN=""
  if grep -qE 'test:integration[[:space:]]+--[[:space:]]' <<<"$CMD"; then
    AFTER=$(sed -E 's/.*test:integration[[:space:]]+--[[:space:]]+//' <<<"$CMD")
    # Drop flags: `-- --silent` is not a spec pattern and would still run all 88.
    PATTERN=$(tr ' ' '\n' <<<"$AFTER" | grep -vE '^-' || true)
    PATTERN=$(tr -d '[:space:]' <<<"$PATTERN")
  fi
  if [ -z "$PATTERN" ]; then
    deny "Bare 'test:integration' runs all 88 spec files (1191 tests) — measured 588s / 9m48s.

Scope it to the spec you actually need (~5s):
  pnpm --filter @myco/api test:integration -- <spec-name>

e.g.  pnpm --filter @myco/api test:integration -- subscriptions-plan-change

To genuinely run the whole suite, prefix with MYCO_FULL=1 (this also routes it
at the RAM-backed Postgres, which brings 9m48s down to 6m25s):
  MYCO_FULL=1 pnpm --filter @myco/api test:integration"
  fi
fi

# --- 3. fast-DB redirect (FULL RUNS ONLY) -------------------------------
# Docker's volume layer fsyncs every commit; cleanDatabase() TRUNCATEs 29 tables
# in a beforeEach (~1100x per run) on top of that. Measured full-suite A/B, both
# green at 88 suites / 1191 tests: disk 588s vs RAM 385s — 203s, 35% off.
# Negligible on a single spec (~0.3s), so only full runs get redirected;
# otherwise every scoped run would pay a deny/retry round-trip for nothing.
if [ "$IS_FULL" = 1 ] && ! grep -qE 'DATABASE_URL=' <<<"$CMD"; then
  if ! docker exec myco-test-pg pg_isready -U myco >/dev/null 2>&1; then
    docker rm -f myco-test-pg >/dev/null 2>&1 || true
    docker run -d --name myco-test-pg \
      -e POSTGRES_USER=myco -e POSTGRES_PASSWORD=myco -e POSTGRES_DB=myco_dev \
      -p 5433:5432 --tmpfs /var/lib/postgresql/data:rw,size=2g \
      postgres:16-alpine >/dev/null 2>&1 || exit 0
    for _ in $(seq 1 30); do
      docker exec myco-test-pg pg_isready -U myco >/dev/null 2>&1 && break
      sleep 1
    done
  fi
  deny "Run the full suite against the RAM-backed Postgres on :5433 — measured
588s -> 385s (35% off), same 88 suites / 1191 tests green. Container is ready:

  DATABASE_URL=postgresql://myco:myco@localhost:5433/myco_dev $CMD"
fi

exit 0
