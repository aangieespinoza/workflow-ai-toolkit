# Config & Behavior

My Claude Code configuration — model, behavior, permissions, and UI. Sanitized
copy lives in [`../settings/`](../settings/).

## Model

- **`opus[1m]`** — the 1M-token-context Opus alias. It tracks the current Opus
  release rather than pinning a version, so this stays correct as models ship.
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
| `skipWorkflowUsageWarning` | **true** | Suppresses the per-run token-cost prompt — `execute-plan` opts into Workflow deliberately, so the warning is noise. |

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
- **Default mode:** `auto` — anything not matched by a rule above runs without a
  prompt. The `ask`/`deny` lists are what actually hold the line, so read them
  before copying this.

## Hooks

Two hooks live in [`../hooks/`](../hooks/) and are wired in `settings.json`.
Copy them to `~/.claude/hooks/` (the config references them via `$HOME`).

| Hook | Event | What it does |
|---|---|---|
| `format-edited-files.sh` | `PostToolUse` (`Edit\|Write\|MultiEdit`) | Runs each repo's own prettier on **only** the files just edited. `--ignore-unknown` skips non-formattable files; `--no-install` makes repos without prettier a silent no-op. Portable as-is. |
| `guard-integration-tests.sh` | `PreToolUse` (`Bash`) | Refuses concurrent integration runs (they deadlock on a shared test DB), refuses a bare full-suite run without a spec pattern, and redirects full runs at a RAM-backed Postgres. **Project-specific — adapt before use.** |

The guard is sanitized with a shell-safe `myco` placeholder (a `<company>`-style
placeholder would parse as a shell redirection and break the script). Its
timings are measured against one specific project; the reusable part is the
pattern — positional command parsing, so `git commit -m "…test:integration"`
isn't caught by a naive substring match. `guard-integration-tests.test.sh` is its
test script.

## UI / UX

- **Theme:** `dark-daltonized`.
- **TUI:** `fullscreen`.
- **Statusline:** [`claude-hud`](https://github.com/jarrodwatts/claude-hud) plugin
  (command-based statusline). ⚠️ The command hardcodes a Node path
  (`$HOME/.nvm/versions/node/v24.18.0/bin/node`) — change that version to yours or
  the statusline silently won't render.
- **Voice:** enabled, hold-to-talk mode.
- **Notifications:** auto channel.
- **Teammate mode:** in-process.
- **Worktree background isolation:** none (work happens in place).

## MCP flag

- `ENABLE_CLAUDEAI_MCP_SERVERS=1` — enables the claude.ai-hosted MCP servers
  (Linear, Slack, Notion, etc.). See [`mcp-servers.md`](./mcp-servers.md).
