# GaugeX PCB — schematic status

KiCad project: `pcb/GaugeX/GaugeX.kicad_pro`
KiCad: 10.0.8
Sheet: A1 single sheet

## Result

| Check | Result |
|---|---|
| ERC | **PASS — 0 violations** |
| Netlist export | `GaugeX.net` |
| PDF | `GaugeX_schematic.pdf` |
| PNG | `GaugeX_schematic.png` |
| ERC report | `ERC_report.json` |

The schematic is a **first-pass functional schematic**. Connectivity is
verified by netlist and `sch_trace_net`, but the auto-generated placement is
label-based and not yet visually clean (`sch_visual_qa` reports text/field
overlaps, cosmetic score 36/100). A manual layout cleanup or a hierarchical
split is the next quality step; the electrical design is complete.

## Net checks (from KiCad)

| Net | Members |
|---|---|
| `CANH` | L1.2, R17.2, R8.1, U3.7 |
| `CANL` | L1.4, R18.2, R8.2, U3.6 |
| `CAN_TX` | U1.34 (PA12), U3.1 (TXD) |
| `CAN_RX` | U1.33 (PA11), U3.4 (RXD) |
| `CAN_SILENT` | U1.17 (PB0), U3.8 (S) |
| `+3V3` | U1 VDD 23/35/48, VBAT 1, U3.3, displays, pull-ups |
| `GND` | U1.49 (exposed pad), U2.1/9, U3.2/5, all decoupling |
| `DISP1_SCK` | U1.13 (PA5), J2.3 |
| `DISP2_SCK` | U1.26 (PB13), J3.3 |
| `DISP3_SCK` | U1.41 (PB3), J4.3 |
| `DISP_RST` | U1.10 (PA2), J2.7, J3.7, J4.7 |
| `HSE_IN/OUT` | U1.5/6, Y1.1/2, C10/C11 |

## Design notes

- Power tree: J1 pads → F1 → D1 SS36 → D2 SMBJ24A → LM5164-Q1 → +3V3.
- `+3V3A` is the filtered analog rail: FB1 + C16/C17, feeding VDDA and
  VREF+ (U1.21/U1.20), with C18/C19.
- CAN: TCAN330G, `S` tied to PB0 (silent/listen-only), `SHDN` tied to GND.
  L1 CMC and R8 termination are DNP; R17/R18 are 0 Ω bypasses.
- Displays: three 8-pin connectors; BL pins tied to +3V3 through 0 Ω.
- Buttons: 10 kΩ pull-ups and 100 nF.
- SWD/boot/USART/PGOOD/BL_PWM on 1.27 mm test pads.
- Unused MCU pins have no-connect flags.

## Known follow-ups

1. Visual cleanup: the auto-placed label-only layout needs manual grouping or
   hierarchical sheets (Power / MCU / CAN / IO).
2. Y1 footprint is a placeholder `Crystal_SMD_3215-2Pin_3.2x1.5mm`; the BOM
   specifies a 3.2×2.5 crystal. Match the final part. `[VERIFY]`
3. Assign the exact LCSC/Mouser parts and final footprints before layout.
4. No PCB placement or routing yet.
