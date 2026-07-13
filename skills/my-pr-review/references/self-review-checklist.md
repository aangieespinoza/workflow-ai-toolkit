# Self-review checklist (<company> + global conventions)

Walk this after the agents run — it catches the things reviewers repeatedly flag
on this codebase. Not every item applies to every PR; skip what's irrelevant and
call out what's missing.

## Correctness & scope
- [ ] The diff does exactly what the ticket's scope/AC says — nothing extra.
- [ ] No debugging leftovers: `console.log`, `.only`/`.skip` in tests, commented-out code, TODOs without a ticket.
- [ ] Edge cases handled: empty/null, first-run, concurrent access where relevant.
- [ ] Errors aren't silently swallowed; catches log or rethrow with context.

## Backend (NestJS + Prisma)
- [ ] **Tenant isolation:** every query is org-scoped; 404 when a resource isn't in the caller's org, 403 for authz failures. Authorization is server-side, not UI-only.
- [ ] **Audit trail:** data mutations write one `audit.AuditLog` row in the *same* `$transaction` (precedent: `jobs.service.ts`).
- [ ] **Validation envelope:** invalid input returns the standard shape (`code: VAL_xxx`, `detail: string[]`); no stack traces leaked.
- [ ] **Migrations:** destructive vs. non-destructive noted; Prisma types regenerated + exported from `packages/database`; migration is reversible or the risk is called out.
- [ ] Input validated at the boundary (class-validator DTOs).

## Frontend (apps/web)
- [ ] Loading / error / empty states handled, consistent with existing pages.
- [ ] Optimistic updates roll back on error.
- [ ] Permission-gated UI hides actions the user can't take (with the server-side enforcement still in place).

## Types & quality
- [ ] No `any`; strict-mode clean. Types express real invariants, not loose bags.
- [ ] SOLID / composition; modules stay small and focused. No needless duplication.

## Tests
- [ ] New behavior has unit tests (services/repositories); critical flows have e2e.
- [ ] Tests assert behavior, not implementation detail. They fail if the change regresses.
- [ ] `pnpm --filter @<company>/<pkg> test` and typecheck pass locally — with output seen, not assumed.

## Security & secrets
- [ ] No secrets/tokens/PII in code or logs; config via env vars.
- [ ] New endpoints considered against the OWASP Top 10.

## PR hygiene
- [ ] Title/description explain the *why*; linked to the TICKET-### ticket.
- [ ] Diff is one logical change; unrelated churn (formatting, renames) split out or called out.
