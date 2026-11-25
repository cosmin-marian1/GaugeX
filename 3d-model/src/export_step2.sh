#!/usr/bin/env bash
# GaugeX - STEP 2 export: back plate + full-enclosure size check
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"
mkdir -p ../stl ../renders

FN_STL=96
FN_PNG=64

echo "== STEP 2: export back plate =="
openscad -o ../stl/back_plate.stl --export-format binstl \
    -D 'PART="back_plate"' -D "FN=$FN_STL" gaugex.scad

echo "== manifold =="
python3 check_mesh.py ../stl/body.stl ../stl/back_plate.stl

echo "== hard size check (individual + enclosure) =="
python3 check_size.py ../stl/body.stl
python3 check_size.py ../stl/back_plate.stl
openscad -o ../stl/enclosure_check.stl --export-format binstl \
    -D 'PART="enclosure"' -D "FN=$FN_STL" gaugex.scad
python3 check_mesh.py ../stl/enclosure_check.stl
python3 check_size.py ../stl/enclosure_check.stl

echo "== renders =="
openscad -o ../renders/step2_front.png --imgsize=1400,1000 \
    --camera=0,0,600,0,0,0 --viewall --autocenter --projection=ortho \
    --colorscheme=Tomorrow -D 'PART="assembly"' -D "FN=$FN_PNG" gaugex.scad

openscad -o ../renders/step2_rear.png --imgsize=1400,1000 \
    --camera=0.55,0.45,-0.75,0,0,0 --viewall --autocenter \
    --projection=perspective --colorscheme=Tomorrow \
    -D 'PART="assembly"' -D "FN=$FN_PNG" gaugex.scad

openscad -o ../renders/step2_exploded.png --imgsize=1400,1000 \
    --camera=0.8,0.6,0.8,0,0,0 --viewall --autocenter \
    --projection=perspective --colorscheme=Tomorrow \
    -D 'PART="exploded"' -D "FN=$FN_PNG" gaugex.scad

echo "== done =="
ls -l ../stl/back_plate.stl ../stl/enclosure_check.stl ../renders/step2_*.png
