#!/usr/bin/env python3
"""rename-merge.py: merge public/main into the rename branch checked out here (decomp worktree).

Rename pairs come from the branch's own diff against the merge base (word-paired - / + lines).
Conflicted files take main's side; then every tracked text file under src/ include/ config/ docs/
tools/ gets the old names replaced as whole words, where the old name is gone from the branch.
"""
import re
import subprocess
from collections import Counter

def git(*a, check=True):
    return subprocess.run(["git", *a], capture_output=True, text=True, check=check).stdout

base = git("merge-base", "HEAD", "public/main").strip()
diff = git("diff", "--word-diff=porcelain", "--word-diff-regex=[A-Za-z_][A-Za-z0-9_]*|[^[:space:]]", base, "HEAD", "--", "src", "include")
lines = diff.split("\n")
votes = Counter()
ident = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
for i in range(len(lines) - 1):
    a, b = lines[i], lines[i + 1]
    if a.startswith("-") and not a.startswith("---") and b.startswith("+") and not b.startswith("+++"):
        x, y = a[1:], b[1:]
        if ident.match(x) and ident.match(y) and x != y:
            votes[(x, y)] += 1
pairs = {}
for (x, y), n in votes.most_common():
    pairs.setdefault(x, y)
tree = set(re.findall(r"[A-Za-z_][A-Za-z0-9_]*", git("grep", "-h", "-o", "-w", "-E", "[A-Za-z_][A-Za-z0-9_]*", "HEAD", "--", "src", "include", check=False)))
pairs = {x: y for x, y in pairs.items() if x not in tree and y in tree}
print(f"{len(pairs)} rename pairs")

subprocess.run(["git", "merge", "--no-edit", "public/main"], capture_output=True, text=True)
conflicted = git("diff", "--name-only", "--diff-filter=U").split()
for f in conflicted:
    git("checkout", "--theirs", "--", f)
pat = re.compile(r"\b(" + "|".join(map(re.escape, sorted(pairs, key=len, reverse=True))) + r")\b") if pairs else None
changed = 0
if pat:
    files = git("grep", "-l", "-w", "-E", "|".join(map(re.escape, pairs)), "--", "src", "include", "config", "docs", "tools", check=False).split()
    for f in set(files) | set(conflicted):
        try:
            s = open(f, encoding="utf-8").read()
        except (UnicodeDecodeError, FileNotFoundError):
            continue
        t = pat.sub(lambda m: pairs[m.group(1)], s)
        if t != s:
            open(f, "w", encoding="utf-8").write(t)
            changed += 1
for f in conflicted:
    git("add", "--", f, check=False)
print(f"conflicted {len(conflicted)}: {' '.join(conflicted)}; rewrote {changed} files")
