# MCP Servers

MCP servers I use and — more importantly — **how I combine them** with my skills.
Enabled via `ENABLE_CLAUDEAI_MCP_SERVERS=1` (claude.ai-hosted servers) plus
plugin-provided servers.

## Servers I actually use

| Server | Used for | Combined with |
|---|---|---|
| **Linear** | Read ticket/cycle state, author & comment on tickets directly (no copy-paste) | `linear-tickets` + `feature-discovery` |
| **GitHub** | PR metadata, review comments, PR state | `pr-review-triage`, `my-pr-review`, `agent-pr-creator` |
| **Figma** (plugin) | Design → code, Code Connect mapping | figma skills for UI work |
| **Playwright** (plugin) | Drive a browser to verify UI changes | `/verify`, `/run` |
| **Context7** | Fetch current library/framework docs on demand | Any coding task touching a library |

Other claude.ai servers are available in the environment (Slack, Notion, Sentry,
Google Workspace, etc.) but the five above are my daily drivers.

## How I combine them

### Linear MCP + skills → better tickets
The Linear MCP reads real cycle/ticket state; `linear-tickets` authors in house
style; `feature-discovery` grounds the ticket in the actual codebase. Chained,
they produce a ticket that's scoped, in-style, and buildable before pickup.

```
Linear MCP (read state) → linear-tickets (house style) → feature-discovery (codebase grounding)
```

### GitHub MCP + review skills → controlled PR review
`pr-review-triage` pulls the diff via GitHub, runs pr-review-toolkit agents, I add
my own findings, then post *only* what I approve back through GitHub. My own PRs
run the same plumbing through `my-pr-review` and `agent-pr-creator`.

### Context7 for library truth
Whenever a task touches a framework/SDK/CLI, I let Context7 fetch current docs
instead of relying on memory — avoids stale-API mistakes during `plan-builder`
and implementation.

## Rules of thumb

- Prefer the **Linear/GitHub MCP** over shelling out to `gh`/manual paste when the
  MCP call is simpler.
- Interactively-authenticated MCP servers may be absent in headless/cron runs —
  don't depend on them in unattended workflows.
