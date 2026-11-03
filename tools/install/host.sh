#!/usr/bin/env bash
# Host tool dispatcher: runs the release installers for the selected groups.
# Passes --force through; each installer owns its own skip-if-satisfied check.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
  cat <<EOF
Usage: bash tools/install/host.sh [OPTIONS] <selection>...

Install host tools by workflow group. Selections (repeatable):
  format     dprint
  game       uv
  docs       mdbook, mdbook-mermaid
  analysis   coddog, objdiff-cli, rizin

Options:
  --force     Forward --force to every installer that runs.
  -h, --help  Show this help and exit.

Exit 0 on success; 1 on unknown selection or no selection. Each installer
writes to INSTALL_BIN_DIR (rizin: INSTALL_PREFIX) as documented in its --help.
EOF
}

FORCE_ARGS=()
SELECTIONS=()
for arg in "$@"; do
  case "$arg" in
    --force) FORCE_ARGS=(--force) ;;
    -h|--help) usage; exit 0 ;;
    format|game|docs|analysis) SELECTIONS+=("$arg") ;;
    *) usage >&2; exit 1 ;;
  esac
done

if [[ "${#SELECTIONS[@]}" -eq 0 ]]; then
  usage >&2
  exit 1
fi

for selection in "${SELECTIONS[@]}"; do
  case "$selection" in
    format)
      bash "$DIR/dprint.sh" "${FORCE_ARGS[@]}"
      ;;
    game)
      bash "$DIR/uv.sh" "${FORCE_ARGS[@]}"
      ;;
    docs)
      bash "$DIR/mdbook.sh" "${FORCE_ARGS[@]}"
      bash "$DIR/mdbook-mermaid.sh" "${FORCE_ARGS[@]}"
      ;;
    analysis)
      bash "$DIR/coddog.sh" "${FORCE_ARGS[@]}"
      bash "$DIR/objdiff-cli.sh" "${FORCE_ARGS[@]}"
      bash "$DIR/rizin.sh" "${FORCE_ARGS[@]}"
      ;;
  esac
done
