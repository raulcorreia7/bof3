#!/usr/bin/env bash
# rizin 0.9.1 (static): disassembly and analysis for reverse engineering.
# Extracts the pinned static release prefix tree into $INSTALL_PREFIX; existing
# files are touched only after a checksum-verified download.
set -euo pipefail

PIN=0.9.1
SHA256=9102249a9f0b6319c5334a2e5cf8d9cc3f2035e1d3def027c41f6a90f647e8cf
BIN=rizin
PREFIX="${INSTALL_PREFIX:-$HOME/.local}"

usage() {
  cat <<EOF
Usage: bash tools/install/$BIN.sh [OPTIONS]

Install rizin $PIN (Linux x86_64 static build) into \$INSTALL_PREFIX,
so the binary lands at \$INSTALL_PREFIX/bin/rizin with its runtime data.

Options:
  --force     Reinstall even when some rizin is already on PATH.
  -h, --help  Show this help and exit.

Environment:
  INSTALL_PREFIX  Install prefix (default: \$HOME/.local).

Exit 0 when already satisfied or on success; 1 on usage, platform, checksum,
or unwritable prefix. Skips on presence alone (unstable version output).
No PATH edits, no sudo.
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
  echo "unsupported platform: $(uname -s) $(uname -m); see https://github.com/rizinorg/rizin/releases" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
curl -fL --retry 3 -o "$TMP/rizin.tar.xz" \
  "https://github.com/rizinorg/rizin/releases/download/v$PIN/rizin-v$PIN-static-x86_64.tar.xz"
echo "$SHA256  $TMP/rizin.tar.xz" | sha256sum -c -

if ! mkdir -p "$PREFIX"; then
  echo "cannot create $PREFIX" >&2
  exit 1
fi
if [[ ! -w "$PREFIX" ]]; then
  echo "cannot write $PREFIX; point INSTALL_PREFIX at a writable directory" >&2
  exit 1
fi

tar xJf "$TMP/rizin.tar.xz" -C "$PREFIX"
"$PREFIX/bin/rizin" -v | head -1
case ":$PATH:" in
  *":$PREFIX/bin:"*) ;;
  *) echo "note: put $PREFIX/bin on PATH" ;;
esac
