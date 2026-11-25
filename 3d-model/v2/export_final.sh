#!/usr/bin/env bash
# GaugeX v2 - final export and verification
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"
mkdir -p stl renders

FN_STL=128
FN_PNG=72
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "== export printable parts =="
openscad -o stl/body.stl --export-format binstl \
    -D 'PART="body"' -D "FN=$FN_STL" gaugex_v2.scad
openscad -o stl/back_plate.stl --export-format binstl \
    -D 'PART="back_plate"' -D "FN=$FN_STL" gaugex_v2.scad

echo "== manifold =="
python3 check_mesh.py stl/body.stl stl/back_plate.stl

echo "== envelope =="
python3 check_size.py stl/body.stl
python3 check_size.py stl/back_plate.stl
openscad -o "$TMP/enclosure.stl" --export-format binstl \
    -D 'PART="enclosure"' -D "FN=$FN_STL" gaugex_v2.scad
python3 check_size.py "$TMP/enclosure.stl"

echo "== final renders =="
openscad -o renders/final_front.png --imgsize=1600,1200 \
    --camera=0,0,600,0,0,0 --viewall --autocenter --projection=ortho \
    --colorscheme=Tomorrow -D 'PART="assembly"' -D "FN=$FN_PNG" gaugex_v2.scad
openscad -o renders/final_rear.png --imgsize=1600,1200 \
    --camera=0.55,0.45,-0.75,0,0,0 --viewall --autocenter \
    --projection=perspective --colorscheme=Tomorrow \
    -D 'PART="assembly"' -D "FN=$FN_PNG" gaugex_v2.scad
openscad -o renders/final_exploded.png --imgsize=1600,1200 \
    --camera=0.8,0.6,0.8,0,0,0 --viewall --autocenter \
    --projection=perspective --colorscheme=Tomorrow \
    -D 'PART="exploded"' -D "FN=$FN_PNG" gaugex_v2.scad

echo "== done =="
ls -l stl/body.stl stl/back_plate.stl renders/final_*.png
