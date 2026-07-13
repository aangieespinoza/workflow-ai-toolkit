# Mode A — Self-review engine

Review your pushed PR the way a rigorous reviewer would, against the **real base**.

## Scope to the actual base

```bash
gh pr view --json number,baseRefName,headRefName,url
git fetch origin <baseRefName>
git diff origin/<baseRefName>...HEAD            # three-dot: changes on your branch since it forked
git diff origin/<baseRefName>...HEAD --stat     # quick shape of the change
```

Three-dot (`...`) diffs against the merge-base, which is what the reviewer sees.
Two-dot or diffing against local `main` pulls in unrelated commits and invents
findings — the global CLAUDE.md calls this out specifically.

## Which agents to run

Fan out the active `pr-review-toolkit` agents in parallel (one message, multiple
Agent calls), scoped to the diff:

| Condition | Agent |
|---|---|
| Always | `code-reviewer` |
| Error handling / catch / fallbacks touched | `silent-failure-hunter` |
| New behavior or changed tests | `pr-test-analyzer` |
| New/changed types or interfaces | `type-design-analyzer` |
| Comments/docs changed | `comment-analyzer` |

Layer in `core-coding-standards` and, for <company> backend work, the project
conventions. Then run `self-review-checklist.md` to catch the recurring misses.

## Output + fix loop

Present a triage table: **severity · `file:line` · issue · suggested fix**.
Severity: Critical (a reviewer will block) · Important (they'll ask for it) ·
Suggestion · Nit. Lead with substance; a self-review padded with nits trains you
to ignore it.

For approved fixes: apply minimal, in-scope edits to the working tree; verify
with the scoped command (`pnpm --filter @<company>/<pkg> test`, typecheck); show the
resulting diff. Do **not** commit or push — that's the user's step. Log
out-of-scope ideas as a follow-up list rather than expanding the change.
