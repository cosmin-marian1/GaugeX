// ============================================================================
//  GaugeX - main file (tubes + wedge + base + back plate)
//
//  Usage:
//    openscad -o body.stl -D 'PART="body"' -D 'FN=96' gaugex.scad
//    openscad -o view.png -D 'PART="assembly"' -D 'FN=64' gaugex.scad
// ============================================================================
include <params.scad>
include <body.scad>
include <dummies.scad>
include <back_plate.scad>

module assembly() {
    color([0.32, 0.34, 0.37]) body();
    electronics_tilted();
    color([0.42, 0.44, 0.47]) back_plate();
}

module exploded() {
    color([0.32, 0.34, 0.37]) body();
    rotate([-TILT_ANGLE, 0, 0])
        translate([0, 0, 35]) displays_untilted();
    rotate([-TILT_ANGLE, 0, 0])
        translate([0, 0, -35]) pcb_untilted();
    rotate([-TILT_ANGLE, 0, 0])
        translate([0, 0, -55])
            color([0.62, 0.64, 0.67]) back_plate_untilted();
}

module enclosure() {
    body();
    back_plate();
}

module fitcheck() {
    color([0.32, 0.34, 0.37], 0.30) body();
    electronics_tilted();
    color([0.42, 0.44, 0.47], 0.30) back_plate();
}

module stats() {
    echo("=== GaugeX ===");
    echo(str("tube inner / OD    = ", TUBE_INNER_D, " / ", TUBE_OD));
    echo(str("tube pitch / span  = ", TUBE_PITCH, " / ", TUBE_SPAN));
    echo(str("shared wall        = ", SHARED_WALL));
    echo(str("estimated W x H x D = ", EST_WIDTH, " x ", EST_HEIGHT, " x ", EST_DEPTH));
    echo(str("back plate        = ", BACK_PLATE_W, " x ", BACK_PLATE_H, " x ", BACK_PLATE_TH));
echo(str("limits W x H x D    = ", MAX_W, " x ", MAX_H, " x ", MAX_D));
}

module dispatch() {
    if (is_undef(PART) || PART == "assembly") assembly();
    else if (PART == "body")      body();
    else if (PART == "back_plate") back_plate();
    else if (PART == "enclosure") enclosure();
    else if (PART == "exploded")  exploded();
    else if (PART == "fitcheck")  fitcheck();
    else if (PART == "stats")     stats();
    else echo(str("Unknown PART: ", PART));
}
dispatch();
