# Recipe: Bug

A defect in *shipped* behavior. If it's a known shortcut or deliberate deferral,
it's Technical Debt, not a Bug — see `improvement-and-tech-debt.md`.

**Label:** `Bug` + area label + a `risk:*` label. **Priority:** match user
impact — regressions and data-integrity issues are High/Urgent. Add
`needs-integration-test` when the bug reveals a coverage gap.

## Description sections (override the default skeleton)

```markdown
## What
One sentence: what's broken and the impact/blast radius.

## Steps to reproduce
1. …
2. …
(Include environment: which app, role, org/tenant, data preconditions.)

## Expected vs actual
- **Expected:** …
- **Actual:** … (paste the error, status code, or log excerpt; link Sentry/PR if any)

## Scope of fix
What you'll change and, briefly, the suspected root cause. Note what you will
deliberately NOT touch.

## Acceptance criteria
- The reproduction no longer reproduces.
- A regression test covers it (unit or integration — say which).
- No behavior change outside the fix; tenant isolation and audit trail intact.
```

## Checklist before preview

- [ ] Reproduction is concrete (steps + env + data).
- [ ] Expected vs actual is unambiguous, with evidence.
- [ ] Root cause hypothesis stated (or explicitly "unknown, investigate").
- [ ] AC includes a regression test.
- [ ] `risk:*` label set; `needs-integration-test` if there's a gap.
