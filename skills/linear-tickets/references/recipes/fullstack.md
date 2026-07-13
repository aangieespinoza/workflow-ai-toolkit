# Recipe: Fullstack

One issue that spans backend and frontend. Title prefix `[FS]`, label `FullStack`.
Use only when the two sides are small and tightly coupled (e.g. one endpoint + its
single consumer). If either side is substantial, prefer two linked tickets — the
team routinely splits `[BE]` and `[FE]` and sequences them in prose.

## Structure

Split the body into **`## Backend`** and **`## Frontend`** sections so each is
independently actionable, then a shared **`## Acceptance criteria`** that ties
them together. See TICKET-561 in `examples.md` for the canonical shape.

- **`## Backend`** — follow `backend.md`: endpoint, authorization with exact
  status codes, audit row in `$transaction`, tenant isolation, idempotency.
- **`## Frontend`** — follow `frontend.md`: states, optimistic update + rollback,
  permission-driven visibility, Figma.
- **`## Acceptance criteria`** — cover both sides and their interaction (e.g.
  "non-owner gets 403 AND never sees the action").
- **`## Figma`** — the design node.

## Checklist before preview

- [ ] Backend and Frontend are separate, self-contained sections.
- [ ] AC spans both sides + the cross-cutting behavior.
- [ ] Considered whether this should be split into `[BE]` + `[FE]` instead.
- [ ] Figma linked.
