// =============================================================================
// Desk organizer  --  MagSafe phone stand + tool / pen / drive caddy
//   Holds:  1x Apple MagSafe puck + iPhone 15 Pro (laid-back StandBy angle)
//           3x 3D-printing tools (flush cutters / deburring tool)
//           2x pens
//           3x USB drives
//           1x SD card
//           1x TV remote (lies flat in a front tray)
//
// FORM: an ascending terrace -- low remote tray at the FRONT, stepping up to the
//   USB/SD bank, then up to the deep tool/pen wells at the BACK-LEFT, with the
//   MagSafe stand rising at the BACK-RIGHT. Tall items live at the back so the
//   sightline stays calm from the user's seat at the front (-Y).
//
// PRINTING: modelled already in print orientation -- it prints FLAT on its base,
//   base-side down, ALL wells vertical => support-free. The single exception is
//   the puck recess: it is bored into a 50 deg face, so its upper rim is a ~50 deg
//   overhang. A 2 mm 45 deg chamfered lead-in + shallow (6 mm) depth makes it
//   bridge cleanly on a 0.4 mm nozzle. If it ever sags, lower `phone_angle`
//   (lay the phone back further) -- that rotates the rim toward vertical.
//   PLA, 0.4 mm nozzle, 0.2 mm layers, 3-4 walls, 15% infill. No supports.
//
//   openscad -o organizer.stl -D 'part="print"' desk_organizer.scad
//   openscad -o preview.png --render -D 'part="assembly"' -D show_items=true desk_organizer.scad
// =============================================================================

part       = "assembly";  // "print" (the part alone) | "assembly" (+ mock items)
show_items = false;        // translucent phone / puck / remote in assembly view

$fn = 64;                  // raise to 128 for final export (smooths the 56 mm puck)

// ---- Process / machine (house defaults; see CLAUDE.md) ----------------------
nozzle_d = 0.4;
line_w   = 0.42;
layer_h  = 0.2;
material = "PLA";          // "PLA" | "PETG"  -> drives the loose-fit clearances

// ---- Walls / shells ---------------------------------------------------------
wall    = 6 * line_w;      // 2.52 mm -> whole 6 perimeters, no slicer gap-fill
floor_t = 3.0;             // 15 layers -> a stiff, non-drumming base

// ---- Visual language: one radius, one chamfer everywhere --------------------
edge   = 3.0;              // outer vertical-corner radius (every block reuses it)
top_ch = 0.8;             // top-edge chamfer / soft reveal between zones
rim_ch = 1.2;             // chamfered lead-in at every well/slot mouth

// ---- Fits: loose hand clearances (PLA tight, PETG looser) -------------------
//  Drives, pens, tools and the remote are dropped in/out by hand, so they get a
//  generous slip -- enough to grab, never a fight. The puck is set once, so it
//  gets a snug retaining fit.
k        = (material == "PETG") ? 1.0 : 0.0;   // PETG ooze allowance (mm/side)
tool_clr = 1.0 + k;
pen_clr  = 1.0 + k;
usb_clr  = 0.8 + k;
sd_clr   = 0.5 + k;
rem_clr  = 1.2 + k;
puck_clr = 0.25 + k;       // snug -- the puck should stay seated

// ---- Item nominal sizes (bodies, mm) ----------------------------------------
tool_d  = 18;  tool_depth = 50;     // cutter / deburring-tool handle
pen_d   = 11;  pen_depth  = 46;
usb_w   = 20;  usb_t = 11;  usb_depth = 28;   // USB-A flash drive stood upright
sd_w    = 24;  sd_t  = 2.1; sd_depth  = 16;   // full-size SD card
rem_l   = 178; rem_w = 48;  rem_t = 22;        // standard TV remote, lying flat
puck_d  = 56;  puck_t = 5.5;                    // Apple MagSafe charger puck

// ---- Derived well openings (nominal + clearance per side) -------------------
tool_o = tool_d + 2*tool_clr;     // 20
pen_o  = pen_d  + 2*pen_clr;      // 13
usb_ox = usb_w  + 2*usb_clr;      // 21.6
usb_oy = usb_t  + 2*usb_clr;      // 12.6
sd_ox  = sd_w   + 2*sd_clr;       // 25
sd_oy  = sd_t   + 2*sd_clr;       // 3.1
rem_ox = rem_l  + 2*rem_clr;      // 180.4
rem_oy = rem_w  + 2*rem_clr;      // 50.4
puck_o = puck_d + 2*puck_clr;     // 56.5

// ---- Block heights (the terrace) --------------------------------------------
h_tray = 16;   // front remote tray
h_usb  = 34;   // USB / SD bank
h_tool = 56;   // deep tool / pen wells

// ---- Layout anchors (origin = front-left-bottom; +X right, +Y back, +Z up) --
// Left caddy: x[6..122].  Front->back rows share these blocks.
cad_x0 = 6;   cad_x1 = 122;

// Tool/pen row centres (cumulative, left->right: 3 tools then 2 pens) @ y_back
y_back = 105;
m_in   = 4;   gw = 5;                       // edge inset, gap between wells
t1 = cad_x0 + m_in + tool_o/2;              // 20
t2 = t1 + tool_o + gw;                      // 45
t3 = t2 + tool_o + gw;                      // 70
p1 = t3 + tool_o/2 + gw + pen_o/2;          // 91.5
p2 = p1 + pen_o + gw;                       // 109.5

// USB/SD row centres @ y_front
y_front = 71;
gu = 6;
u1 = cad_x0 + m_in + usb_ox/2;              // 20.8
u2 = u1 + usb_ox + gu;                      // 48.4
u3 = u2 + usb_ox + gu;                      // 76.0
sd_cx = u3 + usb_ox/2 + gu + sd_ox/2;       // 105.3

// MagSafe stand footprint (back-right)
phone_angle = 50;                            // deg from horizontal (StandBy lean)
stand_x0 = 128; stand_w = 64;                // x[128..192]
stand_y0 = 64;  stand_d = 84;                // y[64..148] -- deep enough that the
                                             // 50 deg face fully contains the puck
                                             // pocket (puck centre is 83 mm up-slope)
stand_zH = stand_d * tan(phone_angle);       // back height where hypotenuse meets top
puck_x   = stand_x0 + stand_w/2;             // 160
mag_h    = 83;                               // puck centre, mm up the slope from phone foot
puck_y   = stand_y0 + mag_h * cos(phone_angle);
puck_z   =            mag_h * sin(phone_angle);
recess_depth = 6;  recess_ch = 2.0;          // puck pocket depth + 45 deg lead-in
lip_h    = 12;                               // phone-foot catch lip

// Remote tray (front strip)
tray_cx = 97; tray_cy = 30.5;                // centre of front block x[4..190] y[3..58]

// =============================================================================
// 2D + box helpers
// =============================================================================
module rrect(sx, sy, r)   offset(r) offset(-r) square([sx, sy]);             // corner
module rrect_c(sx, sy, r) offset(r) offset(-r) square([sx, sy], center=true); // centred

// Soft block: rounded vertical edges + a small top-edge chamfer (built at origin).
module soft_box(sx, sy, sz, r, ch) {
    hull() {
        linear_extrude(sz - ch) rrect(sx, sy, r);
        translate([ch, ch, sz - ch])
            linear_extrude(ch) rrect(sx - 2*ch, sy - 2*ch, max(r - ch, 0.1));
    }
}

// =============================================================================
// Cutters (subtracted from the body). Each opens at `top_z` and drops `depth`,
// with a chamfered mouth and a small overshoot above the surface for a clean cut.
// =============================================================================
module cut_round(cx, cy, d, depth, top_z, ch = rim_ch) {
    translate([cx, cy, 0]) {
        translate([0, 0, top_z - depth]) cylinder(d = d, h = depth + 0.1);
        translate([0, 0, top_z - ch])    cylinder(d1 = d, d2 = d + 2*ch, h = ch);
        translate([0, 0, top_z - 0.01])  cylinder(d = d + 2*ch, h = 2);
    }
}

module cut_rect(cx, cy, sx, sy, depth, top_z, r = 2, ch = rim_ch) {
    translate([cx, cy, 0]) {
        translate([0, 0, top_z - depth]) linear_extrude(depth + 0.1) rrect_c(sx, sy, r);
        hull() {
            translate([0, 0, top_z - ch]) linear_extrude(0.01) rrect_c(sx, sy, r);
            translate([0, 0, top_z])      linear_extrude(0.01) rrect_c(sx + 2*ch, sy + 2*ch, r);
        }
        translate([0, 0, top_z - 0.01]) linear_extrude(2) rrect_c(sx + 2*ch, sy + 2*ch, r);
    }
}

// =============================================================================
// MagSafe stand: a 50 deg wedge with the puck pocket bored into its face and a
// phone-foot catch lip. The puck cable is hidden by cable_conduit() (cut in
// body() so it also passes the base slab): it drops off the pocket's lower rim
// inside the wedge and exits the REAR at desk level -> invisible from the front.
// =============================================================================
module puck_cut() {
    translate([0, 0, -recess_depth]) cylinder(d = puck_o, h = recess_depth + 0.1);
    cylinder(d1 = puck_o, d2 = puck_o + 2*recess_ch, h = recess_ch);           // chamfer mouth
    translate([0, 0, recess_ch - 0.01]) cylinder(d = puck_o + 2*recess_ch, h = 8); // overshoot
}

module mag_stand() {
    difference() {
        union() {
            // Wedge = bounding box minus everything above the 50 deg hypotenuse
            // (the hypotenuse runs from the phone foot at (stand_y0,0) up to the
            // back-top corner). The up-facing slope prints support-free.
            difference() {
                translate([stand_x0, stand_y0, 0]) cube([stand_w, stand_d, stand_zH + 1]);
                translate([stand_x0 - 5, stand_y0, 0])
                    rotate([phone_angle, 0, 0])
                        translate([0, -300, 0]) cube([stand_w + 10, 600, 600]);
            }
            // Phone-foot catch lip (rounded), just in front of the slope base
            hull() {
                translate([puck_x - 30, stand_y0 - 3.5, 0])     cube([60, 0.1, lip_h]);
                translate([puck_x - 30, stand_y0 - 1.5, 0])     cube([60, 0.1, lip_h - 2]);
            }
        }
        // Puck pocket, normal to the slope face
        translate([puck_x, puck_y, puck_z]) rotate([phone_angle, 0, 0]) puck_cut();
        // (cable conduit is cut in body() so it also passes through the base slab)
    }
}

// Hidden cable conduit: the puck cable drops off the pocket's lower rim (behind
// the phone, so the entry never shows), straight down inside the wedge, then
// runs back in a covered, open-bottom channel and exits the REAR face at desk
// level -> the cable falls invisibly down behind the organizer. Seat the puck
// with its cable pointing down-slope (toward the phone foot) so it feeds in.
cable_w = 7;   // channel width: braided USB-C + connector boot, loose
module cable_conduit() {
    // 1) vertical drop: pocket lower rim -> base
    translate([puck_x - cable_w/2, 97, -0.1]) cube([cable_w, 8, 43.2]);
    // 2) covered under-base run: drop -> out through the rear face & slab edge
    translate([puck_x - cable_w/2, 100, -0.1])
        cube([cable_w, stand_y0 + stand_d + 4 - 100, 6]);
}

// =============================================================================
// Body
// =============================================================================
module body() {
    difference() {
        union() {
            // Unifying base slab ties every zone into one part and fills the
            // reveals between blocks.
            translate([3, 2, 0])  soft_box(190, 148, floor_t, edge, 0.6);
            // Terrace blocks (front -> back, low -> tall)
            translate([4, 3, 0])  soft_box(186, 55, h_tray, edge, top_ch);  // remote tray
            translate([6, 62, 0]) soft_box(116, 30, h_usb,  edge, top_ch);  // USB / SD bank
            translate([6, 94, 0]) soft_box(116, 34, h_tool, edge, top_ch);  // tool / pen wells
            mag_stand();                                                    // phone stand
        }

        // --- Remote tray: a shallow cradle with a thumb scallop to lift it out
        cut_rect(tray_cx, tray_cy, rem_ox, rem_oy, h_tray - floor_t, h_tray, r = 4);
        translate([tray_cx, 3, h_tray]) rotate([0, 90, 0]) cylinder(r = 9, h = 44, center = true);

        // --- Tool wells (deep) + pen wells
        for (cx = [t1, t2, t3]) cut_round(cx, y_back, tool_o, tool_depth, h_tool);
        for (cx = [p1, p2])     cut_round(cx, y_back, pen_o,  pen_depth,  h_tool);

        // --- USB drives stood upright
        for (cx = [u1, u2, u3]) cut_rect(cx, y_front, usb_ox, usb_oy, usb_depth, h_usb, r = 2);

        // --- SD card slot + a finger scallop at the front to pinch it out
        cut_rect(sd_cx, y_front, sd_ox, sd_oy, sd_depth, h_usb, r = 1, ch = 0.6);
        translate([sd_cx, 62, h_usb]) rotate([90, 0, 0]) cylinder(r = 5, h = 16, center = true);

        // --- Hidden MagSafe cable conduit (drops down the wedge, out the rear)
        cable_conduit();
    }
}

// =============================================================================
// Mock items (visualisation only)
// =============================================================================
module mocks() {
    // Remote lying in its tray
    color("DimGray", 0.6)
        translate([tray_cx - rem_l/2, tray_cy - rem_w/2, floor_t]) cube([rem_l, rem_w, rem_t]);
    // Puck seated in the pocket + phone laid back on the slope
    translate([puck_x, puck_y, puck_z]) rotate([phone_angle, 0, 0]) {
        color("Silver", 0.7) translate([0, 0, -recess_depth]) cylinder(d = puck_d, h = puck_t);
    }
    color("Gainsboro", 0.5)
        translate([puck_x, stand_y0, 0]) rotate([phone_angle, 0, 0])
            translate([-35, -2, 1]) cube([70, 147, 8]);
}

// =============================================================================
// Output
// =============================================================================
xray = false;   // debug: ghost the body and show the conduit cutter solid (red)
if (xray) { %body(); color("red") cable_conduit(); }
else { body(); if (part == "assembly" && show_items) mocks(); }
