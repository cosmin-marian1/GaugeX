# GaugeX PCB — layout status

KiCad project: `pcb/GaugeX/GaugeX.kicad_pro`
Board: `pcb/GaugeX/GaugeX.kicad_pcb`
Previews: `GaugeX_board_routed.png`, `GaugeX_board_all_layers.png`

## Mechanical

| Item | Value |
|---|---|
| Outline | **50 × 40 mm**, 2.5 mm corner radius |
| Mounting holes | 4 × **Ø2.7 mm** (M2.5), 5.0 mm pad, pattern **44 × 34 mm** |
| Hole positions | (3,3), (47,3), (3,37), (47,37) |
| Layers | **4 copper** (F.Cu / In1.Cu / In2.Cu / B.Cu), 1.6 mm |
| Board origin | bottom-left |

## Routing

| Item | Value |
|---|---|
| Tracks | **784** |
| Vias | **107** |
| Track widths | 0.20 mm signal, **0.60 mm power** |
| GND zone | 1 plane on **B.Cu**, filled |
| Router | FreeRouting 2.6 + manual GND via-in-pad fix |
| DRC | **PASS — 0 errors, 0 warnings, 0 unconnected** |

Notes:

- All four layers are used: F.Cu 557 tracks, In1.Cu 92, In2.Cu 105, B.Cu 30.
- Power nets (`VIN`, `+3V3`, `GND`) use 0.6 mm tracks.
- Clearance is **0.15 mm** (JLCPCB-compatible); the project netclass was set to
  0.15 mm accordingly.
- The U1 exposed pad is connected to the B.Cu GND zone with a via placed away
  from the inner-layer tracks.
- Silkscreen references are hidden on passives and connectors to keep the
  silkscreen clean.

## Not done

- Gerber / drill / BOM / pick-and-place export
- DFM sign-off for the chosen fab
- Electrical review of the final netlist vs the schematic (ERC already PASS)

## Next

1. Export Gerbers + drill + BOM/P&P.
2. Run the fab DFM profile (JLCPCB).
3. Final visual review and release.
