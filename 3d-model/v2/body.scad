// ============================================================================
//  GaugeX v2 - STEP 1: three fused tubes + low wedge + flat base
//
//  PRINT ORIENTATION
//    Rotate so the rear openings face UP.  Rest the part on the three front
//    hood/lip rims; use a brim.  The flat base becomes a vertical fin but the
//    tube pockets, wedge cavity and retention clips need no supports.
//
//  Local coordinates (before tilt): X horizontal, Y up, Z toward driver.
//  Display front plane z=0; tube backs z=-TUBE_DEPTH.
// ============================================================================
include <params.scad>

/* ===========================================================================
   HELPERS
   =========================================================================== */
module rrect2d(w, h, r) {
    offset(r = r, $fn = max(16, $fn))
        square([w - 2*r, h - 2*r], center = true);
}

function tube_x(i) = (i - (N_GAUGES-1)/2) * TUBE_PITCH;
function tube_yaw(i) =
    (i == 0) ? SIDE_TOE_IN : (i == N_GAUGES-1) ? -SIDE_TOE_IN : 0;

/* ===========================================================================
   TUBE BLANK (outer wall + hood; pockets are cut after all tubes are fused)
   =========================================================================== */
module tube_blank(i) {
    translate([tube_x(i), 0, 0])
        rotate([0, tube_yaw(i), 0]) {
            // tube outer wall
            translate([0, 0, -TUBE_DEPTH])
                cylinder(h = TUBE_DEPTH, d = TUBE_OD, $fn = max(64, $fn));

            // full-ring sun hood, 0.2 mm embedded into the front lip
            if (HOOD_DEPTH > 0)
                difference() {
                    translate([0, 0, -0.2])
                        cylinder(h = HOOD_DEPTH + 0.2,
                                 r1 = FRONT_OPENING_D/2 + HOOD_WALL,
                                 r2 = FRONT_OPENING_D/2 + HOOD_WALL + HOOD_FLARE,
                                 $fn = max(64, $fn));
                    translate([0, 0, -0.2 - EPS])
                        cylinder(h = HOOD_DEPTH + 0.2 + 2*EPS,
                                 r1 = FRONT_OPENING_D/2,
                                 r2 = FRONT_OPENING_D/2 + HOOD_FLARE,
                                 $fn = max(64, $fn));
                }
        }
}

/* ===========================================================================
   TUBE CUTS
   =========================================================================== */
module tube_cuts(i) {
    translate([tube_x(i), 0, 0])
        rotate([0, tube_yaw(i), 0]) {
            // main pocket; leaves the front lip intact
            translate([0, 0, -TUBE_DEPTH - EPS])
                cylinder(h = TUBE_DEPTH - FRONT_LIP_W + EPS,
                         d = TUBE_INNER_D, $fn = max(64, $fn));

            // front opening through the lip
            translate([0, 0, -FRONT_LIP_W - EPS])
                cylinder(h = FRONT_LIP_W + 2*EPS,
                         d = FRONT_OPENING_D, $fn = max(64, $fn));

            // front chamfer
            translate([0, 0, -FRONT_CHAMFER])
                cylinder(h = FRONT_CHAMFER + EPS,
                         r1 = FRONT_OPENING_D/2,
                         r2 = FRONT_OPENING_D/2 + FRONT_CHAMFER,
                         $fn = max(64, $fn));

            // cable pass-through: tube -> cavity, open at the bottom
            translate([-CABLE_NOTCH_W/2, -TUBE_OD/2 - EPS,
                       CAVITY_FRONT_Z - 0.2])
                cube([CABLE_NOTCH_W, CABLE_NOTCH_H + 2*EPS, CABLE_NOTCH_D]);
        }
}

/* ===========================================================================
   RETENTION CLIPS  (3 per tube, behind the display PCB)
   =========================================================================== */
module retention_clip(angle) {
    r_out = TUBE_INNER_D/2 + 0.3;
    r_in  = TUBE_INNER_D/2 - CLIP_REACH;

    // polygon is (radial, axial); Rx(90) maps it into the XZ plane
    rotate([0, 0, angle])
        rotate([90, 0, 0])
            linear_extrude(height = CLIP_TH, center = true)
                polygon([
                    [r_out, CLIP_Z0 + 0.8],
                    [r_out, CLIP_Z1 - 0.1],
                    [r_in,  CLIP_Z1],
                    [r_in - 0.3, CLIP_Z1 - BACK_LIP_W],
                    [r_in + 0.5, CLIP_Z0]
                ]);
}

module all_clips() {
    for (i = [0:N_GAUGES-1])
        translate([tube_x(i), 0, 0])
            rotate([0, tube_yaw(i), 0])
                for (a = [90, 210, 330])
                    retention_clip(a);
}

/* ===========================================================================
   WEDGE BODY  (rounded trapezoidal side profile, extruded across X)
   =========================================================================== */
module wedge_outer() {
    r = WEDGE_RADIUS;
    // Inset the sharp profile by r; offset(r) restores the nominal envelope
    // while rounding all four corners.
    profile = [
        [-WEDGE_FRONT_Z + r, -WEDGE_FRONT_H/2 + r],
        [-WEDGE_FRONT_Z + r,  WEDGE_FRONT_H/2 - r],
        [-WEDGE_BACK_Z  - r,  WEDGE_REAR_H/2  - r],
        [-WEDGE_BACK_Z  - r, -WEDGE_REAR_H/2  + r]
    ];
    rotate([0, 90, 0])
        linear_extrude(height = WEDGE_WIDTH, center = true)
            offset(r = r, $fn = max(24, $fn)) polygon(profile);
}

module m3_bosses() {
    // pillars stand inside the full-width cavity, rooted in the front wall
    h = CAVITY_FRONT_Z - WEDGE_BACK_Z + 0.2;
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*BACK_SCREW_DX, sy*BACK_SCREW_DY, WEDGE_BACK_Z])
            cylinder(h = h, d = M3_BOSS_D, $fn = max(24, $fn));
}

module pcb_cavity_cut() {
    translate([0, 0, WEDGE_BACK_Z - EPS])
        linear_extrude(height = CAVITY_FRONT_Z - WEDGE_BACK_Z + EPS)
            rrect2d(CAVITY_W, CAVITY_H, CAVITY_R);
}

/* ===========================================================================
   BODY BEFORE TILT
   =========================================================================== */
module body_untilted() {
    difference() {
        union() {
            // fused outer geometry first, then all pockets are cut through it
            difference() {
                union() {
                    for (i = [0:N_GAUGES-1]) tube_blank(i);
                    wedge_outer();
                }
                for (i = [0:N_GAUGES-1]) tube_cuts(i);
                pcb_cavity_cut();
            }

            // M3 interface pillars inside the cavity
            m3_bosses();

            // flexible rear clips
            all_clips();

            // PCB standoffs, embedded 0.2 mm into the cavity front wall
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*PCB_HOLE_X/2, sy*PCB_HOLE_Y/2, PCB_Z])
                    cylinder(h = STANDOFF_H + 0.2, d = M2P5_BOSS_D,
                             $fn = max(24, $fn));
        }

        // M3 heat-set insert holes, opening at the rear
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*BACK_SCREW_DX, sy*BACK_SCREW_DY, WEDGE_BACK_Z - EPS])
                cylinder(h = M3_INSERT_DEPTH + EPS, d = M3_INSERT_D,
                         $fn = max(20, $fn));

        // M2.5 heat-set insert holes, pressed from the rear of each standoff
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*PCB_HOLE_X/2, sy*PCB_HOLE_Y/2, PCB_Z - EPS])
                cylinder(h = M2P5_INSERT_DEPTH + EPS, d = M2P5_INSERT_D,
                         $fn = max(20, $fn));
    }
}

/* ===========================================================================
   FLAT BASE + TILTED POD
   =========================================================================== */
module flat_base() {
    cy = BASE_BOTTOM_Y + BASE_TH/2;
    translate([0, cy, BASE_Z_CENTER])
        rotate([90, 0, 0])
            linear_extrude(height = BASE_TH, center = true)
                rrect2d(BASE_W, BASE_L, BASE_R);
}

module body() {
    assert(TUBE_WALL >= MIN_WALL && TUBE_WALL <= 2.0,
           str("tube_wall must be 1.6..2.0, got ", TUBE_WALL));
    assert(SHARED_WALL >= MIN_WALL,
           str("shared wall too thin: ", SHARED_WALL));
    assert(EST_WIDTH <= MAX_W, str("estimated width exceeds limit: ", EST_WIDTH));
    assert(EST_HEIGHT <= MAX_H, str("estimated height exceeds limit: ", EST_HEIGHT));
    assert(EST_DEPTH <= MAX_D, str("estimated depth exceeds limit: ", EST_DEPTH));

    union() {
        rotate([-TILT_ANGLE, 0, 0]) body_untilted();
        flat_base();
    }
}
