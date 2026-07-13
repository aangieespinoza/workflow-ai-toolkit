# Discovery Brief — {feature / task name}

**Ticket:** {TICKET-### + URL, or "none"}
**Brief file:** `~/.claude/plans/{slug}-discovery.md`
**Feeds plan:** `~/.claude/plans/{slug}.md`
**Date:** {YYYY-MM-DD}

## Ticket summary (from linear-tickets)

- **Goal:** {the outcome the ticket wants}
- **Scope / AC:** {bullets — the acceptance criteria to satisfy}
- **Out of scope:** {explicit boundaries}
- **Links:** parent epic, ADR(s), related issues

## Codebase findings

Grounded in the actual repo — every point cites a file path.

- **Where it lives / will live:** {modules, packages — e.g. `apps/api/src/modules/...`}
- **Patterns & precedents to follow:** {e.g. strategy pattern in `report.registry.ts`; audit row in `$transaction` per `jobs.service.ts`}
- **Integration points:** {callers, schema models, DTOs, config wiring like `apps/web/src/config/api.ts`}
- **Verified dependencies:** {checked in code — e.g. "✅ `Document` model present in schema.prisma" / "⛔ `PerformanceReportsReadRepository` NOT found — TICKET-570 not merged yet"}
- **Gaps / create-vs-modify:** {what must be newly created vs. what already exists and is modified}

## What we need to build (derived)

The concrete required work, grounded in the findings above — this is what
`plan-builder` turns into a file map + tasks. Keep it to *what*, not the task
breakdown.

- {requirement} → {file(s) it touches}
- {requirement} → {file(s)}

## Open questions & risks

- {unknowns to resolve before planning; verified blockers with their impact}

## Ready for planning?

- **Status:** {Ready → hand to plan-builder | Blocked → what must resolve first}
- **Slug for the plan:** `{slug}`
