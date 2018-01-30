#!/usr/bin/env python

import itertools

with open("ladder1") as f:
    ldr = [l.rstrip() for l in f.readlines() if not l.isspace()]
print ldr

indent = None
roots = []
at_depth = {}
down_branches = {}
up_branch = {}

for l in ldr:
    pfx = "".join(itertools.takewhile(str.isspace, l))
    if pfx and not indent:
        indent = pfx
    depth = len(pfx) / len(indent) if pfx else 0
    print depth
    b = l.strip()
    at_depth[depth] = b
    if depth:
        p = at_depth[depth - 1]
        up_branch[b] = p
        if p in down_branches:
            down_branches[p] += [b]
        else:
            down_branches[p] = [b]
    else:
        roots += [b]


def push(b, onto = None):
    global roots
    if not onto:
        roots += [b]
    elif onto in down_branches:
        down_branches[onto] += [b]
    else:
        down_branches[p] = [b]


def render_ladder():
    def render_dfs(u, d):
        print d * indent + u
        for v in down_branches.get(u) or []:
            render_dfs(v, d + 1)
    for r in roots:
        render_dfs(r, 0)


push("foo", "bugfix/fee-margin-20p")
push("bar", "master")
push("qux")
render_ladder()
