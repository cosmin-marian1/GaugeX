# GaugeX 3D model — legacy v1 (core + shell)

> The current design is the compact pod in [`v2/README.md`](v2/README.md).
> This document describes the earlier two-part core/shell version, kept for
> reference.

# GaugeX 3D model — modular (core + shell)

Two-part design:

| Module | File | Changes per car? |
|---|---|---|
| **Core** — electronics tray + back cover | `src/core.scad` | **Never** |
| **Shell** — display pods, hoods, base | `src/shell.scad` | Yes, via presets |
| Presets — per-car shell overrides | `src/presets.scad` | — |
| Main model / dispatch | `src/gaugex.scad` | — |

The core is a self-contained module: 50 × 40 mm PCB tray, four M2.5
heat-set standoffs, removable back cover (2 × 12 mm buttons, cable slot,
vents, 4 × M3 screws) and a fixed 80 mm display-wire channel. It contains
**no car-specific parameter**. The shell mounts on the core through a fixed
interface: four M3 screws on a ±42 / ±28 mm pattern, the tray centred behind
the middle gauge, and one standard display-wire opening.

```
cd src
./export.sh              # default shell preset: generic
./export.sh e90          # export the E90 shell + render it
```

`export.sh` exports the core once, the shell for the chosen preset, all four
shell variants, verifies that the core STLs are geometrically identical for
`generic` and `e90`, checks every mesh and renders three PNGs.

> All dimensions are millimetres. Shell dimensions are arguments of
> `shell(...)`; change them in `presets.scad`, not in the core.

---

## 1. Fixed interface (shared constants)

Defined in `core.scad`, read by `shell.scad`:

| Constant | Value | Meaning |
|---|---|---|
| `CORE_W × CORE_H` | 100 × 76 mm | tray outer size |
| `CORE_DEPTH` | 26 mm | tray depth |
| `CORE_FRONT_Z` | −26 mm | tray front face = shell rear plane |
| `CORE_IFACE_X/Y` | ±42 / ±28 mm | 4-screw pattern |
| `WIRE_OPENING_W × H` | 74 × 9 mm | standard display-wire opening |
| `display_wire_len` | 80 mm | display cable channel |
| `WIRE_OPENING_Y` | 29 mm | opening / channel height |

The back cover screws pass through the core's four through-bosses and thread
into M3 heat-set inserts in the shell. One set of 4 × M3 × 35 mm screws clamps
cover + core + shell.

## 2. Core parameters (fixed)

| Parameter | Default | Meaning |
|---|---|---|
| `pcb_w × pcb_h × pcb_th` | 50 × 40 × 1.6 | main board |
| `pcb_hole_spacing_x/y` | 44 / 34 | 4-hole pattern (full pitch) |
| `standoff_h` | 7 | standoff height |
| `m2p5_insert_d` / depth | 4.2 / 4.0 | M2.5 heat-set insert — **VERIFY** |
| `m3_insert_d` / depth | 4.6 / 5.5 | M3 insert (in the shell) — **VERIFY** |
| `m3_clear_d` | 3.4 | M3 clearance through core |
| `button_dia` / spacing | 12 / 20 | panel push-buttons |
| `cable_slot_w × h` | 20 × 8 | harness exit, top |
| `vent_count/len/w` | 5 / 18 / 2.5 | ventilation slots |
| `back_cover_th` | 2.4 | cover plate |

## 3. Shell parameters (per car)

Defaults live in `shell.scad`; each preset overrides only these.

### Displays / pods
| Parameter | Default | Meaning |
|---|---|---|
| `display_pcb_dia` | 40 | module PCB — **VERIFY** |
| `display_active` | 32.4 | active area — **VERIFY** |
| `display_bezel` | 35.5 | glass OD — **VERIFY** |
| `display_thick` | 5.0 | module thickness — **VERIFY** |
| `window_margin` | 0.5 | per side |
| `face_t` | 1.5 | front window ring thickness |
| `shell_wall` | 2.5 | pod wall |
| `shoulder_th` | 2.5 | rear retaining shoulder |
| `ret_ribs` | 4 | retention ribs per pod |
| `tol_clear` | 0.3 | pocket clearance |

### Arc / orientation
| Parameter | Default | Meaning |
|---|---|---|
| `arc_radius` | 320 | horizontal arc radius (mm) |
| `display_spacing` | 50 | arc-length spacing between gauges |
| `toe_in` | 0 | extra inward yaw of the outer gauges (°) |
| `tilt` | 6 | common vertical tilt (°, positive = faces down) |
| `hood_depth` | 6 | sun-hood height |
| `hood_wall` | 1.8 | hood wall |
| `hood_flare` | 1.4 | hood outward flare |

### Base
| Parameter | Default | Meaning |
|---|---|---|
| `base_type` | `"flat"` | `flat` / `curved` / `clip` / `bracket` |
| `base_width` | 110 | flange width |
| `base_length` | 36 | flange length below the shell |
| `base_th` | 3 | flange thickness |
| `base_curve_radius` | 400 | dash crown radius (curved) |

- **flat** — plain mounting flange.
- **curved** — rear face trimmed to a concave cylinder of `base_curve_radius`
  so it sits on a crowned dash.
- **clip** — two U-slots form flexible tongues for a snap-in dash lip.
- **bracket** — flange with two Ø4.5 mm holes and a stiffening rib.

### Derived
| | generic | e90 |
|---|---|---|
| window Ø | 33.4 | 33.4 |
| pocket Ø × depth | 40.6 × 6.8 | 40.6 × 6.8 |
| pod depth | 9.3 | 9.3 |
| pod Ø | 45.6 | 45.6 |
| shell plate | 108 × 84 × 8 | 108 × 84 × 8 |
| overall shell (W×H×D) | ~147.5 × 118 × 33 | ~152 × 128 × 40 |
| total cluster depth | ~60 | ~66 |

## 4. Presets

`src/presets.scad`:

| Preset | Arc R | Spacing | Toe-in | Tilt | Hood | Base |
|---|---|---|---|---|---|---|
| `generic` | 320 | 50 | 0° | 6° | 5 | flat |
| `e90` | 260 | 52 | 4° | 11° | 8 | curved (R300) |
| `clip` | 300 | 50 | 2° | 8° | 6 | clip |
| `bracket` | 340 | 50 | 0° | 5° | 5 | bracket |

Add a new car by copying one module in `presets.scad`, changing only shell
arguments, and adding it to `shell_preset()`.

## 5. Print settings

| | Recommendation |
|---|---|
| Material | **ASA** (automotive UV/heat), PETG acceptable, PLA prototype only |
| Nozzle / layer | 0.4 mm / 0.20 mm |
| Perimeters | 3 |
| Infill | core/shell 20–25 % gyroid; bracket base 40 % |
| Supports | **none** |
| Adhesion | brim for shell (large footprint) |

### Orientation
- **shell** — rear interface plate **down** (flat on the bed). Pods, hoods and
  the base flange stand up; no supports.
- **core_tray** — front wall **down**, open back up.
- **core_cover** — outer face **down**, buttons/vents up.

## 6. Assembly order

1. Press 4 × M2.5 inserts into the core standoffs (from the open back).
2. Press 4 × M3 inserts into the shell's rear bosses (from the rear).
3. Screw the 50 × 40 PCB to the standoffs.
4. Fit the 3 displays into the shell pods from the front; they rest on the
   rear shoulder and are backed by the printed ribs.
5. Route the three display cables through the pod collar slots and the
   standard 74 × 9 opening into the core's top wire channel.
6. Mate the core onto the shell rear plate (tray centred behind the middle
   gauge), fit the cover lip, and drive 4 × M3 × 35 screws from the cover
   through the core into the shell inserts.
7. Install the 2 × 12 mm push-buttons; pass the harness through the 20 × 8
   slot and secure it with a zip tie at the anchor.
8. Mount the shell with the selected base profile.

## 7. What to verify with calipers

1. Display module: PCB Ø40, glass Ø35.5, active Ø32.4, thickness 5.
2. Whether the glass sits proud of the PCB (adjust `display_thick`).
3. Rear FPC/connector clearance through the Ø35 rear opening.
4. PCB outline and the 44 × 34 hole pattern.
5. M2.5 and M3 insert diameters/depths.
6. Push-button body diameter behind the Ø12 holes.
7. Dash crown radius for the `curved` base (`base_curve_radius`).
8. Desired arc radius / spacing / tilt / toe-in for the car.

## 8. Debug renders

```bash
openscad -o a.png -D 'PART="assembly"' -D 'PRESET="e90"' gaugex.scad
openscad -o f.png -D 'PART="fitcheck"' -D 'PRESET="e90"' gaugex.scad
openscad -o s.png -D 'PART="section"'  -D 'PRESET="e90"' gaugex.scad
openscad -o x.png -D 'PART="exploded"' -D 'PRESET="e90"' gaugex.scad
openscad -o t.png -D 'PART="stats"'    gaugex.scad
```
