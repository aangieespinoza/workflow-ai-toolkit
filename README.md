# workflow-ai-toolkit

My personal Claude Code setup, packaged as a plugin. It bundles the hand-built
skills I use every day — the ticket-to-PR pipeline (discovery, planning,
orchestrated execution), PR review (my own and others'), Slack announcements,
Linear ticket authoring, and Prisma migration safety — alongside the config,
hooks, plugins, and MCP servers that make them work.

This repo is a **sanitized snapshot**: it documents and reproduces my setup
without shipping any of my employer's identifiers. Real company, repo, and
ticket names are replaced with `<company>`, `<primary-repo>`, `TICKET-###`, and
`<your-*>` placeholders — so expect to fill those in before anything that
references a specific project will work.

## What's here

| Path | Contents |
|---|---|
| [`.claude-plugin/`](./.claude-plugin/) | Manifests — marketplace `workflow-ai-toolkit`, plugin `angieespinoza` |
| [`skills/`](./skills/) | The bundled skills — the heart of this plugin |
| [`CLAUDE.md`](./CLAUDE.md) | My global instructions (role, standards, approval gates, conventions) |
| [`settings/`](./settings/) | Sanitized `settings.json` + `settings.local.json` |
| [`hooks/`](./hooks/) | Hook scripts referenced by `settings.json` (formatter + a test-scope guard) |
| [`docs/workflows.md`](./docs/workflows.md) | **How everything fits together** — my day-to-day flows, with diagrams |
| [`docs/config.md`](./docs/config.md) | Model, behavior, permissions, statusline, voice |
| [`docs/plugins.md`](./docs/plugins.md) | Plugins + marketplaces I install |
| [`docs/mcp-servers.md`](./docs/mcp-servers.md) | MCP servers I use and how I combine them |
| [`docs/skills.md`](./docs/skills.md) | Catalog of the bundled skills |

## Getting started

There are two ways in, depending on how much you want.

### Option A — install the skills as a plugin

Gets you the `skills/` in this repo, nothing else.

```
/plugin marketplace add <path-to-this-repo>      # or the repo URL: https://github.com/aangieespinoza/workflow-ai-toolkit
/plugin install angieespinoza@workflow-ai-toolkit
```

> **Heads up:** the skills expect their neighbors. `pr-review-triage` drives the
> `pr-review-toolkit` agents, and the Linear-facing skills need the Linear MCP.
> Install those too ([`docs/plugins.md`](./docs/plugins.md),
> [`docs/mcp-servers.md`](./docs/mcp-servers.md)) or those flows won't fire.

### Option B — reproduce my full setup

Config, skills, plugins, and MCP servers — the whole thing.

1. Copy [`CLAUDE.md`](./CLAUDE.md) to `~/.claude/CLAUDE.md` and fill in the `<placeholders>`.
2. Merge [`settings/settings.json`](./settings/) into `~/.claude/settings.json` (review paths first —
   the statusline hardcodes a Node version).
3. Copy [`hooks/*.sh`](./hooks/) into `~/.claude/hooks/` — `settings.json` references them from
   there. The formatter is portable; the test-scope guard is project-specific and needs adapting.
4. Install this plugin (Option A) **or** copy `skills/*` into `~/.claude/skills/`.
5. Install the plugins/marketplaces in [`docs/plugins.md`](./docs/plugins.md) via `/plugin`.
6. Enable the MCP servers in [`docs/mcp-servers.md`](./docs/mcp-servers.md).

**The environment it assumes:** the 1M-context Opus alias (`opus[1m]`), proactive
output style, medium effort, and an anti-sycophancy mentor persona. See
[`docs/config.md`](./docs/config.md).

## The workflow I follow

Three flows cover almost everything I do. Full walkthrough with diagrams in
[`docs/workflows.md`](./docs/workflows.md).

**1. Building a feature** — my core loop, run end to end on every task:

```
ticket → feature-discovery → plan-builder → execute-plan → my-pr-review → agent-pr-creator → push → pr-announce
```

`feature-discovery` grounds the ticket in the actual codebase; `plan-builder`
writes the plan and **stops for approval**; `execute-plan` drives the approved
plan to a green diff via Workflow orchestration (TDD-first); `my-pr-review`
self-reviews before anyone else sees it; `pr-announce` posts it to Slack once the
PR is ready. Nothing commits, pushes, opens a PR, or posts to Slack without my
say-so.

**`ticket-to-pr` runs that entire chain as one command**, re-enforcing the
approval gate between every phase. Both it and `execute-plan` are opt-in only —
they never trigger on their own, because both fan out multi-agent work.

**2. Reviewing others' PRs** — `pr-review-triage` runs the `pr-review-toolkit`
agents against the diff, I add my own findings, then **I decide which comments to
post**. Nothing reaches GitHub until I approve the list. For 2+ PRs it fans out
one agent per PR and consolidates into a single triage table.

**3. Creating tickets** — the Linear MCP reads cycle/ticket state directly;
`linear-tickets` authors in the team's house style, usually paired with
`feature-discovery` so the ticket is buildable before anyone picks it up.

`feature-discovery` is the hub — it feeds both planning and ticket authoring.
