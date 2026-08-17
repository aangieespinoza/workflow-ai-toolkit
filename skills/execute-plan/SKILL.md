---
name: execute-plan
disable-model-invocation: true
effort: high
description: >-
  Take an already-approved, saved implementation plan and drive it to a green, self-reviewed
  diff via multi-agent orchestration (the Workflow engine — this is the "ultracode" execution
  path). Use AFTER a plan exists and is approved, when the user wants the plan executed with
  orchestration rather than hand-implemented: "execute plan TICKET-###", "run the plan at <path>",
  "orchestrate this plan", "ultracode this plan", "build out ~/.claude/plans/<slug>.md". Reads
  the plan, maps its independently-verifiable tasks onto a Workflow fan-out, implements TDD-first
  until `pnpm validate` + tests are green, self-reviews, then HARD-STOPS for commit/PR approval.
  Do NOT use to CREATE a plan (that's plan-builder) or for discovery (feature-discovery); this is
  the execution stage only. Invoking this skill is itself the explicit opt-in to run Workflow.
---

# execute-plan

The **orchestrated execution** stage. Your normal flow is: `feature-discovery` → (adjust) →
`plan-builder` (saves to `~/.claude/plans/`) → **this skill**. It replaces the old
`promptify` → paste-an-ultracode-prompt handoff: invoking `execute-plan` is a valid Workflow
opt-in on its own — no `ultracode` keyword needed (though passing `ultracode` as an arg means
"max exhaustiveness": larger finder/verify pools).

## Preconditions (verify first, don't assume)

- A plan file exists and is **approved**. Resolve the arg to a path: an explicit
  `~/.claude/plans/*.md`, or `TICKET-###` → find the matching plan in `~/.claude/plans/`.
  If none is found, **stop and say so** — never fabricate a plan or run against a stale one.
- Read the plan fully. It should already carry a **task breakdown of independently verifiable
  tasks** (plan-builder's output) — that IS the fan-out unit. If the plan has no such
  decomposition, stop and route back to `plan-builder`.

## Non-negotiable gates (from `~/.claude/CLAUDE.md`)

- Runs autonomously **only up to green + self-review.** Then **HARD-STOP** — never commit,
  push, open a PR, or merge without an explicit "yes" for that step. "One-shot to green"
  means unattended *implementation*, not unattended *shipping*.
- The user creates the branch and owns commits unless they explicitly delegate.
- Stay inside the plan's scope; anything new goes to the plan's Followups, not the diff.

## The orchestration (call the `Workflow` tool)

Invoking this skill authorizes the Workflow call. Build a Workflow whose `meta.phases` mirror
the plan, roughly:

1. **Understand** — parallel readers over the files the plan names → confirm the task graph and
   which tasks touch disjoint file sets (parallelizable) vs shared files (must serialize).

2. **Implement (TDD, fan-out)** — one agent per independent task. Each: write the failing test
   first (`<company>-api-testing` for API, `.claude/rules/web-testing.md` for web), implement, run
   the affected tests. **Parallel file-editing safety (see memory `parallel-agents-shared-workspace`):**
   run parallel edit-agents with `isolation: 'worktree'`, or serialize tasks that touch the same
   files — never let parallel agents mutate the same working tree in place (a stray git op
   corrupts another agent's tree). Sequence tasks along the plan's stated dependencies.

3. **Integrate + drive to green** — reconcile the task outputs, then loop: `pnpm validate`
   (lint + typecheck + format:check) + affected tests → fix failures → repeat until green. If
   typecheck fails locally but CI would be green, suspect a **stale shared `dist`** — rebuild
   `@<company>/database` / `@<company>/types` before assuming a code bug. The format hook covers prettier.

4. **Self-review (adversarial)** — review the full diff against the plan and CLAUDE.md
   (mirror `my-pr-review` / the `pr-review-toolkit` lenses); fix real findings. Diff against the
   branch's **actual base**, not current `main`.

Read each phase's result before launching the next (per the Workflow guidance — you stay in the
loop across phases). For a large plan, prefer **several sequential Workflows** (one per plan
phase) over one giant script, so a mid-run failure is contained and inspectable.

## After green

Present a tight summary: what each task delivered, the validate/test result (with evidence,
not assertions), and the self-review findings + fixes. Then **stop for approval.** On "yes":
commit atomically, and hand to `agent-pr-creator` to open the PR (still gated). Never merge.

## Notes

- If the plan surfaces unexpected state mid-run (schema drift, conflicting branch, a dependency
  that doesn't exist), stop and describe it — don't let an agent invent a workaround silently.
- Token cost is expected to be high here by design; that's the ultracode tradeoff. Keep it a
  deliberate, explicit invocation (hence `disable-model-invocation`).
