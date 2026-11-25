# GaugeX

A compact three-gauge automotive pod for **three GC9A01 1.28" round SPI
displays**, driven by an STM32.

The current design is **v2**: three tubes fused side by side on a low wedge
with a flat base. See [`3d-model/v2/README.md`](3d-model/v2/README.md).

## Current design (v2)

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
3d-model/v2/stl/body.stl
3d-model/v2/stl/back_plate.stl
```

Build:

```bash
cd 3d-model/v2
./export_final.sh
```

The script exports both STLs, checks that they are watertight/manifold, fails
if the envelope exceeds **130 × 50 × 45 mm**, and renders front, rear and
exploded PNGs.

## Folder overview

| Path | Contents |
|---|---|
| `3d-model/v2/` | **current** compact pod (source, STL, renders, README) |
| `3d-model/src/` | legacy v1 core/shell design |
| `3d-model/stl/`, `3d-model/renders/` | legacy v1 exports |
| `pcb/` | KiCad project (placeholder) |
| `firmware/` | STM32 firmware (placeholder) |
| `docs/` | notes and datasheets (placeholder) |
