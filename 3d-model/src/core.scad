// ============================================================================
//  GaugeX - CORE  (fixed electronics module, identical for every car)
//
//  Contains: PCB tray for a 50 x 40 mm board, 4x M2.5 heat-set standoffs,
//            removable back cover (2x 12 mm buttons, cable slot, vents,
//            4x M3 screws), fixed wire channel for the 3 display cables.
//
//  THIS FILE MUST NOT REFERENCE ANY SHELL / CAR PARAMETER.
//  Only the fixed interface constants below are shared with shell.scad.
//
//  Local coordinates: front face at z = 0, part extends to negative z.
//  Print: open back UP (front wall on the bed), no supports.
// ============================================================================

/* ===========================================================================
   FIXED INTERFACE  (shell.scad reads these, core never reads shell)
   =========================================================================== */
CORE_W              = 100.0;   // tray outer width
CORE_H              = 76.0;    // tray outer height
CORE_DEPTH          = 26.0;    // tray depth (front face -> cover rim)
CORE_WALL           = 2.4;
CORE_R              = 5.0;

CORE_IFACE_X        = 42.0;    // interface screw pattern, half pitch X
CORE_IFACE_Y        = 28.0;    // interface screw pattern, half pitch Y
CORE_FRONT_Z        = -26.0;   // z of tray front face (shell rear plane)
CORE_BOSS_D         = 8.2;     // through-boss diameter
CORE_SCREW_D        = 3.4;     // M3 clearance through the boss

WIRE_OPENING_W      = 74.0;    // standard display-wire opening
WIRE_OPENING_H      = 9.0;
WIRE_OPENING_Y      = 29.0;    // centre Y of the opening
display_wire_len    = 80.0;    // display_wire_len
WIRE_CHANNEL_LANES  = 3;
WIRE_LANE_W         = 3.6;
WIRE_RIB_T          = 1.2;
WIRE_CHANNEL_TOP    = CORE_H/2 - CORE_WALL;          // 35.6 inner top
WIRE_CHANNEL_BOT    = WIRE_CHANNEL_TOP - (4*WIRE_RIB_T + 3*WIRE_LANE_W) - 2*WIRE_RIB_T;
WIRE_CHANNEL_Z      = -12.0;   // shelf depth from front face

/* ===========================================================================
   CORE PARAMETERS
   =========================================================================== */
pcb_w               = 50.0;
pcb_h               = 40.0;
pcb_th              = 1.6;
pcb_hole_spacing_x  = 44.0;    // hole pattern (full pitch)
pcb_hole_spacing_y  = 34.0;
pcb_clear           = 4.0;
standoff_h          = 7.0;

m2p5_insert_d       = 4.2;
m2p5_insert_depth   = 4.0;
m2p5_boss_wall      = 1.8;
m2p5_boss_r         = (m2p5_insert_d + 2*m2p5_boss_wall) / 2;

m3_insert_d         = 4.6;
m3_insert_depth     = 5.5;
m3_clear_d          = 3.4;
m3_head_d           = 6.4;
m3_head_depth       = 3.2;

back_cover_th       = 2.4;
lip_h               = 3.0;
lip_w               = 3.0;

button_dia          = 12.0;
button_spacing      = 20.0;
button_x            = -button_spacing/2;   // two buttons centred on X
button_y            = -28.0;

cable_slot_w        = 20.0;
cable_slot_h        = 8.0;
cable_slot_y        = 28.0;

vent_count          = 5;
vent_len            = 18.0;
vent_w              = 2.5;
vent_y              = -6.0;

eps                 = 0.01;

/* ---- derived ------------------------------------------------------------ */
core_inner_w        = CORE_W - 2*CORE_WALL;
core_inner_h        = CORE_H - 2*CORE_WALL;
core_inner_r        = max(1.0, CORE_R - CORE_WALL);
pcb_z               = -(CORE_WALL + standoff_h);   // PCB front face (local)

/* ===========================================================================
   HELPERS  (self-contained, also used by shell.scad)
   =========================================================================== */
module gx_rrect(w, h, r) {
    offset(r = r, $fn = max(16, $fn)) square([w - 2*r, h - 2*r], center = true);
}
module gx_rbox_down(w, h, d, r) {
    translate([0, 0, -d]) linear_extrude(height = d) gx_rrect(w, h, r);
}
module gx_rbox_up(w, h, d, r) {
    linear_extrude(height = d) gx_rrect(w, h, r);
}
module gx_slot2d(len, w) {
    hull() {
        translate([-(len - w)/2, 0]) circle(d = w, $fn = 20);
        translate([ (len - w)/2, 0]) circle(d = w, $fn = 20);
    }
}

/* ===========================================================================
   CORE PARTS
   =========================================================================== */

module core_tray() {
    difference() {
        union() {
            // outer shell, front wall closed, rear open
            gx_rbox_down(CORE_W, CORE_H, CORE_DEPTH, CORE_R);

            // 4 interface through-bosses (back cover screws pass through,
            // then thread into the shell's M3 inserts)
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*CORE_IFACE_X, sy*CORE_IFACE_Y, -CORE_DEPTH])
                    cylinder(h = CORE_DEPTH, d = CORE_BOSS_D, $fn = max(24, $fn));

            // PCB standoffs on the front wall inner face
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*pcb_hole_spacing_x/2, sy*pcb_hole_spacing_y/2,
                           pcb_z])
                    cylinder(h = standoff_h, d = 2*m2p5_boss_r, $fn = max(24, $fn));

            // fixed display-wire channel along the top edge
            wire_channel();
        }

        // rear cavity
        translate([0, 0, -CORE_DEPTH - eps])
            gx_rbox_up(core_inner_w, core_inner_h,
                       CORE_DEPTH - CORE_WALL + eps, core_inner_r);

        // M3 clearance through every interface boss
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*CORE_IFACE_X, sy*CORE_IFACE_Y, -CORE_DEPTH - eps])
                cylinder(h = CORE_DEPTH + 2*eps, d = CORE_SCREW_D, $fn = max(20, $fn));

        // M2.5 heat-set insert holes (pressed from the open back)
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*pcb_hole_spacing_x/2, sy*pcb_hole_spacing_y/2,
                       pcb_z - eps])
                cylinder(h = m2p5_insert_depth + eps, d = m2p5_insert_d,
                         $fn = max(20, $fn));

        // standard display-wire opening in the front wall
        translate([-WIRE_OPENING_W/2, WIRE_OPENING_Y - WIRE_OPENING_H/2,
                   -CORE_WALL - eps])
            cube([WIRE_OPENING_W, WIRE_OPENING_H, CORE_WALL + 2*eps]);
    }
}

/* ---- wire channel: shelf + 4 ribs -> 3 lanes, open toward the rear -------- */
module wire_channel() {
    shelf_z = WIRE_CHANNEL_Z;
    y0 = WIRE_CHANNEL_BOT;
    y1 = WIRE_CHANNEL_TOP;

    // shelf
    translate([-display_wire_len/2, y0, shelf_z])
        cube([display_wire_len, y1 - y0, 1.6]);

    // 4 ribs running along X
    for (k = [0 : WIRE_CHANNEL_LANES])
        translate([-display_wire_len/2,
                   y0 + k*(WIRE_LANE_W + WIRE_RIB_T),
                   shelf_z])
            cube([display_wire_len, WIRE_RIB_T, -CORE_WALL - shelf_z]);
}

/* ---- back cover ---------------------------------------------------------- */
module core_cover() {
    difference() {
        union() {
            // plate: z = -th .. 0 (inner face at z = 0)
            gx_rbox_down(CORE_W, CORE_H, back_cover_th, CORE_R);

            // locating lip
            difference() {
                gx_rbox_up(core_inner_w - 2*eps, core_inner_h - 2*eps,
                           lip_h, core_inner_r);
                translate([0, 0, -eps])
                    gx_rbox_up(core_inner_w - 2*eps - 2*lip_w,
                               core_inner_h - 2*eps - 2*lip_w,
                               lip_h + 2*eps, max(1.0, core_inner_r - lip_w));
            }

            // zip-tie anchor next to the cable slot
            translate([cable_slot_w/2 + 4, cable_slot_y - 8, 0])
                difference() {
                    gx_rbox_up(16, 10, 6, 2);
                    translate([-eps, 0, 2.5])
                        cube([16 + 2*eps, 5, 6 + eps]);
                }
        }

        // M3 clearance + counterbore at the interface pattern
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*CORE_IFACE_X, sy*CORE_IFACE_Y, -back_cover_th - eps])
                cylinder(h = back_cover_th + lip_h + 2*eps, d = m3_clear_d,
                         $fn = max(20, $fn));
            translate([sx*CORE_IFACE_X, sy*CORE_IFACE_Y, -back_cover_th - eps])
                cylinder(h = m3_head_depth + eps, d = m3_head_d,
                         $fn = max(20, $fn));
        }

        // 2x push-button holes (12 mm, 20 mm apart)
        for (i = [0:1])
            translate([button_x + i*button_spacing, button_y,
                       -back_cover_th - eps])
                cylinder(h = back_cover_th + lip_h + 2*eps, d = button_dia,
                         $fn = max(32, $fn));

        // cable exit slot, aligned with the wire channel
        translate([-cable_slot_w/2, cable_slot_y - cable_slot_h/2,
                   -back_cover_th - eps])
            linear_extrude(height = back_cover_th + 2*eps)
                gx_rrect(cable_slot_w, cable_slot_h, 3);

        // ventilation slots
        for (i = [0:vent_count-1])
            translate([-14 + i*7, vent_y, -back_cover_th - eps])
                linear_extrude(height = back_cover_th + 2*eps)
                    rotate(90) gx_slot2d(vent_len, vent_w);
    }
}

/* ---- dummy PCB for fit checks ------------------------------------------- */
module core_pcb_dummy() {
    color([0.05, 0.30, 0.10])
        translate([-pcb_w/2, -pcb_h/2, pcb_z - pcb_th])
            cube([pcb_w, pcb_h, pcb_th]);
    // representative connectors behind the board
    color([0.12, 0.12, 0.12])
        translate([-pcb_w/2 + 4, -pcb_h/2 + 6, pcb_z - pcb_th - 6])
            cube([14, 9, 6]);
    color([0.12, 0.12, 0.12])
        translate([ pcb_w/2 - 10, -pcb_h/2 + 6, pcb_z - pcb_th - 4])
            cube([6, 12, 4]);
}

/* ---- core in its own local frame (front at z = 0) ----------------------- */
module core_assembly() {
    color([0.58, 0.59, 0.61]) core_tray();
    translate([0, 0, -CORE_DEPTH]) color([0.58, 0.59, 0.61]) core_cover();
    translate([0, 0, 0]) core_pcb_dummy();
}
