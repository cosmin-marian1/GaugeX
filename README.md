# GaugeX

A compact three-gauge automotive pod for **three GC9A01 1.28" round SPI
displays**, driven by an STM32.

Three tubes are fused side by side on a low wedge with a flat base. See
[`3d-model/README.md`](3d-model/README.md) for the full parameter list and
assembly guide.

## Design

| | |
|---|---|
| Overall size | **129.8 × 49.7 × 43.4 mm** |
| Tubes | 3 × Ø44.2 mm, 14 mm deep, fused |
| Displays | GC9A01, PCB Ø40, active Ø32.4 |
| Tilt | 15° toward the driver |
| Base | flat, 128 × 28 mm |
| PCB | 50 × 40 mm, behind the centre tube |
| Back plate | 120 × 43.5 × 3 mm, 4 × M3 |
| Buttons | 2 × Ø12, 20 mm apart |
| Cable exit | 20 × 8 mm slot in the back plate |

Printable parts:

```text
3d-model/stl/body.stl
3d-model/stl/back_plate.stl
```

Build:

```bash
cd 3d-model/src
./export_final.sh
```

The script exports both STLs, checks that they are watertight/manifold, fails
if the envelope exceeds **130 × 50 × 45 mm**, and renders front, rear and
exploded PNGs.

## Folder overview

| Path | Contents |
|---|---|
| `3d-model/src/` | parametric OpenSCAD source, checkers, export scripts |
| `3d-model/stl/` | printable STLs |
| `3d-model/renders/` | preview PNGs |
| `pcb/` | KiCad project (placeholder) |
| `firmware/` | STM32 firmware (placeholder) |
| `docs/` | notes and datasheets (placeholder) |
