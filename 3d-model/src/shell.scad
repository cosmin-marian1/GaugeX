// ============================================================================
//  GaugeX - SHELL  (parametric per car, changes with every preset)
//
//  3 round GC9A01 pockets on a horizontal arc (arc_radius), with per-gauge
//  toe-in / tilt and a sun hood.  Base profile is selectable:
//      "flat" | "curved" | "clip" | "bracket"
//
//  The shell mates to the CORE through the fixed interface defined in
//  core.scad: same 4-screw pattern, tray centred behind the middle gauge,
//  standard display-wire opening.  Only shell parameters are exposed here.
//
//  Local coordinates: display front plane at z = 0, rear interface plate at
//  z = CORE_FRONT_Z.  Print: rear plate DOWN (flat on the bed), no supports.
// ============================================================================

/* ===========================================================================
   SHELL DEFAULTS  (presets override these through shell(...) arguments)
   =========================================================================== */
def_n_displays       = 3;
def_display_pcb_dia  = 40.0;
def_display_active   = 32.4;
def_display_bezel    = 35.5;
def_display_thick    = 5.0;
def_window_margin    = 0.5;
def_window_chamfer   = 1.2;
def_face_t           = 1.5;
def_shell_wall       = 2.5;
def_shoulder_th      = 2.5;
def_ret_ribs         = 4;
def_tol_clear        = 0.3;

def_arc_radius       = 320.0;
def_display_spacing  = 50.0;
def_toe_in           = 0.0;
def_tilt             = 6.0;

def_hood_depth       = 6.0;
def_hood_wall        = 1.8;
def_hood_flare       = 1.4;

def_base_type        = "flat";
def_base_width       = 110.0;
def_base_length      = 36.0;
def_base_th          = 3.0;
def_base_curve_radius= 400.0;

shell_plate_w        = CORE_W + 8.0;    // 108
shell_plate_h        = CORE_H + 8.0;    // 84
shell_plate_th       = 8.0;
shell_plate_r        = 6.0;
plate_front_z        = CORE_FRONT_Z + shell_plate_th;   // -18

/* ===========================================================================
   ARC HELPERS  (pure functions, arguments explicit)
   =========================================================================== */
function arc_angle(i, n, spacing, R) =
    (i - (n - 1)/2) * spacing / R;                       // radians
function arc_x(i, n, spacing, R) = R * sin(arc_angle(i, n, spacing, R) * 180/PI);
function arc_z(i, n, spacing, R) = -R * (1 - cos(arc_angle(i, n, spacing, R) * 180/PI));
function arc_yaw(i, n, spacing, R, toe) =
    -arc_angle(i, n, spacing, R) * 180 / PI
    - sign(i - (n - 1)/2) * toe;                         // degrees

/* ===========================================================================
   DISPLAY POD  (local frame: window plane z = 0, pocket toward -z)
   =========================================================================== */
module display_pod(pod_dia, window_dia, pocket_dia, pocket_depth, front_layer,
                   back_open_dia, face_t, chamfer, shoulder_th, ribs,
                   hood_depth, hood_wall, hood_flare) {
    difference() {
        union() {
            // pod body (z = -front_layer .. 0)
            translate([0, 0, -front_layer])
                cylinder(h = front_layer, d = pod_dia, $fn = max(64, $fn));
            // sun hood (tapered ring, flares outward toward the front)
            translate([0, 0, 0])
                difference() {
                    cylinder(h = hood_depth,
                             r1 = pod_dia/2,
                             r2 = pod_dia/2 + hood_flare*0.4,
                             $fn = max(64, $fn));
                    translate([0, 0, -eps])
                        cylinder(h = hood_depth + 2*eps,
                                 r1 = window_dia/2 + hood_wall,
                                 r2 = window_dia/2 + hood_wall + hood_flare*1.5,
                                 $fn = max(64, $fn));
                }
        }
        // pocket (stops face_t below the front face, leaving the window ring)
        translate([0, 0, -pocket_depth])
            cylinder(h = pocket_depth - face_t + eps, d = pocket_dia,
                     $fn = max(64, $fn));
        // window through the front ring
        translate([0, 0, -face_t - eps])
            cylinder(h = face_t + 2*eps, d = window_dia, $fn = max(64, $fn));
        // cosmetic chamfer on the window
        translate([0, 0, -chamfer])
            cylinder(h = chamfer + eps,
                     r1 = window_dia/2, r2 = window_dia/2 + chamfer,
                     $fn = max(64, $fn));
        // rear opening
        translate([0, 0, -front_layer - eps])
            cylinder(h = shoulder_th + 2*eps, d = back_open_dia,
                     $fn = max(64, $fn));
    }
    // retention ribs behind the display (slightly embedded to stay manifold)
    for (k = [0 : ribs-1])
        rotate([0, 0, 45 + k*360/ribs])
            translate([back_open_dia/2 - 3.5, -1.5, -front_layer - 0.2])
                cube([5.0, 3.0, shoulder_th + 0.35]);
}

/* ---- collar: tube from pod rear to the interface plate, slotted on top --- */
module pod_collar(len, outer_d, inner_d) {
    difference() {
        translate([0, 0, -len])
            cylinder(h = len, d = outer_d, $fn = max(48, $fn));
        translate([0, 0, -eps])
            cylinder(h = len + 2*eps, d = inner_d, $fn = max(48, $fn));
        // cable exit slot at the top
        translate([-10, inner_d/2 - 2, -len - eps])
            cube([20, 20, len + 2*eps]);
    }
}

/* ===========================================================================
   BASE PROFILES
   =========================================================================== */
module base_plate(w, len, th, r, y_top) {
    translate([0, y_top - len/2 + 6, CORE_FRONT_Z])
        linear_extrude(height = th)
            gx_rrect(w, len + 12, r);
}

module shell_base(type, w, len, th, curve_r, y_top) {
    yc = y_top - len/2 + 6;

    difference() {
        // ---- solid base, optionally trimmed to a dash crown -------------
        if (type == "curved")
            intersection() {
                base_plate(w, len, th, 4, y_top);
                translate([0, yc, CORE_FRONT_Z + curve_r])
                    rotate([0, 90, 0])
                        cylinder(h = w + 20, r = curve_r, center = true,
                                 $fn = max(96, $fn));
            }
        else
            union() {
                base_plate(w, len, th, 4, y_top);
                // bracket: stiffening rib on the front side
                if (type == "bracket")
                    translate([-w/2 + 8, y_top - len + 6, CORE_FRONT_Z + th])
                        cube([w - 16, 5, 12]);
            }

        // clip: two U-slots leaving flexible tongues
        if (type == "clip") {
            for (tx = [-w/4, w/4]) {
                translate([tx - 11, y_top - len - 2, CORE_FRONT_Z - eps])
                    cube([2, len*0.62 + 2, th + 2*eps]);
                translate([tx + 9, y_top - len - 2, CORE_FRONT_Z - eps])
                    cube([2, len*0.62 + 2, th + 2*eps]);
                translate([tx - 11, y_top - len - 3, CORE_FRONT_Z - eps])
                    cube([22, 4, th + 2*eps]);
            }
        }

        // bracket: two M4 mounting holes through the plate
        if (type == "bracket")
            for (hx = [-w/2 + 20, w/2 - 20])
                translate([hx, y_top - len + 14, CORE_FRONT_Z - eps])
                    cylinder(h = th + 2*eps, d = 4.5, $fn = 24);
    }
}

/* ===========================================================================
   SHELL
   =========================================================================== */
module shell(n_displays       = def_n_displays,
             display_pcb_dia  = def_display_pcb_dia,
             display_active   = def_display_active,
             display_bezel    = def_display_bezel,
             display_thick    = def_display_thick,
             window_margin    = def_window_margin,
             window_chamfer   = def_window_chamfer,
             face_t           = def_face_t,
             shell_wall       = def_shell_wall,
             shoulder_th      = def_shoulder_th,
             ret_ribs         = def_ret_ribs,
             tol_clear        = def_tol_clear,
             arc_radius       = def_arc_radius,
             display_spacing  = def_display_spacing,
             toe_in           = def_toe_in,
             tilt             = def_tilt,
             hood_depth       = def_hood_depth,
             hood_wall        = def_hood_wall,
             hood_flare       = def_hood_flare,
             base_type        = def_base_type,
             base_width       = def_base_width,
             base_length      = def_base_length,
             base_th          = def_base_th,
             base_curve_radius= def_base_curve_radius,
             dummies          = false) {

    window_dia     = display_active + 2*window_margin;
    pocket_dia     = display_pcb_dia + 2*tol_clear;
    pocket_depth   = face_t + display_thick + tol_clear;
    front_layer    = pocket_depth + shoulder_th;
    back_open_dia  = display_pcb_dia - 5.0;
    pod_dia        = pocket_dia + 2*shell_wall;

    assert(base_type == "flat" || base_type == "curved" ||
           base_type == "clip" || base_type == "bracket",
           str("Unknown base_type: ", base_type));

    difference() {
        union() {
            // ---- rear interface plate (mates with the core) -------------
            translate([0, 0, CORE_FRONT_Z])
                gx_rbox_up(shell_plate_w, shell_plate_h, shell_plate_th,
                           shell_plate_r);

            // ---- M3 heat-set bosses for the interface screws ------------
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*CORE_IFACE_X, sy*CORE_IFACE_Y, CORE_FRONT_Z])
                    cylinder(h = 5.5 + shell_plate_th, d = 8.2,
                             $fn = max(24, $fn));

            // ---- display pods + collars ---------------------------------
            for (i = [0 : n_displays-1]) {
                px  = arc_x(i, n_displays, display_spacing, arc_radius);
                pz  = arc_z(i, n_displays, display_spacing, arc_radius);
                yaw = arc_yaw(i, n_displays, display_spacing, arc_radius, toe_in);
                collar_r = (pod_dia - 4.0)/2;
                // end the tilted collar just inside the plate, never in the core
                z_end = CORE_FRONT_Z + 0.8
                        + collar_r*(sin(abs(tilt)) + sin(abs(yaw)));
                clen  = max(2.0, ((pz - front_layer + 0.3) - z_end)
                                 / max(0.2, cos(tilt)*cos(yaw)));

                translate([px, 0, pz])
                    rotate([tilt, yaw, 0]) {
                        display_pod(pod_dia, window_dia, pocket_dia, pocket_depth,
                                    front_layer, back_open_dia, face_t,
                                    window_chamfer, shoulder_th, ret_ribs,
                                    hood_depth, hood_wall, hood_flare);
                        translate([0, 0, -front_layer + 0.3])
                            pod_collar(clen, pod_dia - 4.0, back_open_dia + 0.4);
                    }
            }

            // ---- base profile -------------------------------------------
            shell_base(base_type, base_width, base_length, base_th,
                       base_curve_radius, -shell_plate_h/2);
        }

        // ---- standard display-wire opening ------------------------------
        translate([-WIRE_OPENING_W/2, WIRE_OPENING_Y - WIRE_OPENING_H/2,
                   CORE_FRONT_Z - eps])
            cube([WIRE_OPENING_W, WIRE_OPENING_H, shell_plate_th + 2*eps]);

        // ---- M3 insert holes (pressed from the rear, through the core) --
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*CORE_IFACE_X, sy*CORE_IFACE_Y, CORE_FRONT_Z - eps])
                cylinder(h = 5.5 + eps, d = 4.6, $fn = max(20, $fn));
    }

    // ---- optional dummy displays (fit verification only) ----------------
    if (dummies)
        for (i = [0 : n_displays-1])
            translate([arc_x(i, n_displays, display_spacing, arc_radius), 0,
                       arc_z(i, n_displays, display_spacing, arc_radius)])
                rotate([tilt,
                        arc_yaw(i, n_displays, display_spacing, arc_radius, toe_in),
                        0])
                    translate([0, 0, -face_t])
                        shell_display_dummy(display_pcb_dia, display_bezel,
                                            display_thick);
}

/* ---- dummy display, local frame: glass front at z = 0 ------------------- */
module shell_display_dummy(display_pcb_dia = def_display_pcb_dia,
                           display_bezel  = def_display_bezel,
                           display_thick  = def_display_thick) {
    color([0.08, 0.09, 0.10])
        translate([0, 0, -display_thick])
            cylinder(h = display_thick - 1.5, d = display_pcb_dia, $fn = 64);
    color([0.10, 0.16, 0.38])
        translate([0, 0, -1.5])
            cylinder(h = 1.5, d = display_bezel, $fn = 64);
}
