# Config & Behavior

My Claude Code configuration — model, behavior, permissions, and UI. Sanitized
copy lives in [`../settings/`](../settings/).

## Model

- **`opus[1m]`** — Claude Opus 4.8 with the **1M-token context window**.
- I lean on the large context so `feature-discovery` and `plan-builder` can hold
  a whole ticket + the relevant slice of the codebase at once.

## Behavior

| Setting | Value | Why |
|---|---|---|
| Output style | **Proactive** | Execute autonomously, minimize interruptions, prefer action over planning. |
| Effort level | **medium** | Balanced depth vs. speed for day-to-day work. |
| Persona | **Senior Lead Fullstack mentor** (see `CLAUDE.md`) | Backend/architecture depth, direct tone. |
| Anti-sycophancy | **On** (via `CLAUDE.md`) | No empty praise; hunt for weaknesses, edge cases, race conditions; offer alternatives. |
| `includeCoAuthoredBy` | **false** | No "co-authored-by" trailer on commits. |
| Agent teams | **enabled** (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) | Multi-agent orchestration. |

The full working relationship, approval gates, and coding standards are in
[`../CLAUDE.md`](../CLAUDE.md).

## Permissions

A safety-first permission policy:

- **Allow (no prompt):** core tools (`Bash`, `Read`, `Edit`, `Write`, `Glob`,
  `Grep`, `Skill`) and low-risk git reads (`git add`, `git pull`, `git branch`,
  `git status`, `git diff`).
- **Ask (confirm first):** `git push`, `git commit`, `git merge` — I handle these
  myself; Claude never commits/pushes without explicit approval.
- **Deny (never):** reading `.env` / `.env.*`, anything under `secrets/`,
  `~/.ssh/**`, plus `rm -rf` and `sudo`.

## UI / UX

- **Theme:** `dark-daltonized`.
- **TUI:** `fullscreen`.
- **Statusline:** [`claude-hud`](https://github.com/jarrodwatts/claude-hud) plugin
  (command-based statusline).
- **Voice:** enabled, hold-to-talk mode.
- **Notifications:** auto channel.
- **Teammate mode:** in-process.
- **Worktree background isolation:** none (work happens in place).

## MCP flag

- `ENABLE_CLAUDEAI_MCP_SERVERS=1` — enables the claude.ai-hosted MCP servers
  (Linear, Slack, Notion, etc.). See [`mcp-servers.md`](./mcp-servers.md).
