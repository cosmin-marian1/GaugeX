# GaugeX PCB — BOM

Generated from the schematic symbol fields (`MPN`, `LCSC`). **Do not edit the
table by hand** — edit the fields in `pcb/GaugeX/GaugeX.kicad_sch` and
re-export. Design values live in `pcb/DESIGN.md`; open checks in
`pcb/OPEN-ITEMS.md`.

## Regenerate

```bash
kicad-cli sch export bom \
  --fields "Reference,Value,Footprint,MPN,LCSC,QUANTITY,DNP" \
  --labels "Refs,Value,Footprint,MPN,LCSC,Qty,DNP" \
  --group-by "Value,Footprint,MPN,LCSC" \
  --output bom.csv pcb/GaugeX/GaugeX.kicad_sch
```

The table below is that export with the library prefix stripped from the
footprint column. 44 groups, 67 parts.

## Table

| Refs | Value | Footprint | MPN | LCSC | Qty | DNP |
|---|---|---|---|---|---|---|
| C1 | 4.7uF | C_0805_2012Metric | GRM21BR61E475KA12L |  | 1 |  |
| C2,C6,C7,C9,C12-C15,C17,C19-C23 | 100nF | C_0402_1005Metric | GRM155R71H104KA88D | C1525 | 14 |  |
| C3,C4 | 22uF | C_0805_2012Metric | GRM21BR61A226ME44L |  | 2 |  |
| C5 | 2.2nF | C_0402_1005Metric | GCM155R71H222KA37D |  | 1 |  |
| C8 | 100uF | CP_Elec_6.3x4.5 |  |  | 1 | DNP |
| C10,C11 | 10pF | C_0402_1005Metric | GRM1555C1H100JA01D |  | 2 |  |
| C16,C18 | 1uF | C_0402_1005Metric | GRM155R61C105KA12D |  | 2 |  |
| D1 | SS36 | D_SMA | SS36-E3/57T |  | 1 |  |
| D2 | SMBJ24A | D_SMB | SMBJ24A |  | 1 |  |
| D3 | PESD2CAN | SOT-23 | PESD2CAN,115 |  | 1 |  |
| D4 | Green | LED_0402_1005Metric |  |  | 1 |  |
| F1 | 0.5A | Fuse_1206_3216Metric | 0437.500WR |  | 1 |  |
| FB1 | 600R | L_0603_1608Metric | BLM18AG601SN1D |  | 1 |  |
| J1 | 12V/GND/CANH/CANL | GaugeX_SolderPad_1x04_P2.54mm |  |  | 1 |  |
| J2 | DISP1 | JST_SH_SM08B-SRSS-TB_1x08-1MP_P1.00mm_Horizontal | SM08B-SRSS-TB(LF)(SN) |  | 1 |  |
| J3 | DISP2 | JST_SH_SM08B-SRSS-TB_1x08-1MP_P1.00mm_Horizontal | SM08B-SRSS-TB(LF)(SN) |  | 1 |  |
| J4 | DISP3 | JST_SH_SM08B-SRSS-TB_1x08-1MP_P1.00mm_Horizontal | SM08B-SRSS-TB(LF)(SN) |  | 1 |  |
| J5 | BTN1/BTN2/GND | JST_SH_SM04B-SRSS-TB_1x04-1MP_P1.00mm_Horizontal | SM04B-SRSS-TB(LF)(SN) |  | 1 |  |
| L1 | CMC | L_CommonModeChoke_TDK_ACM2520-2P | ACM2520-101-2P |  | 1 | DNP |
| L2 | 10uH | L_Coilcraft_XAL5030-XXX | XAL5030-103MEC |  | 1 |  |
| R1,R6 | 100k | R_0402_1005Metric | RC0402FR-07100KL |  | 2 |  |
| R2 | 57.6k | R_0402_1005Metric | RC0402FR-0757K6L |  | 1 |  |
| R3 | 27.5k | R_0402_1005Metric | RC0402FR-0727K5L |  | 1 |  |
| R4 | 1M | R_0402_1005Metric | RC0402FR-071ML |  | 1 |  |
| R5 | 300k | R_0402_1005Metric | RC0402FR-07300KL |  | 1 |  |
| R7 | 15k | R_0402_1005Metric | RC0402FR-0715KL |  | 1 |  |
| R8 | 120R | R_0402_1005Metric | RC0402FR-07120RL |  | 1 | DNP |
| R10,R12,R13 | 10k | R_0402_1005Metric | RC0402FR-0710KL | C25744 | 3 |  |
| R11 | 1k | R_0402_1005Metric | RC0402FR-071KL |  | 1 |  |
| R14-R18 | 0R | R_0402_1005Metric | RC0402JR-070RL |  | 5 |  |
| TP1 | +3V3 | TestPoint_Pad_D1.0mm |  |  | 1 |  |
| TP2 | SWDIO | TestPoint_Pad_D1.0mm |  |  | 1 |  |
| TP3 | SWCLK | TestPoint_Pad_D1.0mm |  |  | 1 |  |
| TP4 | NRST | TestPoint_Pad_D1.0mm |  |  | 1 |  |
| TP5 | GND | TestPoint_Pad_D1.0mm |  |  | 1 |  |
| TP6 | USART1_TX | TestPoint_Pad_D1.0mm |  |  | 1 |  |
| TP7 | USART1_RX | TestPoint_Pad_D1.0mm |  |  | 1 |  |
| TP8 | BOOT0 | TestPoint_Pad_D1.0mm |  |  | 1 |  |
| TP9 | PGOOD | TestPoint_Pad_D1.0mm |  |  | 1 |  |
| TP10 | BL_PWM | TestPoint_Pad_D1.0mm |  |  | 1 |  |
| U1 | STM32G474CBU6 | QFN-48-1EP_7x7mm_P0.5mm_EP5.6x5.6mm | STM32G474CBU6 |  | 1 |  |
| U2 | LM5164-Q1 | HSOP-8-1EP_3.9x4.9mm_P1.27mm_EP2.41x3.1mm_ThermalVias | LM5164QDDARQ1 |  | 1 |  |
| U3 | TCAN330G | SOIC-8_3.9x4.9mm_P1.27mm | TCAN330GDR |  | 1 |  |
| Y1 | 8MHz | Crystal_SMD_3215-2Pin_3.2x1.5mm | ABM8-8.000MHZ-B2-T |  | 1 |  |

## Notes

### U2 — package
**HSOP-8-1EP** (PowerPAD, 3.9 × 4.9 mm, EP 2.41 × 3.1), **not VSSOP-10**. The
MPN `LM5164QDDARQ1` is the DDA/HSOP-8 part. The old BOM's "VSSOP-10" was wrong;
design value now in `pcb/DESIGN.md` §4.2.

### C8 — hold-up capacitor (DNP)
One **100 µF** part on the +3V3 rail, footprint `CP_Elec_6.3x4.5`, DNP. Replaces
the old "`C_hold`: 2 × 100 µF / 25 V polymer, 6.3 × 6.3" line, which could not
fit: two parts, a 6.3 × 6.3 body against a 6.3 × 4.5 footprint, and 25 V is
unnecessary on a 3.3 V rail. Choose a single 6.3 × 4.5 part (height ≤ 4.5 mm)
if the hold-up is ever fitted — MPN `[VERIFY]`.

### Y1 — 8 MHz crystal: the 3.2 × 1.5 footprint is wrong
Footprint `Crystal_SMD_3215-2Pin_3.2x1.5mm`; the MPN in the field,
`ABM8-8.000MHZ-B2-T`, is **3.2 × 2.5 mm**. Datasheets checked:

| Source | Fact |
|---|---|
| Abracon ABS07 series | 3.2 × 1.5 mm package = **32.768 kHz** tuning-fork crystal |
| Abracon ABM8 series | 3.2 × 2.5 mm, **8–125 MHz** — where 8 MHz lives |
| Abracon ABM10 / ABM11 | 2.5 × 2.0 (12–55 MHz) / 2.0 × 1.6 (16–50 MHz) — smaller bodies start above 8 MHz |

**No 8 MHz part exists in 3.2 × 1.5** in the Abracon range, so the footprint is
wrong for this design; it must become 3.2 × 2.5 (ABM8) before fab. Nothing was
changed here — tracked as a **blocks-fab** item in `pcb/OPEN-ITEMS.md`.

### DNP
C8, L1 (common-mode choke) and R8 (120 Ω termination) carry the native DNP flag
and are excluded from assembly. R17/R18 (0 Ω CMC bypasses) are fitted.

### LCSC codes
Only **100 nF 0402 (C1525)** and **10 k 0402 (C25744)** are assigned. The
remaining lines need LCSC codes at order time — `pcb/OPEN-ITEMS.md`.

### Rows without an MPN
J1 (4 solder pads + pigtail), TP1–TP10 (test pads), D4 (generic green LED) and
C8 (to be chosen). J1 is hand-soldered: no paste window, exclude it from the
stencil and mark it "do not place" in the P&P file.

### Alternatives kept in the design
- U2: **TPS54360B-Q1** (HSOIC-8, 4.5 V minimum input) if cranking ride-through
  becomes mandatory.
- U3: **SN65HVD230Q1**.
- L1: CMC DNP, bypassed by R17/R18.

### Prices
Not part of this generated table. Re-quote at order time (single-unit prices in
the old BOM were indicative).
