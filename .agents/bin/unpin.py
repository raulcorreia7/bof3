#!/usr/bin/env python3
"""unpin.py: for every FAKE_REG in a MATCH function of a .c file, try plain typed declarations.

Keeps the first form whose function still equals retail under tools/match.sh. Run from a decomp
worktree with a fresh build. Writes results to stdout as TSV: file, function, var, old, new|KEPT.
"""
import gzip
import json
import re
import subprocess
from pathlib import Path

ROOT = Path.cwd()
index = json.load(gzip.open(ROOT / "build/func_index.json.gz"))
image_of = {(f["src"], f["name"]): f["image"] for f in index}
PIN = re.compile(r'^(\s*)FAKE_REG\(\s*([^,]+?)\s*,\s*(\w+)\s*,\s*"(\w+)"\s*\)\s*;[ \t]*(/\*.*\*/)?[ \t]*$')
DEF = re.compile(r"^(?:MATCH|HAND_ASM|NON_MATCHING)\s+[\w\s\*]*?\b(\w+)\s*\(")
TYPES = ["u16", "s16", "u8", "s8", "s32", "u32"]


def matches(image: str, func: str) -> bool:
    r = subprocess.run(["tools/match.sh", image, func], capture_output=True, text=True)
    return r.returncode == 0


def sites(lines):
    func = None
    for i, line in enumerate(lines):
        d = DEF.match(line)
        if d:
            func = d.group(1) if line.startswith("MATCH") else None
        m = PIN.match(line)
        if m and func:
            yield i, func, m


def attempt(path: Path):
    rel = str(path.relative_to(ROOT))
    done = set()
    while True:
        lines = path.read_text().split("\n")
        todo = [(i, f, m) for i, f, m in sites(lines) if (f, m.group(3)) not in done]
        if not todo:
            return
        i, func, m = todo[0]
        indent, typ, var, reg = m.group(1), m.group(2), m.group(3), m.group(4)
        done.add((func, var))
        image = image_of.get((rel, func))
        if not image:
            print(f"{rel}\t{func}\t{var}\t{typ} {reg}\tSKIP no image", flush=True)
            continue
        if not matches(image, func):
            print(f"{rel}\t{func}\t{var}\t{typ} {reg}\tSKIP baseline differs", flush=True)
            continue
        original = "\n".join(lines)
        helper = re.compile(r"^\s*FAKE_(?:OPAQUE|USE)\(\s*" + re.escape(var) + r"\s*\)\s*;\s*$")
        note = i > 0 and re.match(r"^\s*/\* FAKE:.*\*/\s*$", lines[i - 1]) is not None
        won = None
        for t in [typ] + [x for x in TYPES if x != typ]:
            for drop_helpers in (True, False):
                cand = list(lines)
                cand[i] = f"{indent}{t} {var};"
                if note:
                    cand[i - 1] = None
                if drop_helpers:
                    cand = [c for c in cand if c is None or not helper.match(c)]
                elif not any(helper.match(c) for c in lines):
                    continue  # same as the drop form
                text = "\n".join(c for c in cand if c is not None)
                path.write_text(text)
                if matches(image, func):
                    won = f"{t}{'' if drop_helpers else ' +helpers kept'}"
                    break
            if won:
                break
        if not won:
            path.write_text(original)
        print(f"{rel}\t{func}\t{var}\t{typ} {reg}\t{won or 'KEPT'}", flush=True)


files = subprocess.run(["git", "grep", "-l", "FAKE_REG(", "--", "src/*.c"], capture_output=True, text=True).stdout.split()
for name in files:
    attempt(ROOT / name)
