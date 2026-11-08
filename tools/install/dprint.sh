#!/usr/bin/env bash
# dprint 0.64.3: source formatter used by make format across the monorepo.
# Installs the pinned release binary into $INSTALL_BIN_DIR; an existing binary
# is replaced only after a checksum-verified download.
set -euo pipefail

PIN="${DPRINT_VERSION:-0.64.3}"
SHA256=f71cb7e22d6776439eba168d5cb296092d6413fea7148fe4d70684a2702a4fee
BIN=dprint
DEST="${INSTALL_BIN_DIR:-$HOME/.local/bin}"

usage() {
  cat <<EOF
Usage: bash tools/install/$BIN.sh [OPTIONS]

Install dprint $PIN (Linux x86_64) into \$INSTALL_BIN_DIR.

Options:
  --force     Reinstall even when a sufficient dprint is already on PATH.
  --latest    Resolve the newest GitHub release and its published digest.
  -h, --help  Show this help and exit.

Environment:
  DPRINT_VERSION     Pin a specific version (only 0.64.3 has a pinned digest).
  INSTALL_BIN_DIR    Install directory (default: \$HOME/.local/bin).

Exit 0 when already satisfied or on success; 1 on usage, platform, digest,
checksum, or unwritable install directory. No PATH edits, no sudo.
EOF
}

FORCE=0
LATEST=0
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    --latest) LATEST=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "usage: $0 [--force|--latest]" >&2; exit 1 ;;
  esac
done

if [[ "$LATEST" == 1 ]]; then
  REL="$(curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors https://api.github.com/repos/dprint/dprint/releases/latest)"
  PIN="$(printf '%s\n' "$REL" | sed -n 's/.*"tag_name": *"\([0-9][0-9.]*\)".*/\1/p' | head -1 || true)"
  SHA256="$(printf '%s\n' "$REL" \
    | grep -A8 '"name": "dprint-x86_64-unknown-linux-gnu.zip"' \
    | sed -n 's/.*"digest": *"sha256:\([0-9a-f]*\)".*/\1/p' | head -1 || true)"
  if [[ -z "$PIN" || -z "$SHA256" ]]; then
    echo "no digest; pin DPRINT_VERSION" >&2
    exit 1
  fi
elif [[ "$PIN" != 0.64.3 ]]; then
  echo "no pinned digest for dprint $PIN; use --latest or leave DPRINT_VERSION unset" >&2
  exit 1
fi

if [[ "$FORCE" == 0 ]] && command -v "$BIN" >/dev/null 2>&1; then
  v="$("$BIN" --version 2>/dev/null | head -1 | grep -o '[0-9][0-9.]*' | head -1 || true)"
  if [[ -n "$v" ]] && [[ "$(printf '%s\n%s\n' "$PIN" "$v" | sort -V | head -1)" == "$PIN" ]]; then
    echo "$BIN $v already on PATH ($(command -v "$BIN")); use --force to reinstall $PIN"
    exit 0
  fi
fi

if [[ "$(uname -s)" != Linux || "$(uname -m)" != x86_64 ]]; then
  echo "unsupported platform: $(uname -s) $(uname -m); see https://github.com/dprint/dprint/releases" >&2
  exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
  echo "unzip missing; install unzip (e.g. sudo apt-get install -y unzip)" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
curl -fL --retry 5 --retry-delay 5 --retry-all-errors -o "$TMP/dprint.zip" \
  "https://github.com/dprint/dprint/releases/download/$PIN/dprint-x86_64-unknown-linux-gnu.zip"
echo "$SHA256  $TMP/dprint.zip" | sha256sum -c -

if ! mkdir -p "$DEST"; then
  echo "cannot create $DEST" >&2
  exit 1
fi
if [[ ! -w "$DEST" ]]; then
  echo "cannot write $DEST; point INSTALL_BIN_DIR at a writable directory" >&2
  exit 1
fi

mkdir -p "$TMP/x"
unzip -q -o -j "$TMP/dprint.zip" -d "$TMP/x"
mv -f "$TMP/x/dprint" "$DEST/dprint"
"$DEST/dprint" --version | head -1
case ":$PATH:" in
  *":$DEST:"*) ;;
  *) echo "note: put $DEST on PATH" ;;
esac
