#!/usr/bin/env bash
# PostToolUse hook (Edit|Write|MultiEdit): format ONLY the files Claude just edited,
# using each repo's own prettier. --ignore-unknown skips non-formattable files
# (.env, images, lockfiles) instead of erroring — the prettier false-positive class.
# --no-install means repos without prettier are a silent no-op, never an error.
set -u
[ -n "${CLAUDE_FILE_PATHS:-}" ] || exit 0
for f in $CLAUDE_FILE_PATHS; do
  [ -f "$f" ] || continue
  npx --no-install prettier --write --ignore-unknown "$f" >/dev/null 2>&1 || true
done
exit 0
