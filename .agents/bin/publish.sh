#!/bin/sh
# publish.sh [worktree] [--force]: publish decomp main's progress report to bof3-status.
#
# The report needs the extracted disc and the PsyQ toolchain, so it is built here, on the
# owner's machine, never in hosted CI. Build decomp main in a worktree that has both, upload
# build/report.json to the bof3-status `progress` release, and start the site deploy. When the
# released report already names main's commit, exit without a build.
set -eu

repo=raulcorreia7/bof3-status
state_dir=${BOF3_SWARM:-$HOME/.cache/bof3-swarm}
root=$(cd "$(dirname "$0")/../.." && pwd)
wt=$root/.worktrees/status-publish
force=

usage() {
	cat <<'EOF'
usage: publish.sh [worktree] [--force]

Publish decomp main's progress report to https://raulcorreia7.github.io/bof3-status/.

  worktree   decomp checkout with a disc build (default: .worktrees/status-publish)
  --force    publish even when the released report is already from main

Needs gh (logged in), meson, python3, objdiff-cli and the extracted disc.
EOF
}

fail() {
	echo "publish: $*" >&2
	exit 1
}

for arg in "$@"; do
	case $arg in
	-h | --help) usage; exit 0 ;;
	--force) force=1 ;;
	-*) fail "unknown option: $arg" ;;
	*) wt=$arg ;;
	esac
done

[ -d "$wt" ] || fail "no worktree at $wt"
cd "$wt"
git rev-parse --git-dir >/dev/null 2>&1 || fail "$wt is not a git checkout"
[ -d build/bin ] || [ -d build/disc ] || fail "$wt has no extracted disc (build/bin or build/disc)"
[ -z "$(git status --porcelain --untracked-files=no)" ] || fail "$wt has local changes; commit or stash them first"
for tool in meson gh python3; do
	command -v "$tool" >/dev/null 2>&1 || fail "$tool is not on PATH"
done
gh auth status >/dev/null 2>&1 || fail "gh is not logged in"
bin/internal/find-tool objdiff-cli >/dev/null 2>&1 || fail "objdiff-cli not found; see decomp/docs/toolchain.md#matching-tools"

remote=$(git remote | grep -m1 -E '^(public|origin)$') || fail "$wt has no origin or public remote"
git fetch -q "$remote"
main=$(git rev-parse --short=9 "$remote/main")

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' 0 1 2 15
released=
if gh release download progress -R "$repo" -p report.json -O "$tmp/report.json" --clobber >/dev/null 2>&1; then
	released=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("provenance",{}).get("commit",""))' "$tmp/report.json")
fi
if [ -z "$force" ] && [ "$released" = "$main" ]; then
	echo "publish: the site is already from $main; nothing to do (--force publishes again)"
	exit 0
fi

git checkout -q --detach "$remote/main"
printf 'publish: building %s in %s\n' "$main" "$wt"
if ! { meson setup --reconfigure build/meson && meson compile -C build/meson && meson compile -C build/meson report; } >build/report.log 2>&1; then
	tail -n 20 build/report.log >&2
	fail "build failed; full log: $wt/build/report.log"
fi

counts=$(python3 - "$wt/build/report.json" <<'EOF'
import json, sys

report = json.load(open(sys.argv[1]))
game = next(c for c in report["categories"] if c["id"] == "game")["measures"]
print(game["matched_functions"], game["total_functions"])
EOF
)
matched=${counts% *}
total=${counts#* }

gh release upload progress build/report.json --clobber -R "$repo" >/dev/null
gh workflow run deploy.yml -R "$repo"
mkdir -p "$state_dir"
printf '%s\n' "$counts" >"$state_dir/published"
printf 'publish: %s/%s game functions matched, report from %s\n' "$matched" "$total" "$main"
printf 'publish: deploy started: https://github.com/%s/actions/workflows/deploy.yml\n' "$repo"
