// ============================================================================
//  GaugeX - CAR PRESETS
//
//  Each preset overrides SHELL parameters only.  It never touches the core:
//  the electronics module is identical in every car.
//
//  Select with:  -D PRESET="e90"   (default is "generic")
//  "dummies" is a fit-check flag, not a car parameter.
// ============================================================================

module preset_generic(dummies = false) {
    shell(
        arc_radius        = 320,
        display_spacing   = 50,
        toe_in            = 0,
        tilt              = 6,
        hood_depth        = 5,
        base_type         = "flat",
        base_curve_radius = 400,
        base_width        = 110,
        base_length       = 34,
        dummies           = dummies
    );
}

module preset_e90(dummies = false) {
    shell(
        arc_radius        = 260,
        display_spacing   = 52,
        toe_in            = 4,
        tilt              = 11,
        hood_depth        = 8,
        base_type         = "curved",
        base_curve_radius = 300,
        base_width        = 118,
        base_length       = 44,
        dummies           = dummies
    );
}

module preset_clip(dummies = false) {
    shell(
        arc_radius        = 300,
        display_spacing   = 50,
        toe_in            = 2,
        tilt              = 8,
        hood_depth        = 6,
        base_type         = "clip",
        base_curve_radius = 380,
        base_width        = 112,
        base_length       = 40,
        dummies           = dummies
    );
}

module preset_bracket(dummies = false) {
    shell(
        arc_radius        = 340,
        display_spacing   = 50,
        toe_in            = 0,
        tilt              = 5,
        hood_depth        = 5,
        base_type         = "bracket",
        base_curve_radius = 400,
        base_width        = 120,
        base_length       = 48,
        dummies           = dummies
    );
}

/* ---- selector ----------------------------------------------------------- */
module shell_preset(dummies = false) {
    if (PRESET == "e90")          preset_e90(dummies = dummies);
    else if (PRESET == "clip")    preset_clip(dummies = dummies);
    else if (PRESET == "bracket") preset_bracket(dummies = dummies);
    else                          preset_generic(dummies = dummies);
}
