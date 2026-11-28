# GaugeX — project state

Branch `main` (`docs-cleanup` merged), updated 2026-11-28. Facts only; session
handoff.
Open items and `[VERIFY]`: `pcb/OPEN-ITEMS.md` (not copied here).

**Rule: each design value lives in exactly one file.** Owners: `pcb/README.md`
(board, stackup, routing, DRC, heights), `pcb/DESIGN.md` (electrical),
`pcb/BOM.md` (parts), `pcb/sim/README.md` (model limits), `3d-model/README.md`
(enclosure). Everything else links to the owner and never restates the value.

## Decisions

- Input 12 V from Kl.15 only; one 3.3 V rail; CAN listen-only, never transmit.
- MCU STM32G474CBU6 (UFQFPN48); fallback STM32G474CEU6.
- Buck U2 LM5164-Q1 (HSOP-8-1EP, `LM5164QDDARQ1`); TPS54360B-Q1 is the
  crank-ride-through alternative.
- CAN U3 TCAN330G, silent pin driven by PB0; fallback SN65HVD230Q1.
- Stackup: L1 signal, L2 solid GND, L3 3V3 pour + GND fill, L4 signal + GND.
- Power entry J1: 4 SMD solder pads, no THT, 0 mm below the board.
- C5 = 2.2 nF / 50 V / X7R: required by the LM5164-Q1 datasheet (p. 3, 12, 17);
  do not change. Owner: `pcb/DESIGN.md` §4.5.
- C8 = one 100 µF, DNP; the old 2 × 100 µF 6.3 × 6.3 cannot fit.
- Height is per face: front ≤ 5.0 mm, back ≤ 3.0 mm (`pcb/README.md`).
- 0402 passives; parts ≥ 105 °C preferred, never below 85 °C; JLCPCB/LCSC first.

## Done (commit, oldest first)

- `9b4721e` pcb: buck hot loop, U2 thermal vias, front-side dummies.
- `aede99b` sim: buck/front-end proxy model and its limits.
- `f6e6619` docs: layout status merged into `pcb/README.md`.
- `9ad92b6` docs: DESIGN cleanup, U2 HSOP-8, front-side J2–J4.
- `c88b324` bom: MPN/LCSC in the schematic, kicad-cli BOM export.
- `6ff7b06` docs: `pcb/OPEN-ITEMS.md` as the single open list.
- `e2d5ea4` docs: superseded docs archived, ERC/net membership in DESIGN §5.3.
- `6c25ee3` docs: root README as index; 0 broken links.
- `e74c89e` review: `pcb/review/pins.md`, pin/net table from the netlist.

Validated on the current board: ERC 0; DRC 0 errors, 0 unconnected, 4 documented
`lib_footprint_mismatch` warnings (C2, C5, U1, U2). Re-run 2026-11-28 together
with a schematic↔board net comparison (0 mismatches): `pcb/review/final-report.md`.
Pin names, pads and AF numbers audited against ST pin data: `pcb/review/pins_names.md`.
No Gerber/drill/P&P yet.

## Blocked for fab

All in `pcb/OPEN-ITEMS.md` §A. First: A1 — Y1 footprint `3.2 × 1.5` has no
8 MHz part; it must become `3.2 × 2.5` (ABM8) before any Gerber export. The
2-pad footprint also shorts HSE_IN/OUT to the ABM8 GND pads, so A1 needs the
4-pad footprint **and** `Device:Crystal_GND24` (`pcb/review/pins_names.md` §5).
Then A2–A8: stencil/P&P exclusions, DNP set (the board carries no `dnp` flag
yet, so `--exclude-dnp` would not exclude R8/L1), LCSC codes, stock, DRC
warnings, Gerber/DFM export.

## Next

1. Fix A1 (Y1 footprint + crystal symbol), then export Gerber/drill/BOM/P&P and
   run the JLCPCB DFM profile.
2. Assign LCSC codes and confirm stock (A4–A6); quote.
3. Firmware is out of scope here (`firmware/`). Board bring-up must assume HSI
   until A1 is fixed — the 8 MHz HSE cannot start on the current board.
