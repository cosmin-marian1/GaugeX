// ============================================================================
//  GaugeX - STEP 2: removable back plate
//
//  Covers the full cavity, carries 2 push-buttons and the cable exit slot,
//  and is fixed with 4 x M3 screws into the body's heat-set inserts.
//
//  PRINT: outer face DOWN on the bed, inner lip up. No supports.
// ============================================================================
include <params.scad>

module plate_rrect2d(w, h, r) {
    offset(r = r, $fn = max(16, $fn))
        square([w - 2*r, h - 2*r], center = true);
}

module back_plate_untilted() {
    z_out = WEDGE_BACK_Z - BACK_PLATE_TH;   // outer face

    difference() {
        union() {
            // main plate
            translate([0, 0, z_out])
                linear_extrude(height = BACK_PLATE_TH)
                    plate_rrect2d(BACK_PLATE_W, BACK_PLATE_H, BACK_PLATE_R);

            // locating lip entering the cavity
            translate([0, 0, WEDGE_BACK_Z])
                difference() {
                    linear_extrude(height = PLATE_LIP_H)
                        plate_rrect2d(CAVITY_W - 0.4, CAVITY_H - 0.4, CAVITY_R - 0.2);
                    translate([0, 0, -EPS])
                        linear_extrude(height = PLATE_LIP_H + 2*EPS)
                            plate_rrect2d(CAVITY_W - 0.4 - 2*PLATE_LIP_W,
                                          CAVITY_H - 0.4 - 2*PLATE_LIP_W, 1);
                }
        }

        // M3 clearance + socket-head counterbore
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*BACK_SCREW_DX, sy*BACK_SCREW_DY, z_out - EPS])
                cylinder(h = BACK_PLATE_TH + 2*EPS, d = M3_CLEAR_D,
                         $fn = max(20, $fn));
            translate([sx*BACK_SCREW_DX, sy*BACK_SCREW_DY, z_out - EPS])
                cylinder(h = M3_HEAD_DEPTH + EPS, d = M3_HEAD_D,
                         $fn = max(20, $fn));
        }

        // 2x 12 mm push-buttons, 20 mm apart
        for (i = [0:1])
            translate([-BUTTON_SPACING/2 + i*BUTTON_SPACING, BUTTON_Y,
                       z_out - EPS])
                cylinder(h = BACK_PLATE_TH + 2*EPS, d = BUTTON_D,
                         $fn = max(32, $fn));

        // cable exit slot 20 x 8, top centre
        translate([0, CABLE_SLOT_Y, z_out - EPS])
            linear_extrude(height = BACK_PLATE_TH + 2*EPS)
                plate_rrect2d(CABLE_SLOT_W, CABLE_SLOT_H, 3);
    }
}

module back_plate() {
    rotate([-TILT_ANGLE, 0, 0]) back_plate_untilted();
}
