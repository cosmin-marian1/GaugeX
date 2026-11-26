// ============================================================================
//  GaugeX - dummy electronics for fit checks only (never exported as parts)
// ============================================================================
include <params.scad>

// Local display frame: front glass plane z = 0, module extends to z = -DISPLAY_TH.
module display_dummy() {
    color([0.07, 0.08, 0.09])
        translate([0, 0, -DISPLAY_TH])
            cylinder(h = DISPLAY_TH - 1.5, d = DISPLAY_PCB_D, $fn = 64);
    color([0.10, 0.16, 0.38])
        translate([0, 0, -1.5])
            cylinder(h = 1.5, d = DISPLAY_GLASS_D, $fn = 64);
}

// Local main-PCB frame: front face z = 0 (F.Cu, faces the displays), board
// extends to z = -PCB_TH (faces the back plate).
module pcb_dummy() {
    color([0.05, 0.30, 0.10])
        translate([-PCB_W/2, -PCB_H/2, -PCB_TH])
            cube([PCB_W, PCB_H, PCB_TH]);

    // Connectors are on the FRONT face, same as the real board (all 67 parts
    // are on F.Cu). Positions come from GaugeX.kicad_pcb, mapped as
    // enclosure_x = pcb_x - PCB_W/2, enclosure_y = PCB_H/2 - pcb_y.
    // Heights are the STEP-model Z extents: 2.96 mm for the JST-SH bodies.

    // J2, J3, J4: JST-SH 8-pin right-angle, 10.0 x 4.96 x 2.96 mm
    for (x = [-13, -1, 11])
        color([0.12, 0.12, 0.12])
            translate([x - 5, -15.5 - 2.48, 0])
                cube([10, 4.96, 2.96]);

    // J5: JST-SH 4-pin right-angle, rotated 90 deg, 4.96 x 5.2 x 2.96 mm
    color([0.12, 0.12, 0.12])
        translate([20 - 2.48, -5 - 2.6, 0])
            cube([4.96, 5.2, 2.96]);

    // J1 is 4 flush SMD pads at the top edge (pcb y = 3); no body.
    // Tallest other front-side parts for reference: L2 3.1 mm, C8 4.5 mm (DNP).
}

module gauge_transform(i) {
    cx  = (i - (N_GAUGES-1)/2) * TUBE_PITCH;
    yaw = (i == 0) ? SIDE_TOE_IN : (i == N_GAUGES-1) ? -SIDE_TOE_IN : 0;
    translate([cx, 0, 0]) rotate([0, yaw, 0]);
}

module displays_untilted() {
    for (i = [0:N_GAUGES-1])
        gauge_transform(i)
            translate([0, 0, -1.5])
                display_dummy();
}

module pcb_untilted() {
    translate([0, 0, PCB_Z]) pcb_dummy();
}

module electronics_tilted() {
    rotate([-TILT_ANGLE, 0, 0]) {
        displays_untilted();
        pcb_untilted();
    }
}
