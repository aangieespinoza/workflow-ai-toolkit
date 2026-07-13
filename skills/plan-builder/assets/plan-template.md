# {Plan title — short, human}

**Plan file:** `~/.claude/plans/{slug}.md`
**Ticket:** {TICKET-### + URL, or "none"}
**Date:** {YYYY-MM-DD}

## Context

{The core feature/problem: what this is about and why it matters now. Link the
ticket, governing ADR(s), and any related plan or PR.}

## Goal

{One or two sentences — the outcome. What is true when this is done.}

## Scope check

- **In scope:** {bullets}
- **Out of scope:** {explicit boundaries — what this deliberately does NOT touch}
- **Assumptions:** {what we're taking as given}

## Tooling (agents / skills / hooks)

{Which tools this plan relies on and when. Example:}
- `linear-tickets` — read ticket scope/AC (done; see Context)
- `pr-review-toolkit` agents — review during implementation
- `my-pr-review` — self-review before pushing (see Verification)
- hooks: {e.g. typecheck PostToolUse, or "none"}

## File structure

Map every file and its single responsibility *before* the tasks — this locks in
the decomposition (see the decomposition principles this plan follows).

| File | Action | Responsibility |
|------|--------|----------------|
| `apps/api/.../x.strategy.ts` | add | one clear responsibility |
| `apps/api/.../registry.ts` | edit | register the new strategy |

## Code conventions (plan-specific only)

{Universal rules live in core-coding-standards + the global CLAUDE.md — don't
restate them. List only conventions specific to THIS plan, e.g.:}
- Follow the strategy pattern established in `report.registry.ts`.
- New validation errors use `VAL_` codes per the error envelope.

## Tasks

Each task stands alone and has a checkable finish line.

### Task 1: {name}
- **Intent:** {one line}
- **Files:**
  - `+ path/to/new.ts`
  - `~ path/to/edited.ts`
  - `- path/to/removed.ts`
- **Verify:** {test command or observable behavior that proves it's done}
- **Depends on:** {none | Task N}

### Task 2: {name}
- **Intent:** …
- **Files:** …
- **Verify:** …
- **Depends on:** Task 1

## Risks & open questions

{Unknowns to resolve before/at implementation: dependencies not yet merged,
unsettled contracts, ambiguous AC. If something blocks the plan, say so plainly.}

## Verification & self-review

- **Per task:** run each task's Verify step.
- **Before pushing:** run the `my-pr-review` skill (self-review) on the branch
  diff against its actual base.
- **Whole change:** {e2e/integration checks, migration safety, etc.}

## Expected output

{What "done" delivers: the observable result, the PR, passing tests, and which
acceptance criteria are satisfied.}

---

## Followups

{Out-of-scope improvements spotted while planning — captured here, NOT
implemented as part of this plan.}
