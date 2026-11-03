#!/bin/sh
# Remove generated workspace outputs without deleting operator-supplied game inputs.
set -eu

cd "$(dirname "$0")/.."

case "${1:-}" in
    clean|distclean) [ "$#" -eq 1 ] ;;
    *) echo 'usage: sh tools/clean.sh clean|distclean' >&2; exit 2 ;;
esac

# Game: remove built images, objects and scratch. The Meson configuration and the extracted disc
# (build/disc, build/bin) stay, so `make build` needs no setup.
if [ -f decomp/build/meson/build.ninja ]; then meson compile -C decomp/build/meson --clean; fi
rm -rf decomp/work decomp/build/report.json
if [ -f status/Makefile ]; then make -C status clean; fi
rm -rf build/extract build/wiki build/rust/tmp

# Prune workspace-owned Python caches, not member repositories.
find . \( -path './.git' -o -path './.venv' -o -path './build' \
    -o -path './bin' -o -path './decomp' \
    -o -path './status' -o -path './player' \
    -o -path './.local' \) -prune -o \
    -type d \( -name '__pycache__' -o -name '.pytest_cache' -o -name '.ruff_cache' \) \
    -prune -exec rm -rf {} +

if [ "$1" = distclean ]; then
    if [ -f status/Makefile ]; then make -C status distclean; fi
    if [ -f decomp/tools/bof3-tools/Makefile ]; then
        CARGO_TARGET_DIR="$(pwd)/build/rust" make -C decomp/tools/bof3-tools clean
    fi
    rm -rf decomp/build/meson decomp/.venv .venv build/rust build/audio
fi
