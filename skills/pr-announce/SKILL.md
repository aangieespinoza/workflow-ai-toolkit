---
name: pr-announce
disallowed-tools: Edit, Write
description: >
  Announce a pull request in Slack using <your-name>'s house format. Use right after a PR
  is opened (typically following `agent-pr-creator`), or whenever they say "announce
  the PR", "post the PR to Slack", "share this PR with the team", "send the PR
  message". Derives a short human-readable feature title from the PR, posts to
  #internal-<company>-mvp with link unfurling on, and ALWAYS previews the text before
  posting to a real channel. Also handles "send it to myself first" (self-DM dry run).
---

# PR Announce

Post a PR to Slack in the house format. Small skill, one job — but the approval gate
is the point, so do not skip it.

## The format (do not redesign it)

```
Helloo team! :claude-code-working-on-it-fast:
Here a PR for {{short title about the feature}}
{{url-pr}}
```

Three lines, exactly. `{{short title}}` completes the sentence "Here a PR for …" —
so it reads as a noun phrase, not a commit subject:

- ✅ `exact subscription org resolution + a foreign-subscription guard (TICKET-871)`
- ❌ `fix(stripe): make subscription org resolution exact (TICKET-871)` — that's the commit title
- ❌ `TICKET-871` alone — a reviewer can't triage from a ticket id

Keep the `TICKET-###` in parentheses at the end. Aim for one line; if it needs two,
it's too long.

## Targets

- **Default channel:** `#internal-<company>-mvp` (`C09RG6YUVAA`)
- **Self-DM (dry run):** <your-name>'s own user id — the tool description reports the
  logged-in user id; use that as `channel_id`. Use this when they ask to "send myself
  first", or when a custom emoji / format change is being tried out.

Always set `unfurl_app_links: true` so the GitHub link renders as a rich preview
(title, checks, status) instead of a bare URL.

## Process

1. **Resolve the PR.** Take a number/URL if given; otherwise `gh pr view --json
   number,title,url,isDraft,body` on the current branch. If no PR exists, say so and
   stop — never invent a URL.
2. **Check it is announceable — a draft is a hard stop.** Announce **only** a PR that is
   ready for review. If `isDraft` is `true`, do **not** announce and do **not** ask whether
   to announce anyway: say it is still a draft, and stop. The announcement is a request for
   review, so a draft ping wastes reviewers' time on something that is not ready. If <your-name>
   wants it out, they mark it ready (`gh pr ready`) and asks again. Draft status comes from
   the `gh pr view` call in step 1 — do not make a separate call, and do not look at CI
   (see Guardrails).
3. **Derive the short title** from the PR title/body per the rules above. Prefer the
   user-visible behaviour over the mechanism.
4. **Preview, then post.**
   - Posting to **a real channel** → show the exact message text and get an explicit
     yes first. This is a public, effectively irreversible action.
   - Posting to **their own DM** → just send it; that is the dry run.
5. **Return the Slack permalink** so they can edit or delete it.

## Guardrails

- **Never announce without the PR URL resolved from `gh`.** A wrong link is worse
  than no message.
- **Never announce a draft.** `isDraft: true` → stop, no message, no "announce anyway?"
  prompt. Ready-for-review is the only announceable state. This is not a judgment call.
- **Do NOT check CI.** No `gh pr checks`, no `gh run` polling, no sleep-and-retry
  waiting for jobs to drain. Announce when asked and stop. <your-name> watches CI themselves;
  polling it burns turns and tells them nothing they cannot see. If they want the status
  they will ask for it. (Consequence they have accepted: an announcement may go out while
  checks are red or pending.)
- **Never post to a channel other than the default without being asked.**
- One announcement per PR. If they want to re-share after a force-push or a
  ready-for-review flip, post a short follow-up in the same thread (`thread_ts`)
  rather than a second top-level message.
- The custom emoji `:claude-code-working-on-it-fast:` must exist in the workspace.
  If a format change is ever proposed, dry-run it to their DM first to confirm it
  renders.
