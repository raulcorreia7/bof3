# Match lane

You are one lane of the Breath of Fire III decompilation. The coordinator's prompt gives your lane
name and your rows. Work alone, no subagents, continuously, until your rows are done or you are told
to stop. Say `CONTEXT` when your context is nearly full.

Read first, in this order: `~/projects/bof3/.agents/workflow.re.yml` (rules, quality.rules, steps,
tactics), `~/projects/bof3/decomp/AGENTS.md`, `decomp/.agents/skills/decomp/SKILL.md` and its
`references/match.md` and `references/name.md`, `decomp/docs/matching.md` (the tactics table).

Never read or use another decompilation of this game.

## Setup, once

    cd ~/projects/bof3/decomp
    tools/worktree.sh --from . --dir ~/projects/bof3/.worktrees/<lane> match/<lane>-<mmdd>

Work only in that worktree. A new branch from `public/main` for each pull request.

## Loop

1. Queue: `python3 tools/worklist.py --image <your images> --order strategy -n 400 --measure`; take
   your rows (the prompt names the cause or class), smallest first. Skip a row that already matches.
2. Claim: `~/projects/bof3/.agents/bin/claim.sh <lane> <target>@0x<ADDR>`; exit 1 means another lane
   has it: take the next row.
3. Check the body: is the draft this function? Compare size, callees, globals and constants with
   the assembly (`tools/seed.py`, `work/.../asm.s`). A stub or another function's body is written
   again from the assembly.
4. Match: `tools/match.sh <target>@0x<ADDR> --diff`, the tactics table, `tools/opcode_diff.py`.
   Three structurally different tries, then keep the closest draft under `NON_MATCHING` and record
   it: `tools/attempts.py add --function <ref> --tried "<what>" --first-diff "<cause>"`.
   A permuter run is 10 minutes at most (`tools/near_miss.sh <ref> <src> 600`).
5. Prove: `BOF3_CC_CACHE=0 meson compile -C build/meson check-<image>` must pass before a function
   is called MATCH. `match.sh` alone is not a proof.
6. Polish while it matches (keep a change only if `match.sh` still says match): struct members and
   typed pointers for offsets and scalar runs, SDK macros and types, names that say what the thing
   is, `FAKE_` helpers retried with plain typed forms, a one-line comment. Battle and battle-magic
   code reads the task as `TASK(PartyMember)->member`.
7. Batch 3 to 6 matches: `git merge public/main`, `meson compile -C build/meson format`, commit,
   then the gate: `meson compile -C build/meson pre-push >| build/gate.log 2>&1`, which must end
   `pre-push: all checks passed`. Push, open the pull request with the repository template (What,
   Why, Checks) and `gh pr merge --squash --auto --delete-branch`. If it turns DIRTY, merge
   `public/main`, gate again, push.

## Never

- Amend, force-push, rebase, or close a pull request. Integrate with `git merge public/main`.
- `rm` under `build/`, or delete anything outside your worktree.
- Edit or delete an attempts row or a draft. Turn a MATCH function back into a draft.
- Change a target map, `splat.yaml` (other than a jump table's own `.rodata` row), compiler flags,
  or a file under `include/` that other images share: write a `needs:` line in the pull request.
- Put a model or tool name, or `Co-authored-by`, in a commit or pull request.
- Stop a process other than by its PID. Write logs with `>|` (the shell is zsh with noclobber).

Commit as `git -c user.name='Raúl Correia' -c user.email=19838093+raulcorreia7@users.noreply.github.com`.
