#!/usr/bin/env bash
# Regression harness for guard-integration-tests.sh. Run after editing the hook.
#   bash ~/.claude/hooks/guard-integration-tests.test.sh
#
# NOTE: the collision guard fires whenever a real integration run is in flight,
# which would turn every ALLOW case into a DENY. Refuse to run in that state
# rather than report bogus failures.

H="$(dirname "${BASH_SOURCE[0]}")/guard-integration-tests.sh"
fail=0

if pgrep -f 'jest\.js --config test/integration/jest-integration\.config\.ts' >/dev/null 2>&1; then
  echo "SKIP: an integration run is in progress; collision guard would mask every case."
  exit 0
fi

bash -n "$H" || { echo "FAIL: syntax error"; exit 1; }

check() { # expected cmd label
  local want="$1" cmd="$2" label="$3" out got
  out=$(jq -nc --arg c "$cmd" '{tool_input:{command:$c}}' | bash "$H" 2>&1)
  [ -z "$out" ] && got=ALLOW || got=DENY
  if [ "$got" = "$want" ]; then
    printf '  ok   %-46s %s\n' "$label" "$got"
  else
    printf '  FAIL %-46s want=%s got=%s\n' "$label" "$want" "$got"; fail=1
  fi
}

echo "guard-integration-tests.sh"
check ALLOW 'ls -la'                                                              'unrelated command'
check ALLOW 'git status'                                                          'git'
check ALLOW 'echo "pnpm --filter @myco/api test:integration"'                    'echo quoting the command'
check ALLOW 'git commit -m "fix pnpm --filter @myco/api test:integration"'       'commit message quoting it'
check ALLOW 'pnpm --filter @myco/web test -- --maxWorkers=4'                     'web unit tests'
check ALLOW 'pnpm --filter @myco/api test -- --maxWorkers=4 jobs.service'        'api unit tests'
check ALLOW 'pnpm --filter @myco/functions test:integration -- --runInBand'      'functions package (not apps/api)'
check ALLOW 'pnpm --filter @myco/api test:integration -- auth.int-spec'          'scoped run'
check ALLOW 'pnpm --filter @myco/api test:integration -- --silent jobs'          'flags plus a real pattern'
check ALLOW 'MYCO_FULL=1 DATABASE_URL=postgresql://c@localhost:5433/d pnpm --filter @myco/api test:integration' 'full run already redirected'

check DENY  'pnpm --filter @myco/api test:integration'                           'bare full-suite run'
check DENY  'pnpm --filter @myco/api test:integration -- --silent'               'flags only, no spec pattern'
check DENY  'MYCO_FULL=1 pnpm --filter @myco/api test:integration'              'full run needing DB redirect'

[ "$fail" = 0 ] && echo "all passed" || echo "FAILURES"
exit "$fail"
