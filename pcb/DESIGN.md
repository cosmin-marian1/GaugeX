# GaugeX PCB — DESIGN

Status: pre-schematic. Everything not confirmed from a datasheet is marked
`[VERIFY]`. No KiCad project or routing yet.

## 1. Scope

- Board: **50 × 40 × 1.6 mm**, 4-layer preferred.
- Mounting: 4 × M2.5 on a **44 × 34 mm** pattern, centred.
- Enclosure: compact 3-gauge pod v2. PCB sits behind the centre tube.
- Input: switched ignition **12 V (Kl.15)**, single **3.3 V** rail.
- CAN: listen-only by default.
- MCU: **STM32G474CBU6**, UFQFPN48, 128 KB flash / 128 KB RAM.
- No routing, no firmware in this phase.

## 2. Mechanical interface

| Item | Value | Source |
|---|---:|---|
| PCB outline | 50 × 40 mm | enclosure `pcb_w × pcb_h` |
| PCB thickness | 1.6 mm | spec |
| Mounting holes | 4 × M2.5, 44 × 34 mm | enclosure `pcb_hole_x/y` |
| PCB front face to cavity front wall | 5.0 mm | enclosure `CAVITY_FRONT_Z` / `PCB_Z` |
| PCB back face to back plate | **3.4 mm** | enclosure `WEDGE_BACK_Z` / `PCB_Z` |
| Back-side component limit | **3.0 mm** | decided, 0.4 mm margin |
| Back-plate cable slot | **20 × 8 mm at x=0, y=+10** | enclosure `CABLE_SLOT_W/H/Y` |
| Corner radius | 2.5 mm | proposed |

### J1 — solder pads, pigtail, external Micro-Fit

There is **no PCB-mounted power connector**. The board has **4 through-hole
solder pads** on the top edge:

| Pad | Net | Position |
|---|---|---|
| 1 | 12V | top edge, 2.54 mm pitch |
| 2 | GND | |
| 3 | CAN_H | |
| 4 | CAN_L | |

Proposed: 1.0 mm drill / 2.0 mm annular pad, plus a 2 mm strain-relief hole
nearby for a zip tie. A short **pigtail** is soldered to the pads, dressed to
the enclosure's **20 × 8 mm** back-plate slot at `y=+10`, and terminated
outside in a **Micro-Fit 3.0 4-pin receptacle**. The mating plug/harness stays
outside the enclosure; no tall connector is mounted on the PCB.

This removes the 9.9 mm Micro-Fit body from the cavity entirely. The only
height contribution on the board is the solder joint and the wire, which lie
flat.

## 3. Block diagram

```text
J1 12V/GND/CANH/CANL
  │
  ├─ 12V ─ F1 0.5A ─ D1 SS36 ─ D2 SMBJ24A ─ C_in ─ U2 LM5164-Q1 ─ +3V3
  │                                      │
  │                                      └─ R_div 100k/15k ─ PA1 (ADC)
  │
  └─ CANH/CANL ─ D3 PESD2CAN ─ (L1 CMC DNP) ─ U3 TCAN330G ─ PA11/PA12 (FDCAN1)
                                                       └─ PB0 (silent)

+3V3 ─ U1 STM32G474CBU6
     ├─ SPI1 ─ J2 display 1
     ├─ SPI2 ─ J3 display 2
     ├─ SPI3 ─ J4 display 3
     ├─ PB1/PB2 ─ J5 buttons
     ├─ SWD/boot pads
     └─ PB9 ─ D4 status LED
```

## 4. Power architecture

### 4.1 Input protection

| Ref | Part | Function |
|---|---|---|
| F1 | 500 mA, 1206, ≥32 V | input fuse |
| D1 | SS36 (60 V / 3 A, SMA) | reverse-polarity Schottky |
| D2 | SMBJ24A (SMB) | load-dump / transient clamp (~38.9 V) |
| C_in | 4.7 µF / 25 V 0805 + 100 nF 0402 | input decoupling |
| R_div | 100 k / 15 k + 100 nF | 12 V sense to PA1 |

D2 is after D1, so a reverse-connected battery is blocked instead of clamped.

### 4.2 Buck — LM5164-Q1

| Item | Value | Status |
|---|---|---|
| Input range | 6 V … 100 V | datasheet |
| Output | 3.3 V, up to 1 A | decided |
| Switching frequency | 300 kHz | proposed |
| R_RON | 27.5 kΩ (3.3 × 2500 / 300) | `[VERIFY]` E-series value |
| Inductor | 10 µH, 5 × 5 × 2.0 mm, Isat ≥ 2.5 A | `[VERIFY]` |
| Output caps | 2 × 22 µF / 10 V 0805 + 100 nF | `[VERIFY]` |
| Bootstrap cap | 2.2 nF | `[VERIFY]` per datasheet |
| Feedback | 3.3 V divider per datasheet | `[VERIFY]` |

### 4.3 Power budget

| Load | Min (mA) | Typ (mA) | Max (mA) | Notes |
|---|---:|---:|---:|---|
| STM32G474 @ 170 MHz | 30 | 40 | 55 | Table 21, 85 °C, peripherals off + I/O estimate |
| 3 × display logic | 9 | 15 | 24 | 3–8 mA each `[VERIFY]` |
| 3 × backlight | 60 | 90 | 120 | 20–40 mA each `[VERIFY]` |
| CAN transceiver | 5 | 15 | 70 | worst-case dominant |
| LED + dividers + misc | 2 | 5 | 10 | |
| **Total @ 3.3 V** | **106** | **165** | **279** | |

- Max 3.3 V power: 279 mA × 3.3 V ≈ **0.92 W**.
- Input at 85 % efficiency: ≈ **1.08 W** → **90 mA @ 12 V**, **180 mA @ 6 V**.
- LM5164-Q1 1 A rating → **>3.5× margin** at the worst case.

## 5. MCU and pin allocation

**STM32G474CBU6**, UFQFPN48 7×7, 128 KB flash, 128 KB RAM.
Exact orderable code and stock: `[VERIFY]` LCSC/Mouser.

Clock: 8 MHz HSE + PLL to 170 MHz. HSE on PF0/PF1.

Pin numbers are from `STM32G474C(B-C-E)Ux.xml`; AF numbers are verified
against DS12288 Table 13 (pages 73–74).

| Function | Pin | No. | AF | Notes |
|---|---|---:|---|---|
| SPI1 SCK | PA5 | 13 | AF5 | display 1 |
| SPI1 MOSI | PA7 | 15 | AF5 | display 1 |
| SPI1 CS | PA4 | 12 | GPIO | display 1 |
| SPI1 DC | PA3 | 11 | GPIO | display 1 |
| SPI2 SCK | PB13 | 26 | AF5 | display 2 |
| SPI2 MOSI | PB15 | 28 | AF5 | display 2 |
| SPI2 CS | PB12 | 25 | GPIO | display 2 |
| SPI2 DC | PB14 | 27 | GPIO | display 2 |
| SPI3 SCK | PB3 | 41 | AF6 | display 3; PB3 = SWO |
| SPI3 MOSI | PB5 | 43 | AF6 | display 3 |
| SPI3 CS | PB6 | 44 | GPIO | display 3 |
| SPI3 DC | PB7 | 45 | GPIO | display 3 |
| Display RST shared | PA2 | 10 | GPIO | all 3 panels |
| Backlight PWM (optional) | PA0 | 8 | AF1 / TIM2_CH1 | |
| FDCAN1 RX | PA11 | 33 | AF9 | |
| FDCAN1 TX | PA12 | 34 | AF9 | |
| CAN silent | PB0 | 17 | GPIO | high = listen-only |
| Button 1 | PB1 | 18 | GPIO/EXTI | |
| Button 2 | PB2 | 19 | GPIO/EXTI | |
| 12 V sense | PA1 | 9 | ADC1_IN2 | divider |
| HSE | PF0 / PF1 | 5 / 6 | OSC | 8 MHz |
| SWDIO / SWCLK | PA13 / PA14 | 36 / 37 | SWD | |
| USART1 TX / RX | PA9 / PA10 | 31 / 32 | AF7 | test pads |
| BOOT0 | PB8 | 46 | BOOT0 | 10 k pulldown |
| LED | PB9 | 47 | GPIO | |

### 5.1 Power pins

| Pin | Connection |
|---|---|
| VDD 23, 35, 48 | +3V3, 100 nF each |
| VDDA 21 | +3V3 via ferrite bead, 1 µF + 100 nF |
| VREF+ 20 | tied to VDDA at the pin, 1 µF + 100 nF; VREF- is double-bonded to VSSA |
| VBAT 1 | +3V3, 100 nF |
| VSS | exposed pad (all VSS pads connect to it; no separate VSS pins on UFQFPN48) |

### 5.2 Pin conflict check

- SPI3 needs SCK/MISO/MOSI. PC10/PC11 exist on UFQFPN48 but **PC12 is not
  bonded**, so SPI3 must use **PB3/PB4/PB5**. Only SCK and MOSI are needed for
  the display (write-only), so PB3/PB5 are used; PB4 stays free.
- FDCAN1 uses **PA11/PA12**, leaving **PB8 = BOOT0**. PB8 is also
  FDCAN1_RX, but it is not used as CAN.
- PB3 is SWO. Debug is SWD-only; this is acceptable.
- USART1 is on PA9/PA10; PB6/PB7 are used as GPIO for display 3, not USART1.
- No other conflict found.

## 6. Interfaces

### 6.1 Displays (J2–J4)

8-pin JST-SH 1.0 mm, right-angle, on the **back side**:
`VCC, GND, SCL, SDA, DC, CS, RST, BL`.

- SCL/SDA are SPI SCK/MOSI (write-only; MISO not connected).
- CS and DC are individual GPIOs.
- RST is shared on PA2.
- BL: 0 Ω jumper to +3V3 by default. Do **not** drive three backlights from
  one GPIO. If the module has a transistor-driven BL input, a single PWM pin
  can drive all three through a transistor footprint (DNP).
- `[VERIFY]` real module: 8-pin vs 7-pin and BL polarity/current.

### 6.2 CAN (J1, U3)

**Transceiver: TCAN330G (SOIC-8, 3.3 V, silent mode).** This is a correction to
the earlier TCAN334 proposal: the TCAN334 pin 8 is **STB (standby with wake)**,
not silent mode. In standby the main receiver is off, so it cannot be used for
continuous listen-only reception. The **TCAN330/TCAN330G** has the `S` pin:
driver disabled, receiver fully operational — exactly what listen-only needs.

- TCAN330G: CAN FD capable (5 Mbps), same pinout as TCAN330.
- `CAN_SILENT` on PB0: high = silent/listen-only (`S` pin, internal pull-down).
- 120 Ω termination footprint with solder jumper, **open by default**.
- PESD2CAN at the J1 pads; CMC footprint L1 **DNP**.
- CAN_H/CAN_L routed as a differential pair.
- Automotive `-Q1` variant: `[VERIFY]` availability/price; if not available,
  TCAN330G is used for the prototype and SN65HVD230Q1 is the automotive
  fallback (check its `Rs` pin behavior).

### 6.3 Buttons (J5)

4-pin JST-SH: `BTN1, BTN2, GND, GND`. 10 k pull-up + 100 nF per input.

### 6.4 Debug / boot (TP)

1.27 mm pads: `3V3, SWDIO, SWCLK, NRST, GND, USART1_TX, USART1_RX, BOOT0`.

### 6.5 Status LED (D4)

0402 LED + series resistor from PB9 to GND (or +3V3, depending on selected
LED). `[VERIFY]` resistor value.

## 7. Component height check (3.0 mm back-side limit)

| Ref | Part | Side | Height | Verdict |
|---|---|---|---:|---|
| J1 | 4 THT solder pads + pigtail | back, through slot | 0 mm on board (wire lies flat) | passes `[VERIFY]` wire dress |
| J2–J4 | JST-SH 8-pin right-angle | back | ~2.9 mm | fits 3.0 mm `[VERIFY]` |
| J5 | JST-SH 4-pin right-angle | back | ~2.9 mm | fits `[VERIFY]` |
| L2 | 10 µH 5×5×2.0 | back | 2.0 mm | fits |
| C_in | 4.7 µF 25 V 0805 | back | ~1.4 mm | fits |
| C_bulk | 10 µF 25 V 1206 | back | ~1.6 mm | fits |
| D2 | SMBJ24A SMB | back | ~2.2 mm | fits |
| D1 | SS36 SMA | back | ~2.1 mm | fits |
| U1 | STM32G474CBU6 UFQFPN48 | back | ~0.9 mm | fits |
| U2 | LM5164-Q1 VSSOP-10 | back | ~1.1 mm | fits |
| Y1 | 8 MHz 3.2×2.5 | back | ~0.8 mm | fits |
| C_hold | 25 V polymer, 100–470 µF | front | 4.0–6.0 mm | **only front, verify** `[VERIFY]` |

**J1:** the board has only 4 through-hole pads and a soldered pigtail, so
there is no tall connector in the cavity. The wires are dressed to the 20 × 8
mm slot at `y=+10` and terminated outside in a Micro-Fit receptacle.
`[VERIFY]` wire gauge, bend radius and strain relief with the real harness.

**J2–J4:** right-angle bodies are ~2.9 mm, under the 3.0 mm limit. The mated
plug extends horizontally into the cavity, not toward the back plate.
`[VERIFY]` the actual mated height; if >3.0 mm, move the connectors to the
front side (5.0 mm limit) or use a lower-profile series.

**J5:** same right-angle JST-SH, 2.9 mm.

**Buck inductor and bulk caps:** 2.0 mm and ≤1.6 mm, back side, under 3.0 mm.

**Cranking hold-up capacitor:** any capacitor large enough to ride through a
real cranking dip is taller than 3.0 mm. It must go on the front side and
still may not fit 5.0 mm at the required capacitance; see section 8.

## 8. Cranking dip and LM5164-Q1

### 8.1 Datasheet facts

- LM5164-Q1 recommended operating input range: **6 V … 100 V** — datasheet
  **SNVSB51C, Section 5.3 “Recommended Operating Conditions”, page 4**.
- Minimum controllable on-time **50 ns** — datasheet **SNVSB51C, Section 6.1
  “Overview”, page 9** and **Section 6.3.5 “On-Time Generator”, page 12**.
- SS36 forward drop at ~0.15 A: **~0.35 V** `[VERIFY]` datasheet curve.

### 8.2 What happens at a 6 V dip

```text
J1 6.0 V − D1 SS36 0.35 V = 5.65 V at VIN
LM5164-Q1 minimum VIN = 6.0 V
→ converter is in dropout / UVLO
→ +3V3 follows the falling input; MCU browns out and resets
```

So with the selected SS36 + LM5164-Q1 combination, a 6 V cranking dip is
**not** ridden through. This is a real limitation, not a layout issue.

A P-FET ideal diode is **not** an acceptable fix either: even with a near-zero
drop, the harness/connector/input path still leaves about **5.95 V**, below
the 6.0 V minimum. The decision is therefore to **accept the reset** and make
it clean.

### 8.3 Input capacitance

Rough hold-up calculation:

```text
Pout(max) ≈ 0.95 W, η ≈ 0.85 → Pin ≈ 1.12 W
Iin at 6.5 V ≈ 172 mA
C = Iin × Δt / ΔV
```

| Dip duration | ΔV = 4 V | Required C |
|---|---:|---:|
| 5 ms | 4 V | ~215 µF |
| 10 ms | 4 V | ~430 µF |
| 20 ms | 4 V | ~860 µF |

A 25 V polymer/electrolytic of 430–860 µF is physically much taller than the
5.0 mm front clearance and wider than the available board area. **Extra input
capacitance alone is not a practical fix in this enclosure.** The input
capacitance is therefore sized for buck stability, not for cranking hold-up:

- C_in: 4.7 µF / 25 V 0805 + 100 nF.
- C_bulk: 10 µF / 25 V 1206.
- Optional C_hold 100 µF / 25 V polymer on the **front side**, DNP by default;
  it only shortens the droop, it does not guarantee ride-through.

### 8.4 Decision: accept reset, keep an alternate buck

- **Accepted:** the 3.3 V rail will drop during a 6 V cranking dip and the MCU
  will reset.
- Keep **TPS54360B-Q1** (4.5 V minimum input) in the BOM as the alternate if
  cranking ride-through becomes mandatory later.
- Do **not** use the P-FET as a cranking fix.
- `[VERIFY]` the car's actual cranking profile (duration and minimum voltage).

### 8.5 Clean-reset strategy

Hardware:

- Configure the MCU **BOR to level 4**: 2.90 V rising / 2.81 V falling (typ),
  2.85–2.95 V / 2.76–2.86 V over temperature (datasheet DS12288, Table 19,
  page 85–86). This is the highest BOR level and ensures a defined reset before
  the core can execute from a drooping rail.
- **NRST:** 100 nF to GND close to the pin (the internal pull-up remains).
- **BOOT0:** 10 kΩ pulldown; no boot straps that could float during a dip.
- Backlight default: 0 Ω to 3V3 means the display is lit as soon as 3.3 V is
  present. If a visible flash during reset is unacceptable, fit the optional
  **Q_BL** MOSFET and drive BL from PA0 with a gate pulldown (default off).
  `[VERIFY]` with the real module.
- No external supervisory IC is required; the MCU BOR plus the buck UVLO is
  sufficient for a clean reset.

Firmware (requirements for the later phase):

- **No flash writes at boot.** The boot path is read-only; defer calibration
  or logging writes until the rail has been stable for ≥ 500 ms and the
  ignition state is valid.
- **Fast boot:** start on HSI16, configure the minimum peripherals, then switch
  to HSE/PLL. Target < 100 ms to first display frame. Do not wait for CAN or
  optional hardware before showing a safe screen.
- On reset, all GPIOs default to a safe state; display CS/DC/RST and BL must
  not produce a visible glitch.
- Detect a brownout/reset cause and skip non-essential self-tests after a
  cranking reset.

### 8.6 LM5164-Q1 UVLO hysteresis (chatter check)

Datasheet SNVSB51C, **Section 5.5 “Electrical Characteristics”, page 5** and
**Section 6.3.9 “Enable/Undervoltage Lockout”, page 13**:

| Parameter | Min | Typ | Max |
|---|---:|---:|---:|
| EN/UVLO rising | 1.45 V | 1.50 V | 1.55 V |
| EN/UVLO falling | 1.35 V | 1.40 V | 1.44 V |

Typical hysteresis is **0.10 V**; worst-case is only **0.01 V**. That is too
small to rely on if EN/UVLO is tied directly to VIN. Use the precision divider:

```text
R_UV1 = 1 MΩ, R_UV2 = 300 kΩ
VIN_on  = 1.5 × (1 + 1M/300k) = 6.50 V
VIN_off = 1.4 × (1 + 1M/300k) = 6.07 V
Hysteresis ≈ 0.43 V typ, ≈ 0.043 V worst case
```

- Turn-off at ~6.07 V, turn-on at ~6.50 V: during a cranking dip the converter
  stays off until the input recovers, so there is **no repeated retry/chatter**.
- Add a **100 nF** from EN/UVLO to GND (and optionally 10 kΩ series) to filter
  noise; `[VERIFY]` values against the final divider.
- The LM5164-Q1 has **no hiccup mode**: it stops switching on UVLO and restarts
  with its 3 ms soft-start when EN/UVLO rises again. With the divider above,
  this is a single clean restart, not a burst of retries.

## 9. LM5164-Q1 minimum on-time

Datasheet facts (LM5164-Q1, **SNVSB51C**):

- Minimum controllable on-time: **50 ns** — Section 6.1, page 9, and
  Section 6.3.5, page 12.
- On-time: `tON = R_RON / (VIN × 2.5)` (µs, kΩ, V) — Section 6.3.5, page 12.
- Frequency: `FSW = VOUT × 2500 / R_RON` (kHz, V, kΩ) — Section 6.3.5, page 12.
- Programmed on-time examples: Section 5.5, page 5, TIMING (RON) table.

For 3.3 V output and **300 kHz**:

```text
R_RON = 3.3 × 2500 / 300 = 27.5 kΩ
```

| VIN | tON | vs 50 ns |
|---:|---:|---|
| 6 V | 1.83 µs | OK |
| 13.5 V (nominal) | 815 ns | OK |
| **39 V (SMBJ24A clamp)** | **282 ns** | **>5× margin** |
| 100 V (absolute) | 110 ns | >2× margin |

Maximum VIN at 300 kHz before frequency reduction:

```text
VIN(max) = VOUT / (tON(min) × FSW) = 3.3 / (50 ns × 300 kHz) = 220 V
```

Conclusion: **the 50 ns minimum on-time is not a limitation** at the TVS
clamp voltage or even at 100 V. 300 kHz is a safe choice.

## 10. Layout rules for the later phase

- 4-layer stackup: L1 signal, L2 solid GND, L3 +3V3/power, L4 signal.
- Buck input loop (C_in, D2, U2 VIN, SW, L2) as small as possible; keep away
  from Y1 and SPI.
- CAN pair 120 Ω differential, ESD at J1.
- Crystal close to U1; GND guard; no traces underneath.
- J1 solder pads on the top edge at x=0; pigtail dressed to the 20×8 slot at y=+10.
- J2–J4 right-angle at board edges, cables exit sideways toward tube notches.
- Keep all back-side parts ≤ 3.0 mm; keep front-side parts ≤ 5.0 mm.

## 11. Open items

1. AF numbers and VSS/VREF+ pin mapping verified in DS12288; re-check only if the pin allocation changes.
2. `[VERIFY]` VREF+/VDDA decoupling values against the G4 hardware design note.
3. `[VERIFY]` J1 pigtail wire gauge, bend radius and strain relief through the 20×8 slot.
4. `[VERIFY]` J2–J4 mated height; 7-pin vs 8-pin module pinout.
5. `[VERIFY]` cranking profile; BOR4 threshold confirmed from DS12288 Table 19.
6. `[VERIFY]` exact orderable MCU code and stock.
7. `[VERIFY]` buck inductor part number, saturation current and height.
8. `[VERIFY]` display backlight current and whether a transistor is needed.
9. `[VERIFY]` EN/UVLO divider values and 100 nF filter against the final BOM.
10. `[VERIFY]` Micro-Fit cable-end kit part numbers (housing, terminals, TPA).
