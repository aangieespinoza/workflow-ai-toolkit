# Posting approved findings

Only runs after the user names the specific findings to publish. Post them as a
**single review** carrying inline comments, so the author gets one coherent pass
instead of a stream of notifications.

## Resolve owner/repo and the head commit

Inline comments must attach to a commit SHA. Get everything in one call:

```bash
gh pr view <PR> --json headRepositoryOwner,headRepository,headRefOid,url
# owner  = .headRepositoryOwner.login
# repo   = .headRepository.name
# commit = .headRefOid   (the HEAD SHA the comments pin to)
```

(If the PR comes from a fork, `headRepositoryOwner` is the fork's owner — the
review still posts to the base repo's PR; the API path below uses the base repo,
which `gh` resolves from the PR number in the current repo. When in doubt, run
these from a clone of the base repo.)

## Batched review (preferred)

Build a JSON body from the approved findings and post one review. `event:
"COMMENT"` leaves a comment review — it does NOT approve or request changes.

Write the body to the scratchpad, then send it with `--input` (reliable quoting
for multi-line comment bodies):

```jsonc
// /tmp/review-<PR>.json
{
  "commit_id": "<headRefOid>",
  "event": "COMMENT",
  "body": "<optional short summary — omit if all feedback is inline>",
  "comments": [
    { "path": "src/x.ts", "line": 42, "side": "RIGHT", "body": "<finding #1 comment>" },
    { "path": "src/y.ts", "line": 88, "side": "RIGHT", "body": "<finding #2 comment>" }
  ]
}
```

```bash
gh api --method POST \
  "repos/<owner>/<repo>/pulls/<PR>/reviews" \
  --input /tmp/review-<PR>.json
```

- `line` is the line number in the **new** file (the `+` side of the diff);
  `side: "RIGHT"`. For a comment on a deleted line use `side: "LEFT"`.
- For a multi-line range add `"start_line"` + `"start_side"` alongside `"line"`.
- Only include comments the user approved.

## Alternatives

- **Top-level summary only** (no inline anchoring):
  ```bash
  gh pr comment <PR> --body "<summary>"
  ```
- **Approve / request changes** — ONLY when the user explicitly says so:
  set `"event": "APPROVE"` or `"event": "REQUEST_CHANGES"` in the JSON above.
  Never default to these; a comment review is the safe default.

## After posting

Report back: the review URL (from the API response `html_url`), how many
comments went out, and which findings were held per the user's decision. Do not
resolve threads or take further action on the PR.

## Comment tone

Specific, actionable, professional — match the author's context. State the issue
and a concrete suggestion or question. No filler openers ("Great catch!",
"Thanks!", "Nice work!") — they add noise. A good inline comment reads like:
"This `catch` swallows the error — the caller can't distinguish a 404 from a
network failure. Rethrow as a typed error or log with context?"
