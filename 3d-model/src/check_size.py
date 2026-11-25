#!/usr/bin/env python3
"""Hard envelope check for GaugeX STLs.

Usage: check_size.py file.stl [--max-w 130] [--max-h 50] [--max-d 45]
"""
import argparse
import sys
from check_mesh import bbox, read_stl


def main(argv=None):
    p = argparse.ArgumentParser()
    p.add_argument("stl")
    p.add_argument("--max-w", type=float, default=130.0)
    p.add_argument("--max-h", type=float, default=50.0)
    p.add_argument("--max-d", type=float, default=45.0)
    a = p.parse_args(argv)
    tris = read_stl(a.stl)
    if not tris:
        print(f"FAIL {a.stl}: empty mesh")
        return 1
    bb = bbox(tris)
    dims = (bb[3]-bb[0], bb[4]-bb[1], bb[5]-bb[2])
    limits = (a.max_w, a.max_h, a.max_d)
    ok = all(d <= lim + 1e-6 for d, lim in zip(dims, limits))
    print(f"{'OK  ' if ok else 'FAIL'} {a.stl}: "
          f"W={dims[0]:.2f} H={dims[1]:.2f} D={dims[2]:.2f} mm "
          f"(limits {limits[0]:.1f}/{limits[1]:.1f}/{limits[2]:.1f})")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
