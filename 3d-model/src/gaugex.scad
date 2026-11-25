// ============================================================================
//  GaugeX - MAIN MODEL
//
//  Two-part modular cluster:
//     CORE  (core.scad)   fixed electronics module, same for every car
//     SHELL (shell.scad)  car-specific front shell, driven by presets.scad
//
//  USAGE
//    openscad -o out.stl -D 'PART="core_tray"'  gaugex.scad
//    openscad -o out.stl -D 'PART="shell"' -D 'PRESET="e90"' gaugex.scad
//    openscad -o out.png -D 'PART="assembly"' -D 'PRESET="e90"' gaugex.scad
//
//  PART: core_tray | core_cover | core_assembly | shell
//        assembly | exploded | fitcheck | section | stats
//  PRESET: generic (default) | e90 | clip | bracket
//  PRINT: shell rear plate down, core open back up, cover outer face down.
// ============================================================================

$fn = is_undef(FN) ? 48 : FN;

include <core.scad>
include <shell.scad>
include <presets.scad>

/* ===========================================================================
   ASSEMBLY
   =========================================================================== */
module core_placed() {
    translate([0, 0, CORE_FRONT_Z]) {
        color([0.58, 0.59, 0.61]) core_tray();
        color([0.05, 0.30, 0.10]) core_pcb_dummy();
        translate([0, 0, -CORE_DEPTH])
            color([0.50, 0.51, 0.53]) core_cover();
    }
}

module assembly() {
    color([0.34, 0.35, 0.37]) shell_preset(dummies = true);
    core_placed();
}

module exploded() {
    color([0.34, 0.35, 0.37]) shell_preset(dummies = true);

    translate([0, 0, -55]) color([0.58, 0.59, 0.61]) core_tray();
    translate([0, 0, -90]) color([0.05, 0.30, 0.10]) core_pcb_dummy();
    translate([0, 0, -125]) color([0.50, 0.51, 0.53]) core_cover();
}

// internal fit check: transparent shell, displays, tray + PCB, no cover
module fitcheck() {
    color([0.45, 0.47, 0.50], 0.30) shell_preset();
    shell_preset(dummies = true);
    translate([0, 0, CORE_FRONT_Z]) {
        color([0.58, 0.59, 0.61], 0.45) core_tray();
        color([0.05, 0.30, 0.10]) core_pcb_dummy();
    }
}

// half-section (removes y > 0) for stack-up verification
module section() {
    difference() {
        assembly();
        translate([-250, 0, -250]) cube([500, 300, 500]);
    }
}

/* ===========================================================================
   STATISTICS
   =========================================================================== */
module stats() {
    echo("=== GaugeX core (fixed) ===");
    echo(str("tray              = ", CORE_W, " x ", CORE_H, " x ", CORE_DEPTH));
    echo(str("pcb               = ", pcb_w, " x ", pcb_h));
    echo(str("pcb holes         = ", pcb_hole_spacing_x, " x ",
             pcb_hole_spacing_y));
    echo(str("pcb_z (local)     = ", pcb_z));
    echo(str("interface screws  = +/-", CORE_IFACE_X, ", +/-", CORE_IFACE_Y));
    echo(str("wire channel len  = ", display_wire_len));
    echo("=== Shell ===");
    echo(str("plate             = ", shell_plate_w, " x ", shell_plate_h));
    echo(str("rear plate z      = ", CORE_FRONT_Z));
    echo(str("base width/length = ", def_base_width, " / ", def_base_length));
    echo(str("selected preset   = ",
             is_undef(PRESET) ? "generic" : PRESET));
}

/* ===========================================================================
   DISPATCH
   =========================================================================== */
module dispatch() {
    if (is_undef(PART) || PART == "assembly") {
        if (!is_undef(EXPLODED) && EXPLODED) exploded();
        else assembly();
    }
    else if (PART == "core_tray")    core_tray();
    else if (PART == "core_cover")   core_cover();
    else if (PART == "core_assembly") core_assembly();
    else if (PART == "shell")        shell_preset();
    else if (PART == "exploded")     exploded();
    else if (PART == "fitcheck")     fitcheck();
    else if (PART == "section")      section();
    else if (PART == "stats")        stats();
    else echo(str("Unknown PART: ", PART));
}
dispatch();
