#!/usr/bin/env python3
"""yield.py [add LANE ROUND MODEL EFFORT CLASS MATCHES CALLS KTOKENS | trend]: the rounds ledger.

With no argument, prints matches per 100k tokens by model and class of work, best first: the
routing table of the workflow reads from it. `add` appends one round. `trend` prints the rate by day
and each lane's last three rounds, for the stop rules. The ledger is
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
    rows = [json.loads(line) for line in LEDGER.read_text(encoding="utf-8").splitlines()]
    rate = lambda g: g[1] * 100 / g[2] if g[2] else 0.0
    if argv[:1] == ["trend"]:
        days, lanes = defaultdict(lambda: [0, 0, 0]), defaultdict(list)
        for row in rows:
            day = days[row["date"]]
            day[0] += 1
            day[1] += row["matches"]
            day[2] += row["ktokens"] or 0
            lanes[row["lane"]].append(row["matches"])
        for date, day in sorted(days.items()):
            print(f"{date}  rounds {day[0]:3}  matches {day[1]:4}  ktok {day[2]:6}  per100k {rate(day):5.2f}")
        for lane, matches in lanes.items():
            last = matches[-3:]
            print(f"{lane:12}last {last}  {'DRY: stop' if len(last) >= 2 and not any(last[-2:]) else ''}")
        return 0
    groups = defaultdict(lambda: [0, 0, 0])
    for row in rows:
        group = groups[(row["model"], row["effort"], row["class"])]
        group[0] += 1
        group[1] += row["matches"]
        group[2] += row["ktokens"] or 0
    print(f"{'model':8}{'effort':8}{'rounds':>7}{'matches':>8}{'ktok':>7}{'per100k':>9}  class")
    for (model, effort, work), g in sorted(groups.items(), key=lambda item: -rate(item[1])):
        print(f"{model:8}{effort:8}{g[0]:7}{g[1]:8}{g[2]:7}{rate(g):9.2f}  {work}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
