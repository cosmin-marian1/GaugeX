# PCB

KiCad project and board documentation.

| File | Contents |
|---|---|
| `GaugeX_PCB_spec.md` | requirements and decisions |
| `DESIGN.md` | block diagram, pin table, power budget, mechanical/height checks |
| `BOM.md` | draft BOM, prices, alternatives |
| `SCHEMATIC.md` | schematic status, ERC result, net checks, known follow-ups |
| `LAYOUT.md` | board outline, placement, DRC status |
| `GaugeX/` | KiCad 10 project, schematic PDF/PNG, netlist, board preview |
| `../docs/datasheets/INDEX.md` | datasheet index and verified extracts |

Board: **50 × 40 × 1.6 mm**, 4 layers, 4 × M2.5 on a **44 × 34 mm** pattern.
Mounts behind the centre tube of the compact pod (`../3d-model/src`). Back-side
component height limit is **3.0 mm**; front side **5.0 mm**.

Power/CAN leave the board through **4 solder pads + pigtail** at the top edge;
the Micro-Fit connector is on the cable end, outside the enclosure.

## Current status

- Schematic: **ERC PASS, 0 violations** (KiCad 10.0.8).
- Netlist verified for CAN, SPI, power, crystal and reset nets.
- Schematic layout is a first-pass auto-placement (label-based); visual
  cleanup/hierarchical split is pending.
- PCB: **50 × 40 mm, 4 layers**, 4 × M2.5 holes on 44 × 34 mm.
- Placement: **71 footprints**, DRC **0 errors**, 12 silkscreen warnings,
  147 unconnected (expected before routing).
- **No routing yet.**
