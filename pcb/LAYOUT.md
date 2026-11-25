# GaugeX PCB — layout status

KiCad project: `pcb/GaugeX/GaugeX.kicad_pro`
Board: `pcb/GaugeX/GaugeX.kicad_pcb`
Preview: `pcb/GaugeX/GaugeX_board.png`

## Mechanical

| Item | Value |
|---|---|
| Outline | **50 × 40 mm**, 2.5 mm corner radius |
| Mounting holes | 4 × **Ø2.7 mm** (M2.5), 5.0 mm pad, pattern **44 × 34 mm** |
| Hole positions | (3,3), (47,3), (3,37), (47,37) |
| Layers | **4 copper** (F.Cu / In1.Cu / In2.Cu / B.Cu), 1.6 mm |
| Board origin | bottom-left |

## Placement

- 67 schematic footprints + 4 mounting holes = **71 footprints**
- Functional zones:
  - top edge: J1 power/CAN pads
  - top-left: input protection + LM5164 buck
  - centre: STM32G474 + decoupling + crystal
  - top-right: TCAN330G + CAN protection
  - bottom edge: J2–J4 display connectors
  - right edge: J5 button connector
  - edges: test pads

## DRC

```text
Errors:        0
Warnings:      12  (silkscreen clearance / solder mask clipping)
Unconnected:  147  (expected — no routing yet)
Courtyard:      0
```

The 12 warnings are silkscreen-only (reference/value text on small passives).
Reference/value text is hidden on passives; the remaining warnings are
connector/pad silkscreen. No electrical errors.

## Not done

- No tracks or vias
- No copper zones / ground plane
- No length matching or differential pair routing
- No final Gerber/drill export

## Next

1. Fix the 12 silkscreen warnings (move/hide remaining text).
2. Route power first: input → buck → 3V3, then CAN pair, then SPI/display, then buttons/SWD.
3. Add solid GND plane on L2, 3V3/power on L3.
4. DRC 0 errors, then Gerber/drill/BOM/P&P export.
