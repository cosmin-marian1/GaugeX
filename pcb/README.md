# PCB

KiCad project and board documentation.

| File | Contents |
|---|---|
| `GaugeX_PCB_spec.md` | requirements and decisions |
| `DESIGN.md` | block diagram, pin table, power budget, mechanical/height checks |
| `BOM.md` | draft BOM, prices, alternatives |
| `../docs/datasheets/INDEX.md` | datasheet index and verified extracts |

Board: **50 × 40 × 1.6 mm**, 4 layers, 4 × M2.5 on a **44 × 34 mm** pattern.
Mounts behind the centre tube of the compact pod (`../3d-model/src`). Back-side
component height limit is **3.0 mm**; front side **5.0 mm**.

Power/CAN leave the board through **4 solder pads + pigtail** at the top edge;
the Micro-Fit connector is on the cable end, outside the enclosure.

No schematic or layout yet.
