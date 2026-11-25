#!/usr/bin/env python3
"""Dependency-free STL checks for GaugeX."""
import struct
import sys


def read_stl(path):
    with open(path, "rb") as f:
        head = f.read(5)
        f.seek(0)
        if head[:5] == b"solid" and b"facet" in f.read(4096):
            f.seek(0)
            return _ascii(f)
        return _binary(f)


def _ascii(f):
    tris, cur = [], []
    for raw in f:
        s = raw.decode("ascii", "ignore").strip().split()
        if s[:1] == ["vertex"]:
            cur.append(tuple(float(x) for x in s[1:4]))
            if len(cur) == 3:
                tris.append(cur)
                cur = []
    return tris


def _binary(f):
    f.read(80)
    (n,) = struct.unpack("<I", f.read(4))
    tris = []
    for _ in range(n):
        d = struct.unpack("<12fH", f.read(50))
        tris.append([(d[3], d[4], d[5]), (d[6], d[7], d[8]), (d[9], d[10], d[11])])
    return tris


def bbox(tris):
    xs = [p[0] for t in tris for p in t]
    ys = [p[1] for t in tris for p in t]
    zs = [p[2] for t in tris for p in t]
    return min(xs), min(ys), min(zs), max(xs), max(ys), max(zs)


def analyse(tris, tol=4):
    edges = {}
    vol = 0.0
    for i, (a, b, c) in enumerate(tris):
        for p, q in ((a, b), (b, c), (c, a)):
            e = tuple(sorted((tuple(round(x, tol) for x in p),
                              tuple(round(x, tol) for x in q))))
            edges.setdefault(e, []).append(i)
        vol += (a[0]*(b[1]*c[2]-b[2]*c[1])
                - a[1]*(b[0]*c[2]-b[2]*c[0])
                + a[2]*(b[0]*c[1]-b[1]*c[0])) / 6.0
    parent = list(range(len(tris)))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx != ry:
            parent[ry] = rx

    for faces in edges.values():
        for j in faces[1:]:
            union(faces[0], j)
    shells = len({find(i) for i in range(len(tris))})
    boundary = sum(1 for f in edges.values() if len(f) == 1)
    nonman = sum(1 for f in edges.values() if len(f) > 2)
    return boundary, nonman, shells, abs(vol)


def main(argv):
    volume = "--volume" in argv
    files = [a for a in argv if not a.startswith("--")]
    if not files:
        print("usage: check_mesh.py [--volume] file.stl [...]")
        return 2
    failed = False
    for path in files:
        try:
            tris = read_stl(path)
        except Exception as exc:
            print(f"FAIL {path}: {exc}")
            failed = True
            continue
        if not tris:
            print(f"EMPTY {path}")
            failed = True
            continue
        boundary, nonman, shells, vol = analyse(tris)
        if volume:
            print(f"{vol:.4f}")
            continue
        bb = bbox(tris)
        dims = (bb[3]-bb[0], bb[4]-bb[1], bb[5]-bb[2])
        ok = boundary == 0 and nonman == 0 and shells == 1
        print(f"{'OK  ' if ok else 'FAIL'} {path}: {len(tris)} tris, "
              f"shells={shells}, boundary={boundary}, nonmanifold={nonman}, "
              f"volume={vol:.2f} mm^3, size={dims[0]:.2f}x{dims[1]:.2f}x{dims[2]:.2f} mm")
        failed |= not ok
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
