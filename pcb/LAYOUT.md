# GaugeX PCB — layout status

KiCad project: `pcb/GaugeX/GaugeX.kicad_pro`
Board: `pcb/GaugeX/GaugeX.kicad_pcb`
Previews: `GaugeX_board_routed.png` (F.Cu + B.Cu + silk), `GaugeX_board_all_layers.png`

## Mechanical

| Item | Value |
|---|---|
| Outline | **50 × 40 mm**, r2.5 corners |
| Mounting holes | 4 × **Ø2.7 mm** (M2.5), Ø5.0 pad, pattern **44 × 34 mm** |
| Hole positions | (3,3), (47,3), (3,37), (47,37) |
| Layers | **4 copper**, 1.6 mm |
| Footprints | 71 (67 parts + 4 mounting holes) |
| Power entry | **J1 = 4 SMD solder pads**, 2.0 × 2.6 mm, 2.54 mm pitch, top edge — no drill, nothing below the board |

## Stackup

| Layer | Use |
|---|---|
| F.Cu | signal + GND pour |
| In1.Cu | **solid GND plane** (no signal routing) |
| In2.Cu | **+3V3 pour** (priority 1) + GND fill elsewhere |
| B.Cu | signal + GND pour |

All routing is on F.Cu/B.Cu. In1/In2 carry copper pours only, so the SPI and
CAN traces always run over an uninterrupted reference plane.

## Routing

| Item | Value |
|---|---|
| Tracks | **619** (F.Cu 383 / B.Cu 236) |
| Vias | **166** — 149 × 0.5/0.2, 15 × 0.6/0.3, 2 × 0.46/0.2 |
| Track widths | 0.20 mm signal, 0.60 mm power (`Default` / `Power` netclasses) |
| Zones | In1 GND, In2 +3V3 + GND, B.Cu GND, F.Cu GND — all filled |
| GND vias | 64 (22 per-pad fanout, 9 in U1 exposed pad, 27 perimeter ring, island/plane ties, 1 at J1) |
| Protrusion below board | **0 mm** — no THT component pads (only 4 × Ø2.7 NPTH holes and U2's 6 × Ø0.2 plated thermal vias) |
| DRC | **0 errors, 0 unconnected, 1 warning** |

### Design rules

| Rule | Value | Note |
|---|---|---|
| Track/space (`Default`) | 0.20 / 0.12 mm | JLCPCB 4-layer allows 0.09/0.09 |
| Track/space (`Power`) | 0.60 / 0.15 mm | +12V_IN, VIN, VIN_F, +3V3, +3V3A, SW, BST |
| Via (`Default`) | 0.5 / 0.2 mm | annular 0.15 mm |
| Via (`Power`) | 0.6 / 0.3 mm | annular 0.15 mm |
| Min via diameter (board) | 0.46 mm | see exceptions |
| Min annular (board) | 0.13 mm | = JLCPCB 4-layer minimum |
| Copper to edge | 0.30 mm | |
| Hole clearance / hole-to-hole | 0.25 mm | |

### Remaining DRC warning

`Footprint 'QFN-48-1EP_7x7mm_P0.5mm_EP5.6x5.6mm' does not match copy in library`
— expected: the 16 mask-only land pads inside U1's exposed pad were given the
GND net and F.Cu/F.Mask layers so they can host the thermal vias. The library
copy still has them net-less. Cosmetic only; re-sync the library in a future
edit session.

## What changed vs. the first 4-layer route

The first route (commit `33f5ddd`) put 197 segments on In1/In2 and failed the
JLCPCB 4-layer rules (119 violations at 0.18 mm annular). It was fully ripped
up and re-routed:

1. **Fanout first.** U1 is a 0.5 mm-pitch QFN-48; FreeRouting cannot escape it
   on 2 layers. 27 pad stubs + vias were placed radially around U1
   (alternating 1.3 / 2.1 mm rows), which makes the rest of the board routable.
2. Power routed first (0.6 mm, DRC clean), then CAN, then SPI ×3, then the rest.
3. Inner layers released for planes only.
4. GND connected two ways: a per-pad via fanout (22 pads), plus an F.Cu GND
   pour for the pads whose via site is blocked on B.Cu. Every isolated pour
   island got its own stitching via, so the plane set is fully connected.
5. U1 exposed pad: 9 × 0.5/0.2 thermal vias (3×3, 1.6 mm pitch) plus the
   mask-land pads, per the fab's 4-layer rules.

## Placements touched during routing

| Ref | From → To | Reason |
|---|---|---|
| D3 (PESD2CAN) | (35.5, 7.5) → (29.0, 6.8) | ESD diode at the J1 connector |
| R1 (FB divider) | unchanged | would have blocked the NRST escape |
| C10 | unchanged | HSE load cap; GND via fitted after LED_DRIVE re-route |
| C22 | unchanged | 3V3/BTN1 decoupling, via-in-pad GND |
| **J1** | PinHeader 1×04 P2.54 THT → `GaugeX:GaugeX_SolderPad_1x04_P2.54mm` (4 SMD pads) | removes 8.65 mm above / 3.11 mm of pin below; +12V_IN and CANH_J moved to a via 2 mm below the pads |

## Component heights

All 67 parts are on the **front** face. Heights are STEP-model Z extents
(details and flags in `DESIGN.md` §7):

| Face | Limit | Tallest part |
|---|---|---|
| Front (toward the displays) | 5.0 mm | C8 4.50 mm (DNP); otherwise L2 3.10 mm |
| Back (toward the back plate) | 3.0 mm | nothing — the face is empty |

J1 is now 0.05 mm of copper; the flying lead is the only thing leaving the
board, and it wraps the edge to the back-plate cable slot at `y = +10`.

## Known limitations / Rev B

- **C5 (BOOT cap) sits ~10 mm from U2** (pads 7/8). The SW/BST loop is longer
  than ideal for a 300 kHz buck. Move C5 next to U2 pins 7 and 8 in Rev B.
- **2 × 0.46/0.2 mm GND vias** (C10.2 under the HSE load cap, and one pour-island
  stitch at 33.6/26.6). 0.46 mm is the smallest diameter that keeps JLCPCB's
  0.13 mm annular minimum with a 0.2 mm drill; a 0.5 mm via does not fit there.
- `Default` clearance is 0.12 mm (not 0.15) for the same reason; 0.12 is still
  1.3× the fab minimum and applies to the whole board.
- CAN is not a tight pair end to end: L1 (common-mode choke) is DNP and the
  0 Ω bypasses R17/R18 sit at opposite edges, so the two nets necessarily split
  around the choke. The pair is adjacent from J1 to D3 and from the choke to U3.

## Not done

- Gerber / drill / BOM / pick-and-place export
- DFM sign-off for the chosen fab

## Next

1. Export Gerbers + drill + BOM/P&P.
2. Run the JLCPCB DFM profile.
3. Final visual review and release.
