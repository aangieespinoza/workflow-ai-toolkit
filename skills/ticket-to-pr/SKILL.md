---
name: ticket-to-pr
disable-model-invocation: true
effort: high
description: >-
  End-to-end conductor that drives a single <company> Linear ticket from discovery all the way to
  a merge-ready PR, with hard approval stops at every gate. Use when the user commits to
  delivering a ticket and wants the whole pipeline run — "take TICKET-### to a PR", "ticket to
  pr", "drive TICKET-### end to end", "build and ship TICKET-###", "run the full pipeline on this
  ticket". It does NOT invent workflow — it chains the existing skills (feature-discovery →
  plan-builder → TDD implementation → my-pr-review → agent-pr-creator) and enforces the house
  approval gates between phases. Produces a discovery brief, a plan, tested code, and an open
  PR — and NEVER commits, pushes, opens a PR, or merges without explicit approval. This is the
  bridge that was missing: feature-discovery + plan-builder stop at the plan; this carries it
  the rest of the way. Do NOT use for reviewing others' PRs (pr-review-triage) or for a bare
  planning request with no intent to implement (plan-builder alone).
---

# ticket-to-pr

A **thin conductor**. Every phase is an existing skill; this skill only sequences them and
holds the approval gates. Do not re-implement discovery, planning, testing, review, or PR
creation here — invoke the owning skill.

## Non-negotiable gates (from `~/.claude/CLAUDE.md`)

- **Never** commit, push, open a PR, or merge without an explicit "yes" for that specific step.
- After a plan is approved, **stage the concrete steps first** — do not roll straight into code.
- **Ground existence claims** (B2 rule): before saying a helper/table/endpoint doesn't exist,
  cite the path or say "I didn't find it." Reuse existing patterns; don't add packages/files
  the audit didn't justify.
- **List the change-set** and confirm before touching files outside the ticket's scope.
- The user creates the branch and handles commits unless they explicitly delegate.

## Pipeline

Announce the current phase before each step. Stop and wait at every 🛑.

1. **Discovery** — invoke `feature-discovery` on the ticket. It reads the Linear ticket + linked
   spec, audits the codebase for reuse, and writes a discovery brief to `~/.claude/discovery/`.
   🛑 Confirm the brief's scope with the user before planning.

2. **Plan** — `feature-discovery` hands to `plan-builder` (or invoke it directly). Propose the
   `TICKET-###-<slug>` filename up front, write the plan to `~/.claude/plans/`, cross-link the brief.
   🛑 **Stop for plan approval.** Do not write code yet.

3. **Stage the how** — once approved, lay out the concrete implementation steps (files, order,
   tests to write). 🛑 Wait for "implement it" / "execute" before any edit.

4. **TDD implementation** — write the **failing tests first** against the acceptance criteria,
   using the repo's conventions:
   - API → `<company>-api-testing` (Jest unit + `*.int-spec.ts` integration).
   - Web → `.claude/rules/web-testing.md` (Vitest + RTL); use `/verify` when tests exist.
   Then implement full-stack until green. Reuse helpers per `.claude/rules/*code-reuse*`.

5. **Validate gate** — before each atomic commit run `pnpm validate` (lint + typecheck +
   format:check) and the affected tests. If typecheck fails locally but CI is green, suspect a
   **stale shared `dist`** — rebuild `@<company>/database` / `@<company>/types` (`pnpm --filter … build`)
   before assuming a code bug. The format hook handles prettier on edited files.

6. **Self-review** — invoke `my-pr-review` on the diff (against the branch's actual base, not
   current `main`). Address findings before opening the PR.

7. **Open PR** — 🛑 with approval, invoke `agent-pr-creator` to fill the template from the diff
   and open the PR via `gh` (actor `<your-github-handle>`). Post the discovery/plan cross-links.

8. **Merge** — **hard stop.** Never merge. Hand back to the user.

## Notes

- If the ticket spans multiple sub-issues, confirm whether to do one PR or split before step 4.
- If any phase surfaces unexpected state (schema drift, conflicting branch, missing dependency),
  describe it and ask — do not work around it silently.
