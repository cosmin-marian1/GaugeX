# Datasheet index — GaugeX PCB

Read only the section needed for the task. Page numbers are the PDF page
numbers printed on each page (the document page, not the viewer page).

## Available

| File | Document | Pages | Use for |
|---|---|---:|---|
| `DS_stm32g474cb.pdf` | ST **DS12288 Rev 6** — STM32G474xB/xC/xE datasheet | 236 | pinout, AF table, current, BOR, package |
| `lm5164-q1.pdf` | TI **SNVSB51C** — LM5164-Q1 100 V / 1 A buck | 41 | VIN range, on-time, UVLO, layout |
| `tcan334.pdf` | TI **TCAN33x Rev F** — TCAN330/332/334/337 | 47 | pin functions, silent vs standby, loop |
| `tps54360b-q1.pdf` | TI **TPS54360B-Q1** — 60 V / 3.5 A buck | 50 | alternate buck, 4.5 V min VIN |

## Verified extracts

### STM32G474CBU6 — DS12288 Rev 6

| Topic | Section | Page | Result |
|---|---|---:|---|
| UFQFPN48 pinout | 4.1 / Figure 5 | 49 | VSS = exposed pad; no separate VSS pins |
| Alternate function table | 4.11 / Table 13 | 73–78 | SPI1/2/3, FDCAN1, USART1, TIM2 confirmed |
| Supply current, 170 MHz | 5.3.5 / Table 21 | 88 | 29.5 mA typ @25 °C, 31 mA typ @85 °C, 42 mA max @85 °C (peripherals off) |
| BOR thresholds | Table 19 | 85–86 | BOR4: 2.90 V rising / 2.81 V falling typ |
| UFQFPN48 package | 6.2 | 203–205 | 7×7 mm, exposed pad |

Confirmed pin/AF pairs:

| Signal | Pin | AF | Page |
|---|---|---:|---|
| SPI1_SCK / MOSI | PA5 / PA7 | AF5 | 73 |
| SPI2_SCK / MOSI | PB13 / PB15 | AF5 | 74 |
| SPI3_SCK | PB3 | AF6 | 74 |
| SPI3_MOSI | PB5 | AF6 | 74 |
| FDCAN1_RX / TX | PA11 / PA12 | AF9 | 73 |
| USART1_TX / RX | PA9 / PA10 | AF7 | 73 |
| TIM2_CH1 | PA0 | AF1 | 73 |

### LM5164-Q1 — SNVSB51C

| Topic | Section | Page | Result |
|---|---|---:|---|
| Recommended VIN | 5.3 | 4 | **6 V … 100 V** |
| Minimum controllable on-time | 6.1 / 6.3.5 | 9 / 12 | **50 ns** |
| On-time equation | 6.3.5 | 12 | `tON(µs) = R_RON(kΩ) / (VIN(V) × 2.5)` |
| Frequency equation | 6.3.5 | 12 | `FSW(kHz) = VOUT(V) × 2500 / R_RON(kΩ)` |
| EN/UVLO thresholds | 5.5 / 6.3.9 | 5 / 13 | rising 1.45/1.50/1.55 V; falling 1.35/1.40/1.44 V |
| Typical application | 7.2 | 16–18 | 300 kHz, RRON 100 k for 12 V output |

### TCAN33x — Rev F

| Topic | Section | Page | Result |
|---|---|---:|---|
| Pin functions | Table 4-1 | 4 | TCAN330 pin 8 = `S` (silent); TCAN334 pin 8 = `STB` (standby) |
| Silent mode | 6.4.3 | 23 | driver disabled, receiver fully operational |
| Standby with wake | 6.4.4 | 23 | main receiver off; not continuous receive |

**Conclusion:** use **TCAN330G** for listen-only; TCAN334 is not suitable for
continuous listen-only.

### TPS54360B-Q1 (alternate)

| Topic | Section | Page | Result |
|---|---|---:|---|
| Operating VIN | 5 | 3 | **4.5 V … 60 V** |

## Missing documents

These are still needed before the schematic is frozen:

- GC9A01 1.28" module pinout / vendor datasheet (8 vs 7 pin, BL current)
- Molex Micro-Fit 3.0 cable-end drawing (`43025-0400`, `43030-0007`)
- JST-SH right-angle drawing (`SM08B-SRSS-TB`, `SM04B-SRSS-TB`)
- 8 MHz crystal datasheet (load capacitance)
- SS36, SMBJ24A, PESD2CAN datasheets (exact clamp/drop/capacitance)
- Buck inductor datasheet (saturation current, height)
- 25 V polymer capacitor datasheet, if C_hold is fitted

Until these are added, the corresponding values stay `[VERIFY]` in
`pcb/DESIGN.md` and `pcb/BOM.md`.
