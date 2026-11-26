# GaugeX PCB — BOM (pre-schematic)

Prices are indicative, single-unit, USD, and **must be re-checked at order
time**. LCSC codes are assigned where the part is a known basic part; for ICs
use the MPN search. Everything marked `[VERIFY]` still needs a datasheet or
stock check.

## 1. Power / protection

| Ref | Value / MPN | Package | Qty | Mouser | LCSC | ~Unit | Notes |
|---|---|---|---:|---|---|---:|---|
| F1 | Littelfuse **0437.500WR**, 500 mA, 63 V | 1206 | 1 | 576-0437.500WR | search MPN | $0.65 | `[VERIFY]` |
| D1 | Vishay **SS36-E3/57T** | SMA | 1 | 625-SS36-E3/57T | search MPN | $0.36 | reverse protection |
| D2 | Littelfuse **SMBJ24A** | SMB | 1 | 576-SMBJ24A | search MPN | $0.36 | load dump |
| U2 | TI **LM5164QDDARQ1** | VSSOP-10 | 1 | 595-LM5164QDDARQ1 | search MPN | $3.50 | 100 V / 1 A buck `[VERIFY]` |
| U2-ALT | TI **TPS54360BQDDARQ1** (alternate) | HSOIC-8 | 0–1 | 595-TPS54360BQDDARQ1 `[VERIFY]` | search MPN | $4.50 | lower Vin (4.5 V), not fitted by default |
| L2 | Coilcraft **XAL5030-103MEC**, 10 µH ±20 %, AEC-Q200 | 5.3×5.3×3.0 | 1 | search MPN | search MPN | ~$1.60 | Isat / Irms / DCR `[VERIFY]`; load check in DESIGN §4.4 (0.70 A peak, 0.28 A rms) |
| C_in1 | 4.7 µF / 25 V X5R | 0805 | 1 | 81-GRM21BR61E475KA12L | C-`[VERIFY]` | $0.10 | |
| C_in2 | 100 nF / 50 V X7R | 0402 | 2 | 81-GRM155R71H104KA88D | **C1525** | $0.01 | |
| C_bulk | 10 µF / 25 V X5R | 1206 | 1 | 81-GRM31CR61E106KA12L | C-`[VERIFY]` | $0.18 | |
| C_out | 22 µF / 10 V X5R | 0805 | 2 | 81-GRM21BR61A226ME44L | C-`[VERIFY]` | $0.15 | |
| C_bst | 2.2 nF / 50 V | 0402 | 1 | generic | C-`[VERIFY]` | $0.01 | `[VERIFY]` per datasheet |
| R_RON | 27.5 kΩ 1 % | 0402 | 1 | generic | C-`[VERIFY]` | $0.01 | 300 kHz |
| R_FB1/2 | per LM5164 datasheet | 0402 | 2 | generic | C-`[VERIFY]` | $0.01 | `[VERIFY]` values |
| C_ff | per LM5164 datasheet | 0402 | 1 | generic | C-`[VERIFY]` | $0.01 | `[VERIFY]` |
| C_hold | 2× 100 µF / 25 V polymer (optional) | 6.3×6.3 | 0–2 | 667-25SVPF100M `[VERIFY]` | search MPN | $1.20 | front side, DNP by default |
| R_div1 | 100 kΩ 1 % | 0402 | 1 | generic | C-`[VERIFY]` | $0.01 | 12 V sense |
| R_div2 | 15 kΩ 1 % | 0402 | 1 | generic | C-`[VERIFY]` | $0.01 | |
| C_div | 100 nF / 50 V | 0402 | 1 | generic | **C1525** | $0.01 | |
| R_UV1 | 1 MΩ 1 % | 0402 | 1 | generic | C-`[VERIFY]` | $0.01 | EN/UVLO divider |
| R_UV2 | 300 kΩ 1 % | 0402 | 1 | generic | C-`[VERIFY]` | $0.01 | EN/UVLO divider |
| C_UV | 100 nF / 50 V | 0402 | 1 | generic | **C1525** | $0.01 | EN/UVLO filter `[VERIFY]` |
| C_NRST | 100 nF / 50 V | 0402 | 1 | generic | **C1525** | $0.01 | NRST to GND |

## 2. MCU / clock / debug

| Ref | Value / MPN | Package | Qty | Mouser | LCSC | ~Unit | Notes |
|---|---|---|---:|---|---|---:|---|
| U1 | ST **STM32G474CBU6** | UFQFPN48 7×7 | 1 | 511-STM32G474CBU6 | search MPN | $7.50 | 128 KB flash / 128 KB RAM `[VERIFY]` stock |
| Y1 | Abracon **ABM8-8.000MHZ-B2-T** | 3.2×2.5 | 1 | 815-ABM8-8.000MHZ-B2-T | search MPN | $0.80 | 8 MHz; schematic uses a 3.2×1.5 2-pin footprint placeholder `[VERIFY]` |
| C_HSE1/2 | 10 pF (value from crystal CL) | 0402 | 2 | generic | C-`[VERIFY]` | $0.01 | `[VERIFY]` |
| C_VDD1..4 | 100 nF / 50 V | 0402 | 4 | generic | **C1525** | $0.01 | one per VDD |
| C_VDDA1 | 1 µF / 16 V | 0402 | 1 | generic | C-`[VERIFY]` | $0.03 | |
| C_VDDA2 | 100 nF / 50 V | 0402 | 1 | generic | **C1525** | $0.01 | |
| C_VREF1 | 1 µF / 16 V | 0402 | 1 | generic | C-`[VERIFY]` | $0.03 | `[VERIFY]` |
| C_VREF2 | 100 nF / 50 V | 0402 | 1 | generic | **C1525** | $0.01 | |
| C_VBAT | 100 nF / 50 V | 0402 | 1 | generic | **C1525** | $0.01 | |
| FB1 | ferrite bead 600 Ω @100 MHz | 0603 | 1 | generic | C-`[VERIFY]` | $0.05 | VDDA |
| R_BOOT | 10 kΩ 1 % | 0402 | 1 | generic | C-`[VERIFY]` | $0.01 | BOOT0 pulldown |
| R_SWD | 100 kΩ (optional) | 0402 | 1 | generic | C-`[VERIFY]` | $0.01 | NRST pull-up if needed |
| D4 | 0402 LED, green | 0402 | 1 | generic | C-`[VERIFY]` | $0.05 | status |
| R_LED | 1 kΩ 1 % | 0402 | 1 | generic | C-`[VERIFY]` | $0.01 | `[VERIFY]` value |

## 3. CAN

| Ref | Value / MPN | Package | Qty | Mouser | LCSC | ~Unit | Notes |
|---|---|---|---:|---|---|---:|---|
| U3 | TI **TCAN330GDR** (silent mode, CAN FD) | SOIC-8 | 1 | 595-TCAN330GDR `[VERIFY]` | search MPN | $2.20 | 3.3 V, `S` pin listen-only `[VERIFY]` |
| D3 | Nexperia **PESD2CAN,115** | SOT-23 | 1 | 771-PESD2CAN,115 | search MPN | $0.40 | |
| L1 | common-mode choke footprint | 2520 | 1 DNP | e.g. 871-ACM2520-101-2P `[VERIFY]` | search MPN | $0.80 | DNP |
| R_T | 120 Ω 1 % | 0402 | 1 DNP | generic | C-`[VERIFY]` | $0.01 | solder jumper open |
| JP_T | solder jumper, 2-pad | 0402 | 1 | generic | C-`[VERIFY]` | $0.02 | termination enable |

Alternative CAN transceiver: **SN65HVD230QDRQ1** (Mouser 595-SN65HVD230QDRQ1) `[VERIFY]`.

## 4. Connectors

| Ref | Value / MPN | Package | Qty | Mouser | LCSC | ~Unit | Notes |
|---|---|---|---:|---|---|---:|---|
| J1 | **4 SMD solder pads** (no connector), 2.0 × 2.6 mm, 2.54 mm pitch | pad, 2.54 mm | 1 | n/a | n/a | $0 | 12V/GND/CAN_H/CAN_L flying lead; no drill, no paste, nothing below the board |
| J1-cable | Molex **43025-0400** housing + **43030-0007** terminals ×4 + TPA | cable end | 1 kit | 538-43025-0400 / 538-43030-0007 | search MPN | $2.00 | outside enclosure `[VERIFY]` |
| J2–J4 | JST **SM08B-SRSS-TB(LF)(SN)**, 8-pin right-angle | SMT | 3 | 306-SM08B-SRSSTB | search MPN | $0.90 | displays `[VERIFY]` |
| J5 | JST **SM04B-SRSS-TB(LF)(SN)**, 4-pin right-angle | SMT | 1 | 306-SM04B-SRSSTB | search MPN | $0.60 | buttons |
| TP1 | 1.27 mm test pads | pad | 8 | n/a | n/a | $0 | SWD/boot/USART |

## 5. Passives / jumpers

| Ref | Value | Package | Qty | Mouser | LCSC | ~Unit | Notes |
|---|---|---|---:|---|---|---:|---|
| R_BTN1/2 | 10 kΩ 1 % | 0402 | 2 | generic | **C25744** | $0.01 | pull-ups |
| C_BTN1/2 | 100 nF / 50 V | 0402 | 2 | generic | **C1525** | $0.01 | |
| R_BL1..3 | 0 Ω jumper | 0402 | 3 | generic | C-`[VERIFY]` | $0.01 | BL to 3V3 default |
| Q_BL | N-MOSFET footprint (DNP) | SOT-23 | 1 DNP | generic | C-`[VERIFY]` | $0.10 | optional PWM |
| R_BL_G | 10 kΩ | 0402 | 1 DNP | generic | C-`[VERIFY]` | $0.01 | gate pulldown |
| R_ST1..3 | 0 Ω / DNP option | 0402 | 3 | generic | C-`[VERIFY]` | $0.01 | series SPI resistors |
| C_BL | 100 nF | 0402 | 1 | generic | **C1525** | $0.01 | |

## 6. Not fitted / options

| Ref | Option | Default |
|---|---|---|
| L1 | CAN common-mode choke | DNP |
| R_T + JP_T | 120 Ω termination | open |
| C_hold | cranking hold-up polymer | DNP |
| Q_BL | backlight PWM MOSFET | DNP |
| D4 | status LED | fitted |
| R_ST1..3 | SPI series resistors | 0 Ω or DNP |

## 7. Cost summary (approx, 1 board)

| Group | ~USD |
|---|---:|
| Power / protection | $7.00 |
| MCU / clock / debug | $8.60 |
| CAN | $2.60 |
| Connectors (J2–J5 + J1 cable kit; no board J1 header) | $5.30 |
| Passives / jumpers | $0.60 |
| **Board BOM total** | **~$24.1** |

**The 3 GC9A01 displays are NOT included** in this total. They are a separate
purchase (typically ~$8–12 each, `[VERIFY]`).

### 7.1 Project cost estimate (one unit, excluding enclosure)

| Item | ~USD |
|---|---:|
| Board BOM (electronics only) | $24 |
| PCB fabrication (4-layer, 50×40, 5 pcs, ENIG) | $20–30 total |
| SMT assembly (one side, ~50 placements) | $30–60 |
| **3 × GC9A01 displays (not included above)** | **$24–36** |
| Wire, Micro-Fit pigtail, heat-shrink | included in BOM line |
| Shipping, taxes, enclosure hardware | not included |

Prices are indicative and must be re-checked at order time.

## 8. Procurement notes

- LCSC codes for ICs are intentionally left as “search MPN”; assign them in
  the schematic/BOM tool after the symbol is chosen.
- Prefer JLCPCB basic parts for 0402 resistors/capacitors.
- The MCU and buck are the two parts most likely to have stock/price swings;
  check both before freezing the schematic.
- Alternative MCU if 128 KB flash is tight: **STM32G474CEU6** (512 KB),
  pin-compatible UFQFPN48 `[VERIFY]`.
- Alternative buck if cranking ride-through is required:
  **TPS54360BQDDARQ1** (4.5 V min input) `[VERIFY]`. This is the preferred
  fallback; a P-FET is not sufficient (still ~5.95 V < 6.0 V).
- Pre-crimped 4-pin Micro-Fit cable assemblies may be cheaper/cleaner than
  loose housing + terminals; check before ordering `[VERIFY]`.
