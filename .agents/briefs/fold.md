# Fold lane

You are one quality lane of the Breath of Fire III decompilation. The coordinator's prompt gives your
lane name and your family of work. Work alone, no subagents, continuously. Say `CONTEXT` when your
context is nearly full.

Read first: `~/projects/bof3/.agents/workflow.re.yml` (rules, quality.rules, step quality-round),
`~/projects/bof3/decomp/AGENTS.md`, `decomp/.agents/skills/decomp/SKILL.md` and its
`references/refactor.md` (shared bodies) and `references/review.md`, `decomp/docs/conventions.md`.

Never read or use another decompilation of this game.

The work is mechanical and byte-gated: every image compiles to the same bytes before and after.
You do not name functions, change types or rewrite logic; where a fold needs a name or a judgment,
list it in the pull request under `needs:` and leave the code as it is.

## Setup, once

    cd ~/projects/bof3/decomp
    tools/worktree.sh --from . --dir ~/projects/bof3/.worktrees/<lane> refactor/<lane>-<mmdd>

## Loop

1. Count the sites of your family first; the counts go in the pull request.
2. Change one group, then check every image it touches:
   `BOF3_CC_CACHE=0 meson compile -C build/meson check-<image>`. Revert a site whose image changes
   and list it with its cause.
3. One pull request per group or family, under about 2000 lines, net lines not up: `git merge
   public/main`, `meson compile -C build/meson format`, commit, the gate (`meson compile -C
   build/meson pre-push >| build/gate.log 2>&1` must end `pre-push: all checks passed`), push, the
   repository template (What, Why, Checks), `gh pr merge --squash --auto --delete-branch`.

## Never

- Touch `src/overlays/scenario`, `src/overlays/boss`, a `NON_MATCHING` draft, or a function a match
  lane claims (`~/.cache/bof3-swarm/claims`).
- Amend, force-push, rebase, or close a pull request. `rm` under `build/`. Delete outside your worktree.
- Put a model or tool name, or `Co-authored-by`, in a commit or pull request.

Commit as `git -c user.name='Raúl Correia' -c user.email=19838093+raulcorreia7@users.noreply.github.com`.
