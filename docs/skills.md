# Personal Skills

Skills I hand-built and keep in `~/.claude/skills/`. Sanitized copies are in
[`../skills/`](../skills/). These form the backbone of my workflows (see
[`workflows.md`](./workflows.md)).

| Skill | What it does | Where it fits |
|---|---|---|
| **`ticket-to-pr`** | End-to-end conductor: drives one ticket from discovery to a merge-ready PR by chaining the skills below, enforcing an approval gate between every phase. Invents no workflow of its own. | The whole pipeline, one entry point |
| **`feature-discovery`** | Turns a Linear ticket into a codebase-grounded discovery brief (scope + AC + real findings: which files, patterns, dependencies), then hands off to `plan-builder`. | Start of every build; also feeds ticket authoring |
| **`plan-builder`** | Writes an implementation plan in my house format, breaks work into independently verifiable tasks, saves it, and **stops for approval** — never codes straight away. | After discovery |
| **`execute-plan`** | Takes an **already-approved** plan and drives it to a green, self-reviewed diff via Workflow multi-agent orchestration (TDD-first, until validate + tests pass), then hard-stops for commit/PR approval. | After the plan is approved |
| **`my-pr-review`** | Author-side workflow for my **own** PRs: self-review after pushing, and address review comments (triage, fix, reply). | After implementation |
| **`pr-review-triage`** | Review **others'** PRs: runs pr-review-toolkit agents + my findings, I pick which to post as inline comments. | Reviewing teammates |
| **`pr-announce`** | Posts the PR to the team Slack channel in my house format. Previews the text first, and refuses to announce a **draft** — announcing is a request for review. | After the PR is opened and marked ready |
| **`linear-tickets`** | Read/analyze/author Linear tickets in house style. Previews in chat and gets approval before creating. | Ticket creation & triage |
| **`migration-check`** | Prisma migration safety check — ordering, pending migrations, rebase state — before generating a new migration. | Backend schema changes |
| **`find-skills`** | Discover & install skills from the open ecosystem. | Extending capabilities |

## Design principles baked into these skills

- **Approval gates everywhere** — planning and PR steps stop for explicit
  approval; nothing auto-commits, pushes, or posts to GitHub.
- **Codebase-grounded** — discovery and planning read real code, ADRs, and
  existing patterns before proposing anything.
- **Composable** — `feature-discovery` feeds both `plan-builder` and
  `linear-tickets`; the review skills share the pr-review-toolkit engine;
  `ticket-to-pr` chains the others rather than duplicating them.
- **Orchestration is opt-in** — `execute-plan` and `ticket-to-pr` set
  `disable-model-invocation: true`, so they only run when I ask for them by name.
  Nothing fans out a fleet of agents on its own initiative.
- **Read-only where it matters** — the skills that only inspect and report
  (`pr-review-triage`, `linear-tickets`, `migration-check`, `find-skills`) declare
  `disallowed-tools: Edit, Write`, so a review pass structurally cannot edit code.

> Copies here are sanitized: `<company>`, `<primary-repo>`, `TICKET-###`, and
> `<your-*>` placeholders replace real identifiers.
