# Recipe: Backend

Server-side work in `apps/api` (NestJS) and/or `packages/database` (Prisma).
Title prefix `[BE]`, label `BACKEND`. Compose with a type recipe (feature/bug/…).

## Sections to include

- **`## Contract (ADR-xxx)`** — when the change touches the data model or an API
  shape. Name every field with type + nullability, and state what is explicitly
  excluded. Reference the governing ADR; if none exists and the shape isn't
  settled, flag it as an open question rather than inventing it.
- **`## Scope`** grouped as **Migration** and **Endpoint** when both apply.

## Specify these in acceptance criteria (<company> conventions)

- **Persistence + validation:** endpoint persists the expected shape; invalid
  bodies return the standard validation envelope (`VAL_xxx`, `detail: string[]`).
- **Audit trail:** exactly one `audit.AuditLog` row written atomically in the
  same `$transaction` as the mutation (precedent: `jobs.service.ts`).
- **Tenant isolation:** scoped to the caller's org; 404 when a resource isn't in
  the org, 403 for role/authorization failures.
- **Migrations:** say whether destructive; if the table is empty, say so.
  Prisma types regenerated and exported from `packages/database`.
- **Idempotency** where relevant (e.g. soft-delete of an already-inactive row).

## Checklist before preview

- [ ] Contract references an ADR (or flags the gap).
- [ ] Route(s) named in the title.
- [ ] Audit + tenant + validation-envelope AC present for any mutation.
- [ ] Migration destructiveness stated; `risk:*` label if schema-touching.
