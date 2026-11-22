#!/usr/bin/env python3
"""primfold.py: fold raw primitive field stores into the PsyQ macros where the bytes stay.

For every run of consecutive `prim->field = value;` statements on one primitive, inside a MATCH
function of a .c file, try each SDK macro whose fields the run sets (setXY4/3/2/0, setUV4/3/0,
setRGB0..3, setWH) in place of those lines; keep it when tools/match.sh still says match. Run
from a decomp worktree with a fresh build. Prints TSV: file, function, macro, KEPT|FOLDED.
"""
import gzip
import json
import re
import subprocess
from pathlib import Path

ROOT = Path.cwd()
index = json.load(gzip.open(ROOT / "build/func_index.json.gz"))
image_of = {(f["src"], f["name"]): f["image"] for f in index}
DEF = re.compile(r"^(MATCH|HAND_ASM|NON_MATCHING)\s+[\w\s\*]*?\b(\w+)\s*\(")
STORE = re.compile(r"^(\s*)([A-Za-z_][\w]*(?:(?:->|\.)\w+|\[[^\]]+\])*)->([xyuvrgbwh][0-3]?)\s*=\s*([^=;][^;]*);\s*$")
MACROS = [  # name, fields in argument order
    ("setXY4", ["x0", "y0", "x1", "y1", "x2", "y2", "x3", "y3"]),
    ("setXY3", ["x0", "y0", "x1", "y1", "x2", "y2"]),
    ("setXY2", ["x0", "y0", "x1", "y1"]),
    ("setXY0", ["x0", "y0"]),
    ("setUV4", ["u0", "v0", "u1", "v1", "u2", "v2", "u3", "v3"]),
    ("setUV3", ["u0", "v0", "u1", "v1", "u2", "v2"]),
    ("setUV0", ["u0", "v0"]),
    ("setRGB0", ["r0", "g0", "b0"]),
    ("setRGB1", ["r1", "g1", "b1"]),
    ("setRGB2", ["r2", "g2", "b2"]),
    ("setRGB3", ["r3", "g3", "b3"]),
    ("setWH", ["w", "h"]),
]


def matches(image: str, func: str) -> bool:
    return subprocess.run(["tools/match.sh", image, func], capture_output=True, text=True).returncode == 0


def runs(lines: list[str]):
    """Each run: (function, primitive, {field: (line index, value)}) over consecutive stores."""
    func, current, prim = None, {}, None
    for i, line in enumerate(lines + [""]):
        d = DEF.match(line)
        if d:
            func = d.group(2) if d.group(1) == "MATCH" else None
        m = STORE.match(line)
        if m and func and (prim is None or m.group(2) == prim) and m.group(3) not in current and "," not in m.group(4):
            prim = m.group(2)
            current[m.group(3)] = (i, m.group(4).strip(), m.group(1))
            continue
        if current:
            yield func, prim, current
        current, prim = {}, None
        if m and func and "," not in m.group(4):
            prim = m.group(2)
            current[m.group(3)] = (i, m.group(4).strip(), m.group(1))


def fold(path: Path) -> None:
    rel = str(path.relative_to(ROOT))
    tried: set[tuple] = set()
    while True:
        lines = path.read_text().split("\n")
        step = None
        for func, prim, fields in runs(lines):
            for name, need in MACROS:
                key = (func, prim, name, tuple(fields[f][0] for f in need if f in fields))
                if all(f in fields for f in need) and key not in tried:
                    step = (func, prim, fields, name, need, key)
                    break
            if step:
                break
        if not step:
            return
        func, prim, fields, name, need, key = step
        tried.add(key)
        image = image_of.get((rel, func))
        if not image or not matches(image, func):
            continue
        rows = sorted(fields[f][0] for f in need)
        indent = fields[need[0]][2]
        call = f"{indent}{name}({prim}, {', '.join(fields[f][1] for f in need)});"
        cand = [call if i == rows[0] else line for i, line in enumerate(lines) if i == rows[0] or i not in rows]
        original = "\n".join(lines)
        path.write_text("\n".join(cand))
        if matches(image, func):
            print(f"{rel}\t{func}\t{name}\tFOLDED", flush=True)
        else:
            path.write_text(original)
            print(f"{rel}\t{func}\t{name}\tKEPT", flush=True)


for name in subprocess.run(
    ["git", "grep", "-l", "-E", "-e", r"->[xyuvrgbwh][0-3]?\s*=", "--", "src/*.c"], capture_output=True, text=True
).stdout.split():
    fold(ROOT / name)
