# Pin names, pads and alternate functions — review snapshot

Read-only review of `GaugeX.kicad_sch` / `GaugeX.kicad_pcb`. **No design file was
changed.** This extends `pcb/review/pins.md` (which keeps the full per-net
membership lists); the net → part mapping here is the same data.

Owners, not restated as authority: pin allocation and AF choice live in
`pcb/DESIGN.md` §5, parts in `pcb/BOM.md`, open checks in `pcb/OPEN-ITEMS.md`.
This file records what the files *actually say*, so the two can be compared.

## Sources

| What | Where |
|---|---|
| Pin names | `GaugeX.kicad_sch`, `lib_symbols` block (embedded symbol definitions) |
| Pad numbers, pad nets | `GaugeX.kicad_pcb`, footprint `pad` nodes (all 71 footprints parsed) |
| ST pin data | `STM32G474C(B-C-E)Ux.xml`, `DBVersion V3.0`, `Package="UFQFPN48"`, fetched 2026-11-28 from `raw.githubusercontent.com/STMicroelectronics/STM32_open_pin_data/master/mcu/STM32G474C(B-C-E)Ux.xml`. **Not committed** — copy lives only in `/tmp/opencode/`. |
| AF numbers | DS12288 Rev 6 (`docs/datasheets/DS_stm32g474cb.pdf`), §4.11 Table 13 "Alternate function", printed pages 73–79. Read with `pdftotext -bbox-layout` and column clustering; 12 anchor rows (PA5, PA9–PA14, PB3, PB5, PB13, PB15, PF0, PG10) cross-checked by hand against `DESIGN.md` §5. |
| Y1 land pattern | Abracon ABM8 series datasheet, REVISED 07-29-20, `abracon.com/Resonators/ABM8.pdf`, "Recommended land pattern" |
| U3 pin 5 | TCAN33x family datasheet present as `docs/datasheets/tcan334.pdf` (pin table covers TCAN330/330G) |

Net names are taken from the PCB pad nets; `unconnected-(…)` is shown as `—`.

## 1. Symbol and footprint identity

| Part | Value | Symbol library entry | Footprint | Pads |
|---|---|---|---|---|
| U1 | STM32G474CBU6 | `MCU_ST_STM32G4:STM32G474CBUx` — **UFQFPN48**, 49-pin symbol | `Package_DFN_QFN:QFN-48-1EP_7x7mm_P0.5mm_EP5.6x5.6mm` | 1–49 + 16 unnumbered GND via pads |
| U2 | LM5164-Q1 | `Regulator_Switching:LM5164DDA` — **HSOP-8-1EP** | `Package_SO:HSOP-8-1EP_3.9x4.9mm_P1.27mm_EP2.41x3.1mm_ThermalVias` | 1–8, 9, 9 + 4 unnumbered GND via pads |
| U3 | TCAN330G | `Interface_CAN_LIN:TCAN330G` — **SOIC-8** | `Package_SO:SOIC-8_3.9x4.9mm_P1.27mm` | 1–8 |
| Y1 | 8MHz | `Device:Crystal` — 2-pin | `Crystal:Crystal_SMD_3215-2Pin_3.2x1.5mm` | 1–2 |
| D1 | SS36 | `Device:D_Schottky` | `Diode_SMD:D_SMA` | 1–2 |
| D2 | SMBJ24A | `Device:D_TVS` (bidirectional TVS drawing) | `Diode_SMD:D_SMB` | 1–2 |
| D3 | PESD2CAN | `Device:D_TVS_Dual_AAC` | `Package_TO_SOT_SMD:SOT-23` | 1–3 |
| J1 | 12V/GND/CANH/CANL | `Connector_Generic:Conn_01x04` | `GaugeX:GaugeX_SolderPad_1x04_P2.54mm` (project lib) | 1–4 |

U1's package name in the symbol is `UFQFPN48`, matching the XML `Package`
attribute; the symbol is drawn from KiCad's `MCU_ST_STM32G4` library, not from
ST data, so pin *names* differ where KiCad keeps the short port name.

## 2. U1 — STM32G474CBU6 (UFQFPN48)

`AF` = the alternate function the net needs, per `DESIGN.md` §5, with the AF
number from DS12288 Table 13. `GPIO` (no AF number) means a plain digital pin
in this design; a usable AF exists for some of them but is not selected.

| Pin | Symbol pin name | Pad | Net | ST XML pin name | Net needs | AF | Flag |
|---:|---|---:|---|---|---|---|---|
| 1 | VBAT | 1 | +3V3 | VBAT | — | — |  |
| 2 | PC13 | 2 | — | PC13 | — | — |  |
| 3 | PC14 | 3 | — | PC14-OSC32_IN | — | — | **name≠XML** |
| 4 | PC15 | 4 | — | PC15-OSC32_OUT | — | — | **name≠XML** |
| 5 | PF0 | 5 | HSE_IN | PF0-OSC_IN | RCC_OSC_IN (HSE) | — (OSC) | **name≠XML** |
| 6 | PF1 | 6 | HSE_OUT | PF1-OSC_OUT | RCC_OSC_OUT (HSE) | — (OSC) | **name≠XML** |
| 7 | PG10 | 7 | NRST | PG10-NRST | — | — | **name≠XML**; **XML has no NRST signal entry** |
| 8 | PA0 | 8 | BL_PWM | PA0 | TIM2_CH1 (BL_PWM, optional) | AF1 |  |
| 9 | PA1 | 9 | VSENSE | PA1 | ADC1_IN2 (12 V divider sense) | analog |  |
| 10 | PA2 | 10 | DISP_RST | PA2 | GPIO (display RST, shared) | — |  |
| 11 | PA3 | 11 | DISP1_DC | PA3 | GPIO (display 1 DC) | — |  |
| 12 | PA4 | 12 | DISP1_CS | PA4 | GPIO (SPI1_NSS = AF5, not used) | — |  |
| 13 | PA5 | 13 | DISP1_SCK | PA5 | SPI1_SCK | AF5 |  |
| 14 | PA6 | 14 | — | PA6 | — | — |  |
| 15 | PA7 | 15 | DISP1_MOSI | PA7 | SPI1_MOSI | AF5 |  |
| 16 | PC4 | 16 | — | PC4 | — | — |  |
| 17 | PB0 | 17 | CAN_SILENT | PB0 | GPIO (CAN silent, high = listen-only) | — |  |
| 18 | PB1 | 18 | BTN1 | PB1 | GPIO (BTN1, EXTI) | — |  |
| 19 | PB2 | 19 | BTN2 | PB2 | GPIO (BTN2, EXTI) | — |  |
| 20 | VREF+ | 20 | +3V3A | VREF+ | — | analog |  |
| 21 | VDDA | 21 | +3V3A | VDDA | — | — |  |
| 22 | PB10 | 22 | — | PB10 | — | — |  |
| 23 | VDD | 23 | +3V3 | VDD | — | — |  |
| 24 | PB11 | 24 | — | PB11 | — | — |  |
| 25 | PB12 | 25 | DISP2_CS | PB12 | GPIO (SPI2_NSS = AF5, not used) | — |  |
| 26 | PB13 | 26 | DISP2_SCK | PB13 | SPI2_SCK | AF5 |  |
| 27 | PB14 | 27 | DISP2_DC | PB14 | GPIO (display 2 DC) | — |  |
| 28 | PB15 | 28 | DISP2_MOSI | PB15 | SPI2_MOSI | AF5 |  |
| 29 | PC6 | 29 | — | PC6 | — | — |  |
| 30 | PA8 | 30 | — | PA8 | — | — |  |
| 31 | PA9 | 31 | USART1_TX | PA9 | USART1_TX (test pad) | AF7 |  |
| 32 | PA10 | 32 | USART1_RX | PA10 | USART1_RX (test pad) | AF7 |  |
| 33 | PA11 | 33 | CAN_RX | PA11 | FDCAN1_RX | AF9 |  |
| 34 | PA12 | 34 | CAN_TX | PA12 | FDCAN1_TX | AF9 |  |
| 35 | VDD | 35 | +3V3 | VDD | — | — |  |
| 36 | PA13 | 36 | SWDIO | PA13 | SYS_JTMS-SWDIO (SWD) | AF0 |  |
| 37 | PA14 | 37 | SWCLK | PA14 | SYS_JTCK-SWCLK (SWD) | AF0 |  |
| 38 | PA15 | 38 | — | PA15 | — | — |  |
| 39 | PC10 | 39 | — | PC10 | — | — |  |
| 40 | PC11 | 40 | — | PC11 | — | — |  |
| 41 | PB3 | 41 | DISP3_SCK | PB3 | SPI3_SCK (display 3) | AF6 |  |
| 42 | PB4 | 42 | — | PB4 | — | — |  |
| 43 | PB5 | 43 | DISP3_MOSI | PB5 | SPI3_MOSI (display 3) | AF6 |  |
| 44 | PB6 | 44 | DISP3_CS | PB6 | GPIO (display 3 CS) | — |  |
| 45 | PB7 | 45 | DISP3_DC | PB7 | GPIO (display 3 DC) | — |  |
| 46 | PB8 | 46 | BOOT0 | PB8-BOOT0 | BOOT0 (sampled at reset) | system | **name≠XML**; **XML has no BOOT0 signal entry** |
| 47 | PB9 | 47 | LED_DRIVE | PB9 | GPIO (LED) | — |  |
| 48 | VDD | 48 | +3V3 | VDD | — | — |  |
| 49 | VSS | 49 | GND | — | — | — | **no such pin in XML** |

### 2.1 What the U1 comparison found

- **Six symbol names are short forms of the XML names**: pin 3 `PC14` /
  `PC14-OSC32_IN`, 4 `PC15` / `PC15-OSC32_OUT`, 5 `PF0` / `PF0-OSC_IN`,
  6 `PF1` / `PF1-OSC_OUT`, 7 `PG10` / `PG10-NRST`, 46 `PB8` / `PB8-BOOT0`.
  Same pin numbers, so no electrical effect; only datasheet lookups are affected.
- **Pin 49 (`VSS`) has no counterpart in the XML.** ST's data set stops at
  48 pins — the exposed pad is not modelled, so `VSS` here is the EP, exactly
  as `DESIGN.md` §5.1 states ("no separate VSS pins on UFQFPN48").
- **Two "system" functions are named in the XML but absent from its signal
  list**: `NRST` (pin 7) and `BOOT0` (pin 46). The XML only carries AF-selectable
  signals plus `GPIO`; this is a data-set property, not a design problem.
- **All AF numbers in `DESIGN.md` §5 re-check clean**: SPI1_SCK/PA5 = AF5,
  SPI1_MOSI/PA7 = AF5, SPI2_SCK/PB13 = AF5, SPI2_MOSI/PB15 = AF5,
  SPI3_SCK/PB3 = AF6, SPI3_MOSI/PB5 = AF6, FDCAN1_RX/PA11 = AF9,
  FDCAN1_TX/PA12 = AF9, USART1_TX/PA9 = AF7, USART1_RX/PA10 = AF7,
  SWDIO/PA13 = AF0, SWCLK/PA14 = AF0, TIM2_CH1/PA0 = AF1. `ADC1_IN2` on PA1 is
  an analog function and has no AF row, which matches the XML (present) and the
  table (absent).
- **No "required AF missing from the XML" case exists** among the signals in
  use: every `SPI*`, `FDCAN1_*`, `USART1_*`, `SYS_JTMS-SWDIO`,
  `SYS_JTCK-SWCLK`, `RCC_OSC_IN/OUT` and `ADC1_IN2` appears in the XML signal
  list of its pin.
- Note on the DFN number: PB3 is `SPI3_SCK` (AF6) and also carries
  `SYS_JTDO-SWO` (AF0), so the SWO trace is unavailable while SPI3 drives the
  pin — already recorded in `DESIGN.md` §5.2.

## 3. U2, U3, Y1, D1, D2, D3, J1

"Net members" repeats `pins.md`; `GND` is the global ground plane (see
`pins.md` for the full list).

### U2 — LM5164-Q1 (HSOP-8-1EP)

| Pin | Symbol pin name | Pad | Net | Net members | Note |
|---:|---|---:|---|---|---|
| 1 | GND | 1 | GND | global |  |
| 2 | VIN | 2 | VIN | C1.1, C2.1, D1.1, D2.1, R4.1, R6.1 |  |
| 3 | EN/UVLO | 3 | UVLO | C6.1, R4.2, R5.1 |  |
| 4 | RON | 4 | RON | R3.1 |  |
| 5 | FB | 5 | FB | R1.2, R2.1 |  |
| 6 | PGOOD | 6 | PGOOD | TP9.1 |  |
| 7 | BST | 7 | BST | C5.1 |  |
| 8 | SW | 8 | SW | C5.2, L2.1 |  |
| 9 | EP | 9, 9 | GND | global | EP is **two** pads both numbered 9, plus 4 unnumbered GND via pads |

### U3 — TCAN330G (SOIC-8)

| Pin | Symbol pin name | Pad | Net | Net members | Note |
|---:|---|---:|---|---|---|
| 1 | TXD | 1 | CAN_TX | U1.34 |  |
| 2 | GND | 2 | GND | global |  |
| 3 | VCC | 3 | +3V3 | U1.1/23/35/48, C3.1, C4.1, C8.1, C9.1, R1.1, FB1.1, J2–J4.1, … |  |
| 4 | RXD | 4 | CAN_RX | U1.33 |  |
| 5 | SHDN | 5 | GND | global | tied low = normal operation ("Drive high for shutdown mode. Internal pull-down.", tcan334.pdf pin table) |
| 6 | CANL | 6 | CANL | L1.4, R8.2, R18.2 |  |
| 7 | CANH | 7 | CANH | L1.2, R8.1, R17.2 |  |
| 8 | S | 8 | CAN_SILENT | U1.17 | silent/listen-only, high = silent |

### Y1 — 8 MHz crystal

| Pin | Symbol pin name | Pad | Net | Net members | Note |
|---:|---|---:|---|---|---|
| 1 | 1 | 1 | HSE_IN | C10.1, U1.5 | symbol gives bare numbers, no functional name |
| 2 | 2 | 2 | HSE_OUT | C11.1, U1.6 |  |

Pad layout is wrong for the fitted part — see §6.

### D1 — SS36

| Pin | Symbol pin name | Pad | Net | Net members | Note |
|---:|---|---:|---|---|---|
| 1 | K | 1 | VIN | C1.1, C2.1, D2.1, R4.1, R6.1, U2.2 | cathode to the load |
| 2 | A | 2 | VIN_F | F1.2 | anode to the fused input → series reverse-polarity protection, orientation correct |

### D2 — SMBJ24A

| Pin | Symbol pin name | Pad | Net | Net members | Note |
|---:|---|---:|---|---|---|
| 1 | A1 | 1 | VIN | C1.1, C2.1, D1.1, R4.1, R6.1, U2.2 |  |
| 2 | A2 | 2 | GND | global |  |

Symbol drawn as `Device:D_TVS`, i.e. the **bidirectional** TVS (two opposed
triangles, pins `A1`/`A2`); the fitted `SMBJ24A` is unidirectional. Polarity
therefore exists only in the footprint (`Diode_SMD:D_SMB` pad 1 = cathode, and
pad 1 is on VIN). Electrically that is the intended clamp, but the schematic
cannot show the band — worth a part-number symbol if D2 is ever reviewed from
the schematic alone.

### D3 — PESD2CAN

| Pin | Symbol pin name | Pad | Net | Net members | Note |
|---:|---|---:|---|---|---|
| 1 | A1 | 1 | CANH_J | J1.3, L1.1, R17.1 |  |
| 2 | A2 | 2 | CANL_J | J1.4, L1.3, R18.1 |  |
| 3 | common | 3 | GND | global | `[VERIFY]` symbol is A–A–common; confirm against the PESD2CAN datasheet that the common terminal is the cathode side before trusting GND here |

### J1 — 12V/GND/CANH/CANL

| Pin | Symbol pin name | Pad | Net | Net members | Note |
|---:|---|---:|---|---|---|
| 1 | Pin_1 | 1 | +12V_IN | F1.1 |  |
| 2 | Pin_2 | 2 | GND | global |  |
| 3 | Pin_3 | 3 | CANH_J | D3.1, L1.1, R17.1 |  |
| 4 | Pin_4 | 4 | CANL_J | D3.2, L1.3, R18.1 |  |

`Conn_01x04` gives generic `Pin_n` names; the connector's real assignment is
only in the Value field and in `pcb/README.md`. 4 SMD pads, no paste window
(open item A2).

## 4. Values, DNP, BOM and CPL state

Schematic flags are read from each symbol's `dnp` / `in_bom` / `in_pos_files`.
There is **no CPL / pick-and-place file in the repo** (open item A8); the
"CPL" column therefore says what the export *would* do today.

| Ref | Value | MPN | DNP (schematic) | In BOM | In pos file | `BOM.md` row | CPL effect today |
|---|---|---|---|---|---|---|---|
| R1 | 100k | RC0402FR-07100KL | no | yes | yes | own line | placed |
| R2 | 57.6k | RC0402FR-0757K6L | no | yes | yes | own line | placed |
| R3 | 27.5k | RC0402FR-0727K5L | no | yes | yes | own line | placed |
| R4 | 1M | RC0402FR-071ML | no | yes | yes | own line | placed |
| R5 | 300k | RC0402FR-07300KL | no | yes | yes | own line | placed |
| R6 | 100k | RC0402FR-07100KL | no | yes | yes | own line | placed |
| R7 | 15k | RC0402FR-0715KL | no | yes | yes | own line | placed |
| R8 | 120R | RC0402FR-07120RL | **yes** | yes | yes | `R8 … DNP` | **placed unless excluded** |
| R14 | 0R | RC0402JR-070RL | no | yes | yes | `R14-R18 0R` | placed |
| R15 | 0R | RC0402JR-070RL | no | yes | yes | `R14-R18 0R` | placed |
| R16 | 0R | RC0402JR-070RL | no | yes | yes | `R14-R18 0R` | placed |
| R17 | 0R | RC0402JR-070RL | no | yes | yes | `R14-R18 0R` | placed (L1 bypass) |
| R18 | 0R | RC0402JR-070RL | no | yes | yes | `R14-R18 0R` | placed (L1 bypass) |
| L1 | CMC | ACM2520-101-2P | **yes** | yes | yes | `L1 … DNP` | **placed unless excluded** |
| C10 | 10pF | GRM1555C1H100JA01D | no | yes | yes | `C10,C11 10pF` | placed |
| C11 | 10pF | GRM1555C1H100JA01D | no | yes | yes | `C10,C11 10pF` | placed |
| Y1 | 8MHz | ABM8-8.000MHZ-B2-T | no | yes | yes | own line | placed — **but footprint is wrong, §6** |

**DNP export risk (this is open item A3).** The DNP flag is set on the three
schematic symbols (C8, L1, R8) but **no footprint in `GaugeX.kicad_pcb` carries
the `dnp` attribute** — a parser pass over all 71 footprints finds only `smd`,
plus `exclude_from_pos_files` / `exclude_from_bom` on TP1–TP10 and H1–H4.
`kicad-cli pcb export pos --exclude-dnp` acts on the *board* footprint flag, so
as the files stand it would emit R8 and L1 as normal placements. Either sync
the board from the schematic or drop these two rows by hand before the first
CPL. (R17/R18 are correctly not DNP — they are the fitted CMC bypass.)

## 5. Y1 pad layout vs the ABM8 datasheet

| Item | Footprint in use: `Crystal:Crystal_SMD_3215-2Pin_3.2x1.5mm` | ABM8 (Abracon, rev 07-29-20) |
|---|---|---|
| Package | 3.2 × 1.5 nominal, **2 terminals** | 3.2 ± 0.20 × 2.5 ± 0.20 × 0.80 max, **4 terminals** |
| Terminal function | pins 1, 2 only | 1 and 3 = crystal; **2 and 4 = GND** |
| Part pad size | — | 1.2 ± 0.10 × 0.9 ± 0.10, gaps 0.9 (x) / 0.7 (y) → centres ±1.05 / ±0.80 |
| Footprint pad size | 1.00 × 1.80 mm | — |
| Footprint pad centres | x = ±1.25 mm, both on y = 0 | — |
| Recommended land | — | 4 pads 1.3 × 1.05, gap 1.0 (x) / 0.7 (y) → centres ±1.15 / ±0.875 |

**This is not only "the wrong size" — it shorts the oscillator.** Each 1.8 mm
tall pad spans y ∈ [−0.9, +0.9]. ABM8 terminal 1 (crystal) occupies
y ∈ [0.35, 1.25] at x ≈ −1.05 and terminal 4 (GND) occupies y ∈ [−1.25, −0.35]
at the same x. So footprint pad 1 (`HSE_IN`) overlaps both the crystal terminal
**and** a GND terminal; likewise pad 2 (`HSE_OUT`) overlaps terminal 3 and
terminal 2 (GND). Fitting the ABM8 on this footprint shorts HSE_IN→GND and
HSE_OUT→GND, so the HSE cannot start. The pads are also 0.2 mm too far apart in
x. Confirms A1 with numbers.

Closing A1 is a two-part change (needs approval, per `AGENTS.md` rule 3):

1. Footprint → `Crystal:Crystal_SMD_3225-4Pin_3.2x2.5mm` (pads 1.4 × 1.2 at
   ±1.1 / ±0.85 mm; pad numbering matches the ABM8 bottom view: 1 top-left,
   2 top-right, 3 bottom-right, 4 bottom-left).
2. Symbol → `Device:Crystal_GND24` (pins 1/3 crystal, 2/4 = GND). The current
   `Device:Crystal` has only two pins, so with a 4-pad footprint pads 2 and 4
   would have no net and would show up as unconnected.

## 6. Not covered here

- AF numbers were machine-read from the PDF; the anchors listed above were
  hand-checked, but pins with no net were not read row by row.
- `DESIGN.md` §5 cites "pages 73–74" for Table 13; the table actually runs
  through printed page 79 (it lists every port up to PG10). Documentation nit
  only — no value changes.
- Crystal load capacitance: the ABM8 ordering code `-B2-` carries no CL field,
  so the standard **18 pF** applies, while C10/C11 are 10 pF (CL ≈ 8 pF with
  ~3 pF stray). Already tracked as open item **B9**; not re-derived here.
- No Gerber, drill or CPL files exist yet, so no placement data was checked
  against a fab output.
