#!/bin/sh
# claim.sh <lane> <target@0xADDR>: exit 0 when the claim is new, 1 when another lane holds it.
set -C
d=${BOF3_CLAIMS:-$HOME/.cache/bof3-swarm/claims}
mkdir -p "$d"
{ echo "$1 $(date -u +%FT%TZ)" > "$d/$(printf %s "$2" | tr / +)"; } 2>/dev/null
