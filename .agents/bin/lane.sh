#!/bin/sh
# lane.sh <workspace> <name> <kind> <brief> <prompt> [-- agent args]: start one lane in a new pane
# of the herdr workspace: the agent reads .agents/briefs/<brief>, then gets <prompt>.
set -eu
ws=$1 name=$2 kind=$3 brief=$4 prompt=$5
shift 5
[ "${1:-}" = -- ] && shift
root=$(cd "$(dirname "$0")/../.." && pwd)
first=$(herdr pane list --workspace "$ws" | jq -r '.result.panes[0].pane_id')
pane=$(herdr pane split "$first" --direction down --cwd "$root/decomp" --env DOTFILES_TMUX_AUTOSTART=0 --no-focus | jq -r .result.pane.pane_id)
herdr agent start "$name" --kind "$kind" --pane "$pane" --timeout 60000 -- "$@" >/dev/null
herdr agent prompt "$name" "You are lane '$name'. Read $root/.agents/briefs/$brief and follow it. $prompt"
echo "$name $pane"
