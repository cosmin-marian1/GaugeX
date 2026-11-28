# AGENTS.md — GaugeX guardrails

Start with `pcb/STATE.md`, then `pcb/OPEN-ITEMS.md`.
Each design value lives in exactly one file: `pcb/README.md` (board),
`pcb/DESIGN.md` (electrical), `pcb/BOM.md` (parts), `pcb/sim/README.md`
(model), `3d-model/README.md` (enclosure). Link to the owner; never restate or
edit a value in two files.

## Hard rules

1. **C5 = 2.2 nF / 50 V / X7R is required by the LM5164-Q1 datasheet**
   (BST–SW, pp. 3, 12, 17; allowed range 1.5–2.5 nF). Do not change the value.
   Placement may change.
2. **Per-face height rule:** front (display side) ≤ 5.0 mm, back ≤ 3.0 mm.
   Owner: `pcb/README.md` §Mechanical. Never add a part that breaks it.
3. **Do not modify `GaugeX.kicad_pcb`, `GaugeX.kicad_sch` or `3d-model/`
   without explicit user approval.** Read-only inspection is fine.
4. Before any fab export, item A1 in `pcb/OPEN-ITEMS.md` must be closed.
5. End every task with `git log --oneline -3` and `git status`.

## Tooling notes (verified 2026-11-28)

KiCad 10.0.8 at `/usr/bin/kicad-cli`.

BOM — fields live in the schematic, never hand-edit `pcb/BOM.md`:

```bash
kicad-cli sch export bom \
  --fields "Reference,Value,Footprint,MPN,LCSC,QUANTITY,DNP" \
  --labels "Refs,Value,Footprint,MPN,LCSC,Qty,DNP" \
  --group-by "Value,Footprint,MPN,LCSC" \
  --output bom.csv pcb/GaugeX/GaugeX.kicad_sch
```

Netlist for `pcb/review/pins.md`:

```bash
kicad-cli sch export netlist --format kicadsexpr \
  --output /tmp/opencode/pins.net pcb/GaugeX/GaugeX.kicad_sch
```

FreeRouting: `/tmp/opencode/freerouting.jar`, v2.6.0, present 2026-11-28.
`/tmp` may be cleared; recreate it from the local image:

```bash
docker create --name fr ghcr.io/freerouting/freerouting:latest
docker cp fr:/app/freerouting-executable.jar /tmp/opencode/freerouting.jar
docker rm fr
```

Run headless: `java -jar /tmp/opencode/freerouting.jar -de in.dsn -do out.ses`.
The image entrypoint (`/__cacert_entrypoint.sh`) is broken here — use the jar.
Export the DSN from a **2-layer copy** of the board.

pcbnew (SWIG) pitfalls:

- Never materialise `board.GetTracks()` with `list()` — it corrupts the SWIG
  proxies. Iterate the container directly.
- `fp.Pads()` and `fp.GraphicalItems()` are methods, not attributes.
- Call `gc.disable()` before touching the board in a script; GC during proxy
  use crashes the process.
