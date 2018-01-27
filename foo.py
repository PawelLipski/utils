#!/usr/bin/env python

ladder_file = "ladder"


def split_array(arr, sep):
    res = []
    start_new = True
    for elem in arr:
        if elem == sep:
            start_new = True
        else:
            if start_new:
                res.append([])
                start_new = False
            res[-1].append(elem)
    return res


def replace_in_array(arr, orig, dest):
    for i in range(len(arr)):
        if arr[i] == orig:
            arr[i] = dest


def read_ladder():
    with open(ladder_file, "r") as f:
        return map(lambda l: l.strip(), f.readlines())


trails = split_array(read_ladder(), '')
trail_tops = map(lambda x: x[0], trails)
prev = {}
for t in trails:
    prev.update(dict(zip(t[:-1], t[1:])))

nexts = {}
for b, p in prev.items():
    if p in nexts:
        nexts[p].append(b)
    else:
        nexts[p] = [b]
print nexts


def push(name, onto=None):
    if not onto: onto = trail_tops[0]
    if onto in trail_tops:
        replace_in_array(trail_tops, onto, name)
    else:
        trail_tops.append(name)
    prev[name] = onto


def print_ladder():
    printed = set()
    for tt in trail_tops:
        while True:
            print tt
            if tt in printed: break
            printed.add(tt)
            p = prev.get(tt)
            if not p: break
            tt = p
        print


push("foo")
push("bar", onto="feature/pip-467-cancel-withdrawal")
push("qux", onto="bugfix/fee-margin-20p")
print_ladder()
