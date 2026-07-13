---
name: migration-check
description: >
  Prisma migration safety check. Use before generating any new Prisma migration,
  when touching schema.prisma, or when implementing a story that requires a schema
  change. Auto-detects the project's integration base branch (main or develop),
  verifies migration ordering, checks for pending unapplied migrations, and confirms
  the branch is rebased before generating. Prevents the most common Prisma migration
  ordering conflicts.
---

# Migration Check

Run before every `prisma migrate dev` to prevent ordering conflicts.

Throughout this skill, `$BASE` refers to the project's integration branch — it is
**not always `develop`**. Some repos integrate on `main`, others on `develop`.
Step 0 resolves it; every later step uses `origin/$BASE`.

## Step 0 — Resolve the base branch and migrations path

**Base branch.** Try these in order and use the first that resolves:

1. The remote's default branch:
   Run bash: `git symbolic-ref --quiet refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`
2. If that is empty (never set locally), refresh it once:
   Run bash: `git remote set-head origin --auto 2>/dev/null && git symbolic-ref --quiet refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`
3. Fallback — pick whichever integration branch actually exists on the remote,
   preferring `develop`:
   Run bash: `for b in develop main master; do git rev-parse --verify --quiet "origin/$b" >/dev/null && echo "$b" && break; done`

Set `$BASE` to the result. If the current branch was itself cut from a non-default
branch (e.g. a feature stacked on another feature), and you know the real parent,
prefer that parent as `$BASE` — state which base you chose and why before proceeding.

**Migrations path.** The Prisma schema/migrations location is also project-dependent
(e.g. `apps/api/prisma/` vs `packages/database/prisma/`). Detect it rather than
assuming:

Run bash: `find . -type d -name migrations -path '*prisma*' -not -path '*/node_modules/*' 2>/dev/null`

Use the discovered directory as `$MIGRATIONS_DIR`, and its parent (the folder
containing `schema.prisma`) as `$PRISMA_DIR`. If more than one matches, ask which
package owns the migration before continuing.

## Step 1 — Verify branch is current

Run bash: `git fetch origin $BASE --quiet`
Run bash: `git log --oneline origin/$BASE..HEAD | head -5`
Run bash: `git log --oneline HEAD..origin/$BASE | head -5`

If any commits exist on `origin/$BASE` that are not on the current branch,
**stop and instruct the user to rebase first**.

## Step 2 — Check existing migrations

Run bash: `ls -1 "$MIGRATIONS_DIR" | sort | tail -5`

Note the timestamp of the most recent migration file.

## Step 3 — Check for pending unapplied migrations

Run bash: `cd "$PRISMA_DIR/.." && npx prisma migrate status`
(run from the package that owns the Prisma schema).

If any migrations are listed as "not yet applied", surface them before proceeding.

## Step 4 — Check for in-progress local migration

If a migration folder exists in `$MIGRATIONS_DIR` with a timestamp **earlier** than
the latest committed migration, it was generated pre-rebase and must be deleted and
regenerated.

## Step 5 — Clear to generate

Only confirm "clear to generate" if:
- Branch is rebased on `origin/$BASE`
- No pending unapplied migrations
- No stale pre-rebase migration folder exists

Then instruct: Run bash: `cd "$PRISMA_DIR/.." && npx prisma migrate dev --name <description>`
