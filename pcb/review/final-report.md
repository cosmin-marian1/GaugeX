# PCB verification report — 2026-11-28

Full-project re-check of the board before the work moves to firmware. Read-only:
**no design value was changed** by this pass. Values stay in their owner files
(`pcb/README.md` board, `pcb/DESIGN.md` electrical, `pcb/BOM.md` parts).

## Verdict

| Area | State |
|---|---|
| Schematic (ERC) | **PASS** — 0 violations |
| Board (DRC) | **PASS** — 0 errors, 0 unconnected, 4 documented warnings |
| Schematic ↔ board consistency | **PASS** — 0 net mismatches, 0 missing pins |
| Netlist ↔ `pins.md` / `pins_names.md` | **PASS** — consistent |
| Pin names / AF map | **PASS** — all AF numbers in `DESIGN.md` §5 re-check against DS12288 |
| Ready to order | **NO** — A1 still open (plus A2–A8) |
| Ready for firmware work | **YES**, with the HSE caveat below |

## Evidence

Tooling: KiCad 10.0.8 (`/usr/bin/kicad-cli`), 2026-11-28.

| Check | Command | Result |
|---|---|---|
| ERC | `kicad-cli sch erc --severity-all GaugeX.kicad_sch` | `Found 0 violations` |
| DRC | `kicad-cli pcb drc --severity-all GaugeX.kicad_pcb` | `Found 4 violations`, `Found 0 unconnected items`, `0 footprint errors` |
| BOM | `kicad-cli sch export bom --group-by Value,Footprint,MPN,LCSC` | 44 groups, 67 parts; DNP = C8, L1, R8 |
| Netlist vs board | `kicad-cli sch export netlist` compared pad-by-pad against the `.kicad_pcb` | 209 nodes / 213 numbered pads, **0** net mismatches, **0** netlist pins without a board pad |
| Board statistics | parse of `GaugeX.kicad_pcb` | 611 segments, 168 vias, 71 footprints, 5 zones — reproduces `pcb/README.md` |

The four DRC items are the known `lib_footprint_mismatch` warnings:
`C_0402_1005Metric` ×2 (C2, C5 — courtyard removed), `QFN-48-1EP…` (U1 — EP land
pads given GND), `HSOP-8-1EP…` (U2 — PTH pads replaced by vias). No new DRC item
appeared since the last save.

The four board pads with no netlist node are `MP` (mechanical) pads on J2–J5,
deliberately unconnected.

The 42 BOM groups without an LCSC code are item A4, unchanged.

## Ordering blockers (unchanged, with what this pass added)

**A1 — Y1, the only true showstopper, and it is worse than "wrong size".**
The fitted footprint is 2-pad `Crystal_SMD_3215-2Pin_3.2x1.5mm` with
1.00 × 1.80 mm pads at x = ±1.25 mm, y = 0; the part is an ABM8, 3.2 × 2.5 mm
with 4 terminals (1/3 crystal, **2/4 GND**) at ±1.05 / ±0.80 mm. Each 1.8 mm
pad covers y ∈ [−0.9, +0.9], i.e. it touches both the crystal terminal and a GND
terminal of the ABM8. Fitting the part **shorts HSE_IN and HSE_OUT to GND** and
the oscillator cannot start. The fix is two-sided — 4-pad footprint
(`Crystal:Crystal_SMD_3225-4Pin_3.2x2.5mm`) *and* a symbol that exposes the two
GND pins (`Device:Crystal_GND24`), otherwise pads 2/4 end up unconnected. Both
are design-file changes and need sign-off (`AGENTS.md` rule 3). Detail:
`pcb/review/pins_names.md` §5.

**A3 — DNP would not reach the CPL.** C8, L1 and R8 are DNP in the schematic,
but no footprint in `GaugeX.kicad_pcb` carries the `dnp` attribute (checked over
all 71). `kicad-cli pcb export pos --exclude-dnp` acts on the board flag, so it
would place R8 and L1 today.

A2 (J1 stencil / do-not-place), A4 (LCSC codes), A5/A6 (stock), A7 (the four
warnings), A8 (Gerber/drill/P&P + JLCPCB DFM) are all still open in
`pcb/OPEN-ITEMS.md` §A.

## Smaller observations (documentation, not electrical)

1. D2 `SMBJ24A` uses `Device:D_TVS`, the **bidirectional** TVS symbol, for a
   unidirectional part. The clamp is correct only because the footprint puts
   pad 1 (cathode) on VIN — the schematic cannot show it.
2. D3 `PESD2CAN` on `Device:D_TVS_Dual_AAC` (A–A–common) with `common` on GND:
   worth one look at the PESD2CAN datasheet to confirm the internal
   configuration. `[VERIFY]`, not resolvable from the files in this repo.
3. `DESIGN.md` §5 cites DS12288 Table 13 "pages 73–74"; the table runs to
   printed page 79.
4. B9 (crystal load caps) is unchanged: the ABM8 ordering code carries no CL
   field → standard 18 pF, while C10/C11 are 10 pF.

## Firmware readiness

The pin/AF map is verified end to end (`pcb/review/pins_names.md`): SPI1/2/3 for
the three displays, FDCAN1 on PA11/PA12, USART1 on PA9/PA10, SWD on PA13/PA14,
BOOT0 on PB8, ADC1_IN2 on PA1. Firmware can be written against it now.

**Caveat for bring-up:** the 8 MHz HSE cannot start on the current board until
A1 is fixed, so first light on hardware needs the HSI fallback (or a fixed Y1
board). SWD and USART1 work from HSI.

Not verified here: Gerber/drill/P&P (blocked by A1, `AGENTS.md` rule 4),
JLCPCB DFM profile, component heights (still STEP-proxy values from
`DESIGN.md` §7).
