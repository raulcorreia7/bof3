# Resolver lane

You keep the pull requests of `raulcorreia7/bof3-decomp` landing. Work alone, no subagents,
continuously: after each pass wait five minutes (`sleep 300`) and start again. Say `CONTEXT` when
your context is nearly full.

Read first: `~/projects/bof3/.agents/workflow.re.yml` (rules, commands), `~/projects/bof3/decomp/AGENTS.md`,
`decomp/tools/README.md` (the pre-push table).

Never read or use another decompilation of this game.

## Setup, once

    cd ~/projects/bof3/decomp
    tools/worktree.sh --from . --dir ~/projects/bof3/.worktrees/resolver resolver/base

All your work happens in that worktree, on a detached checkout of the pull request's branch.

## Each pass

1. `gh pr list --state open --json number,headRefName,mergeStateStatus,statusCheckRollup,updatedAt`.
2. Leave a pull request alone when it is younger than 20 minutes or its checks are still running:
   its lane is on it.
3. DIRTY (conflicts): `git fetch public; git checkout --detach public/<branch>; git merge public/main`.
   - `config/attempts*.jsonl` and `docs/matching.md` table rows: keep both sides' rows.
   - A file one side only renamed things in: take the other side's body and apply the renames again
     (`~/projects/bof3/.agents/bin/rename-merge.py` does this for a rename branch).
   - Code that no longer compiles after the merge because `main` changed a name or a macro (for
     example `g_Task->member` is now `TASK(PartyMember)->member` in battle and battle-magic code):
     apply `main`'s form.
   - A conflict between two different bodies of the same function: keep the one that is `MATCH`;
     never keep a draft over a match. If both are drafts, keep `main`'s and say so in a comment on
     the pull request.
4. Failed checks: `gh run view <id> --log-failed`, then `build/pre-push/<check>.log` after running
   the gate locally. Fix what the check names (format, a raw address in a comment, a header that
   needs `meson setup --reconfigure build/meson`, a missing attempts row). Do not weaken a check.
5. After any change: `meson compile -C build/meson format`, commit, then
   `BOF3_CC_CACHE=0 meson compile -C build/meson check-<image>` for every image whose files the
   merge touched, and the gate: `meson compile -C build/meson pre-push >| build/gate.log 2>&1`,
   which must end `pre-push: all checks passed`. Then `git push public HEAD:refs/heads/<branch>`.
6. A pull request with no auto-merge: `gh pr merge <n> --squash --auto --delete-branch`.
7. A problem you cannot fix in three tries: comment on the pull request with the failing check and
   what you tried, and move on.

## Never

- Close a pull request, delete a branch, amend, force-push or rebase.
- Turn a `MATCH` function into a draft, or drop an attempts row, to make a merge pass.
- `rm` under `build/`, or delete anything outside your worktree.
- Put a model or tool name, or `Co-authored-by`, in a commit, comment or pull request.

Commit as `git -c user.name='Raúl Correia' -c user.email=19838093+raulcorreia7@users.noreply.github.com`.
