#!/usr/bin/env bash
# objdiff-cli 3.8.3: progressive binary diff for matching decompilation.
# Installs the pinned release binary into $INSTALL_BIN_DIR; an existing binary
# is replaced only after a checksum-verified download.
set -euo pipefail
PIN=3.8.3
SHA256=e823ae932a56c68dcd86b68d12f2268c953e0c027402162c8a6dfa6a00d65008
BIN=objdiff-cli
DEST="${INSTALL_BIN_DIR:-$HOME/.local/bin}"

usage() {
  cat <<EOF
Usage: bash tools/install/$BIN.sh [OPTIONS]

Install objdiff-cli $PIN (Linux x86_64) into \$INSTALL_BIN_DIR.

Options:
  --force     Reinstall even when a sufficient objdiff-cli is already on PATH.
  -h, --help  Show this help and exit.

Environment:
  INSTALL_BIN_DIR  Install directory (default: \$HOME/.local/bin).

Exit 0 when already satisfied or on success; 1 on usage, platform, checksum,
or unwritable install directory. No PATH edits, no sudo.
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
  v="$("$BIN" --version 2>/dev/null | head -1 | grep -o '[0-9][0-9.]*' | head -1 || true)"
  if [[ -n "$v" ]] && [[ "$(printf '%s\n%s\n' "$PIN" "$v" | sort -V | head -1)" == "$PIN" ]]; then
    echo "$BIN $v already on PATH ($(command -v "$BIN")); use --force to reinstall $PIN"
    exit 0
  fi
fi

if [[ "$(uname -s)" != Linux || "$(uname -m)" != x86_64 ]]; then
  echo "unsupported platform: $(uname -s) $(uname -m); see https://github.com/encounter/objdiff/releases" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
curl -fL --retry 3 -o "$TMP/objdiff-cli" \
  "https://github.com/encounter/objdiff/releases/download/v$PIN/objdiff-cli-linux-x86_64"
echo "$SHA256  $TMP/objdiff-cli" | sha256sum -c -

if ! mkdir -p "$DEST"; then
  echo "cannot create $DEST" >&2
  exit 1
fi
if [[ ! -w "$DEST" ]]; then
  echo "cannot write $DEST; point INSTALL_BIN_DIR at a writable directory" >&2
  exit 1
fi

chmod +x "$TMP/objdiff-cli"
mv -f "$TMP/objdiff-cli" "$DEST/objdiff-cli"
"$DEST/objdiff-cli" --version | head -1
case ":$PATH:" in
  *":$DEST:"*) ;;
  *) echo "note: put $DEST on PATH" ;;
esac
