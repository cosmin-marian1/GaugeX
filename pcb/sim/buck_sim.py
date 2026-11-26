#!/usr/bin/env python3
"""GaugeX front-end + buck transient model.

THIS IS NOT THE TI VENDOR MODEL AND NOT A SPICE SIMULATION.

It is a switched, averaged-behaviour proxy used only to check trends and
timings: buck loop response, UVLO shutdown, output hold-up, restart. It is
NOT valid for efficiency, EMI, loop stability or absolute ripple guarantees.

Sources for the parameters:
  LM5164-Q1  SNVSB51C:  abs max VIN 100 V (p.4); EN/UVLO 1.5 V rising /
             1.4 V falling (p.5); tSS 3 ms typ (p.6); IPEAK 1.5 A typ (p.6);
             COUT min via Eq.21 (p.18); DEM (p.12-13)
  SS36       Vishay 88751: VF 0.75 V max @ 3 A, 60 V, IFSM 100 A
  SMBJ24A    Littelfuse: VR 24 V, VBR 26.7-29.5 V, VC 38.9 V @ 15.5 A, 600 W
  STM32G474  DS: BOR4 falling 2.81 V typ (Table 19, p.85)

Circuit as placed:  J1 -> F1 0.5 A -> VIN_F -> D1 SS36 -> VIN (D2 TVS, C1,
C2) -> U2 VIN pin.  The UVLO divider (1 M / 300 k) sits on VIN.
"""
import math

# ---- buck ----------------------------------------------------------------
L = 10e-6
R_L = 0.040
COUT = 28e-6          # 2 x 22 uF 10 V X5R 0805, ~64 % retained at 3.3 V [VERIFY]
ESR = 1.5e-3
RDS_HS = 0.725        # SNVSB51C p.13
RDS_LS = 0.33
FSW = 300e3
TS = 1.0 / FSW
ILIM = 1.5            # SNVSB51C p.6 (typ)
VOUT_SET = 3.3
SOFT = 3e-3           # SNVSB51C p.6 (tSS typ)
ILOAD = 0.28          # design max (power budget)
DT = 20e-9

# ---- front end -----------------------------------------------------------
VIN_ON = 6.50         # EN 1.5 V x (1M+300k)/300k
VIN_OFF = 6.07        # EN 1.4 V x (1M+300k)/300k
VF0, VF_K = 0.30, 0.15    # SS36: 0.345 V @ 0.3 A, 0.75 V @ 3 A (88751)


def vf_ss36(i):
    return VF0 + VF_K * abs(i)


# ---- scenario: cranking ------------------------------------------------
T_END = 40e-3


def j1_of(t):
    if t < 12e-3:
        return 12.0
    if t < 13e-3:
        return 12.0 + (6.0 - 12.0) * (t - 12e-3) / 1e-3
    if t < 30e-3:
        return 6.0
    if t < 31e-3:
        return 6.0 + (12.0 - 6.0) * (t - 30e-3) / 1e-3
    return 12.0


def iload_of(t, vout):
    # the boards stop drawing current once the rail is below their own UVLO
    return ILOAD if vout > 2.6 else 0.0


# ---- run ----------------------------------------------------------------
iL = 0.0            # start at the DCM valley; steady state is measured later
vc = VOUT_SET
t = 0.0
trim = 0.0
skip = False
last_phase = 0.0
enabled = False
t_enable = None
t_shut = t_bor = t_restart_vth = t_restart_ok = None
i_peak = 0.0
ss_n = 0
ss_v = ss_imin = ss_imax = 0.0
ss_vmin, ss_vmax = 9.9, -9.9
vmax_after = 0.0
plot = []
step = 0

while t < T_END:
    vj1 = j1_of(t)
    il = iload_of(t, vc)

    # SS36 drop depends on the current drawn from VIN; first guess with iL
    i_in_guess = max(iL, 0.0)
    vin = vj1 - vf_ss36(i_in_guess) if vj1 > 0 else 0.0

    # UVLO (EN/UVLO divider on VIN)
    if not enabled and vin > VIN_ON:
        enabled = True
    elif enabled and vin < VIN_OFF:
        enabled = False
        if t_shut is None and t > 5e-3:
            t_shut = t

    if enabled and t_enable is None:
        t_enable = -SOFT if t < 1e-6 else t
    if not enabled:
        t_enable = None
    vref = VOUT_SET * min(1.0, (t - t_enable) / SOFT) if enabled else 0.0
    vout = vc + ESR * (iL - il)

    # feed-forward duty from the reference + a slow integral trim (loop proxy)
    if enabled:
        if vref < vout - 0.15:
            # soft-start reference still below the rail: the buck stays off
            # (it cannot sink current, so it must not track the reference down)
            D = 0.0
        else:
            D_ff = vref / max(vin, 0.1)
            err = vref - vout
            trim += 300.0 * err * DT
            trim = min(max(trim, -0.06), 0.06)
            D = min(max(D_ff + trim, 0.0), 0.95)
    else:
        D = 0.0
        trim = 0.0

    phase = (t % TS) / TS
    if phase < last_phase:            # new switching cycle
        skip = False
    on = enabled and (phase < D) and not skip
    if on and iL >= ILIM:             # cycle-by-cycle peak current limit
        skip = True
        on = False
    last_phase = phase
    i_in = iL if on else 0.0

    if on:
        iL += (vin - vout - iL * (R_L + RDS_HS)) / L * DT
    else:
        if iL > 0.0:                      # DEM
            iL += (-vout - iL * (R_L + RDS_LS)) / L * DT
            if iL < 0.0:
                iL = 0.0

    # reload with the real input current for the diode drop next step
    vc += (iL - il) / COUT * DT
    if iL > i_peak:
        i_peak = iL
        t_peak = t

    if 8.0e-3 <= t < 10.0e-3:
        ss_n += 1
        ss_v += vout
        ss_vmin = min(ss_vmin, vout)
        ss_vmax = max(ss_vmax, vout)
        ss_imax = max(ss_imax, iL)
        ss_imin = min(ss_imin, iL)

    if t_shut is not None and t_bor is None and vout < 2.81:
        t_bor = t

    # restart: VIN crossing 6.50 V on the way up, then time to 3.2 V
    if t_restart_vth is None and t > 30e-3 and vin > VIN_ON:
        t_restart_vth = t
    if t_restart_vth is not None and t_restart_ok is None and vout > 3.2:
        t_restart_ok = t
    if t > 31e-3:
        vmax_after = max(vmax_after, vout)

    if step % 50 == 0:
        plot.append((t, vj1, vin, vout, iL))
    step += 1
    t += DT

print("=" * 72)
print("GaugeX buck / front-end transient model  (proxy, not the TI model)")
print("=" * 72)
print("J1: 12 V -> 6.0 V (1 ms ramp) -> 18 ms at 6.0 V -> 12 V (1 ms ramp)")
print("load 0.28 A, Cout 28 uF effective, tSS 3 ms, ILIM 1.5 A")
print()
if t_shut:
    print("UVLO off (VIN 6.07 V) at t = %.2f ms  (J1 = %.2f V)"
          % (t_shut * 1e3, j1_of(t_shut)))
if t_bor:
    print("Vout reaches BOR4 2.81 V at t = %.2f ms" % (t_bor * 1e3))
if t_shut and t_bor:
    print("=> 3V3 hold-up after shutdown: %.0f us" % ((t_bor - t_shut) * 1e6))
if t_restart_vth:
    print("restart: VIN crosses 6.50 V at t = %.2f ms (J1 = %.2f V)"
          % (t_restart_vth * 1e3, j1_of(t_restart_vth)))
if t_restart_ok and t_restart_vth:
    print("         Vout back to 3.2 V at t = %.2f ms  -> %.2f ms after EN"
          % (t_restart_ok * 1e3, (t_restart_ok - t_restart_vth) * 1e3))
print("  max Vout after 31 ms: %.3f V" % vmax_after)
print()
if ss_n:
    print("steady state 12 V / 0.28 A (sim, 8-10 ms window):")
    print("  Vout %.4f V  ripple %.1f mV   iL %.3f .. %.3f A (DCM, valley clamped)"
          % (ss_v / ss_n, (ss_vmax - ss_vmin) * 1e3, ss_imin, ss_imax))

# ---- analytical checks --------------------------------------------------
print()
print("-" * 72)
print("analytical checks (CCM formula, datasheet Eq.18)")
for vin in (12.0, 13.8, 6.5):
    d = VOUT_SET / vin
    dil = (vin - VOUT_SET) * d / (L * FSW)
    print("  Vin %5.1f V  D %.3f  dIL %.3f A" % (vin, d, dil))

print()
print("output capacitance, SNVSB51C Eq.21 (p.18), 0.5 %% ripple = 16.5 mV:")
d = VOUT_SET / 12.0
dil = (12.0 - VOUT_SET) * d / (L * FSW)
print("  dIL(12 V) %.3f A  -> Cout(min) = %.1f uF"
      % (dil, dil / (8 * FSW * 0.0165) * 1e6))
print("  placed: 2 x 22 uF 10 V X5R 0805, ~64 %% at 3.3 V -> ~28 uF  [VERIFY]")
print("  -> predicted ripple dIL/(8 f C) = %.1f mV" % (dil / (8 * FSW * COUT) * 1e3))
print("  BOR4 falling 2.81 V (STM32G474 DS Table 19, p.85)")
print("  hold-up calc: %.0f us @0.28 A, %.0f us @0.165 A (typ load)"
      % (COUT * (3.3 - 2.81) / 0.28 * 1e6, COUT * (3.3 - 2.81) / 0.165 * 1e6))

# ---- front-end stress ---------------------------------------------------
print()
print("-" * 72)
print("load dump / reverse battery (datasheet numbers)")
print("  SS36 : 60 V, 3 A avg, IFSM 100 A (8.3 ms), VF 0.75 V max @ 3 A")
print("  SMBJ24A: VR 24 V, VBR 26.7..29.5 V, VC 38.9 V @ 15.5 A, 600 W")
print("  LM5164: VIN abs max 100 V (SNVSB51C p.4)")
for name, u, ri in (("clamped system 35 V", 35.0, 2.0),
                    ("unclamped 87 V, Ri 2 ohm", 87.0, 2.0),
                    ("unclamped 87 V, Ri 0.5 ohm", 87.0, 0.5)):
    if u <= 38.9:
        print("  %-26s TVS off, VIN = %.1f V (< 100 V abs max)"
              % (name, u - vf_ss36(0.1)))
    else:
        ipp = (u - 38.9) / ri
        p_tvs = ipp * 38.9
        print("  %-26s I_TVS %.1f A, P_TVS %.0f W (> 600 W), SS36 %.1f A;"
              % (name, ipp, p_tvs, ipp))
        print("  %-26s F1 0.5 A opens in ~1-2 ms -> TVS sees a 1-2 ms pulse"
              % "")
print("  reverse battery -14 V: D1 blocks (VIN ~0 V); D2 is after D1, no conduction")
print("  SS36 reverse leakage: 0.5 mA @25 C, 10 mA @100 C (60 V) -> [VERIFY] at 14 V")
