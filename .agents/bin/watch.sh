#!/bin/bash
# watch.sh [MINUTES]: wait until the swarm needs the coordinator, then print why and exit.
# Reasons: a blocked lane, a pull request failing or open over an hour, a new published count,
# the keepalive loop gone, or MINUTES (default 45) passed.
limit=${1:-45}
repo=raulcorreia7/bof3-decomp
count0=$(cat "$HOME/.cache/bof3-swarm/published" 2>/dev/null)
for ((i = 0; i < limit; i += 5)); do
  why=""
  blocked=$(herdr agent list | python3 -c 'import json,sys; print(" ".join(a["name"] for a in json.load(sys.stdin)["result"]["agents"] if a.get("name") and a["agent_status"] in ("blocked","unknown")))')
  [ -n "$blocked" ] && why+="blocked lanes: $blocked\n"
  prs=$(gh pr list -R $repo --json number,createdAt,statusCheckRollup,mergeStateStatus -q '.[] | select((.statusCheckRollup // [] | map(.conclusion) | index("FAILURE")) or ((now - (.createdAt | fromdate)) > 3600)) | "\(.number):\(.mergeStateStatus)"' 2>/dev/null | tr '\n' ' ')
  [ -n "$prs" ] && why+="pull requests failing or older than 1 h: $prs\n"
  count=$(cat "$HOME/.cache/bof3-swarm/published" 2>/dev/null)
  [ "$count" != "$count0" ] && why+="published count: $count0 -> $count\n"
  pgrep -f 'bin/keepalive.sh' >/dev/null || why+="keepalive loop is not running\n"
  if [ -n "$why" ]; then printf '%b' "$why"; break; fi
  sleep 300
done
echo "lanes: $(herdr agent list | python3 -c 'import json,sys; print(" ".join(a["name"]+"="+a["agent_status"] for a in json.load(sys.stdin)["result"]["agents"] if a.get("name")))')"
echo "open PRs: $(gh pr list -R $repo --json number,mergeStateStatus -q '.[]|"\(.number):\(.mergeStateStatus)"' | tr '\n' ' ')"
echo "published: $(cat "$HOME/.cache/bof3-swarm/published")"
tail -3 "$HOME/.cache/bof3-swarm/keepalive.log"
