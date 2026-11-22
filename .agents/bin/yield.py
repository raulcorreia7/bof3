#!/usr/bin/env python3
"""yield.py [add LANE ROUND MODEL EFFORT CLASS MATCHES CALLS KTOKENS]: the rounds ledger.

With no argument, prints matches per 100k tokens by model and class of work, best first: the
routing table of the workflow reads from it. `add` appends one round. The ledger is
$BOF3_SWARM/rounds.jsonl (default ~/.cache/bof3-swarm).
"""
import datetime
import json
import os
import sys
from collections import defaultdict
from pathlib import Path

LEDGER = Path(os.environ.get("BOF3_SWARM", Path.home() / ".cache/bof3-swarm")) / "rounds.jsonl"


def main(argv: list[str]) -> int:
    if argv[:1] == ["add"]:
        lane, rnd, model, effort, work, matches, calls, ktokens = argv[1:9]
        row = {
            "date": datetime.date.today().isoformat(), "lane": lane, "round": int(rnd), "model": model,
            "effort": effort, "class": work, "matches": int(matches), "calls": int(calls), "ktokens": int(ktokens),
        }
        with LEDGER.open("a", encoding="utf-8") as ledger:
            ledger.write(json.dumps(row) + "\n")
        return 0
    groups = defaultdict(lambda: [0, 0, 0])
    for line in LEDGER.read_text(encoding="utf-8").splitlines():
        row = json.loads(line)
        group = groups[(row["model"], row["effort"], row["class"])]
        group[0] += 1
        group[1] += row["matches"]
        group[2] += row["ktokens"] or 0
    rate = lambda g: g[1] * 100 / g[2] if g[2] else 0.0
    print(f"{'model':8}{'effort':8}{'rounds':>7}{'matches':>8}{'ktok':>7}{'per100k':>9}  class")
    for (model, effort, work), g in sorted(groups.items(), key=lambda item: -rate(item[1])):
        print(f"{model:8}{effort:8}{g[0]:7}{g[1]:8}{g[2]:7}{rate(g):9.2f}  {work}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
