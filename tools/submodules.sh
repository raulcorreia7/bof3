#!/bin/sh
# Initialize, inspect or synchronize pinned workspace submodules.
set -eu

cd "$(dirname "$0")/.."

usage() {
    echo 'usage: sh tools/submodules.sh status|sync|init game|tools|player|status|wiki' >&2
    exit 2
}

init() {
    case "$1" in
        game)   path=decomp; marker=meson.build ;;
        player) path=player; marker=Cargo.toml ;;
        status) path=status; marker=Makefile ;;
        wiki)   path=wiki; marker=book.toml ;;
        tools)
            init game
            git -C decomp submodule sync -- tools/bof3-tools
            if [ ! -f decomp/tools/bof3-tools/Cargo.toml ]; then
                git -C decomp submodule update --init -- tools/bof3-tools
            fi
            test -f decomp/tools/bof3-tools/Cargo.toml
            return
            ;;
        *) usage ;;
    esac
    if [ ! -f "$path/$marker" ]; then
        git submodule update --init -- "$path"
    fi
    test -f "$path/$marker"
}

case "${1:-}" in
    status)
        [ "$#" -eq 1 ] || usage
        git submodule status --recursive
        ;;
    sync)
        [ "$#" -eq 1 ] || usage
        git submodule sync -- decomp player status wiki
        git submodule update --init -- decomp player status wiki
        git -C decomp submodule sync -- tools/bof3-tools
        git -C decomp submodule update --init -- tools/bof3-tools
        ;;
    init)
        [ "$#" -eq 2 ] || usage
        init "$2"
        ;;
    *) usage ;;
esac
