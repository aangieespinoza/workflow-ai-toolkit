# Plugins

Plugins I have installed, grouped by marketplace. Enabled state reflects my
current setup.

## Marketplaces

| Marketplace | Source repo | Notes |
|---|---|---|
| `claude-plugins-official` | (official catalog) | Anthropic's official plugins |
| `ravn-ai-toolkit` | `ravnhq/ai-toolkit` | My company's internal toolkit |
| `agent-toolkit` | `softaworks/agent-toolkit` | Community agent toolkit |
| `claude-hud` | `jarrodwatts/claude-hud` | Statusline HUD |
| `claude-code-warp` | `warpdotdev/claude-code-warp` | Warp terminal integration |

## Enabled plugins

| Plugin | Marketplace | What I use it for |
|---|---|---|
| `pr-review-toolkit` | official | Specialized review agents (code-reviewer, silent-failure-hunter, type-design-analyzer, pr-test-analyzer, code-simplifier, comment-analyzer) — the engine behind `pr-review-triage` |
| `agent-pr-creator` | ravn-ai-toolkit | Fills PR template from diff + creates the PR (my "pr-creator" step) |
| `core-coding-standards` | ravn-ai-toolkit | Universal quality rules (KISS, DRY, clean code) |
| `skill-creator` | official | Author/optimize my own skills |
| `hookify` | official | Turn observed mistakes into preventive hooks |
| `typescript-lsp` | official | Live TS diagnostics while editing |
| `figma` | official | Design ↔ code (design-to-code, Code Connect) |
| `playwright` | official | Browser automation / UI verification |
| `mermaid-diagrams` | agent-toolkit | Diagram architecture, flows, schemas |
| `writing-clearly-and-concisely` | agent-toolkit | Tighten prose (docs, commits, messages) |
| `claude-hud` | claude-hud | Statusline HUD |
| `warp` | claude-code-warp | Warp terminal integration |
| `security-guidance` | official | Managed security guidance (auto) |

## Disabled / superseded

- **`superpowers`** (official) — installed but **disabled**. My hand-built
  personal skills (`feature-discovery` → `plan-builder` → `my-pr-review`, plus
  `linear-tickets`, `pr-review-triage`) replaced it.
- **`parallel`** (ravn-ai-toolkit) — installed but **disabled**. Background
  sub-agent fan-out is now handled by `execute-plan` on the built-in Workflow
  engine, which gives me deterministic phases and approval gates instead.

## Project-scoped, not global

Installed against a single repo rather than enabled globally, so they're not in
the sanitized `settings.json`:

- **`stripe`** (official) — billing work on one project only.

## Plugins I use across other projects (not enabled globally)

These live in my company marketplace and map to workflows I use on **other
projects** — I enable them per-project via `/plugin` rather than globally. (Project
names intentionally omitted.)

| Plugin | Purpose |
|---|---|
| `platform-backend` | NestJS + Prisma backend patterns |
| `platform-database` | Database/schema workflows |
| `dev-orchestrator` | Ticket analysis before coding |
| `promptify` | Handoff prompts |
| `pr-comments-address` | Address review comments on a PR |
| `eval-agent-md` | Test a `CLAUDE.md` for compliance |
| `grill-me` | Adversarial review |

> On backend projects I pair these with Prisma + Jest (I skip Drizzle/Vitest
> plugins there).
