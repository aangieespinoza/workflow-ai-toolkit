# Codebase investigation methodology

The half of discovery that a ticket can't give you: what the code *actually* is.
The goal is a brief grounded in real file paths and verified facts, not the
ticket's optimistic description. Reconcile the two.

Use the `Explore` agent to fan out (it reads excerpts across many files and
returns conclusions) rather than reading files one by one. Stay within the
exploration budget — investigate enough to ground the brief, then write.

## What to find

1. **Where the work lives / will live.** Locate the module/package. In the <company>
   monorepo that's usually `apps/api/src/modules/<area>` (NestJS),
   `apps/web/src/...` (frontend), or `packages/<pkg>` (database, core, shared).
2. **Patterns & precedents to follow.** How does the codebase already do the
   thing this ticket needs? Find the closest existing example and cite it — the
   plan should follow it, not invent a new shape. Examples seen here: the
   strategy/registry pattern, audit-log-in-`$transaction` (`jobs.service.ts`),
   tenant-scoped queries, the `VAL_` error envelope.
3. **Integration points.** What does this connect to? Controllers/callers, Prisma
   schema models, DTOs/validators, and config wiring (a new frontend route gets
   added to `apps/web/src/config/api.ts`, for instance).
4. **Create-vs-modify + gaps.** Which files are new, which are edited, and what's
   missing between the ticket's assumptions and reality.

## Verify dependencies — the step people skip

A ticket saying a prerequisite is "done" does **not** mean the code is in the
branch you'll build on. Check it yourself:

```bash
# Does the symbol/module the ticket depends on actually exist?
grep -rl "PerformanceReportsReadRepository" apps/api/src
find apps/api/src -type d -iname '*report*'
```

If the symbols aren't there, the dependency isn't merged — that's a **blocker**
for the brief's "Ready for planning?" section, not a detail to gloss over. This
is the single highest-value check in discovery: it's how you avoid planning
against code that doesn't exist yet (the TICKET-571 → TICKET-570 case).

## Turning findings into "What we need to build"

For each AC or scope item from the ticket, ask: what in the code has to change to
satisfy it? Map it to concrete files. The result is the required-work list —
*what*, mapped to files. Leave the *how* (task order, verification steps) to
`plan-builder`; the brief supplies the grounded raw material, the plan does the
decomposition.

## Quality bar

- Every finding cites a path. No path → it's a guess, mark it an open question.
- Prefer "I checked X and found Y" over "X probably does Y."
- Distinguish verified facts from assumptions explicitly — the brief's value is
  that a reader can trust it.
