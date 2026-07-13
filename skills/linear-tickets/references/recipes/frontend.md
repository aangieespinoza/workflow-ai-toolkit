# Recipe: Frontend

Client work in `apps/web`. Title prefix `[FE]`, label `FRONTEND`. Compose with a
type recipe (feature/bug/…).

## Sections to include

- **`## What`** — the screen/component and the user-facing behavior.
- **`## Scope`** — components, routes, and the API endpoint(s) consumed. If a new
  route is consumed, note adding it to the `templates`/relevant block in
  `apps/web/src/config/api.ts` (a recurring step in this codebase).
- **`## Figma`** — link the specific node. Ask for it if not provided; a frontend
  ticket without a design reference is usually under-specified.

## Specify these in acceptance criteria

- **States:** loading, error, empty/first-run, and success — consistent with
  existing list/detail pages.
- **Optimistic updates:** where used, define rollback-on-error behavior.
- **Authorization in UI:** hide/disable actions the user can't perform — but note
  that enforcement is server-side; the UI gate is UX, not security.
- **Accessibility & consistency:** matches existing patterns (dialogs, kebab
  menus, toasts) rather than introducing new ones.

## Checklist before preview

- [ ] Figma node linked.
- [ ] All states enumerated in AC.
- [ ] Consumed endpoint(s) named and, if new, api.ts wiring noted.
- [ ] Permission-driven visibility described (with the server-side caveat).
