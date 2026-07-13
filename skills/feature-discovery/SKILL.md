---
name: feature-discovery
description: >-
  Turn a Linear feature/ticket into a codebase-grounded discovery brief, then
  hand that brief to plan-builder. This is the bridge that makes plans strong:
  it combines the ticket's scope/AC with real findings from the codebase (which
  files, which patterns to follow, what must be built, which dependencies
  actually exist) into one intermediate artifact that feeds planning. Use when
  the user is committing to build a ticket and wants the groundwork done before
  planning: "let's build TICKET-###", "kick off this feature", "analyze the ticket
  and figure out what we need to build", "prep TICKET-### for planning", "do the
  discovery for X", "what do we actually need to change for this ticket". It runs
  the linear-tickets analysis, investigates the codebase, writes a discovery
  brief, and (once the brief is solid) invokes plan-builder. Produces the brief
  and plan only — never implements without explicit approval.
---

# Feature Discovery

The front of the feature workflow: **ticket + codebase → discovery brief →
plan**. A plan is only as good as its grounding; this skill does the grounding
first — reconciling what the ticket *asks for* with what the code *actually
is* — and captures it in one intermediate brief that `plan-builder` consumes.

Chain: `linear-tickets` (read ticket) → **this** (investigate + brief) →
`plan-builder` (brief → plan) → implement → `my-pr-review` (self-review).

## When this vs. neighbors

- **This skill** — you're going to *build* a ticket and want grounded discovery
  before planning.
- `linear-tickets` (Mode 1) — a lighter read/understand of a ticket; this skill
  *uses* it for the ticket half, then goes deeper into the code.
- `plan-builder` — turns the brief into a plan; this skill hands off to it.

## Process

Stay within the exploration budget (~10 tool calls, per CLAUDE.md): investigate
enough to ground the brief, then write it. Use the `Explore` agent to fan out
across the codebase rather than reading files serially.

### 1. Analyze the ticket

Run `linear-tickets` Mode 1: scope, AC, out-of-scope, parent epic, linked ADRs,
and stated dependencies. This is the "what the ticket asks for" half.

### 2. Investigate the codebase

The "what the code actually is" half — the value this skill adds. Follow
`references/codebase-investigation.md`. In short:
- Locate where this work lives / will live (modules, packages).
- Find **patterns and precedents** to follow (e.g. the strategy pattern in
  `report.registry.ts`, audit-in-`$transaction` in `jobs.service.ts`).
- Map **integration points** (callers, schema, DTOs, config like
  `apps/web/src/config/api.ts`).
- **Verify dependencies actually exist in the code** — do not trust a ticket's
  word. A "done" prerequisite ticket may not be merged (the TICKET-571 → TICKET-570
  case: the read module wasn't in the repo yet). Grep for the symbols; if
  they're absent, that's a blocker, not a footnote.
- Identify **create-vs-modify** and the gaps between ticket and reality.

### 3. Write the discovery brief

Fill `assets/discovery-brief-template.md` and save to
**`~/.claude/plans/<slug>-discovery.md`** (same slug you'll use for the plan).
Every finding cites a real file path. The brief's "What we need to build"
section is the bridge — it's what `plan-builder` turns into a file map and tasks.

Present the brief. This is the checkpoint where the user reacts, adds context,
and corrects course before any planning effort is spent.

### 4. Gate, then hand off to plan-builder

- **If blocked** (a dependency isn't merged, a contract isn't settled, AC is
  ambiguous): say so plainly and stop. Don't plan around fiction — resolve the
  blocker or descope first.
- **If ready:** invoke `plan-builder` with the brief as input. It produces the
  plan (file map, verifiable tasks, risks, self-review checkpoint) and stops for
  approval. Implementation waits for an explicit "implement it" (CLAUDE.md).

## Guardrails

- **Verify, don't assume.** Every "X exists / X is done" claim is checked in the
  code before it goes in the brief. Unverified assumptions are the main way plans
  go wrong. If you haven't confirmed it, mark it an open question.
- **Ground every finding in a file path.** A finding you can't point to is a
  guess.
- **The brief is the contract.** It hands `plan-builder` grounded findings +
  required work; `plan-builder` owns decomposition into tasks. Don't duplicate
  the task breakdown in the brief.
- **Stop at the plan.** This chain plans and gets approval — it never rolls into
  coding on its own (CLAUDE.md approval gates).
