---
name: plan-builder
effort: high
description: >-
  Build an implementation plan for a task, ticket, or feature in the user's
  house plan format, then stop for approval — never roll straight into coding.
  Use whenever the user wants to plan work: "plan this", "make a plan for
  TICKET-###", "let's plan out this feature", "how should we build X", "write a
  plan before we start", "help me plan the implementation", or when Claude enters
  plan mode for anything more than a trivial change. It researches the task
  (reading the ticket, ADRs, and existing code), maps the file structure, breaks
  the work into independently verifiable tasks, writes the plan to
  ~/.claude/plans/, and presents it for approval. Produces the plan only — waits
  for an explicit "implement it" before any code is written.
---

# Plan Builder

Turn a task/ticket/feature into a concrete, reviewable implementation plan in the
house format, saved to `~/.claude/plans/`, then stop for approval. This is the
"think through *how* to build it" step from the global CLAUDE.md — planning is
its own phase, separate from execution.

The plan's job is to lock in decomposition decisions *before* code, so execution
(often a fresh session) can proceed task-by-task with confidence. A good plan
makes each task independently executable and verifiable.

## When this vs. neighbors

- **This skill** — authoring the implementation plan (the "how").
- `linear-tickets` (Mode 1) — reading/analyzing an assigned ticket. Its analysis
  is the *input* to this skill; if a `TICKET-###` is in play, start there.
- `my-pr-review` — runs *after* implementation (referenced in the plan's
  Verification step), not during planning.

## Process

Respect the exploration budget (~10 tool calls, per CLAUDE.md): research enough
to decompose confidently, then draft — don't boil the ocean.

### 1. Understand the task

- If a `TICKET-###` is referenced, read it (use `linear-tickets` Mode 1): scope, AC,
  linked ADRs, parent epic, dependencies.
- Read the **ADRs and existing code** for the touched area — follow established
  patterns, find precedents. Don't design against assumptions the codebase or an
  ADR has already settled (CLAUDE.md).
- Note unknowns as you go; they become **Risks & open questions**.

### 2. Map the file structure BEFORE tasks

This is where decomposition gets locked in. List every file to create/modify and
its single responsibility. Apply `references/file-structure-guidance.md` — focused
files, split by responsibility not layer, follow existing patterns. The file map
drives the task breakdown.

### 3. Decompose into independently verifiable tasks

Each task must stand on its own. For every task capture:
- **Intent** — one line: what it accomplishes.
- **Files** — `+` add, `~` edit, `-` delete.
- **Verify** — how you know it's done (a test command, an observable behavior).
- **Depends on** — prior task(s), or none. Sequence explicitly (the `blockedBy`
  relation is unreliable in this workspace — order lives in the plan).

A task without a Verify step isn't a task, it's a wish — every task needs a
checkable finish line.

### 4. Write the plan

Fill `assets/plan-template.md` and save to **`~/.claude/plans/<slug>.md`**, where
`<slug>` is a short, human kebab-case name for the task (Claude's plan-mode
convention, e.g. `report-queries.md`). Include a `TICKET-###-` prefix only if it
genuinely helps you find it later; short and memorable beats exhaustive. Never
save plans inside a project repo (CLAUDE.md).

Write incrementally — flush each section to disk as it's done rather than holding
the whole plan in memory (CLAUDE.md exploration rule).

### 5. Present for approval, then STOP

If in plan mode, present via ExitPlanMode; otherwise show the plan and point to
the saved file. Then stop. Do **not** start implementing — wait for an explicit
"implement it" / "execute" (CLAUDE.md "When I approve an approach"). On approval,
execution can continue here or, for a clean context, hand off to a fresh session
opened from the execution workspace with the plan path.

## Guardrails

- **Plan only.** No code until explicit approval — this skill's whole purpose is
  the planning phase.
- **Goal before scope.** State the outcome, then bound it; out-of-scope items are
  explicit, and stray improvements go in **Followups**, not into the plan's tasks
  (Scope Discipline).
- **Every task is verifiable** and its dependencies are sequenced in prose.
- **Surface unknowns.** If a dependency isn't merged or a contract isn't settled,
  it goes in Risks & open questions — don't plan around fiction.
- **Don't restate universal rules.** Code conventions live in
  `core-coding-standards` + the global CLAUDE.md; the plan lists only
  plan-specific deviations.
