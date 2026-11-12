#!/bin/sh
# Print the host tools each make target needs and which of them are missing.
set -eu

missing=0

need() { # target tool...
    target=$1
    shift
    for tool in "$@"; do
        if command -v "$tool" >/dev/null 2>&1; then
            printf '  ok       %-12s %s\n' "$tool" "$target"
        else
            printf '  MISSING  %-12s %s\n' "$tool" "$target"
            missing=1
        fi
    done
}

need 'all targets' git make
need 'check, format' dprint
need 'setup, build, check-game, check-game-free' curl 7z uv meson ninja cc
need 'build-tools, check-tools, build-player, check-player' cargo
need 'check-tools, check-player' cargo-deny
need 'check, check-status' node npm

if [ "$missing" -eq 1 ]; then
    echo 'Install missing tools from each project README #requirements; cargo install cargo-deny --locked.'
    echo 'Full list: https://github.com/raulcorreia7/bof3-decomp/blob/main/docs/toolchain.md#host-tools'
    exit 1
fi
