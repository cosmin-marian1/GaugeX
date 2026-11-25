#!/usr/bin/env python3
"""Dependency-free STL checker for GaugeX.

Usage: check_mesh.py [--volume] file.stl [...]

Verifies:
  * file parses (binary or ASCII STL)
  * mesh is closed / edge-manifold (every undirected edge shared by exactly
    two triangles)
  * signed volume (for collision tests: pass --volume and use a threshold)

Exit code is non-zero if any mesh fails the manifold test.
"""
import struct
import sys


def read_stl(path):
    with open(path, "rb") as f:
        head = f.read(5)
        f.seek(0)
        if head[:5] == b"solid" and b"facet" in f.read(4096):
            f.seek(0)
            return _read_ascii(f)
        return _read_binary(f)


def _read_binary(f):
    f.read(80)
    (n,) = struct.unpack("<I", f.read(4))
    tris = []
    for _ in range(n):
        data = struct.unpack("<12fH", f.read(50))
        v = [(data[3], data[4], data[5]),
             (data[6], data[7], data[8]),
             (data[9], data[10], data[11])]
        tris.append(v)
    return tris


def _read_ascii(f):
    tris, cur = [], []
    for raw in f:
        s = raw.decode("ascii", "ignore").strip().split()
        if s[:1] == ["vertex"]:
            cur.append(tuple(float(x) for x in s[1:4]))
            if len(cur) == 3:
                tris.append(cur)
                cur = []
    return tris


def analyse(tris, tol=4):
    edges = {}
    vol = 0.0
    for i, (a, b, c) in enumerate(tris):
        for p, q in ((a, b), (b, c), (c, a)):
            e = (tuple(round(x, tol) for x in p),
                 tuple(round(x, tol) for x in q))
            e = tuple(sorted(e))
            edges.setdefault(e, []).append(i)
        vol += (a[0] * (b[1] * c[2] - b[2] * c[1])
                - a[1] * (b[0] * c[2] - b[2] * c[0])
                + a[2] * (b[0] * c[1] - b[1] * c[0])) / 6.0

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

    for f in edges.values():
        for j in f[1:]:
            union(f[0], j)

    shells = len({find(i) for i in range(len(tris))})
    boundary = sum(1 for f in edges.values() if len(f) == 1)
    nonman = sum(1 for f in edges.values() if len(f) > 2)
    return boundary, nonman, shells, abs(vol)


def bbox(tris):
    xs = [p[0] for t in tris for p in t]
    ys = [p[1] for t in tris for p in t]
    zs = [p[2] for t in tris for p in t]
    return (min(xs), min(ys), min(zs), max(xs), max(ys), max(zs))


def compare(path_a, path_b, tol=4):
    """Geometric comparison: ignores vertex/triangle ordering and STL headers."""
    a = sorted(tuple(sorted(tuple(round(x, tol) for x in v) for v in t))
               for t in read_stl(path_a))
    b = sorted(tuple(sorted(tuple(round(x, tol) for x in v) for v in t))
               for t in read_stl(path_b))
    return a == b, len(a), len(b)


def main(argv):
    if "--compare" in argv:
        args = [a for a in argv if not a.startswith("--")]
        if len(args) != 2:
            print("usage: check_mesh.py --compare a.stl b.stl")
            return 2
        same, na, nb = compare(args[0], args[1])
        if same:
            print(f"IDENTICAL  {args[0]}  ==  {args[1]}  ({na} tris)")
            return 0
        print(f"DIFFERENT  {args[0]} ({na} tris)  vs  {args[1]} ({nb} tris)")
        return 1

    volume_only = "--volume" in argv
    files = [a for a in argv if not a.startswith("--")]
    if not files:
        print("usage: check_mesh.py [--volume] file.stl [...]")
        return 2
    failed = False
    for path in files:
        try:
            tris = read_stl(path)
        except Exception as exc:  # noqa: BLE001
            print(f"FAIL  {path}: cannot parse ({exc})")
            failed = True
            continue
        if not tris:
            print(f"EMPTY {path}")
            if volume_only:
                print(f"      {path}: volume 0.0 mm^3")
            continue
        boundary, nonman, shells, vol = analyse(tris)
        if volume_only:
            print(f"{vol:.4f}")
            continue
        ok = (boundary == 0 and nonman == 0 and shells == 1)
        status = "OK  " if ok else "FAIL"
        if not ok:
            failed = True
        bb = bbox(tris)
        dims = (bb[3] - bb[0], bb[4] - bb[1], bb[5] - bb[2])
        print(f"{status}  {path}: {len(tris)} tris, shells={shells}, "
              f"boundary_edges={boundary}, nonmanifold_edges={nonman}, "
              f"volume={vol:.2f} mm^3, "
              f"size={dims[0]:.1f}x{dims[1]:.1f}x{dims[2]:.1f} mm")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
