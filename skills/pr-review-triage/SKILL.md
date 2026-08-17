---
name: pr-review-triage
effort: high
disallowed-tools: Edit, Write
description: >-
  Review other people's GitHub pull requests, surface findings for discussion,
  and post ONLY the findings the user approves as inline PR comments. Use this
  whenever the user wants to review a teammate's PR (by number or URL), asks
  "review this PR for me", "review PR #123 / <github PR url>", "review these
  PRs", "what are the issues in so-and-so's PR", "help me review before I
  approve", or wants a second opinion on a PR they're reviewing. It runs the
  active pr-review-toolkit agents against the PR's diff, presents findings as a
  triage table, lets the user add their own findings and pick which to publish,
  then posts the approved ones. NEVER posts anything to GitHub until the user
  explicitly approves which findings to publish. This is for reviewing OTHERS'
  PRs (outgoing review comments) — not for addressing comments on the user's own
  PR (that's pr-comments-address) and not for reviewing the user's uncommitted
  local diff (that's pr-review-toolkit's review-pr).
---

# PR Review Triage

Review someone else's PR, think hard about it *with* the user, and publish only
what they sign off on. The whole point is the **discussion gate**: findings are
surfaced in chat first; GitHub only sees the subset the user approves.

This wraps the active review agents and adds the two things they don't do:
reviewing an arbitrary **remote** PR (not just the local diff) and **posting**
approved findings as inline comments.

## When this vs. the neighbors

- **This skill** — reviewing *someone else's* PR and authoring outgoing review comments.
- `pr-comments-address` (ravn, enable if needed) — the inverse: comments *others*
  left on *your* PR; it triages, fixes, and replies. Reach for it when the user
  is the PR author receiving feedback.
- `pr-review-toolkit:review-pr` — reviews the user's *local uncommitted diff*
  before a PR exists. This skill uses its agents as the review engine but points
  them at a remote PR.

## Workflow

### 1. Identify the PR(s)

Accept one or more PR numbers or URLs. If none given, ask. Handle a list by
triaging each PR separately — don't merge findings across PRs.

### 2. Fetch and understand

For each PR, get metadata + diff and read for *intent* before judging code:

```bash
gh pr view <PR> --json number,title,author,url,body,headRefName,baseRefName,files
gh pr diff <PR>
```

Read the PR description and any linked ticket (use the Linear MCP if a TICKET-###
is referenced) so findings are anchored to what the PR is *trying* to do. For
deeper context (imports, call sites not in the diff), optionally
`gh pr checkout <PR>` in the repo — but review against the PR's base, not local
`main`, to avoid false positives (per the global CLAUDE.md).

See `references/review-engine.md` for scoping the agents to a remote diff.

### 3. Review (run the engine)

Fan out the active `pr-review-toolkit` agents in parallel over the diff, plus the
`core-coding-standards` lens:

- `code-reviewer` (always) — general quality + CLAUDE.md compliance
- `silent-failure-hunter` — swallowed errors, bad fallbacks
- `pr-test-analyzer` — test coverage of the change
- `type-design-analyzer` — if types are added/changed
- `comment-analyzer` — if comments/docs changed

Apply the repo's own conventions when judging backend code (audit-log-in-
`$transaction`, tenant isolation, the standard error envelope — see the global
CLAUDE.md and, for <company>, the `linear-tickets` house style).

### 4. Present findings for discussion — DO NOT POST

Output a triage table. This is the interactive core; the user will react to it.

```markdown
## PR #<n> — <title>  (author, base←head)

| # | Severity | File:line | Finding | Suggested comment |
|---|----------|-----------|---------|-------------------|
| 1 | Critical | src/x.ts:42 | <what + why it matters> | <the comment you'd post> |
| 2 | Important | … | … | … |
| 3 | Nit | … | … | … |

**Strengths:** <2–3 genuinely good things — brief, specific, no filler.>
**Recommended to post:** #1, #2   **Hold/optional:** #3
```

Severity: **Critical** (blocks merge) · **Important** (should fix) ·
**Suggestion** · **Nit** (optional/style). Every finding cites a real
`file:line` from the diff — never invent locations or issues.

Then invite the discussion the user runs every time:
- their own findings (add them to the table),
- their take on each of yours (agree / disagree / reframe),
- which findings to publish.

Engage honestly per the anti-sycophancy rules — if the user waves off a real
Critical issue, push back once with the risk, then defer to their call.

### 5. Post ONLY the approved findings

After the user explicitly says which to publish, post them. Default to a single
**batched review** with `event: COMMENT` (a comment review, not approve/block) —
one review carrying all approved inline comments. See `references/posting.md`
for the exact `gh api` recipe.

- **Never** submit `APPROVE` or `REQUEST_CHANGES` unless the user explicitly asks
  — approving or blocking a teammate's PR is their decision, not a default.
- Comment text: specific, actionable, professional. No "Great catch!",
  "Thanks!", "Nice work!" filler — state the issue and the suggested fix.
- After posting, return the review/comment URL(s) and a one-line summary of what
  went out vs. what was held.

## Guardrails

- **Discussion gate is absolute.** Nothing reaches GitHub before explicit
  approval of the specific findings — this is the whole reason the skill exists
  (and the global CLAUDE.md rule).
- **Comment on the diff, respect the author's scope.** Flag out-of-scope
  refactors as optional/nits, not blocking demands.
- **One review, not a comment storm.** Batch approved findings into a single
  review so the author gets one coherent pass.
- **Ground every finding.** Real file:line from the diff, tied to the PR's
  intent. If unsure a finding is real, mark it a question, not a defect.
