# GaugeX PCB — routing report

Board: `pcb/GaugeX/GaugeX.kicad_pcb`
Project: `pcb/GaugeX/GaugeX.kicad_pro`
Machine-readable DRC: `pcb/GaugeX/DRC_report.json`
Layout description: `pcb/LAYOUT.md`

## Final result

| Check | Result |
|---|---|
| DRC errors | **0** |
| DRC warnings | **1** (cosmetic, see below) |
| Unconnected items | **0** |
| Tracks | 617 (F.Cu 381 / B.Cu 236) |
| Signal tracks on In1/In2 | **0** |
| Vias | 163 |
| Zones | In1 GND, In2 +3V3 + GND, B.Cu GND, F.Cu GND — all filled |

The single warning is `lib_footprint_mismatch` on U1: the 16 mask-only land
pads inside the exposed pad were given the GND net and F.Cu/F.Mask layers so
they can host the thermal vias. The library copy still has them net-less.
It has no effect on fabrication.

## Vias by size

| Size (pad / drill) | Count | Use |
|---|---|---|
| 0.50 / 0.20 mm | 147 | signal + GND stitching |
| 0.60 / 0.30 mm | 14 | power nets |
| 0.46 / 0.20 mm | 2 | C10.2 GND and one pour-island tie (0.5 mm does not fit) |

Annular ring is 0.15 mm for 0.5/0.6 vias and 0.13 mm for the 0.46 vias, i.e.
at or above the JLCPCB 4-layer minimum (0.13 mm).

## Staged routing history

Routing was done in the agreed order, with a DRC run after every stage. Note
that the staged result (stages 1–4) was later superseded by the QFN fanout
re-route described below — the table documents the process, not the final file.

| Stage | Nets | Copper | DRC after stage |
|---|---|---|---|
| 1 — power | +12V_IN, VIN, VIN_F, +3V3, +3V3A, SW, BST | 152 tracks/vias, 0.6 mm, 15 power vias | 0 violations, 0 power unconnected |
| 2 — CAN | CANH/CANL + _J, CAN_TX/RX/SILENT | 217 items | 0 violations, 0 CAN unconnected |
| 3 — SPI ×3 | DISP{1,2,3}_{SCK,MOSI,CS,DC}, DISP_RST | 334 items | 0 violations, 0 SPI unconnected |
| 4 — rest | BL*, BTN*, FB, HSE, LED, NRST, PGOOD, RON, SWD, USART, UVLO, VSENSE | 553 items | 0 violations, 46 unconnected (GND only) |
| Planes + GND | GND vias + 5 zones | — | islands left 7 F.Cu pockets unconnected |

Stages 1–4 were clean, but the GND work exposed a structural problem: U1 is a
0.5 mm-pitch QFN-48 and the autorouter had boxed in 5 pads (NRST, BL_PWM,
VSENSE, USART1_TX/RX) with no legal escape corridor. Adding GND vias also
became impossible wherever B.Cu tracks ran under a GND pad.

Decision: **rip up and re-route with a via fanout around U1.** This is the
standard way to escape a 0.5 mm QFN on 2 signal layers.

## Final routing procedure

1. Strip all tracks, vias and zones; keep the approved placement.
2. **Fanout U1**: 27 stubs (0.2 mm, 0.7–2.1 mm long) + 0.5/0.2 vias, staggered
   at 1.3 mm and 2.1 mm from the pad row so adjacent vias keep 1.0 mm pitch.
   Pads in the `+3V3`/`+3V3A` classes are left to the pour (0.2 mm clearance).
3. FreeRouting 2.6 on F.Cu + B.Cu only (DSN exported from a temporary 2-layer
   copy so the engine cannot use In1/In2).
4. Manual cleanup: two networks needed a second pass (`NRST`, `+3V3`/`BL_PWM`);
   the last three connections were closed with targeted edits.
5. GND: per-pad via fanout (22 pads), 9 thermal vias in U1's exposed pad
   (3×3, 1.6 mm pitch), a 27-via perimeter ring, and one stitching via in every
   F.Cu pour island that contained a pad.
6. Fill and DRC until 0 errors / 0 unconnected.

## Rules actually used

| Rule | Value |
|---|---|
| `Default` clearance / track / via | 0.12 mm / 0.20 mm / 0.5-0.2 |
| `Power` clearance / track / via | 0.15 mm / 0.60 mm / 0.6-0.3 |
| min track width | 0.15 mm |
| min via diameter / annular | 0.46 mm / 0.13 mm |
| min clearance (board) | 0.12 mm |
| copper to edge | 0.30 mm |
| hole clearance / hole-to-hole | 0.25 mm |

## Deviations from the original plan

| Item | Planned | Actual | Why |
|---|---|---|---|
| Netclass clearance | 0.15 mm | **0.12 mm** | only way a via fits a 0.5 mm QFN pad; fab allows 0.09 |
| Via sizes | 0.5/0.2, 0.6/0.3 | + **2 × 0.46/0.2** | 0.5 mm via does not fit at C10.2 / one island; 0.46 keeps 0.13 mm annular |
| C5 (BOOT cap) | near U2 | 10 mm away | placement was frozen; loop is longer than ideal — move in Rev B |
| CAN pair | routed as a pair | split at L1 | L1 (CMC) is DNP, R17/R18 bypasses sit at opposite edges |

## Open items before release

- Gerber / drill / BOM / pick-and-place export.
- JLCPCB DFM profile on the final gerbers.
- Rev B: move C5 next to U2 pins 7/8; move R17/R18 next to L1.
