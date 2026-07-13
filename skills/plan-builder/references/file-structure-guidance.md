# File-structure decomposition guidance

Apply this when filling the plan's **File structure** section. Mapping files and
their responsibilities *before* writing tasks is where decomposition decisions
get locked in — get this right and the task breakdown falls out naturally.

## Principles

- **One responsibility per file.** Design units with clear boundaries and
  well-defined interfaces. If you can't state a file's single responsibility in
  one line, it's doing too much.
- **Prefer smaller, focused files.** You (and any reviewer or executor) reason
  best about code that fits in context at once, and edits to focused files are
  more reliable. Large do-everything files make both planning and execution
  fragile.
- **Files that change together live together.** Split by *responsibility*, not by
  technical layer. A feature's controller, service, and DTO that always change in
  lockstep belong near each other, not scattered across layer folders because a
  convention says so.
- **Follow the existing codebase.** Match established patterns. If the codebase
  favors large files, don't unilaterally restructure. But if a file you're
  already modifying has grown unwieldy, proposing a split *as part of the plan*
  is reasonable — call it out explicitly so it's a decision, not a surprise.

## Why this drives the tasks

Each task should produce **self-contained changes that make sense
independently**. When the file map is clean — each file with one job, related
files grouped — tasks decompose along those seams: a task owns a coherent set of
files and can be verified on its own. A muddy file map produces tasks that step
on each other and can't be checkpointed.

## Applying it

1. List every file to create/modify/delete.
2. Give each a one-line responsibility. If two files share a responsibility,
   consider merging; if one file has two, consider splitting.
3. Group files that change together — those groupings hint at task boundaries.
4. For each proposed split in an existing file, note *why* (it's grown unwieldy,
   mixing concerns) so the reviewer can weigh it.
