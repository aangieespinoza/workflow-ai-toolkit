# Recipe: Feature

A net-new capability the product didn't have. Compose with an area recipe
(`backend.md` / `frontend.md` / `fullstack.md`) for the technical sections.

**Label:** `Feature` + area label. **Priority:** usually Medium (High if it
gates a demo/release). **Estimate:** size honestly; split if > ~4 points.

## Emphasize

- **`## What`** leads with *user/product value*: what becomes possible and why
  now. Link the epic and any predecessor issues.
- **`## Scope`** draws a tight boundary. New features attract scope creep —
  explicitly list what's *out* (v2 concerns, adjacent surfaces) so the ticket
  stays one logical change.
- **`## Acceptance criteria`** describes observable behavior, not implementation.
  Include the empty/first-run state, permissions, and tenant isolation.

## Checklist before preview

- [ ] Title names the capability (and route, if backend).
- [ ] Value is clear in the first two sentences.
- [ ] Out-of-scope stated.
- [ ] AC is behavior-level and verifiable.
- [ ] Epic set as parent; related issues linked.
- [ ] If it introduces a new data/API shape → is there an ADR? If not, flag it.
