#!/usr/bin/env bash
# GaugeX v2 - STEP 1 export: tubes + wedge + flat base
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"
mkdir -p stl renders

FN_STL=96
FN_PNG=64

echo "== STEP 1: export body =="
openscad -o stl/body.stl --export-format binstl \
    -D 'PART="body"' -D "FN=$FN_STL" gaugex_v2.scad

echo "== manifold =="
python3 check_mesh.py stl/body.stl

echo "== hard size check =="
python3 check_size.py stl/body.stl

echo "== renders =="
openscad -o renders/step1_front.png --imgsize=1400,1000 \
    --camera=0,0,600,0,0,0 --viewall --autocenter --projection=ortho \
    --colorscheme=Tomorrow -D 'PART="assembly"' -D "FN=$FN_PNG" gaugex_v2.scad

openscad -o renders/step1_rear.png --imgsize=1400,1000 \
    --camera=0.55,0.45,-0.75,0,0,0 --viewall --autocenter \
    --projection=perspective --colorscheme=Tomorrow \
    -D 'PART="assembly"' -D "FN=$FN_PNG" gaugex_v2.scad

openscad -o renders/step1_exploded.png --imgsize=1400,1000 \
    --camera=0.8,0.6,0.8,0,0,0 --viewall --autocenter \
    --projection=perspective --colorscheme=Tomorrow \
    -D 'PART="exploded"' -D "FN=$FN_PNG" gaugex_v2.scad

echo "== done =="
ls -l stl/body.stl renders/step1_*.png
