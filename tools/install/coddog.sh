#!/usr/bin/env bash
# coddog 0.6.3: function comparison report for matching decompilation.
# Installs the pinned release binary into $INSTALL_BIN_DIR; an existing binary
# is replaced only after a checksum-verified download.
set -euo pipefail

PIN=0.6.3
SHA256=c8e1dd6228d4363378598b71c57095fc8d5b02c3d0cffb1c71b051a257e75bc7
BIN=coddog
DEST="${INSTALL_BIN_DIR:-$HOME/.local/bin}"

usage() {
  cat <<EOF
Usage: bash tools/install/$BIN.sh [OPTIONS]

Install coddog $PIN (Linux x86_64) into \$INSTALL_BIN_DIR.

Options:
  --force     Reinstall even when some coddog is already on PATH.
  -h, --help  Show this help and exit.

Environment:
  INSTALL_BIN_DIR  Install directory (default: \$HOME/.local/bin).

Exit 0 when already satisfied or on success; 1 on usage, platform, checksum,
or unwritable install directory. Skips on presence alone (unstable version
output). No PATH edits, no sudo.
EOF
}

FORCE=0
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "usage: $0 [--force]" >&2; exit 1 ;;
  esac
done

if [[ "$FORCE" == 0 ]] && command -v "$BIN" >/dev/null 2>&1; then
  echo "$BIN already on PATH ($(command -v "$BIN")); use --force to reinstall $PIN"
  exit 0
fi

if [[ "$(uname -s)" != Linux || "$(uname -m)" != x86_64 ]]; then
  echo "unsupported platform: $(uname -s) $(uname -m); see https://github.com/ethteck/coddog/releases" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
curl -fL --retry 3 -o "$TMP/coddog.tar.xz" \
  "https://github.com/ethteck/coddog/releases/download/$PIN/coddog-cli-x86_64-unknown-linux-gnu.tar.xz"
echo "$SHA256  $TMP/coddog.tar.xz" | sha256sum -c -

if ! mkdir -p "$DEST"; then
  echo "cannot create $DEST" >&2
  exit 1
fi
if [[ ! -w "$DEST" ]]; then
  echo "cannot write $DEST; point INSTALL_BIN_DIR at a writable directory" >&2
  exit 1
fi

mkdir -p "$TMP/x"
tar xJf "$TMP/coddog.tar.xz" -C "$TMP/x"
mv -f "$TMP/x/coddog-cli-x86_64-unknown-linux-gnu/coddog" "$DEST/coddog"
"$DEST/coddog" --version 2>/dev/null | head -1 || echo "installed $BIN $PIN"
case ":$PATH:" in
  *":$DEST:"*) ;;
  *) echo "note: put $DEST on PATH" ;;
esac
