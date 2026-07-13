# Mode B — Address review comments on my PR

Adapted from the ravn `pr-comments-address` workflow, tuned to the global
CLAUDE.md (you own commits; anti-sycophancy replies).

## Phase 1 — Detect PR and fetch comments

```bash
gh pr view <PR> --json number,url,title,author,reviews,comments,reviewThreads
```

Auto-detect from the current branch if no PR is given; if none exists, stop and
ask for a number/URL. Parse each comment: author, file:line, body, resolved
state, and whether it's part of a review or a standalone comment. Read
`CLAUDE.md` / `.claude/rules/` and apply those conventions while triaging.

## Phase 2 — Triage (output a table, act on nothing yet)

Put every unresolved comment in exactly one bucket:

| Category | Definition | Action |
|---|---|---|
| Must-fix | Required, unambiguous, blocks merge | apply code change |
| Should-fix | Clear improvement, good intent | apply after user OK |
| Clarification needed | Intent/solution unclear | ask user before acting |
| Discussion / question | No code change, needs a reply | draft reply only |
| Praise | Positive feedback | brief acknowledgement |

Decision order: change clearly defined? → must/should-fix. Any ambiguity about
the solution? → clarification needed. No code change? → discussion. Subjective? →
discussion.

## Phase 3 — Resolve ambiguities

Present every "clarification needed" comment with full context (file, line,
text) and ask what to change. **Do not proceed until each is answered.** This is
also where anti-sycophancy matters: if a comment is technically wrong or a
suggested change would introduce a regression, say so with reasoning and propose
the alternative — don't comply reflexively, don't get defensive.

## Phase 4 — Change plan (approval gate)

For must-fix / should-fix: show file, current lines, proposed change, rationale.
For discussion/question: show the proposed reply. Ask: "Proceed with these?"
Wait for explicit confirmation before editing.

## Phase 5 — Apply fixes

- Read the full file first — never patch blindly from the comment text.
- Minimal change that addresses the comment; no scope creep, no drive-by reformatting.
- One file at a time to avoid conflicts; verify each with `git diff` and the
  scoped test/typecheck.
- **Do not commit or push** — the user does that.

## Phase 6 — Draft replies (anti-filler)

One reply per comment:
- Applied change → confirm factually: "Done — extracted `validateUser()` in `auth.ts:45-60`."
- Resolved clarification → the decision, briefly.
- Question/discussion → answer directly, no over-explaining.
- Praise → short acknowledgement.

Ban filler: no "Great point!", "Thanks for catching that!", "Absolutely!". They
add noise. Direct and professional.

## Phase 7 — Post replies (approval gate)

Show all drafts; post only on explicit approval. Reply in-thread:

```bash
# reply to a specific review comment thread
gh api repos/<owner>/<repo>/pulls/comments/<comment_id>/replies -f body="<reply>"
# or a top-level PR comment
gh pr comment <PR> --body "<reply>"
```

Get `<owner>/<repo>` from `gh pr view <PR> --json headRepositoryOwner,headRepository`.
Confirm which posted. **Do not resolve threads** — leave that to the reviewer so
they can verify your response. **Do not push or open PRs.**
