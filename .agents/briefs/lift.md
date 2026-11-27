# Lift lane

Goal: every game function still `INCLUDE_ASM` gets a readable C89 body lifted from the retail
assembly, with every image's bytes unchanged. A lift is a `NON_MATCHING` draft; a match is a bonus,
not the goal. Coverage is the goal: a draft that is close is worth more than none.

Rules (each one exists because breaking it cost the project before):
- Never read or use another decompilation of this game.
- Delete nothing outside your own worktree. No rm -r, git clean, worktree remove, branch or PR
  deletion. Never rm under build/.
- Never amend, force-push or rebase; integrate main with `git merge public/main`.
- Never edit existing `config/attempts*` rows; append, and take main's version on a conflict.
- Stop a process only by its exact PID. The shell is zsh with noclobber: write logs with `>|`.
- Commit as `git -c user.name='Raúl Correia' -c user.email='19838093+raulcorreia7@users.noreply.github.com'`.
  No model or tool names and no Co-authored-by trailers in commits or PRs.
- Code rules: ~/projects/bof3/decomp/AGENTS.md, .agents/skills/decomp/SKILL.md and
  .agents/skills/decomp/references/match.md. Comments are one line, only where a name cannot say it.

Setup once:
```sh
cd ~/projects/bof3/decomp
tools/worktree.sh --from . --dir ~/projects/bof3/.worktrees/dl1 match/dl1-1122
```
The script runs `meson setup build/meson`; build once with `meson compile -C build/meson`.

## Which functions

`~/.cache/bof3-swarm/lift-1122.jsonl` holds the measured queue: one row per open function with
`ref`, `name`, `words`, `tier`, `kind`, `twin`. Lift in this order: `undrafted`, then `stub`, then
`hard`, then `medium`. Skip `near` unless it is small: those lanes tune. A row whose `after` field
names another function needs that function lifted first; take the culprit.
Refresh the queue any time: `tools/worklist.py --order strategy -n 0 --measure --jsonl`.
Claim the row first: `~/projects/bof3/.agents/bin/claim.sh dl1 <ref>`; exit 1 means another
lane has it, so take the next row.

## Lift one function

1. Seed: `tools/seed.py <ref>` writes `work/<image>/<ADDR>/` with `asm.s` (the retail assembly),
   `ctx.c`, the m2c draft, twins and callees. Read `hints.md` first.
2. Read the assembly top to bottom and write the body statement for statement: member reads through
   the owner struct's type, SDK macros for hardware work, locals named by what they hold. A twin
   that already has a body is shared, not lifted again: copy the twin body and its types.
3. Draft shape in the function's own `.c`:
   ```c
   #ifdef NON_MATCHING
   NON_MATCHING <ret> func_<ADDR>(<args>) {
       <body>
   }
   #else
   INCLUDE_ASM(func_<ADDR>);
   #endif
   ```
4. Measure: `tools/match.sh <ref> --diff`. Keep the draft even when it is far; the drafts check only
   demands that it compiles with `-DNON_MATCHING`. If it is close, the tactics table
   (`docs/matching.md#tactics-for-gcc-272`) has the next form; do not chase a match for long.
5. Record what the lift established: `tools/attempts.py add --function <ref> --tried TEXT`,
   with `--first-diff` and `--score` when measured.
6. Types and prototypes: add one only when the unit owns it and the model needs it (a struct in the
   unit header, a prototype beside its caller). Anything else is a `needs:` line, left undone.

## Batch and land

Lift 6-10 functions, then:
```sh
git merge public/main
meson compile -C build/meson pre-push >| build/gate.log 2>&1   # must end "pre-push: all checks passed"
```
Commit `lift(<area>): <what>`, push `HEAD:refs/heads/<branch>`, open one PR per branch with
`gh pr create --base main --label needs-review`, then start the next branch from the new main and
keep lifting. Never leave a branch uncommitted for the gate: the checks compare commits.

## Stop and report

Stop when no `undrafted`/`stub` row is left, or two batches in a row fail the gate.
Report: functions lifted with their refs, drafts that came close (hunks), `needs:` lines, the gate
result, and `READY <sha>` or `BLOCKED <reason>` as the last line.
