# GaugeX — compact 3-gauge pod

A small i30N-style three-tube gauge pod. This is the only current design.

## Files

| File | Purpose |
|---|---|
| `src/params.scad` | every dimension and tolerance |
| `src/body.scad` | three fused tubes + wedge + flat base |
| `src/back_plate.scad` | removable back plate |
| `src/dummies.scad` | display / PCB fit-check models (not printed) |
| `src/gaugex.scad` | main model, assembly, dispatch |
| `src/check_mesh.py` | manifold / volume / bbox checker |
| `src/check_size.py` | hard envelope check (fails above 130 / 50 / 45) |
| `src/export_step1.sh` | Step 1 export + renders |
| `src/export_step2.sh` | Step 2 export + renders |
| `src/export_final.sh` | final STL + render export |

Printable parts:

```text
stl/body.stl          tubes + wedge + base
stl/back_plate.stl    removable cover
```

## Hard envelope

| | Measured | Limit | Margin |
|---|---:|---:|---:|
| Width | **129.80 mm** | 130.0 | 0.20 mm |
| Height | **49.63 mm** (body) / **49.73 mm** (assembly) | 50.0 | 0.27 mm |
| Depth | **39.95 mm** (body) / **43.36 mm** (assembly) | 45.0 | 1.64 mm |

`export_final.sh` fails if any part or the assembled enclosure exceeds the
limits.

## Parameters (defaults)

### Displays / tubes

| Parameter | Default |
|---|---:|
| `DISPLAY_PCB_D` | 40.0 **VERIFY** |
| `DISPLAY_ACTIVE_D` | 32.4 **VERIFY** |
| `DISPLAY_GLASS_D` | 35.5 **VERIFY** |
| `DISPLAY_TH` | 5.0 **VERIFY** |
| `TUBE_CLEARANCE` | 0.6 |
| `TUBE_WALL` | 1.8 |
| `TUBE_OVERLAP` | 2.0 |
| `TUBE_PITCH` | 42.2 (derived) |
| `TUBE_SPAN` | 128.6 (derived) |
| `TUBE_DEPTH` | 14.0 |
| `FRONT_OPENING_D` | 37.5 |
| `FRONT_LIP_W` | 1.2 |
| `CLIP_COUNT` | 3 |
| `CABLE_NOTCH_W × H` | 8 × 6 |
| `HOOD_DEPTH` | 5.0 (full ring) |
| `TILT_ANGLE` | 15° |
| `SIDE_TOE_IN` | 0° |

Shared wall between tubes:

```text
2 × 1.8 − 2.0 = 1.6 mm
```

### Wedge / base

| Parameter | Default |
|---|---:|
| `WEDGE_WIDTH` | 129.8 |
| `WEDGE_FRONT_Z` | −13.4 |
| `WEDGE_BACK_Z` | −25.5 |
| `WEDGE_FRONT_H` | 49.0 |
| `WEDGE_REAR_H` | 44.8 |
| `CAVITY_W × H` | 116 × 41.6 (full width) |
| `BASE_W × L × TH` | 128 × 28 × 2.4 |

### PCB

| Parameter | Default |
|---|---:|
| `PCB_W × H × TH` | 50 × 40 × 1.6 |
| `PCB_HOLE_X / Y` | 44 / 34 |
| `STANDOFF_H` | 5.0 |
| `M2P5_INSERT_D / depth` | 4.2 / 4.0 **VERIFY** |

### Back plate

| Parameter | Default |
|---|---:|
| `BACK_PLATE_W × H × TH` | 120 × 43.5 × 3.0 |
| `BACK_SCREW_DX / DY` | 38 / 14 |
| `M3_INSERT_D / depth` | 4.6 / 5.5 **VERIFY** |
| `BUTTON_D / spacing` | 12 / 20 |
| `BUTTON_Y` | −10 |
| `CABLE_SLOT_W × H` | 20 × 8 (top) |

## Cable path

```text
display → 8×6 notch at the bottom-rear of each tube
        → full-width internal cavity
        → 20×8 slot in the back plate (top centre)
```

The cavity spans the full width so the side-tube cables are not blocked by the
wedge.

## Print settings

| | Recommendation |
|---|---|
| Material | **ASA** (automotive), PETG acceptable, PLA prototype only |
| Nozzle / layer | 0.4 mm / 0.20 mm |
| Perimeters | 3 |
| Infill | 20–25 % gyroid |
| Supports | **none** |
| Adhesion | brim |

### Orientation

- **body** — rear openings **up**, resting on the three front hood/lip rims.
  The flat base becomes a vertical fin. Tube pockets, cavity and clips need no
  supports.
- **back plate** — outer face **down**, locating lip up.

## Assembly

1. Press 4 × M2.5 heat-set inserts into the PCB standoffs (from the rear).
2. Press 4 × M3 heat-set inserts into the four rear pillars.
3. Insert each GC9A01 from the **rear** of its tube. The Ø40 PCB pushes past
   the three flexible clips and seats behind the front lip. Glass faces out.
4. Route each display cable through its bottom-rear notch into the cavity.
5. Screw the 50 × 40 PCB to the standoffs (screws from the rear).
6. Fit the back plate locating lip into the cavity and drive 4 × M3 screws.
7. Fit the two 12 mm push-buttons and pass the harness through the 20 × 8 slot.
8. Mount with double-sided adhesive or screws through the flat base.

## Caliper checklist

1. Display PCB Ø40, glass Ø35.5, active Ø32.4, thickness 5.
2. Whether the glass sits proud of the PCB.
3. FPC/connector clearance through the rear opening and notch.
4. PCB outline and 44 × 34 hole pattern.
5. M2.5 / M3 insert diameters and depths.
6. Push-button body diameter behind the Ø12 holes.
7. Desired tilt and toe-in for the car.

## Rebuild

```bash
cd 3d-model/src
./export_final.sh
```

The width is intentionally close to the 130 mm limit. If a real display module
is larger than Ø40, increase `TUBE_OVERLAP` or reduce `TUBE_WALL` (minimum
1.6) and re-run `check_size.py`.
