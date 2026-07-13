# <company> ticket house style

The canonical skeleton every <company> ticket follows. Recipes in `recipes/` refine
this per case; they don't replace it. Derived from real accepted tickets
(see `examples.md`).

## Title

`[BE] | [FE] | [FS] <concise action — include the route/endpoint when relevant>`

- `[BE]` backend only · `[FE]` frontend only · `[FS]` fullstack (both sides in one issue).
- infra/QA tickets use a plain descriptive title (optionally `[Infra]` / `[QA]`).
- Prefer the concrete artifact in the title: `[BE] POST /templates + schema migration`
  beats `[BE] Template creation`. A reader should know the surface area at a glance.

## Description skeleton

Use the sections that apply, in this order. Keep prose tight; bullets over paragraphs.

```markdown
## What
1–3 sentences: the change and why it's needed now. Link the issue(s) this
extends, merges, or replaces inline (see cross-linking below).

## Contract (ADR-xxx)          ← backend/data changes
The data or API contract, referencing the governing ADR. List field names,
nullability, and what is explicitly NOT in the snapshot.

## Scope
Bulleted, grouped by sub-area (Migration / Endpoint / UI). State what is
explicitly OUT of scope so the boundary is unambiguous.

## Backend                      ← fullstack tickets only
## Frontend                     ← fullstack tickets only
Split the two sides so each is independently actionable.

## Acceptance criteria
Verifiable bullets. Cover: happy path, authorization, tenant/org isolation,
edge cases / idempotency, and the error-envelope behavior for invalid input.

## Dependencies / sequencing
Prose + inline issue links. `blockedBy` is unreliable in this workspace — record
order here. Note any ADR that must be accepted before implementation starts.

## Figma                        ← frontend/fullstack
Link to the specific Figma node.
```

## Labels (compose all that apply)

- **Area (exactly one):** `BACKEND` · `FRONTEND` · `FullStack` · `infra` · `QA`
- **Type (exactly one):** `Feature` · `Bug` · `Improvement` · `Nice to have` · `Technical Debt`
- **Risk (optional):** `risk:low` · `risk:medium` · `risk:high` — add for schema
  changes, auth-touching work, or anything with blast radius.
- Other situational labels: `needs-integration-test`, `qa-report`, `infra`.

## Other fields

- **Priority:** Urgent / High / Medium / Low. Most feature work is Medium; demo
  blockers and regressions trend High/Urgent.
- **Estimate:** points (1, 2, 4…). A single endpoint or migration is usually 1–2.
- **Project:** the product area (e.g. Templates, Mail Pieces, Performance Reports).
- **Parent:** the epic issue the work rolls up to. Set `parentId` when known.

## Conventions baked into <company> tickets

These recur across the codebase — specify them in AC so they aren't forgotten:

- **Audit trail:** any data mutation writes one `audit.AuditLog` row
  (`action`, `entityType`) inline in the *same* `$transaction` as the write.
  Precedent: `apps/api/.../jobs.service.ts`.
- **Tenant isolation:** every read/write is scoped to the caller's org. Return
  404 when a resource isn't in the caller's org; 403 for role/authorization
  failures. Authorization is enforced server-side, never UI-only.
- **Validation envelope:** invalid input returns the standard error envelope
  (`code: VAL_xxx`, `detail: string[]`) — see the global CLAUDE.md.
- **Prisma migrations:** state whether the migration is destructive; if the
  table is empty say so. Regenerate and export types from `packages/database`.
- **Soft-delete pattern:** prefer `is_active = false` + retained row over hard
  delete; deleting an already-inactive row is a no-op success (no second audit row).

## Cross-linking

Reference related issues inline so Linear renders them as chips, e.g.
`<issue id="..." href="https://linear.app/<company>/issue/TICKET-543/...">TICKET-543</issue>`.
If you only have the identifier, a plain `TICKET-543` still helps; resolve the full
href with `get_issue` when you can.
