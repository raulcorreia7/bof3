#!/bin/bash
# keepalive.sh [PUBLISH_WT]: every 5 min, restart lanes idle on two checks in a row; every 30 min, publish.
# Lanes are the named herdr agents except the reviewer and those in ~/.cache/bof3-swarm/stopped; logs to keepalive.log there.
here=$(cd "$(dirname "$0")" && pwd)
wt=${1:-$HOME/projects/bof3/.worktrees/status-publish}
log=$HOME/.cache/bof3-swarm/keepalive.log
prompt="Next round now: continue your lane per its brief with the next unclaimed rows (claim each with .agents/bin/claim.sh), a new branch off public/main, prove with check-<image>, polish, batch 3-6, gate, PR with auto-merge, then start the next round without waiting. If your PR is DIRTY, merge public/main first. Do not ask questions."
declare -A seen
tick=0
while :; do
  skip=" rv1 $(tr '\n' ' ' <"$HOME/.cache/bof3-swarm/stopped" 2>/dev/null)"
  while read -r name status; do
    [[ $skip == *" $name "* ]] && continue
    if [[ $status == idle || $status == done ]]; then
      if [[ ${seen[$name]} == 1 ]]; then
        herdr agent prompt "$name" "$prompt" >/dev/null 2>&1 && echo "$(date +%T) nudged $name" >>"$log"
        seen[$name]=0
      else
        seen[$name]=1
      fi
    else
      seen[$name]=0
    fi
  done < <(herdr agent list | python3 -c 'import json,sys; [print(a["name"], a["agent_status"]) for a in json.load(sys.stdin)["result"]["agents"] if a.get("name")]')
  if (( tick % 6 == 0 )); then
    sh "$here/publish.sh" "$wt" >>"$log" 2>&1; echo "$(date +%T) publish ran: $(cat "$HOME/.cache/bof3-swarm/published")" >>"$log"
  fi
  tick=$((tick + 1))
  sleep 300
done
