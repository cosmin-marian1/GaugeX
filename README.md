# GaugeX

A compact three-gauge automotive pod: three GC9A01 1.28" round SPI displays in
fused tubes, driven by an STM32G474, on one 3.3 V rail from switched ignition,
with a listen-only CAN interface.

| Part | State | Entry point |
|---|---|---|
| Enclosure (OpenSCAD) | done, STLs exported | [`3d-model/README.md`](3d-model/README.md) |
| Schematic | ERC 0 violations | [`pcb/DESIGN.md`](pcb/DESIGN.md) §5.3 |
| PCB | routed, planes filled, DRC 0 errors | [`pcb/README.md`](pcb/README.md) |
| BOM | generated from the schematic fields | [`pcb/BOM.md`](pcb/BOM.md) |
| Buck / front-end model | proxy model, timings checked | [`pcb/sim/README.md`](pcb/sim/README.md) |
| Firmware | not started | [`firmware/README.md`](firmware/README.md) |

Everything still open — including the items that block fabrication — is in
[`pcb/OPEN-ITEMS.md`](pcb/OPEN-ITEMS.md).

## Repository map

| Path | Contents |
|---|---|
| `3d-model/` | parametric OpenSCAD source, checkers, STLs, renders |
| `pcb/` | KiCad project (`pcb/GaugeX/`), design/BOM/status docs, simulation |
| `docs/datasheets/` | datasheet PDFs + index with verified page citations |
| `docs/archive/` | superseded documents, kept for traceability only |
| `firmware/` | STM32 firmware (placeholder) |

Each design value has one owner:

| Values | Owner |
|---|---|
| Electronics (power, buck, pins, interfaces, heights) | `pcb/DESIGN.md` |
| Board mechanics, stackup, routing, rules, DRC | `pcb/README.md` |
| Parts, MPN, LCSC | `pcb/BOM.md` |
| Enclosure dimensions and tolerances | `3d-model/README.md` |
| Open checks | `pcb/OPEN-ITEMS.md` |

## Build and verify

Enclosure (exports both STLs, checks the envelope, renders previews):

```bash
cd 3d-model/src && ./export_final.sh
```

Schematic and board checks:

```bash
kicad-cli sch erc pcb/GaugeX/GaugeX.kicad_sch
kicad-cli pcb drc pcb/GaugeX/GaugeX.kicad_pcb
```

BOM (exact field list and notes in `pcb/BOM.md`):

```bash
kicad-cli sch export bom \
  --fields "Reference,Value,Footprint,MPN,LCSC,QUANTITY,DNP" \
  --group-by "Value,Footprint,MPN,LCSC" \
  --output bom.csv pcb/GaugeX/GaugeX.kicad_sch
```

Buck / front-end model:

```bash
python3 pcb/sim/buck_sim.py
```

## Notes

- No 5 V rail; the whole board runs from one 3.3 V rail.
- CAN is listen-only by default (`S` pin on the transceiver).
- The three display modules are a separate purchase and are not in the BOM.
- Datasheet citations are collected in [`docs/datasheets/INDEX.md`](docs/datasheets/INDEX.md).
