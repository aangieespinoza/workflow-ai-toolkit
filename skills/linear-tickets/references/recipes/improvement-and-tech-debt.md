# Recipe: Improvement & Technical Debt

Two related non-feature, non-bug cases. Pick the label by *who benefits*:

- **`Improvement`** — a tangible enhancement to *existing* behavior: performance,
  UX polish, developer experience. There's an observable win for a user or dev.
- **`Technical Debt`** — internal cleanup with *no* user-facing change: refactor,
  dead-code removal, test backfill, paying down a known shortcut.

Compose with an area recipe for the technical sections.

## Emphasize

- **`## What`** states the current state and its cost — *why it's worth doing now*.
  Debt tickets especially need this: "we shortcut X in TICKET-###; it now causes Y."
  Without the cost, these get deprioritized forever (which may be fine — see
  `nice-to-have.md`).
- **`## Scope`** is tightly bounded. Refactors sprawl; name the files/modules and
  what stays untouched.
- **`## Acceptance criteria`** — for debt, the key AC is usually **"no behavior
  change"**: existing tests pass, public contract unchanged, and (if a refactor)
  the diff is behavior-preserving. For improvements, state the measurable win
  (e.g. "list query drops from N+1 to a single query").

## Checklist before preview

- [ ] Correct label chosen (Improvement vs Technical Debt) by user-facing impact.
- [ ] Cost of NOT doing it is stated.
- [ ] Scope bounded; untouched areas named.
- [ ] Debt: "no behavior change" AC. Improvement: measurable win in AC.
- [ ] `risk:*` label if the refactor touches shared/critical paths.
