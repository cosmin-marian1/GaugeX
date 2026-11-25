// ============================================================================
//  GaugeX - parameters (single source of truth)
//  Units: mm.  All dimensions are nominal unless marked VERIFY.
// ============================================================================

/* ---- hard limits --------------------------------------------------------- */
MAX_W               = 130.0;
MAX_H               = 50.0;
MAX_D               = 45.0;
MIN_WALL            = 1.6;

/* ---- display module (GC9A01 1.28") --------------------------------------- */
N_GAUGES            = 3;
DISPLAY_PCB_D       = 40.0;   // VERIFY with calipers
DISPLAY_ACTIVE_D    = 32.4;   // VERIFY
DISPLAY_GLASS_D     = 35.5;   // VERIFY
DISPLAY_TH          = 5.0;    // VERIFY

/* ---- tubes --------------------------------------------------------------- */
TUBE_CLEARANCE      = 0.6;    // diametral clearance
TUBE_WALL           = 1.8;    // allowed range 1.6 .. 2.0
TUBE_OVERLAP        = 2.0;    // radial overlap between neighbouring tubes
TUBE_DEPTH          = 14.0;
FRONT_OPENING_D     = 37.5;   // hides PCB edge, clears the image
FRONT_LIP_W         = 1.2;
FRONT_CHAMFER       = 0.8;
BACK_LIP_W          = 1.2;    // base of each rear retention clip

CLIP_COUNT          = 3;
CLIP_TH             = 1.2;
CLIP_REACH         = 1.3;    // radial reach inward from tube wall
CLIP_Z0             = -8.6;  // rear end of clip
CLIP_Z1             = -6.5;  // front lip, behind display PCB

CABLE_NOTCH_W       = 8.0;
CABLE_NOTCH_H       = 6.0;
CABLE_NOTCH_D       = 6.8;

/* ---- hood / orientation -------------------------------------------------- */
HOOD_DEPTH          = 5.0;    // 0 disables the hood
HOOD_WALL           = 1.2;
HOOD_FLARE          = 0.8;
TILT_ANGLE          = 15.0;   // tubes + wedge + back plate; base stays flat
SIDE_TOE_IN         = 0.0;    // degrees, outer tubes only

/* ---- wedge body ---------------------------------------------------------- */
WEDGE_FRONT_Z       = -TUBE_DEPTH + 0.6;  // overlaps tube backs by 0.6
WEDGE_BACK_Z        = -25.5;
WEDGE_WIDTH         = 129.8;
WEDGE_FRONT_H       = 49.0;
WEDGE_REAR_H        = 44.8;
WEDGE_RADIUS        = 3.0;
CAVITY_FRONT_Z      = -15.5;  // leaves a 2.1 mm front wall
CAVITY_W            = 116.0;
CAVITY_H            = 41.6;
CAVITY_R            = 3.0;

/* ---- flat base ----------------------------------------------------------- */
BASE_W              = 128.0;
BASE_L              = 28.0;
BASE_TH             = 2.4;
BASE_R              = 3.0;
BASE_Z_CENTER       = -4.0;

/* ---- main PCB (behind centre tube only) --------------------------------- */
PCB_W               = 50.0;
PCB_H               = 40.0;
PCB_TH              = 1.6;
PCB_HOLE_X          = 44.0;
PCB_HOLE_Y          = 34.0;
STANDOFF_H          = 5.0;
PCB_Z               = CAVITY_FRONT_Z - STANDOFF_H;   // -20.5

M2P5_INSERT_D       = 4.2;    // VERIFY with real insert
M2P5_INSERT_DEPTH   = 4.0;
M2P5_BOSS_WALL      = 1.6;
M2P5_BOSS_D         = M2P5_INSERT_D + 2*M2P5_BOSS_WALL;

/* ---- back-plate interface (holes/bosses are part of STEP 1) -------------- */
BACK_PLATE_W        = 120.0;
BACK_PLATE_H        = 43.5;
BACK_PLATE_TH       = 3.0;
BACK_PLATE_R        = 4.0;
BACK_SCREW_DX       = 38.0;
BACK_SCREW_DY       = 14.0;
M3_INSERT_D         = 4.6;    // VERIFY
M3_INSERT_DEPTH     = 5.5;
M3_CLEAR_D          = 3.4;
M3_HEAD_D           = 6.4;
M3_HEAD_DEPTH       = 1.8;
M3_BOSS_D           = 8.2;
PLATE_LIP_H         = 1.2;
PLATE_LIP_W         = 1.4;

BUTTON_D            = 12.0;
BUTTON_SPACING      = 20.0;
BUTTON_Y            = -10.0;
CABLE_SLOT_W        = 20.0;
CABLE_SLOT_H        = 8.0;
CABLE_SLOT_Y        = 10.0;

/* ---- tolerances / resolution --------------------------------------------- */
FIT_TOL             = 0.2;
EPS                 = 0.01;
$fn                 = is_undef(FN) ? 48 : FN;

/* ---- derived tube dimensions -------------------------------------------- */
TUBE_INNER_D        = DISPLAY_PCB_D + TUBE_CLEARANCE;          // 40.6
TUBE_OD             = TUBE_INNER_D + 2*TUBE_WALL;              // 44.2
TUBE_PITCH          = TUBE_OD - TUBE_OVERLAP;                  // 42.2
TUBE_SPAN           = TUBE_OD + (N_GAUGES-1)*TUBE_PITCH;        // 128.6
SHARED_WALL         = 2*TUBE_WALL - TUBE_OVERLAP;               // 1.6

/* ---- analytic envelope (actual STL bbox is checked separately) ---------- */
TUBE_MIN_Y          = -(TUBE_OD/2)*cos(TILT_ANGLE) - TUBE_DEPTH*sin(TILT_ANGLE);
WEDGE_MIN_Y         = -(WEDGE_REAR_H/2)*cos(TILT_ANGLE) + WEDGE_BACK_Z*sin(TILT_ANGLE);
WEDGE_FRONT_MIN_Y   = -(WEDGE_FRONT_H/2)*cos(TILT_ANGLE) + WEDGE_FRONT_Z*sin(TILT_ANGLE);
WEDGE_FRONT_MAX_Y   =  (WEDGE_FRONT_H/2)*cos(TILT_ANGLE) + WEDGE_FRONT_Z*sin(TILT_ANGLE);
BASE_BOTTOM_Y       = min(TUBE_MIN_Y, WEDGE_MIN_Y, WEDGE_FRONT_MIN_Y) - 0.05;
TUBE_MAX_Y          =  (TUBE_OD/2)*cos(TILT_ANGLE);
HOOD_MAX_Z          = (FRONT_OPENING_D/2 + HOOD_WALL + HOOD_FLARE)*sin(TILT_ANGLE)
                       + HOOD_DEPTH*cos(TILT_ANGLE);
BODY_MIN_Z          = -(WEDGE_REAR_H/2)*sin(TILT_ANGLE) + WEDGE_BACK_Z*cos(TILT_ANGLE);
EST_WIDTH           = TUBE_SPAN;
EST_HEIGHT          = max(TUBE_MAX_Y, WEDGE_FRONT_MAX_Y) - BASE_BOTTOM_Y;
EST_DEPTH           = HOOD_MAX_Z - BODY_MIN_Z;
