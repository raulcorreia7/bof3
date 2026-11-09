#!/bin/sh
# Stage stable workspace executables after their member build completes.
set -eu
cd "$(dirname "$0")/.."

case "${1:-}" in
    tools)
        [ "$#" -eq 1 ] || exit 2
        mkdir -p bin
        ln -sfn ../build/rust/release/bof3 bin/bof3
        ln -sfn ../build/rust/release/bof3-edit bin/bof3-edit
        ;;
    player|player-gui)
        [ "$#" -eq 1 ] || exit 2
        mkdir -p bin build
        cp player/data/bof3-names.json build/bof3-names.json
        if [ "$1" = player ]; then
            ln -sfn ../build/audio/release/bof3player bin/bof3player
            ln -sfn ../build/audio/release/bof3player-tui bin/bof3player-tui
        else
            ln -sfn ../build/audio/release/bof3player-gui bin/bof3player-gui
        fi
        ;;
    *)
        echo 'usage: sh tools/stage.sh tools|player|player-gui' >&2
        exit 2
        ;;
esac
