---
name: linear-tickets
disallowed-tools: Edit, Write
description: >-
  Read, analyze, and author <company> Linear tickets in the team's house style.
  Use this whenever the user wants to review what's assigned to them in the
  current Linear cycle, understand a ticket's scope and acceptance criteria and
  plan how to implement it, or draft and create a new ticket (feature, bug,
  backend, frontend, fullstack, improvement, nice-to-have, tech-debt). Trigger
  on: "what's assigned to me", "what should I work on", "current cycle",
  "pick up a ticket", "read/analyze TICKET-###", "how do I implement this ticket",
  "create a ticket", "file an issue", "write this up as a bug/feature", or any
  request to turn an idea, bug report, or scope note into a well-structured
  Linear ticket. ALWAYS preview a ticket in chat and get approval before
  creating it in Linear.
---

# Linear Tickets (<company>)

Two jobs: **(1) pick up & analyze** assigned work from the current cycle, and
**(2) author** new tickets to the team's house style. Both run against the
**<company>** Linear team (the only team in this workspace) via the Linear MCP.

The value of this skill is consistency: every <company> ticket follows the same
skeleton (`## What`, `## Scope`, `## Acceptance criteria`, `## Dependencies`),
carries the right labels (area + type + risk), and is grounded in the codebase
and ADRs before a line is written. Read `references/house-style.md` before
drafting anything — it holds the canonical template and conventions.

## Workspace facts (verify, don't hardcode blindly)

- Team: **<company>** (`team: "<company>"`). Ask the MCP for the current cycle rather
  than assuming a number — cycles roll weekly.
- The user's per-ticket working states (beyond Linear status) are `skip`,
  `approve`, `addressing`. Ask which state applies before assuming pickup order.
- `blockedBy` relations are unreliable in this workspace — sequencing is tracked
  in prose under `## Dependencies / sequencing`, not via Linear blocking links.
- Linear MCP takes content directly: use **real newlines** in markdown bodies,
  not literal `\n`.

---

## Mode 1 — Read an assigned ticket to support the user's plan

Use when the user wants to read one of *their own* assigned tickets and build
their implementation plan from it. The skill's job is to help them *understand*
the ticket deeply — scope, AC, and how it maps to the codebase — so they can
plan the build. It informs their plan; it doesn't replace their judgment, and it
never starts coding.

1. **List candidates.** `list_cycles(team, type:"current")` for the active cycle,
   then `list_issues(assignee:"me", team:"<company>", cycle:"current")`. Show a short
   table: identifier, title, status, priority, labels. If several are open, ask
   which to pick up (and honor `skip`/`approve`/`addressing` if the user uses
   those states).
2. **Read it fully.** `get_issue(id, includeRelations:true)`. Read `## What`,
   `## Scope`, `## Acceptance criteria`, and follow every link: the governing
   **ADR**, the parent **epic**, sibling issues, Figma, and any attachment/PR.
3. **Verify cycle membership** before recommending it as this cycle's work — a
   ticket can be assigned but sit in a past/future cycle.
4. **Produce an implementation analysis** — do NOT start coding (see the global
   approval gates). Cover:
   - **Scope restated** in one or two sentences, plus what's explicitly *out*.
   - **Acceptance criteria** as a checklist you'll hold the work to.
   - **What we'll build**: concrete modules/files/endpoints/migrations, mapped
     to the monorepo (`apps/api`, `apps/web`, `packages/database`, …).
   - **Dependencies / blockers** and the order to tackle them.
   - **Risks & open questions** to resolve before implementation.

Hand this analysis back so the user can turn it into their plan (plans live in
`~/.claude/plans/` per the global CLAUDE.md), and stop. Implementation happens
only after the user approves and explicitly says to start.

---

## Mode 2 — Author a new ticket

Use when the user wants to file work — most often a **feature the team requires**
or **something the user identified** (a bug, a gap, a cleanup, an idea). The goal
is a ticket a teammate could pick up cold.

### Step 1 — Classify (two orthogonal axes)

Every ticket has **one area** and **one type**. They map directly to labels.

- **Area** → `BACKEND` · `FRONTEND` · `FullStack` · `infra` · `QA`
  (title prefix `[BE]` · `[FE]` · `[FS]`; infra/QA use a descriptive prefix).
- **Type** → `Feature` · `Bug` · `Improvement` · `Nice to have` · `Technical Debt`.

If either axis is ambiguous from the request, ask one quick question — the wrong
type/area cascades into the wrong template and labels. When it's a bug, confirm
whether it's a *defect in shipped behavior* (Bug) vs a *known-shortcut cleanup*
(Technical Debt).

### Step 2 — Load the right guidance

Always read `references/house-style.md`. Then read the recipe(s) for the case:

| Case | Recipe |
|---|---|
| Feature (net-new capability) | `references/recipes/feature.md` |
| Bug (defect in shipped behavior) | `references/recipes/bug.md` |
| Backend work | `references/recipes/backend.md` |
| Frontend work | `references/recipes/frontend.md` |
| Fullstack (BE + FE in one) | `references/recipes/fullstack.md` |
| Improvement / Technical Debt | `references/recipes/improvement-and-tech-debt.md` |
| Nice to have | `references/recipes/nice-to-have.md` |

Type and area compose: an `[FS]` feature reads `fullstack.md` + `feature.md`.
`references/examples.md` has two real gold-standard tickets — mirror their depth
and tone.

### Step 3 — Ground before drafting

A descriptive ticket is grounded, not generic. Before writing:

- Search the codebase for the touched modules, existing patterns, precedents
  (e.g. `jobs.service.ts` for the audit-log-in-`$transaction` pattern).
- Find the governing ADR and cross-link it; find related/parent issues via
  `list_issues(query:...)` or `get_issue` and link them inline.
- For frontend/fullstack, ask for or locate the Figma node.

### Step 4 — Draft + PREVIEW (mandatory gate)

Assemble the ticket from the house-style skeleton and the recipe. Then show the
user a full preview **in chat** and wait for approval. Never create first.

The preview must show, clearly labeled:
- **Title** (with `[BE]/[FE]/[FS]` prefix)
- **Description** — the full rendered markdown body
- **Labels** (area + type + optional `risk:low|medium|high`)
- **Priority**, **estimate** (points), **project**, **parent epic**
- A one-line **classification rationale** (why this type/area) and a note of any
  assumptions you made.

Invite edits. Iterate on the preview until the user approves.

### Step 5 — Create on approval

Only after explicit approval, load the write tool
(`ToolSearch "select:mcp__claude_ai_Linear__save_issue"`) and create the issue
with the approved title, description, team, labels, priority, estimate, project,
and parent. Return the **issue URL** and the auto-generated **gitBranchName** so
the user can branch. If the user asked for several related tickets, create the
parent/epic first, then children with `parentId` set.

---

## Guardrails

- **Preview before create, always.** Creating a Linear issue is outward-facing
  and hard to undo cleanly. No exceptions without an explicit "just create it".
- **One ticket = one logical change.** If a request spans clearly separable work
  (a migration + an endpoint + a UI), propose splitting into linked tickets
  rather than one sprawling issue — mirror how the team already sequences work.
- **Don't invent contracts.** If the data shape or API contract isn't settled in
  an ADR or the code, flag it as an open question in the ticket instead of
  fabricating field names.
- **Respect the global CLAUDE.md**: analysis before code, approval gates, and
  the standard API error envelope when specifying backend AC.
