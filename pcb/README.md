# PCB — board status

KiCad project: `pcb/GaugeX/GaugeX.kicad_pro`
Board: `pcb/GaugeX/GaugeX.kicad_pcb`
DRC/ERC data: `pcb/GaugeX/DRC_report.json`, `pcb/GaugeX/ERC_report.json`
Preview: `pcb/GaugeX/GaugeX_board_routed.png`

| Document | Contents |
|---|---|
| `pcb/DESIGN.md` | electrical design: power, buck, MCU pins, interfaces |
| `pcb/BOM.md` | parts list (generated from the schematic fields) |
| `pcb/OPEN-ITEMS.md` | open `[VERIFY]` / Rev-B / fab items |
| `pcb/sim/README.md` | buck/front-end model, its results and limits |
| `docs/datasheets/INDEX.md` | datasheet index with page citations |

## Project files

| Path | Contents |
|---|---|
| `GaugeX/` | KiCad project, schematic, board, local footprint library, previews |
| `GaugeX.pretty/` | project footprints (`GaugeX_SolderPad_1x04_P2.54mm`) |
| `sim/` | Python model of the buck and front end |

## Mechanical

| Item | Value |
|---|---|
| Outline | **50 × 40 mm**, r2.5 corners, 1.6 mm thick |
| Mounting holes | 4 × **Ø2.7 mm** (M2.5), Ø5.0 pad, pattern **44 × 34 mm** |
| Hole positions | (3,3), (47,3), (3,37), (47,37) |
| Footprints | **71** (67 parts + 4 mounting holes) |
| Power entry | **J1 = 4 SMD solder pads**, **1.6 × 2.6 mm**, 2.54 mm pitch, top edge |
| Protrusion below the board | **0 mm** — no THT component pads; only the 4 × Ø2.7 NPTH holes |

**Height rule:** front face (toward the displays) **≤ 5.0 mm**; back face
(toward the back plate) **≤ 3.0 mm** (3.4 mm cavity gap). Measured part heights
and verdicts are in `pcb/DESIGN.md` §7.

## Stackup

| Layer | Contents |
|---|---|
| F.Cu | signal + GND pour (all 67 parts) |
| In1.Cu | **solid GND plane**, no tracks |
| In2.Cu | **+3V3 pour** (priority 1) + GND fill |
| B.Cu | signal + GND pour |

All routing is on F.Cu/B.Cu. In1 is one continuous polygon; no slot, no split.
No SPI/CAN trace crosses a plane gap — the worst case is a trace edge grazing a
neighbouring via's antipad (0.12 mm of centreline inside a ~1 mm hole).

## Routing

| Item | Value |
|---|---|
| Tracks | **611** (F.Cu 381 / B.Cu 230) |
| Vias | **168** — 155 × 0.5/0.2, 11 × 0.6/0.3, 2 × 0.46/0.2 |
| Track widths | 0.20 mm signal, 0.60 mm power |
| Zones | F.Cu GND, B.Cu GND, In1 GND, In2 GND, In2 +3V3 — all filled |
| GND vias | 70 (22 per-pad fanout, 9 in U1 EP, 6 in U2 EP, 27 perimeter ring, island/plane ties, 1 at J1) |
| Signal tracks on In1/In2 | **0** |

## Design rules and fab tier

| Rule | Value |
|---|---|
| `Default` clearance / track / via | 0.12 mm / 0.20 mm / 0.5-0.2 |
| `Power` clearance / track / via | 0.15 mm / 0.60 mm / 0.6-0.3 |
| Min track width | 0.15 mm |
| Min via diameter / annular | 0.46 mm / 0.13 mm |
| Copper to edge | 0.30 mm |
| Hole clearance / hole-to-hole | 0.25 mm |

**JLCPCB standard 4-layer, no advanced option, no small-via surcharge.** The
0.2 mm hole is charged only below 0.45 mm diameter; 0.5 and 0.6 are free, and
the two 0.46 vias are 0.01 mm above the cutoff. Annular 0.15 mm (0.5/0.6 vias)
and 0.13 mm (0.46 vias) are at or above the 0.13 mm minimum.

## DRC

**0 errors, 0 unconnected, 4 warnings.** All four are
`lib_footprint_mismatch` on instances edited on purpose:

| Footprint | Deliberate difference |
|---|---|
| `C2`, `C5` | courtyard removed (pads sit flush with U2) |
| `U1` | 16 EP land pads given the GND net + F.Cu/F.Mask |
| `U2` | six 0.2 mm PTH pad-holes replaced by 0.5/0.2 vias |

ERC: **0 violations** (netlist table and result in `pcb/DESIGN.md` §5.3).

## Changes from the original layout

| Ref | Change | Reason |
|---|---|---|
| J1 | 1×04 THT header → 4 SMD pads, 1.6 × 2.6 mm | 8.65 mm above / 3.11 mm of pin below removed |
| D3 | (35.5, 7.5) → (29.0, 6.8) | ESD diode at the connector |
| C2 | (13.5, 11.0) → (6.05, 13.76) | input decoupling at U2 pins 1/2, planar |
| C5 | (22.0, 12.0) → (13.95, 13.90) | bootstrap loop at U2 pins 7/8 |
| U2 | thermal pads → 6 × 0.5/0.2 vias, tented | fab-friendly, no 0.2 mm PTH pads |

Deviations that stay (netclass clearance 0.12 mm, two 0.46 vias, removed C2/C5
courtyards) are listed with their justification in `pcb/OPEN-ITEMS.md`.

## Status

- Schematic: ERC clean, netlist verified.
- Board: routed, planes filled, DRC clean.
- Not done: Gerber/drill export, fab DFM sign-off. See `pcb/OPEN-ITEMS.md`.
