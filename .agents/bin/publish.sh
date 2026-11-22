#!/bin/sh
# publish.sh <decomp worktree with a disc build>: build main there, generate the progress report,
# upload it to the bof3-status `progress` release and start the site deploy. Skips the upload when
# the matched count has not changed since the last publish. The report needs the disc, so this
# runs on the owner's machine, not in hosted CI.
set -eu
wt=$1
state=${BOF3_SWARM:-$HOME/.cache/bof3-swarm}/published
cd "$wt"
remote=$(git remote | grep -m1 -E '^(public|origin)$')
git fetch -q "$remote"
git checkout -q --detach "$remote/main"
meson setup --reconfigure build/meson >/dev/null 2>&1 || true
meson compile -C build/meson >/dev/null
meson compile -C build/meson report >| build/report.log 2>&1
now=$(python3 -c 'import json; m=[c for c in json.load(open("build/report.json"))["categories"] if c["id"]=="game"][0]["measures"]; print(m["matched_functions"], m["total_functions"])')
if [ "$now" = "$(cat "$state" 2>/dev/null)" ]; then
	echo "publish: unchanged ($now)"
	exit 0
fi
gh release upload progress build/report.json --clobber -R raulcorreia7/bof3-status
gh workflow run deploy.yml -R raulcorreia7/bof3-status
echo "$now" >| "$state"
echo "publish: $now"
