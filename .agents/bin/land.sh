#!/bin/bash
# land.sh <worktree> <branch> <pr>...: land pull requests one at a time. For each: merge main into
# the branch (detached, in <worktree>), push, wait for CI and the auto-merge. Stops at a conflict.
# The commit identity comes from GIT_AUTHOR_* and GIT_COMMITTER_*.
set -u
: "${GIT_COMMITTER_EMAIL:?set GIT_AUTHOR_NAME, GIT_AUTHOR_EMAIL, GIT_COMMITTER_NAME, GIT_COMMITTER_EMAIL}"
state() { gh pr view "$1" --json state,mergeStateStatus -q '.state+" "+.mergeStateStatus'; }
while [ $# -ge 3 ]; do
  wt=$1 br=$2 pr=$3; shift 3
  cd "$wt" || exit 1
  remote=$(git remote | grep -m1 -E '^(public|origin)$')
  for _ in 1 2 3; do
    case "$(state "$pr")" in MERGED*) break ;; esac
    git fetch -q "$remote"
    git checkout -q --detach "$remote/$br"
    git merge -q --no-edit "$remote/main" || { echo "#$pr conflict: use rename-merge.py or resolve by hand"; git merge --abort; break; }
    git push -q "$remote" "HEAD:refs/heads/$br"
    sleep 20
    timeout 2400 gh pr checks "$pr" --watch >/dev/null 2>&1
    for _ in $(seq 1 20); do case "$(state "$pr")" in MERGED*) break ;; esac; sleep 15; done
  done
  echo "#$pr $(state "$pr")"
done
