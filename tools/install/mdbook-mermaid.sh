#!/usr/bin/env bash
# mdbook-mermaid 0.17.1: mdBook preprocessor rendering mermaid diagrams in the wiki.
# Installs the pinned release binary into $INSTALL_BIN_DIR; an existing binary
# is replaced only after a checksum-verified download.
set -euo pipefail

PIN=0.17.1
SHA256=9afcfa5b8463afe606d48595a7ae338564302903e626ea5b6edb8007d29393a5
BIN=mdbook-mermaid
DEST="${INSTALL_BIN_DIR:-$HOME/.local/bin}"

usage() {
  cat <<EOF
Usage: bash tools/install/$BIN.sh [OPTIONS]

Install mdbook-mermaid $PIN (Linux x86_64) into \$INSTALL_BIN_DIR.

Options:
  --force     Reinstall even when a sufficient mdbook-mermaid is already on PATH.
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
  echo "unsupported platform: $(uname -s) $(uname -m); see https://github.com/badboy/mdbook-mermaid/releases" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
curl -fL --retry 3 -o "$TMP/mdbook-mermaid.tar.gz" \
  "https://github.com/badboy/mdbook-mermaid/releases/download/v$PIN/mdbook-mermaid-v$PIN-x86_64-unknown-linux-gnu.tar.gz"
echo "$SHA256  $TMP/mdbook-mermaid.tar.gz" | sha256sum -c -

if ! mkdir -p "$DEST"; then
  echo "cannot create $DEST" >&2
  exit 1
fi
if [[ ! -w "$DEST" ]]; then
  echo "cannot write $DEST; point INSTALL_BIN_DIR at a writable directory" >&2
  exit 1
fi

mkdir -p "$TMP/x"
tar xzf "$TMP/mdbook-mermaid.tar.gz" -C "$TMP/x"
mv -f "$TMP/x/mdbook-mermaid" "$DEST/mdbook-mermaid"
"$DEST/mdbook-mermaid" --version | head -1
case ":$PATH:" in
  *":$DEST:"*) ;;
  *) echo "note: put $DEST on PATH" ;;
esac
