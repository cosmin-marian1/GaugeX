> **Archived 2026-11-27.** Superseded by `pcb/DESIGN.md` (design) and `pcb/OPEN-ITEMS.md` (open checks). This is the original requirements/decision log, kept for traceability only.

# GaugeX — PCB specification (input for the planner)

Status: concept, not built physically. Tags: [DECIDED] = fixed, [VERIFY] = check in datasheet before using, [DECIDE] = open choice, ask me.

## 1. Goals and constraints
- Board 50 x 40 mm, 1.6 mm. 4 layers preferred, 2 layers only if routing is clean. 0402 passives. [DECIDED]
- 4 mounting holes M2.5 on a 44 x 34 mm pattern, centered (matches the enclosure: pcb_hole_x=44, pcb_hole_y=34). [DECIDED]
- Max component height on the back side: **3.0 mm** (enclosure clearance is 3.4 mm; 0.4 mm margin). Front side: **5.0 mm** to the cavity front wall. [DECIDED]
- 12 V automotive input from **switched ignition (Kl.15)**, dashboard ambient up to ~85 C in sun: parts rated >= 105 C where possible, never below 85 C. [DECIDED]
- Low cost and assembly-friendly (JLCPCB/LCSC, prefer basic/preferred parts).
- Reads CAN from the car, listen-only by default, never disturbs the bus.
- No 5 V rail: everything runs on one 3.3 V rail (avoids an LDO dropping 12 V -> 5 V -> 3.3 V and heating in a hot dash). [DECIDED]

## 2. Block diagram
```
J1 (12V, GND, CAN_H, CAN_L)
 |-- 12V --> F1 fuse --> D1 reverse Schottky --> D2 TVS --> C_in --> U2 buck --> 3V3 rail
 |                                                    '--> R divider --> MCU ADC (supply sense)
 '-- CAN_H/CAN_L --> D3 ESD --> (L1 CMC, optional) --> U3 CAN transceiver --> MCU FDCAN1
3V3 rail --> U1 MCU, U3, J2/J3/J4 (3 displays), J5 (2 buttons), SWD pads
U1 --SPI1/2/3 + CS/DC--> J2, J3, J4
```

## 3. Components
| Ref | Function | Candidate | Package | Notes | Status |
|---|---|---|---|---|---|
| U1 | MCU | **STM32G474CBU6** | UFQFPN48 7x7 | 128 KB flash, 128 KB RAM, FDCAN, 3 SPI. Exact orderable code and stock to be confirmed. | [DECIDED] |
| Y1 | HSE crystal | 8 MHz, 3.2x2.5 mm | SMD | Stable clock for CAN timing; load caps from crystal datasheet. | [VERIFY] |
| U2 | Buck 12V -> 3.3V | **LM5164-Q1** (100 V, 1 A) | VSSOP-10 | 6 V..100 V input, 50 ns min on-time. Must survive load dump after TVS clamp (~39 V). | [DECIDED] |
| F1 | Input fuse | **500 mA SMD fuse, >= 32 V** | 1206 | | [DECIDED] |
| D1 | Reverse polarity | **SS36 Schottky** (60 V, 3 A) | SMA | Series diode, drop ~0.4 V. P-FET ideal diode only if cranking ride-through requires it. | [DECIDED] |
| D2 | Load dump / transient | SMBJ24A TVS | SMB | Placed AFTER D1, so reverse connection is blocked, not shorted. Clamp ~38.9 V. | [VERIFY] |
| U3 | CAN transceiver | **TCAN330G** (3.3 V, silent mode) or SN65HVD230Q1 fallback | SOIC-8 | Must be 3.3 V-supply (no 5 V rail). TCAN330G has the `S` pin for silent/listen-only; TCAN334's `STB` is standby with wake, not continuous receive. Check automotive `-Q1` availability. | [DECIDED] |
| D3 | CAN ESD | PESD2CAN or NUP2105L | SOT-23 | Close to J1. | [VERIFY] |
| L1 | CAN common-mode choke | footprint only, DNP | SMD | Optional. | [DECIDED] |
| R_T | CAN termination 120 ohm | footprint with solder jumper, open by default | 0402 | The car's bus is already terminated. | [DECIDED] |
| R_div | 12 V sense divider | **100k / 15k + 100 nF** to ADC pin | 0402 | ~1/7.7 ratio; checks supply and ignition. | [DECIDED] |
| C_* | Decoupling | 100 nF per VDD pin, 4.7 uF bulk, VDDA via ferrite bead + 1 uF + 100 nF | 0402 / 0603 | Per STM32G474 datasheet / hardware design guide. | [VERIFY] |
| J1 | Power + CAN connector | **4 THT solder pads at the top edge** + soldered pigtail; **Micro-Fit 3.0 4-pin on the cable end** outside | pad + cable | 12V/GND/CAN_H/CAN_L, 2.54 mm pitch, strain-relief hole; pigtail dresses through the 20x8 back-plate slot. | [DECIDED] |
| J2-J4 | Display connectors (x3) | 8-pin 1.0 mm JST-SH, right-angle | SMD | VCC, GND, SCL, SDA, DC, CS, RST, BL. Right-angle keeps mated height low. | [VERIFY] |
| J5 | Buttons (off-board, on back plate) | 4-pin JST-SH right-angle: BTN1, BTN2, GND, GND | SMD | 10k pull-up + 100 nF each, ESD-tolerant. | [DECIDED] |
| TP | SWD + boot pads | **1.27 mm pads**: 3V3, SWDIO, SWCLK, NRST, GND, USART1 TX/RX, BOOT0 | 1.27 mm pads | No Tag-Connect. | [DECIDED] |
| D4 | Status LED | **0402 LED + resistor included** | 0402 | | [DECIDED] |

Display backlight: BL pins default tied to 3V3 via 0 ohm jumper. If the module's BL input is transistor-driven (low current), one MCU PWM pin may drive all three. Do not drive 3 backlights directly from one GPIO. [VERIFY with the real module]

## 4. Pin allocation (STM32G474CBU6, UFQFPN48)

Pin numbers are from `STM32G474C(B-C-E)Ux.xml` (ST open pin data). AF numbers are verified against DS12288 Table 13 (pages 73–74).

| Function | Pin | Number | AF | Notes |
|---|---|---|---|---|
| SPI1 SCK | PA5 | 13 | AF5 | display 1 |
| SPI1 MOSI | PA7 | 15 | AF5 | display 1 |
| SPI1 CS | PA4 | 12 | GPIO | display 1 |
| SPI1 DC | PA3 | 11 | GPIO | display 1 |
| SPI2 SCK | PB13 | 26 | AF5 | display 2 |
| SPI2 MOSI | PB15 | 28 | AF5 | display 2 |
| SPI2 CS | PB12 | 25 | GPIO | display 2 |
| SPI2 DC | PB14 | 27 | GPIO | display 2 |
| SPI3 SCK | PB3 | 41 | AF6 | display 3; PB3 = SWO, SWD-only debug |
| SPI3 MOSI | PB5 | 43 | AF6 | display 3 |
| SPI3 CS | PB6 | 44 | GPIO | display 3 |
| SPI3 DC | PB7 | 45 | GPIO | display 3 |
| Display RST (shared x3) | PA2 | 10 | GPIO | |
| Backlight PWM (optional) | PA0 | 8 | AF1 (TIM2_CH1) | |
| FDCAN1 RX | PA11 | 33 | AF9 | |
| FDCAN1 TX | PA12 | 34 | AF9 | |
| CAN silent/standby | PB0 | 17 | GPIO | drive high for listen-only (TCAN330G `S` pin) |
| Buttons | PB1, PB2 | 18, 19 | GPIO/EXTI | |
| 12 V sense | PA1 | 9 | ADC1_IN2 | |
| HSE crystal | PF0 / PF1 | 5 / 6 | OSC | |
| SWD | PA13 / PA14 | 36 / 37 | SWD | |
| USART1 TX / RX | PA9 / PA10 | 31 / 32 | AF7 | test pads only |
| BOOT0 | PB8 | 46 | BOOT0 | 10k pulldown; PB8 also FDCAN1_RX but PA11 is used |
| LED | PB9 | 47 | GPIO | |
| VDDA | VDDA | 21 | power | ferrite + 1 uF + 100 nF |
| VREF+ | VREF+ | 20 | power | tied to VDDA, 1 uF + 100 nF [VERIFY] |
| VDD | VDD | 23, 35, 48 | power | 100 nF each |
| VBAT | VBAT | 1 | power | 3V3, 100 nF |
| VSS | exposed pad + VSS pins | TBD | power | confirm in datasheet [VERIFY] |

No pin conflict found with the proposed allocation. SPI3 uses PB3/PB5 because PC12 (the third SPI3 pin) is not bonded in UFQFPN48; PC10/PC11 exist but are not a complete SPI3 set. FDCAN1 uses PA11/PA12, leaving PB8 as BOOT0.

## 5. Power budget (rough, all [VERIFY] against datasheets)
- MCU G474 at 170 MHz: ~40-55 mA (DS12288 Table 21)
- 3 displays (logic + backlight): ~75-135 mA
- CAN transceiver, worst case dominant: ~10-70 mA
- Misc (LED, dividers): ~5-10 mA
- Worst case on 3.3 V: ~279 mA (~0.92 W); input at ~85% efficiency: ~90 mA @ 12 V, ~180 mA @ 6 V
- Buck LM5164-Q1 is rated 1 A: margin >3x at worst case. Planner must produce a real table with min/typ/max.

## 6. Layout rules
- Stackup: L1 signal, L2 solid GND, L3 3V3 / power, L4 signal.
- Buck: input cap, switch node and inductor tight, on the connector side, small loop, away from crystal and SPI.
- SPI lines short, GND reference unbroken. CAN_H/CAN_L routed as a pair, ESD diode right at J1.
- Crystal close to MCU, guard GND around it, no routing underneath.
- Fillets / corner radius 2-3 mm, hole pattern 44 x 34 mm.
- J1 at board centre (x=0, y=+10) so it aligns with the enclosure's 20x8 back-plate slot.
- J2-J4 right-angle on the back side, cables exit sideways.

## 7. Known risks for the planner to address
- **Flash is 128 KB**: keep the UI library footprint small (no full LVGL theme/demo). STM32G474CE (512 KB) is the pin-compatible fallback if flash runs short. RAM warning removed.
- **Cranking dip**: LM5164-Q1 minimum VIN is 6 V. With SS36 drop, a 6 V connector dip becomes ~5.6 V at VIN, below the minimum; the 3.3 V rail will drop out. Extra input capacitance can only bridge short dips; see DESIGN.md. A P-FET ideal diode or TPS54360B-Q1 (4.5 V min) is the robust alternative.
- **Connector height**: J1 Micro-Fit is taller than the 3.0 mm back-side limit. It is mounted at the board centre so its body passes through the 20x8 back-plate slot; this must be verified with the real connector drawing and the enclosure CAD.
- **Power source**: switched ignition 12 V (Kl.15), not permanent battery, otherwise the cluster drains the battery. [DECIDED]
- OBD D-CAN on a BMW E90 sits behind a gateway: request/response PIDs only, no full broadcast. A real tap on PT-CAN/K-CAN changes the connector and wiring.

## 8. What I want from the planner (step by step, no KiCad yet)
1. `pcb/DESIGN.md`: block diagram, pin table checked against the datasheet AF table, power budget, height check, cranking and min-on-time checks.
2. BOM with LCSC / Mouser part numbers and prices, with alternatives for [DECIDE] items.
3. Ask me questions about every [DECIDE] before moving on.
4. Only after I approve: schematic as code (SKiDL) or KiCad, then `kicad-cli sch erc`.
No routing, no firmware.

## 9. Documents to read (small, on demand)
Read `docs/datasheets/INDEX.md` first, then open only what a step needs. Do NOT load a whole PDF.
| Part | Document | Sections needed |
|---|---|---|
| STM32G474CB | Datasheet **DS12288** (STM32G474xB/xC/xE) | Pinouts and pin description, alternate function table, electrical characteristics, UFQFPN48 |
| STM32G474CB pins | ST open pin data `STM32G474C(B-C-E)Ux.xml` | Pin names, package positions, availability |
| Hardware design | **Getting started with STM32G4 Series hardware development** (AN5093 or current G4 note) [VERIFY number] | Power supply, decoupling, VDDA/VREF+, crystal, boot |
| Buck | LM5164-Q1 datasheet (SNVSB51C) | Pin config, typical application, on-time, component selection, layout |
| CAN transceiver | TCAN33x datasheet (TCAN330/334/337) / SN65HVD230Q1 | Pin functions, typical application, layout |
| Display | GC9A01 module datasheet / vendor wiki | Module pinout only |

Reference manual RM0440 is not needed for the schematic. It is for firmware later, by chapter (FDCAN, SPI, DMA).
