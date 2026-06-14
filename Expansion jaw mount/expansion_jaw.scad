// =============================================================================
//  expansion_jaw.scad  —  Wedge-driven 2-jaw expansion mount (slot anchor)
// =============================================================================
//  A parametric recreation + FDM enhancement of the Onshape "Expansion jaw".
//
//  WHAT IT IS
//  ----------
//  A 2-jaw spreader driven by a tapered wedge. Two mirrored jaws sit one above
//  the other with an inclined V-channel between them. A wedge rides in that V;
//  driving the wedge forward along Y (toward the operator) climbs the matched
//  10 deg faces and forces the jaws apart along Z. Collapsed, the jaw stack
//  slides into a slot; expanded, its outer faces clamp the slot's top & bottom.
//  A face plate on the front carries a vertical dovetail interface so any
//  accessory can be dropped onto the mount and is locked in X & Y by the
//  dovetail and held down by gravity.
//
//  Coordinate frame (Onshape Part Studio frame, kept here):
//      X = width  (across the jaws)
//      Y = depth  (-Y = front / room side,  +Y = back / into the slot)
//      Z = height (the expansion / spreading axis;  jaws mirror across Z=0)
//
//  See README.md in this folder for the full mechanism write-up, the mounting
//  standard, the dovetail interface spec, and assembly/print notes.
// =============================================================================

// ---- Process / machine (house defaults) -------------------------------------
nozzle_d = 0.4;
line_w   = 0.42;
layer_h  = 0.2;
material = "PETG";            // "PLA" | "PETG" -> drives the fits below
$fn      = 48;               // raise to 96+ for final export

// ---- Walls / shells ----
wall    = 6 * line_w;        // 2.52 mm, whole-perimeter multiple
floor_t = 2.4;               // >= 4 layers

// ---- Fits (per side; auto-loosened for PETG) ----
fit_slip  = (material == "PETG") ? 0.30 : 0.20;   // moving / sliding
fit_snug  = (material == "PETG") ? 0.20 : 0.10;   // locating
fit_press = (material == "PETG") ? 0.05 : 0.00;   // interference
insert_d  = (material == "PETG") ? 4.2  : 4.0;    // M3 heat-set bore

// =============================================================================
//  RENDER SELECTION
// =============================================================================
part    = "assembly";   // "assembly" | "jaws" | "top_jaw" | "bottom_jaw"
                        // | "wedge" | "face_plate" | "accessory" | "interface_test"
explode = 0;            // mm: pull parts apart along their assembly axes for clarity
show_slot = true;       // draw a translucent mock slot in the assembly view

// =============================================================================
//  MECHANISM PARAMETERS  (named exactly as the Onshape model where possible)
// =============================================================================
Jaws_width  = 20;   // jaw extent along X
Jaws_depth  = 25;   // jaw extent along Y (= how deep the jaws sit in the slot)
Jaws_height = 41;   // collapsed stacked height of the jaw block along Z
Angle_jaws  = 80;   // [deg] inclined channel/wedge face angle vs. the base
incline     = 90 - Angle_jaws;          // = 10 deg half-V incline from the Y axis
wedge_depth = 15;   // wedge extent along Y

// ---- Slot the mount grips (bathroom ledge reveal). Fully parametric. --------
// Collapsed jaws must insert (outer height < slot_gap); the wedge then expands
// them to bite. Default leaves the original 41 mm envelope; set to your slot.
slot_gap    = Jaws_height + 1.0;   // vertical opening of the slot (Z)
slot_depth  = Jaws_depth + 6;      // how deep the slot runs (Y), for the mock

// ---- Derived jaw channel geometry -------------------------------------------
half_h    = Jaws_height / 2;                       // 20.5  outer face |Z|
gap_front = 3.5;                                   // inner half-gap at front (-Y)
gap_back  = gap_front + tan(incline) * Jaws_depth; // ~7.91 inner half-gap at back

// ---- Wedge geometry ---------------------------------------------------------
// Same 10 deg faces as the channel; thick at the back so drawing it forward
// (toward the face plate) feeds the thick section into the jaw zone -> spread.
wedge_front_h = 4.5;                                       // half-height, front
wedge_back_h  = wedge_front_h + tan(incline) * wedge_depth; // ~7.14, back
wedge_y0      = -6.83;                                     // front face Y
wedge_y1      = wedge_y0 + wedge_depth;                    // back face Y (~8.17)
wedge_tab     = 1.0;                                       // end retainer tab thickness
wedge_tab_h   = 9.14;                                      // tab half-height (end stop)

// ---- Visual language --------------------------------------------------------
edge   = 3.0;     // rounded vertical-edge radius on the face plate / accessory
rim_ch = 1.0;     // chamfer on mouths / lead-in edges
cham   = 2.0;     // main outer chamfer (Onshape "Chamfer 1")

// ---- Grip teeth on the clamping faces ---------------------------------------
// A clean inset field of directional sawteeth (steep face toward the front so
// they BITE when the mount is pulled out of the slot, ramp gently on insertion).
// The field is inset from every edge so it never collides with the chamfers.
grip_teeth   = false;        // OFF by default: on a hard slot (tile/stone/metal)
                            //   a FLAT face grips better (see README). Turn on
                            //   only for a soft slot (wood/plaster/plastic).
tooth_h      = 0.5;          // ridge height
tooth_pitch  = 1.6;          // fine, refined texture
tooth_margin = 3.0;          // inset from the side & front edges

// ---- Drive screw (a SINGLE M4 that closes the whole clamp force loop) --------
// Head countersunk in the face-plate front -> shaft through the centre gap
// between the jaws -> threads into the wedge. Tightening draws the wedge forward
// (spreads the jaws) AND sandwiches the face plate against the jaw fronts, so no
// separate anchor screws are needed: ONE fastener does everything.
drive_clear = 4.4;          // M4 free-clearance shaft
drive_pilot = 3.5;          // M4 self-tap pilot into the wedge (set-and-forget). 3.5
                            // (not 3.3): PETG bores print ~0.1-0.15mm undersize and a
                            // tighter pilot is hard to drive / risks splitting the wedge.
screw_head  = "socket";     // "socket" = counter-bore for allen-key socket-cap screw | "flat" = 90-deg countersunk
csk_d       = 9.4;          // flat-head 90-deg countersink rim dia. Depth is DERIVED
                            // = (csk_d-drive_clear)/2 = 2.5mm, enough to fully bury a
                            // DIN 965 M4 head (~2.5mm tall). Use a 90-deg MACHINE screw,
                            // not an 82-deg wood screw, or the head sits proud.
head_d      = 7.4;          // socket-head dia + clearance (counter-bore option)
head_h      = 4.5;          // socket counter-bore depth. M4 cap head is 4.0mm tall (max),
                            // so bore 0.5mm deeper -> head recesses sub-flush even with
                            // elephant's-foot/first-layer squish eating the bore bottom.

// =============================================================================
//  DOVETAIL MOUNTING INTERFACE  (the reusable standard — see README)
// =============================================================================
//  Two vertical dovetail slots in the face plate; accessories carry the two
//  matching male tenons and drop in from the top (locked in X & Y, held by
//  gravity). Keep these in sync between the mount and every accessory file.
dt_pitch = 20;     // centre-to-centre spacing of the two tails (=> X = +-10)
dt_mouth = 5.2;    // narrow (front/mouth) width of the dovetail
dt_base  = 12.0;   // wide (deep) width of the dovetail
dt_depth = 4.1;    // depth of the dovetail into the plate (along +Y)
dt_run_z = Jaws_height;   // the slots run the full plate height (Z)
dt_cham  = 0.7;    // 45-deg CHAMFER on every corner -> relieves the slot roots
                  //   and breaks the tenon tips, while the locking FLANKS stay
                  //   dead straight for full-face contact (no soft/round look)
dt_lead  = 1.8;    // 45-deg lead-in: funnel on the slot top + point on the tenon
                  //   bottom, so the accessory self-aligns as it drops in

// 2D dovetail in the (X,Y) cut plane: mouth at y=0 widening to +Y. Corners are
// chamfered (not rounded): on the female cut the chamfer relieves the root
// corners (printable, nozzle reaches them); on the male tenon it breaks the
// sharp tips. The straight flanks are untouched, so the joint still locks
// solidly. The same profile drives BOTH halves -> they can't drift apart.
module dovetail_profile_2d(clr = 0) {
    offset(delta = dt_cham, chamfer = true) offset(delta = -dt_cham, chamfer = true)
        polygon([
            [-dt_mouth/2 - clr, 0],
            [ dt_mouth/2 + clr, 0],
            [ dt_base/2  + clr, dt_depth],
            [-dt_base/2  - clr, dt_depth],
        ]);
}

// Female slot, swept `h` along Z (the slide axis) and centred, with a flared
// funnel mouth at the TOP (+Z) so a dropped-in tenon is captured even if a
// little off. Printed Z-up this is a constant-section extrusion = no overhang.
module dovetail_slot(h, clr = 0) {
    union() {
        linear_extrude(height = h + 2*eps, center = true) dovetail_profile_2d(clr);
        translate([0, 0, h/2 - dt_lead])               // flare the top entry
            hull() {
                linear_extrude(eps) dovetail_profile_2d(clr);
                translate([0, 0, dt_lead])
                    linear_extrude(eps) offset(delta = dt_lead, chamfer = true) dovetail_profile_2d(clr);
            }
    }
}

// Male tenon, swept `h` along Z and centred, with a 45-deg lead-in point at the
// BOTTOM (-Z, the end that enters the slot first). `clr` is negative for slip.
module dovetail_tenon(h, clr = -fit_slip) {
    translate([0, 0, -h/2])
        union() {
            translate([0, 0, dt_lead])
                linear_extrude(height = h - dt_lead) dovetail_profile_2d(clr);
            hull() {                                   // taper the entering tip
                translate([0, 0, dt_lead])
                    linear_extrude(eps) dovetail_profile_2d(clr);
                linear_extrude(eps) offset(delta = -dt_lead, chamfer = true) dovetail_profile_2d(clr);
            }
        }
}

// =============================================================================
//  LOW-LEVEL HELPERS
// =============================================================================
eps = 0.02;

// Sweep a 2D (Y,Z) polygon `len` mm along +X. Maps polygon-x -> Y, polygon-y -> Z.
module prismX(len) {
    multmatrix([[0,0,1,0],
                [1,0,0,0],
                [0,1,0,0],
                [0,0,0,1]])
        linear_extrude(height = len) children();
}

// Rounded rectangle (vertical-edge rounding) in 2D.
module rrect(w, h, r) {
    offset(r) offset(-r) square([w, h], center = true);
}

// =============================================================================
//  JAWS
// =============================================================================
// Cross-section of the TOP jaw in the (Y,Z) plane, swept along X and centred:
//   outer (top) face flat at Z = half_h
//   inner (bottom) face inclined: gap_front at -Y up to gap_back at +Y
module top_jaw_profile() {
    polygon([
        [-Jaws_depth/2, gap_front],   // front-inner
        [ Jaws_depth/2, gap_back ],   // back-inner
        [ Jaws_depth/2, half_h  ],    // back-outer
        [-Jaws_depth/2, half_h  ],    // front-outer
    ]);
}

// Clean directional grip pad on a clamping face. `face_z` = the outer face Z,
// `dir` = +1 (top jaw) / -1 (bottom jaw). The sawtooth field is generated, then
// intersected with an inset footprint so it stays clear of every edge & chamfer.
module grip_pad(face_z, dir) {
    y0   = -Jaws_depth/2 + tooth_margin;             // clear of the front edge
    y1   =  Jaws_depth/2 - cham - tooth_margin;      // clear of the back chamfer
    x_in =  Jaws_width/2 - tooth_margin;             // clear of both side edges
    n    =  floor((y1 - y0) / tooth_pitch);
    intersection() {
        union()                                       // directional sawteeth
            for (i = [0 : n - 1]) {
                yt = y0 + i * tooth_pitch;
                translate([-x_in, yt, face_z])
                    prismX(2 * x_in)
                        // steep (biting) face toward -Y, ramp toward +Y
                        polygon([[0, 0], [0, dir*tooth_h], [tooth_pitch, 0]]);
            }
        translate([-x_in, y0, face_z - (tooth_h + 1)])  // clip to inset footprint
            cube([2*x_in, y1 - y0, 2*(tooth_h + 1)]);
    }
}

// One consistent lead-in chamfer on an outer top edge of the jaw. `ys` = +1 for
// the back (insertion) edge, -1 for the front edge; `c` = chamfer size.
module jaw_edge_chamfer(ys, c) {
    translate([0, ys * Jaws_depth/2, half_h])
        rotate([45, 0, 0])
            translate([-Jaws_width/2 - eps, -c, -c])
                cube([Jaws_width + 2*eps, 2*c, 2*c]);
}

module top_jaw() {
    union() {
        difference() {
            translate([-Jaws_width/2, 0, 0])
                prismX(Jaws_width) top_jaw_profile();
            jaw_edge_chamfer(+1, cham);     // back/insertion lead-in (bigger)
            jaw_edge_chamfer(-1, rim_ch);   // front edge, consistent soft break
        }
        if (grip_teeth) grip_pad(half_h, +1);
    }
}

module bottom_jaw() { mirror([0, 0, 1]) top_jaw(); }

// =============================================================================
//  WEDGE
// =============================================================================
// Trapezoidal prism: half-height grows from wedge_front_h to wedge_back_h over
// wedge_depth (matched 10 deg faces). End tabs cap each side as retainers so the
// wedge cannot slide out along X.
// `clr` shrinks the wedge off the inclined faces so it can actually slide in
// the channel (nominal faces are exactly coincident with the jaws).
module wedge_core_profile(clr = 0) {
    polygon([
        [wedge_y0, -(wedge_front_h - clr)],
        [wedge_y1, -(wedge_back_h  - clr)],
        [wedge_y1,   wedge_back_h  - clr ],
        [wedge_y0,   wedge_front_h - clr ],
    ]);
}

module wedge() {
    difference() {
        union() {
            // core, centred across X (slip-fit off the inclined faces)
            translate([-Jaws_width/2, 0, 0])
                prismX(Jaws_width) wedge_core_profile(fit_slip);
            // retainer tabs on each X end, a touch taller than the core
            for (sx = [-1, 1])
                translate([sx * (Jaws_width/2), 0, 0]) {
                    if (sx < 0) translate([-wedge_tab, 0, 0]) wedge_tab();
                    else                                      wedge_tab();
                }
        }
        // drive-screw pocket in the FRONT face (pilot or heat-set insert bore)
        translate([0, wedge_y0 - eps, 0])
            rotate([-90, 0, 0])
                cylinder(d = drive_pilot, h = wedge_depth * 0.7);
    }
}

module wedge_tab() {
    translate([0, 0, 0])
        prismX(wedge_tab)
            polygon([
                [wedge_y0, -wedge_tab_h],
                [wedge_y1, -wedge_tab_h],
                [wedge_y1,  wedge_tab_h],
                [wedge_y0,  wedge_tab_h],
            ]);
}

// =============================================================================
//  FACE PLATE  (mount-side: carries the female dovetail interface)
// =============================================================================
fp_w  = 40;                       // X
fp_h  = Jaws_height;              // Z (= 41)
fp_t  = 7.5;                      // Y thickness
fp_y0 = -Jaws_depth/2 - fp_t;     // front face Y (sits against the jaw fronts)
fp_y1 = -Jaws_depth/2;            // back face Y

module face_plate() {
    difference() {
        // plate with rounded vertical edges, extruded along Y
        translate([0, fp_y0, 0])
            rotate([-90, 0, 0])
                linear_extrude(height = fp_t)
                    rrect(fp_w, fp_h, edge);
        // --- two female dovetail slots: run the FULL height along Z, mouth at
        //     the front face widening into +Y, open top & bottom so an accessory
        //     can be dropped in from the top and is locked in X & Y ---
        for (sx = [-1, 1])
            translate([sx * dt_pitch/2, fp_y0, 0])
                dovetail_slot(fp_h, 0);
        // --- single drive screw: countersunk head in the front, shaft through
        //     to the wedge (the head seat is the only fastener feature) ---
        drive_screw_cut();
    }
}

// The drive-screw cut, opening at the face-plate FRONT (-Y) along +Y at Z=0.
module drive_screw_cut() {
    translate([0, fp_y0 - eps, 0])
        rotate([-90, 0, 0]) {
            cylinder(d = drive_clear, h = fp_t + 2*eps);          // shaft
            if (screw_head == "flat")                              // 90-deg countersink
                cylinder(d1 = csk_d, d2 = drive_clear, h = (csk_d - drive_clear)/2 + eps);
            else {                                                 // socket counter-bore
                cylinder(d = head_d, h = head_h);
                cylinder(d1 = csk_d, d2 = head_d, h = (csk_d - head_d)/2 + eps);  // mouth chamfer
            }
        }
}

// =============================================================================
//  ACCESSORY BASE  (accessory-side: carries the male dovetail tenons)
// =============================================================================
// This is the module future accessory files reuse: build your object, then add
// accessory_base() on its back so it keys onto the mount's face plate.
acc_w  = 31;                  // block X
acc_h  = 23;                  // block Z
acc_t  = 4;                   // backing-plate thickness (Y) behind the tenons
acc_y1 = fp_y0;               // tenon tips meet the plate front
acc_y0 = acc_y1 - acc_t;      // back of the accessory backing plate

module accessory_base() {
    // backing plate
    translate([0, acc_y0, 0])
        rotate([-90, 0, 0])
            linear_extrude(height = acc_t)
                rrect(acc_w, acc_h, edge);
    // two male tenons reaching into the face-plate slots (slip fit, run the
    // accessory's full height along Z, lead-in point at the bottom for drop-in)
    for (sx = [-1, 1])
        translate([sx * dt_pitch/2, fp_y0, 0])
            dovetail_tenon(acc_h, -fit_slip);
}

// =============================================================================
//  MOCK SLOT  (visual aid only)
// =============================================================================
module mock_slot() {
    color([0.6, 0.7, 0.8, 0.25])
        difference() {
            translate([-fp_w/2 - 5, -Jaws_depth/2, -slot_gap/2 - 10])
                cube([fp_w + 10, slot_depth, slot_gap + 20]);
            translate([-fp_w/2 - 5 - eps, -Jaws_depth/2 - eps, -slot_gap/2])
                cube([fp_w + 10 + 2*eps, slot_depth + 2*eps, slot_gap]);
        }
}

// =============================================================================
//  ASSEMBLY
// =============================================================================
module assembly() {
    e = explode;
    color("LightSteelBlue") translate([0, 0,  e]) top_jaw();
    color("LightSteelBlue") translate([0, 0, -e]) bottom_jaw();
    color("Khaki")          translate([0, -e, 0]) wedge();
    color("Gainsboro")      translate([0, -2*e, 0]) face_plate();
    color("DarkSeaGreen")   translate([0, -4*e, 0]) accessory_base();
    if (show_slot) mock_slot();
}

// =============================================================================
//  DISPATCH
// =============================================================================
if      (part == "assembly")    assembly();
else if (part == "jaws")        { top_jaw(); bottom_jaw(); }
else if (part == "top_jaw")     top_jaw();
else if (part == "bottom_jaw")  bottom_jaw();
else if (part == "wedge")       wedge();
else if (part == "face_plate")  face_plate();
else if (part == "accessory")   accessory_base();
else if (part == "interface_test") { face_plate(); accessory_base(); }
else if (part == "none")        { /* no-op: lets accessory files include this
                                     file for the dovetail standard + modules
                                     without rendering the jaw assembly */ }
else assembly();
