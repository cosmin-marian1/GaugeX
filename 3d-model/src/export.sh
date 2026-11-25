#!/usr/bin/env bash
# ============================================================================
#  GaugeX export script  (two-part modular model)
#
#  1. Exports the fixed CORE parts (identical for every car).
#  2. Exports the SHELL for the selected preset (default: generic) and, for
#     verification, for every preset in presets.scad.
#  3. Proves the core does not change with the preset (sha256 comparison).
#  4. Checks every STL (watertight / manifold / single shell).
#  5. Renders 3 preview PNGs.
#
#  Usage:  ./export.sh [PRESET]
# ============================================================================
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCAD="$HERE/gaugex.scad"
STL_DIR="$HERE/../stl"
REN_DIR="$HERE/../renders"

PRESET="${1:-generic}"
PRESETS=(generic e90 clip bracket)

FN_EXPORT=128
FN_RENDER=96

command -v openscad >/dev/null 2>&1 || { echo "ERROR: openscad not found"; exit 1; }
command -v python3  >/dev/null 2>&1 || { echo "ERROR: python3 not found"; exit 1; }

mkdir -p "$STL_DIR" "$REN_DIR"

echo "==================================================================="
echo " GaugeX - modular export   (shell preset: $PRESET)"
echo "==================================================================="

# ---- core: fixed, exported once -------------------------------------------
for p in core_tray core_cover; do
    echo ">> CORE STL  $p"
    openscad -o "$STL_DIR/$p.stl" --export-format binstl \
        -D "FN=$FN_EXPORT" -D "PART=\"$p\"" "$SCAD"
done

# ---- shell: selected preset ------------------------------------------------
echo ">> SHELL STL  ($PRESET)"
openscad -o "$STL_DIR/shell.stl" --export-format binstl \
    -D "FN=$FN_EXPORT" -D "PART=\"shell\"" -D "PRESET=\"$PRESET\"" "$SCAD"

# ---- shell variants, for preset verification ------------------------------
for pr in "${PRESETS[@]}"; do
    echo ">> SHELL STL  (verify $pr)"
    openscad -o "$STL_DIR/shell_$pr.stl" --export-format binstl \
        -D "FN=$FN_EXPORT" -D "PART=\"shell\"" -D "PRESET=\"$pr\"" "$SCAD"
done

# ---- proof: core is preset-independent ------------------------------------
echo
echo "==================================================================="
echo " Core invariance check (core must be identical for every preset)"
echo "==================================================================="
TMP="$(mktemp -d)"
for p in core_tray core_cover; do
    openscad -o "$TMP/${p}_generic.stl" --export-format binstl \
        -D "FN=$FN_EXPORT" -D "PART=\"$p\"" -D 'PRESET="generic"' "$SCAD" >/dev/null 2>&1
    openscad -o "$TMP/${p}_e90.stl" --export-format binstl \
        -D "FN=$FN_EXPORT" -D "PART=\"$p\"" -D 'PRESET="e90"' "$SCAD" >/dev/null 2>&1
    if cmp -s "$TMP/${p}_generic.stl" "$TMP/${p}_e90.stl" \
       || python3 "$HERE/check_mesh.py" --compare \
              "$TMP/${p}_generic.stl" "$TMP/${p}_e90.stl" >/dev/null; then
        echo "OK    $p: identical for generic and e90"
    else
        echo "FAIL  $p: changes between presets!"
        rm -rf "$TMP"
        exit 1
    fi
done
rm -rf "$TMP"

echo
echo "==================================================================="
echo " Manifold check"
echo "==================================================================="
python3 "$HERE/check_mesh.py" "$STL_DIR"/*.stl

echo
echo "==================================================================="
echo " Rendering previews"
echo "==================================================================="

openscad -o "$REN_DIR/gauge_cluster_front.png" --imgsize=1600,1200 \
    --camera=0,0,600,0,0,0 --projection=ortho \
    --colorscheme=Tomorrow -D "FN=$FN_RENDER" -D 'PART="assembly"' \
    -D "PRESET=\"$PRESET\"" "$SCAD"

openscad -o "$REN_DIR/gauge_cluster_rear.png" --imgsize=1600,1200 \
    --camera=0.55,0.45,-0.75,0,0,0 --viewall --autocenter \
    --projection=perspective --colorscheme=Tomorrow -D "FN=$FN_RENDER" \
    -D 'PART="assembly"' -D "PRESET=\"$PRESET\"" "$SCAD"

openscad -o "$REN_DIR/gauge_cluster_exploded.png" --imgsize=1600,1200 \
    --camera=0.8,0.6,0.8,0,0,0 --viewall --autocenter \
    --projection=perspective --colorscheme=Tomorrow -D "FN=$FN_RENDER" \
    -D 'PART="exploded"' -D "PRESET=\"$PRESET\"" "$SCAD"

echo
echo "==================================================================="
echo " Done."
echo "   Core   -> $STL_DIR/core_tray.stl, core_cover.stl"
echo "   Shell  -> $STL_DIR/shell.stl  (preset: $PRESET)"
echo "   Renders-> $REN_DIR"
echo "==================================================================="
ls -1 "$STL_DIR"/*.stl "$REN_DIR"/*.png
