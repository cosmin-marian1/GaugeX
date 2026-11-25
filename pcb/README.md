# PCB

KiCad project goes here.

Planned: STM32 main board, **50 × 40 mm** (core default), carrying the MCU,
three GC9A01 SPI display connectors, panel-button inputs and the car-harness
connector.

The board mounts in the universal core on four M2.5 standoffs with a
**44 × 34 mm** hole pattern (`pcb_hole_spacing_x/y` in
`../3d-model/src/core.scad`). Keep the connectors on the back side: the core
provides ~14 mm of depth behind the board.
