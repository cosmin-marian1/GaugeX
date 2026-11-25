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

// Local main-PCB frame: front face z = 0, board extends to z = -PCB_TH.
module pcb_dummy() {
    color([0.05, 0.30, 0.10])
        translate([-PCB_W/2, -PCB_H/2, -PCB_TH])
            cube([PCB_W, PCB_H, PCB_TH]);
    // representative low-profile connectors behind the board
    color([0.12, 0.12, 0.12])
        translate([-PCB_W/2 + 5, -PCB_H/2 + 6, -PCB_TH - 3])
            cube([14, 8, 3]);
    color([0.12, 0.12, 0.12])
        translate([ PCB_W/2 - 10, -PCB_H/2 + 6, -PCB_TH - 2])
            cube([5, 10, 2]);
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
