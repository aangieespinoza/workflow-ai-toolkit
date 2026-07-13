---
name: my-pr-review
description: >-
  Author-side workflow for the user's OWN pull requests: (A) self-review a PR
  after pushing it — catch issues before reviewers do — and (B) address review
  comments left on the user's PR — triage, fix, and reply. Use whenever the user
  says "self-review my PR", "review my own PR", "I just pushed, check my changes
  before anyone reviews", "review my PR #123 before I request review", OR
  "address the comments on my PR", "fix the review feedback", "respond to the
  review on PR #123", "handle the comments I got". This is for the user's OWN PR
  — not for reviewing a teammate's PR (that's pr-review-triage) and not for the
  uncommitted local diff before a PR exists (that's pr-review-toolkit's
  review-pr). Never commits, pushes, or posts to GitHub without explicit
  approval.
---

# My PR Review (author side)

Two modes across the life of *your own* PR:

- **Mode A — Self-review after push:** review your pushed changes the way a good
  reviewer would, so you fix problems before they cost a review round.
- **Mode B — Address review comments:** once teammates comment, triage their
  feedback, apply the fixes you approve, and draft replies.

Both respect the global CLAUDE.md: **you handle commits** (this skill edits the
working tree but never commits/pushes), approval gates hold, and anti-sycophancy
applies (no filler in replies, honest pushback on weak feedback).

## When this vs. the neighbors

- **This skill** — your OWN PR: self-review + handling incoming comments.
- `pr-review-triage` — reviewing *someone else's* PR and posting outgoing comments.
- `pr-review-toolkit:review-pr` — your *uncommitted local diff*, before a PR exists.
- `agent-pr-creator` — creating the PR in the first place.

(Mode B is your own version of the ravn `pr-comments-address` skill, which is
disabled — same intent, adapted to your CLAUDE.md conventions.)

---

## Mode A — Self-review after push

Goal: be your own toughest reviewer. Surface what a reviewer would flag, so you
can fix it first.

### 1. Locate the PR and its real base

```bash
gh pr view --json number,title,url,baseRefName,headRefName,files   # current branch's PR
```

If the branch has no PR yet, say so — this mode is for a pushed PR; before that,
`pr-review-toolkit:review-pr` fits better.

**Diff against the actual base, not local `main`/`develop`** (global CLAUDE.md) —
diffing against the wrong base invents phantom findings:

```bash
git fetch origin <baseRefName>
git diff origin/<baseRefName>...HEAD          # the real PR diff
```

### 2. Review the diff

Run the active `pr-review-toolkit` agents in parallel over the diff, plus the
`core-coding-standards` lens (see `references/self-review.md` for the agent
mapping). Then walk `references/self-review-checklist.md` — it encodes the <company>
backend conventions (audit row in `$transaction`, tenant isolation, the `VAL_xxx`
error envelope, migration safety) and general hygiene (no stray debug logs, no
secrets, tests for new behavior).

### 3. Present findings, then fix on approval

Show a triage table: severity · `file:line` · issue · suggested fix. Lead with
what genuinely matters — don't pad with nits. Then, for the fixes you approve, I
apply them to the working tree (minimal, in-scope edits), verify with the
relevant `pnpm --filter <pkg> test` / typecheck, and show the diff. **I do not
commit or push** — you do that. Anything out of scope goes on a follow-up list,
not into this change (Scope Discipline).

---

## Mode B — Address review comments on my PR

Goal: no feedback missed, every change intentional, replies that are useful and
free of filler. Detailed workflow in `references/address-comments.md`.

### 1. Fetch the comments

```bash
gh pr view <PR> --json number,url,title,reviews,comments,reviewThreads
```

Auto-detect the PR from the current branch if none is given; if none exists, ask.
Extract per comment: author, file:line, body, resolved state, review vs. standalone.

### 2. Triage (present a table, don't act yet)

Categorize every unresolved comment into exactly one bucket:

| Category | Meaning | Action |
|---|---|---|
| Must-fix | Required, unambiguous, blocks merge | apply code change |
| Should-fix | Clear improvement | apply after your OK |
| Clarification needed | Intent/solution unclear | ask you before acting |
| Discussion / question | No code change, needs a reply | draft reply only |
| Praise | Positive feedback | brief acknowledgement |

Resolve every "clarification needed" with you before touching code — never guess
a reviewer's intent.

### 3. Fix, then reply — each behind its own gate

- Present the change plan (file, current lines, proposed change, rationale) and
  wait for your approval. Apply fixes minimally, one file at a time, reading the
  full file first and verifying after. **No commit/push — you do that.**
- Draft replies: factual and specific ("Done — added the null check at
  `auth.ts:42`"), no filler ("Great catch!", "Thanks!"). Show the drafts, and
  post them only on your explicit approval. Don't resolve threads — leave that to
  the reviewer.

---

## Guardrails

- **You own git and GitHub actions.** This skill edits files and drafts replies;
  it never commits, pushes, opens PRs, resolves threads, or posts without your
  explicit go-ahead (global CLAUDE.md approval gates).
- **Self-review diffs against the real base** — otherwise findings are noise.
- **Minimal, in-scope changes only.** Out-of-scope improvements → follow-up list.
- **Honest, not agreeable.** If a reviewer's comment is wrong or a fix is risky,
  say so with reasoning before applying — don't reflexively comply, don't
  reflexively defend.
- **Verify before "done."** Run the relevant tests/typecheck and show output
  before calling a fix complete.
