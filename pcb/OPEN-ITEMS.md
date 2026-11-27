# Open items

Single place for every open check, `[VERIFY]`, and Rev-B decision. Design values
live in `pcb/DESIGN.md`, the parts list in `pcb/BOM.md`, board status in
`pcb/README.md`, model limits in `pcb/sim/README.md`.

**A = blocks fab/production.** Everything else can be closed before or during
the build.

## A — blocks fab / production

| # | Item | Why it blocks | Source |
|---|---|---|---|
| A1 | **Y1 footprint vs part**: footprint `Crystal_SMD_3215-2Pin_3.2x1.5mm`, MPN `ABM8-8.000MHZ-B2-T` is 3.2 × 2.5 mm | 3.2 × 1.5 is the 32.768 kHz package (Abracon ABS07); no 8 MHz part exists in that size → the crystal will not fit the pads | `pcb/BOM.md` note; Abracon ABS07 / ABM8 series |
| A2 | **J1 stencil / pick-and-place**: 4 SMD pads, no paste window | must be excluded from the stencil and marked "do not place" | `pcb/README.md` |
| A3 | **DNP set**: C8, L1, R8 native DNP | assembler must skip them; R17/R18 (0 Ω bypass) are fitted | `pcb/BOM.md` |
| A4 | **LCSC codes**: only C1525 (100 nF) and C25744 (10 k) assigned; in-house codes missing for the other lines | JLC assembly cannot be quoted | `pcb/BOM.md` |
| A5 | **U1 exact orderable code + stock** (`STM32G474CBU6`) | MCU lead time/stock | `pcb/BOM.md` |
| A6 | **U2 stock** `LM5164QDDARQ1`; **U3** automotive `-Q1` variant availability | single-source automotive parts | `pcb/BOM.md` |
| A7 | **Library-mismatch warnings** (C2/C5 no courtyard, U1 EP land pads, U2 thermal pads) | DFM tools may flag them; either document them or resync the library | `pcb/README.md` §DRC |
| A8 | **Gerber / drill / P&P export + JLCPCB DFM** | release step | `pcb/README.md` |

## B — datasheet and value checks

| # | Item | Note |
|---|---|---|
| B1 | Output capacitors at 3.3 V | 2 × 22 µF 10 V X5R 0805 derated to ~28 µF (assumed 64 %); datasheet minimum is 20.1 µF for 0.5 % ripple → 1.4× margin. Confirm the Murata DC-bias curve |
| B2 | L2 `XAL5030-103MEC` | confirm Isat / Irms / DCR; electrical need is 0.70 A peak / 0.28 A rms |
| B3 | Buck values | R_RON 27.5 kΩ E-series, FB divider, C_ff |
| B4 | EN/UVLO divider | 1 M / 300 k + 100 nF → 6.50 V on / 6.07 V off at VIN |
| B5 | VREF+ / VDDA decoupling | against the STM32G4 hardware design note |
| B6 | SS36 forward drop | ~0.35 V at 0.15 A from the datasheet curve |
| B7 | SMBJ24A vs unclamped load dump | 600 W TVS is sized for clamped transients only; a full ISO 7637-2 5a needs a 3 kW class part and/or the clamp ahead of D1 (`pcb/sim/README.md` §5) |
| B8 | Display module | 7 vs 8 pins, BL polarity/current, mated height |
| B9 | Crystal load caps | C10/C11 = 10 pF vs the chosen crystal CL |
| B10 | Cranking profile | actual duration/minimum voltage from the car |

## C — mechanical / enclosure

| # | Item | Note |
|---|---|---|
| C1 | J1 pigtail | wire gauge, bend radius, strain relief through the 20 × 8 slot |
| C2 | Micro-Fit cable-end kit | housing `43025-0400`, terminals `43030-0007`, TPA |
| C3 | J2–J5 mated height | right-angle bodies 2.96 mm; the plug must clear the back plate |
| C4 | Front-side fit check | `3d-model/src/dummies.scad` now models the connectors on the front face — verify against the real boards |

## D — ordering data still missing

| # | Item |
|---|---|
| D1 | C8 hold-up part: single 100 µF, 6.3 × 4.5 mm, height ≤ 4.5 mm (DNP) |
| D2 | D2 `SMBJ24A`, D3 `PESD2CAN`, D4 LED (no MPN chosen), F1 `0437.500WR` stock |
| D3 | L1 CMC MPN (DNP footprint) |
| D4 | JST `SM08B-SRSS-TB` / `SM04B-SRSS-TB` stock |

## E — Rev B ideas (not blocking)

- Move R17/R18 next to L1 (the CAN pair currently splits around the DNP choke).
- Consider a 3 kW TVS class and/or clamping ahead of D1 if an unclamped load
  dump is in the specification.
- Front-side connectors are intentional; if a future enclosure gives more depth,
  the per-face height rule (front 5.0 / back 3.0 mm, `pcb/README.md`) is the
  constraint to revisit.
