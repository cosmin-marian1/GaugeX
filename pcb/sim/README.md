# pcb/sim — GaugeX front-end / buck model

`buck_sim.py` — run with `python3 pcb/sim/buck_sim.py`.

## 1. What this model is (and is not)

**It is a switched proxy model, written in plain Python — not the TI vendor
model, not SPICE.** The power stage is integrated at 20 ns with ideal switches
plus the datasheet `RDS(on)`, a linear diode drop and a simplified loop
(feed-forward duty + integral trim).

| Use it for | Do **not** use it for |
|---|---|
| UVLO / soft-start / restart **timings** | **Efficiency** (never quote a number from here) |
| Hold-up time and BOR interaction | EMI / SW-node ringing |
| Current and ripple **order of magnitude**, DCM/CCM boundary | Loop stability, phase margin |
| Load-dump / reverse-battery arithmetic | Thermal, inductor saturation |

Parameters and their sources:

| Item | Value | Source |
|---|---|---|
| L, DCR | 10 µH, 40 mΩ | XAL5030-103 (BOM) |
| C_out | 28 µF effective (2 × 22 µF derated) | see §6 |
| Rds(on) HS / LS | 0.725 Ω / 0.33 Ω | SNVSB51C p. 13 |
| tSS | 3 ms typ (1.75 / 4.75 min / max) | SNVSB51C p. 6 |
| I_PEAK limit | 1.5 A typ (1.25 / 1.75) | SNVSB51C p. 6 |
| EN/UVLO | 1.5 V rising / 1.4 V falling | SNVSB51C p. 5 |
| VIN abs max | 100 V | SNVSB51C p. 4 |
| DEM (no negative current) | — | SNVSB51C p. 12–13 |
| BOR4 | 2.81 V falling typ | STM32G474 DS, Table 19, p. 85 |
| SS36 | 60 V, 3 A, VF 0.75 V max @ 3 A, IFSM 100 A | Vishay 88751 |
| SMBJ24A | 24 V, VBR 26.7–29.5 V, VC 38.9 V @ 15.5 A, 600 W | Littelfuse SMBJ series |

Known model limits: no gate charge, dead time, ripple injection, thermal
drift, inductor saturation, or package parasitics; the diode is a linear
VF(I) fit; the loop is a proxy (the real part is COT); at light load the real
part pulse-skips (frequency drops below 300 kHz) while the model keeps 300 kHz.

## 2. Where the cranking source is applied

The board chain is **J1 → F1 (500 mA) → VIN_F → D1 (SS36) → VIN (D2 TVS, C1,
C2) → U2 VIN pin**. The model therefore applies the dip at **J1** and passes
it through the **SS36**: `VIN = V_J1 − VF_SS36(I)`, with
`VF = 0.30 V + 0.15 Ω·I` (0.35 V at 0.3 A, 0.75 V at 3 A — Vishay 88751).

The UVLO divider (1 M / 300 k) is on **VIN**, not on J1, so the thresholds are:

| | VIN pin | J1 side (≈ +0.3 V drop) |
|---|---|---|
| Enable (on) | 6.50 V | ≈ 6.80 V |
| Disable (off) | 6.07 V | ≈ 6.42 V |

Quoting a "6.5 V cranking" without saying which node is ambiguous; this model
uses J1 and the Schottky drop.

## 3. Cranking run: J1 12 V → 6.0 V for 18 ms → 12 V

| Event | Result |
|---|---|
| UVLO off (VIN 6.07 V) | t = **12.93 ms**, i.e. **0.93 ms** into the 1 ms dip; J1 = **6.45 V** |
| +3V3 → BOR4 (2.81 V) | **28 µs** after shutdown in the model; **49 µs** analytical at 0.28 A / 28 µF; **83 µs** at 0.165 A |
| Restart threshold | VIN **6.50 V** ↔ J1 **6.80 V** |
| Restart delay (VIN crossing → 3.2 V) | **2.83 ms** ≈ tSS 3 ms (SNVSB51C p. 6) |

The 3.3 V rail does **not** ride through a 6.0 V J1 dip — it is below the
UVLO-off equivalent (6.42 V at J1), by design (clean reset, no brownout). The
MCU resets on BOR4 ~30–50 µs after the buck stops. The restart overshoot in
the proxy is 3.46 V; the real COT soft-start limits this — treat the number as
indicative only.

## 4. The "1.62 A startup peak" — corrected

The earlier 1.62 A was **not** a datasheet prediction: it came from an assumed
1.6 A limit and a 2 ms reference ramp in the first model version, where the
proxy loop saturated. Correct numbers from the datasheet:

- **tSS = 3 ms typ** (SNVSB51C **p. 6**, SOFT START table)
- **I_PEAK = 1.5 A typ** (SNVSB51C **p. 6**, CURRENT LIMIT table)

With C_out = 28 µF, the soft-start charge current is

```text
I = I_load + C_out · ΔV / tSS = 0.28 + 28 µF × 3.3 V / 3 ms = 0.28 + 0.031 = 0.31 A
```

so the **1.5 A current limit is never reached at power-on** for this load. The
model now starts at the steady state and does not simulate power-on (the proxy
loop would only add its own artifact).

## 5. Load dump and reverse battery

| Case | Numbers | Verdict |
|---|---|---|
| Clamped system (35 V) | TVS off; VIN = **34.7 V** | < 100 V abs max (p. 4) ✓ |
| Unclamped dump, 87 V, Ri = 2 Ω | I_TVS = **24.1 A**, P = **936 W** > 600 W; SS36 sees 24.1 A | TVS overstressed |
| Unclamped dump, 87 V, Ri = 0.5 Ω | I_TVS = **96.2 A**, P = **3.7 kW** | TVS fails (shorts) → F1 opens |
| Reverse battery −14 V | D1 blocks, VIN ≈ 0 V; D2 is **after** D1 → no conduction | ✓ (DESIGN §4.1) |

Notes:

- The TVS is **after** the Schottky (D2 on VIN), so during a dump the surge
  flows through F1 **and D1**. The SS36's 3 A average is exceeded; its 100 A
  / 8.3 ms surge rating covers a 1–2 ms pulse while F1 opens, but not a
  400 ms ISO 7637-2 pulse 5a.
- The SMBJ24A (600 W, 10/1000 µs) is adequate for ESD and clamped transients,
  **not for an unclamped load dump**. For a full 5a specification use a 3 kW
  class part (SMDJ24A) and/or move the clamp ahead of D1.
- Reverse battery is handled by D1 blocking; the TVS never conducts. SS36
  reverse leakage is 0.5 mA @ 25 °C, 10 mA @ 100 °C at 60 V — at 14 V the
  leakage is lower `[VERIFY]`, but it is the only path that could parasitically
  bias VIN.

## 6. Output capacitance

Datasheet method (SNVSB51C **p. 18**, §7.2.2.4, Eq. 21):

```text
C_out ≥ ΔIL / (8 · f_sw · V_out_ripple)
```

with the 0.5 % ripple target of the datasheet (16.5 mV at 3.3 V) and
ΔIL(12 V) = 0.797 A:

```text
C_out(min) = 0.797 / (8 × 300 kHz × 16.5 mV) = 20.1 µF
```

Placed: **2 × 22 µF 10 V X5R 0805** (C3, C4). At 3.3 V DC bias a 10 V X5R
retains roughly 60–65 % → **~28 µF total** (Murata SimSurfing `[VERIFY]`).
Predicted ripple `ΔIL/(8·f·C)` = **11.9 mV**, matching the model's 17 mV
(proxy loop adds some). Margin against the 20.1 µF minimum is only **1.4×** —
if the caps retain < 45 % the 0.5 % criterion is missed.

## 7. ΔIL correction

The earlier "0.845 A at 12 V" was wrong. Correct values (Eq. 18):

| VIN | D | ΔIL |
|---|---|---|
| **12.0 V** | 0.275 | **0.797 A** (0.80 A) |
| 13.8 V | 0.239 | 0.837 A (0.84 A) |
| 6.5 V | 0.508 | 0.542 A (0.54 A) |

At 0.28 A the converter is in **DCM** (ΔIL_CCM/2 = 0.40 A > 0.28 A), so the
measured valley is clamped at 0 and the peak is ~0.68 A, not 0.80 A.
