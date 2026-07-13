# Personal Skills

Skills I hand-built and keep in `~/.claude/skills/`. Sanitized copies are in
[`../skills/`](../skills/). These form the backbone of my workflows (see
[`workflows.md`](./workflows.md)).

| Skill | What it does | Where it fits |
|---|---|---|
| **`feature-discovery`** | Turns a Linear ticket into a codebase-grounded discovery brief (scope + AC + real findings: which files, patterns, dependencies), then hands off to `plan-builder`. | Start of every build; also feeds ticket authoring |
| **`plan-builder`** | Writes an implementation plan in my house format, breaks work into independently verifiable tasks, saves it, and **stops for approval** — never codes straight away. | After discovery |
| **`my-pr-review`** | Author-side workflow for my **own** PRs: self-review after pushing, and address review comments (triage, fix, reply). | After implementation |
| **`pr-review-triage`** | Review **others'** PRs: runs pr-review-toolkit agents + my findings, I pick which to post as inline comments. | Reviewing teammates |
| **`linear-tickets`** | Read/analyze/author Linear tickets in house style. Previews in chat and gets approval before creating. | Ticket creation & triage |
| **`migration-check`** | Prisma migration safety check — ordering, pending migrations, rebase state — before generating a new migration. | Backend schema changes |
| **`find-skills`** | Discover & install skills from the open ecosystem. | Extending capabilities |

## Design principles baked into these skills

- **Approval gates everywhere** — planning and PR steps stop for explicit
  approval; nothing auto-commits, pushes, or posts to GitHub.
- **Codebase-grounded** — discovery and planning read real code, ADRs, and
  existing patterns before proposing anything.
- **Composable** — `feature-discovery` feeds both `plan-builder` and
  `linear-tickets`; the review skills share the pr-review-toolkit engine.

> Copies here are sanitized: `<company>`, `<primary-repo>`, `TICKET-###`, and
> `<your-*>` placeholders replace real identifiers.
