# Polish lane (top down)

Goal: the MATCHed C reads as its 1997 authors wrote it. Work the engine from the top down, one
subsystem at a time, and prove every name, type and constant with the retail bytes and with every
user of it. The bytes never change: `check-<image>` after each edit and the full gate per batch.

Rules (each one exists because breaking it cost the project before):
- Never read or use another decompilation of this game.
- Delete nothing outside your own worktree. No rm -r, git clean, worktree remove, branch or PR
  deletion. Never rm under build/. Never touch ~/projects/bof3/.local except bin/claim.sh.
- Never amend, force-push or rebase; integrate main with `git merge public/main`.
- Never edit existing `config/attempts*` rows; append, and take main's version on a conflict.
- Stop a process only by its exact PID. The shell is zsh with noclobber: write logs with `>|`.
- Commit as `git -c user.name='Raúl Correia' -c user.email='19838093+raulcorreia7@users.noreply.github.com'`.
  No model or tool names and no Co-authored-by trailers in commits or PRs.
- Code rules: ~/projects/bof3/decomp/AGENTS.md, .agents/skills/decomp/SKILL.md,
  references/refactor.md and docs/conventions.md. A comment is one line, what not how; keep the
  game's own comments.
- A rename is whole: `rg -n '\bOLD\b' src include` afterwards leaves only address comments and
  attempts history. `tools/symbol.py rename` writes the `config/symbols/<image>.toml` rows.

Setup once:
```sh
cd ~/projects/bof3/decomp
tools/worktree.sh --from . --dir ~/projects/bof3/.worktrees/dp1 polish/dp1-1122
```

## Order, top down

Engine modules in this order: `engine/sys` (scratchpad, scheduler, interrupts, strings, math),
`engine/input`, `engine/cd`, `engine/emi`, `engine/gfx`, `engine/sound`, `engine/actor`,
`engine/area`, `engine/camera`, `engine/worldmap`, `engine/ui`, `engine/party`, `engine/state`,
`engine/slus` + `engine/game`, then `src/overlays/` worst debt first.

Inside a subsystem, start at the top of its call graph: the entry point nothing inside the
subsystem calls (the dispatcher, the scheduler step, the init), then walk its callees. A file's
debt ranking is `tools/quality.py --queue -n 30` (score and metrics, worst first); the per-file
metrics are `addr`, `names`, `casts`, `harmful`, `notes`, `pasted`, `twins`.

## Read everything about a symbol before touching it

- Every use in the tree: `rg -n '\bSYM\b' src include`; in the retail image:
  `bin/rz <target> 'aaa; axt @ SYM'`; typed users: `tools/symbol.py uses <Name>`.
- Callers and callees: `tools/seed.py <ref>` writes `work/<image>/<ADDR>/` with `asm.s`, the callers,
  the callees and the nearest bodies. An address without a name: `tools/symbol.py at <target> 0x<ADDR>`;
  a member: `tools/symbol.py member <Type> 0x<OFF>`; a bare value: `tools/symbol.py value 0x<NN>`.
- Retail check: `tools/match.sh <ref>` after every edit (exit 0 is a match), `--diff` for the
  side-by-side. The asm is the authority on width, sign and order: read `asm.s` before writing a
  type, a cast or a comparison.
- A width must agree across every access. A member gets `ASSERT_SIZE`/`ASSERT_OFFSET` where its
  record has them.

## What to change, in this order

1. Offsets to members: `FIELD`/`MEM_PTR`/raw cast at an offset becomes the owner struct's member or
   a typed global. A record walked by a local becomes one typed pointer; a word shifted apart
   becomes a struct of bytes or bit-fields; a stride becomes the element type (`i * sizeof(Type)`
   only where byte math must stay).
2. SDK first: the PsyQ macros and types (`getTPage`, `setRGB*`, `setXY*`, `setUV*`, `setWH`,
   `setPolyFT4`, `addPrim`, `setRECT`, `setVector`, `gte_*`, `SVECTOR`, `RECT`) wherever they give
   the same bytes; open-coded only where the bytes differ, with a one-line note.
3. Names: what the thing is to the game or the SDK, owner-first prefix, no mechanical locals
   (`tmp*`, `var_*`, `new_var`, `arg<N>`), no constant named by its value, no name that records how
   it matched. A `case` label gets the enum member its users give it.
4. `FAKE_` is the last resort: first try the right type (a `u16 tpage` replaced a `FAKE_REG`), then
   the width/declaration-order/inline forms; every kept pin carries its `FAKE:` note and its byte
   proof on the same line.
5. One body per repeated function (`src/shared`, or the group's `shared/` header), one declaration
   per symbol in its owner header, helper and macro rules from the workflow `quality.rules`.
6. Rewrite any line that still reads like decompiler output, and delete what the change made dead.

## Batch and land

10-20 functions or one subsystem file group, then:
```sh
git merge public/main
meson compile -C build/meson pre-push >| build/gate.log 2>&1   # must end "pre-push: all checks passed"
```
Commit `refactor(<scope>): <what>`, push `HEAD:refs/heads/<branch>`, open one PR per branch with
`gh pr create --base main --label needs-review`, then start the next branch from the new main.
The gate ratchets readability per touched file (`tools/quality.py --diff`): never leave a touched
file worse than you found it.

## Stop and report

Move to the next subsystem when the current one has no `addr`, `names`, `harmful` or `casts` item
left that evidence can fix. Stop the lane after two batches in a row fail the gate; report those as
`BLOCKED`.
Report: subsystem, items fixed (symbol, old form, new form, the evidence), `kept:` items with the
reason, `needs:` lines, the gate result, and `READY <sha>` or `BLOCKED <reason>` as the last line.
