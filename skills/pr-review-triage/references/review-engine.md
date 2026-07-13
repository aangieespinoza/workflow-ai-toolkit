# Review engine — running the agents on a remote PR

The `pr-review-toolkit` agents were built to analyze the local `git diff`. To
review someone else's PR, give them that PR's diff as the material.

## Two ways to feed the diff

**A. Diff-only (fast, no checkout).** Capture the PR diff and hand it to the
agents as the content to review. Good for focused, self-contained PRs.

```bash
gh pr diff <PR> > /tmp/pr-<PR>.diff
```

Spawn each agent with the diff plus enough context to judge it: the PR title,
description, and the base branch. Tell the agent to cite `file:line` using the
new-file line numbers from the diff hunks (the `+` side).

**B. Checkout (deeper).** When findings depend on code *outside* the diff (call
sites, types, existing helpers), check the branch out and let agents read the
full files:

```bash
gh pr checkout <PR>          # in the target repo
git fetch origin <base> && git diff origin/<base>...HEAD --stat
```

Review against the PR's **base branch**, not local `main`/`develop` — diffing
against the wrong base invents phantom findings (global CLAUDE.md).

## Which agents to run

Pick by what the diff touches (mirrors `pr-review-toolkit`'s own mapping):

| Condition | Agent |
|---|---|
| Always | `code-reviewer` |
| Error handling / catch / fallbacks touched | `silent-failure-hunter` |
| Tests changed or behavior added without tests | `pr-test-analyzer` |
| New/changed types or interfaces | `type-design-analyzer` |
| Comments/docs added or changed | `comment-analyzer` |

Run them in parallel (one message, multiple Agent calls) and merge their reports.
Layer in the `core-coding-standards` rules and, for <company> backend PRs, the
project conventions (audit row in the same `$transaction`, tenant isolation with
403-vs-404, the `VAL_xxx` error envelope).

## Normalizing findings

Each agent returns prose; normalize into the triage table rows the SKILL.md
describes. For every finding capture: severity, `file:line`, a one-line
description of the problem *and why it matters*, and the exact comment text you'd
post. Deduplicate where two agents flag the same line. Drop anything you can't
tie to a concrete location — a vague finding wastes the author's time and yours.
