# Gold-standard examples (real <company> tickets)

Mirror the depth, structure, and tone of these when drafting. Both are accepted,
shipped tickets.

---

## Example A — Backend feature + migration (TICKET-543)

**Title:** `[BE] POST /templates + schema migration`
**Labels:** BACKEND · **Priority:** Medium · **Estimate:** 2 · **Project:** Templates · **Parent:** TICKET-82

```markdown
## What

Foundation for the Templates module: the schema migration plus the create
endpoint. This is the first writer of the new template contract defined in
ADR-033, so the migration travels with it.

## Contract (ADR-033)

Template snapshot = Step 1 config only: `name`, `description`, `departmentId`,
`customField1..3`, `printDuplex`, `printColor`, `envelopeType`, `certifiedMail`,
`expeditedFulfillment`, `createdById` (NOT NULL), `usageCount`, `lastUsedAt`,
`isActive`. No send/split mode, no pages-per-piece, no address band — split is
an upload-time decision.

## Scope

Migration (table is empty, so non-destructive):

* ADD `departmentId` (uuid, FK to Department, nullable), `customField1..3` (text, nullable)
* ALTER `createdById` to NOT NULL
* DROP `isFavorite`
* CREATE `TemplateFavorite` (templateId, userId, createdAt; PK(templateId, userId))

Endpoint:

* `TemplatesModule` (controller + service); keep S3/serialization out — pure domain CRUD.
* `POST /templates`: class-validator DTO, sets `createdById` = current user,
  persists the snapshot. Writes one `audit.AuditLog` row inline in the same
  `$transaction`, following the `jobs.service.ts` precedent.

## Acceptance criteria

* Migration applies cleanly; Prisma types regenerated and exported from `packages/database`.
* `POST /templates` persists the snapshot and `createdById`; invalid bodies
  return the standard validation envelope.
* Exactly one audit row written atomically with the insert.
* Template is scoped to the caller's org (tenant isolation).

## Dependencies / sequencing

* Hard blocker for TICKET-82 (FE create form) and TICKET-80 (BE GET /templates): both
  need this migration. `blockedBy` is unreliable here, so sequence is tracked in prose.
* Gated on ADR-033 accepted/committed before implementation starts.
```

Why it's good: the contract is explicit (names + nullability + what's excluded),
scope is grouped (Migration / Endpoint), AC is verifiable and names the audit +
tenant conventions, and sequencing is prose with the ADR gate called out.

---

## Example B — Fullstack, soft-delete + authorization (TICKET-561)

**Title:** `[FS] Delete a template (soft-delete, owner or Admin) + confirmation`
**Labels:** FullStack · **Priority:** Medium · **Estimate:** 2 · **Project:** Templates · **Parent:** TICKET-86

```markdown
## What

Soft-delete a template from the list: a `DELETE` endpoint with owner-or-Admin
authorization, plus a confirmation dialog and kebab entry on the front. Merged
from the former TICKET-85.

## Backend

* Endpoint: `DELETE /templates/:id`.
* Soft-delete: set `is_active = false`; the row is retained. `GET /templates`
  already excludes `is_active = false`.
* Authorization (server-side): allowed only when caller is the template's
  `createdById` OR has role ADMIN. Otherwise 403. 404 if not in the caller's org.
* One `audit.AuditLog` row (`template.deleted`) inline in the same `$transaction`.
* Idempotency: deleting an already-inactive template is a no-op success.

## Frontend

* Kebab "Delete" entry visible only when the user owns the template or is Admin.
* Confirmation dialog before the call.
* On success, remove the row immediately; optimistic with rollback on error.
* Loading/error states consistent with existing list pages.

## Acceptance criteria

* Owner and Admin can delete; a non-owner non-Admin gets 403 and never sees Delete.
* Deleted template disappears immediately and stays gone across reloads; row
  retained with `is_active = false`.
* Exactly one audit row per real deletion; re-deleting is a no-op.
* Deleting does not affect jobs already submitted from the template.

## Dependencies / sequencing

* Depends on the templates module / list (TICKET-543 / TICKET-544 / TICKET-546).
* Within the ADR-033 contract — no new ADR.

## Figma

https://www.figma.com/design/iesFEBeLum5yEXVh0Ed7Lf/<company>-Platform?node-id=332-176700
```

Why it's good: Backend and Frontend are split into independently actionable
sections, authorization is specified server-side with exact status codes,
idempotency and the audit row are explicit, and AC ties both sides together.
