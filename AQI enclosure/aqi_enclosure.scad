// =============================================================================
// Air Quality Sensor Enclosure  --  pole-clamped variant
//   - ESP32 DevKit (38-pin DevKitC class board)
//   - PMS5003 laser particulate matter sensor
//   - SCD30 CO2 / temperature / humidity sensor
//   Wired with jumper (DuPont) cables -- no PCB.
//
// MOUNTING: snaps onto a VERTICAL pole (default 34 mm). The box hangs on the
//   SIDE of the pole like a wall plaque: its flat floor-face sits parallel to
//   the pole (hidden against it) and the lid / vent face looks out into the
//   room. The C-clamp lives on the floor exterior, its axis running vertically
//   ALONG the pole, so its long (~100 mm) grip resists the box tipping forward.
//
// Render parts for printing:
//   openscad -o base.stl -D 'part="base"' aqi_enclosure.scad
//   openscad -o lid.stl  -D 'part="lid"'  aqi_enclosure.scad
// Preview the assembled box on a mock pole:
//   openscad -o preview.png --render -D 'part="assembly"' -D show_mock=true aqi_enclosure.scad
//
// PRINT NOTES: PLA/PETG, 0.4 mm nozzle, 0.2 mm layers, 3 perimeters, 20% infill.
//   - part="base" is emitted already STANDING in its print orientation: it
//     rests on the USB-end wall so the clamp axis is vertical and the C-ring
//     prints as a clean stack of C cross-sections (no supports on the clamp).
//     The internal cradles / bosses become horizontal in this pose and want
//     LIGHT support (they are hidden inside, off every show face). PETG is
//     preferred for the springy snap arms.
//   - Print the lid flat-side-down (modelled in print orientation already).
//   - Closes with 4x M3 self-tapping screws (~12 mm) into the corner bosses.
//   - To snap on: push the box horizontally onto the pole; the funnel mouth
//     cams the arms open and the pole seats with a >180 deg wrap.
// =============================================================================

part      = "assembly";   // "base" | "lid" | "assembly"
show_mock = false;        // show translucent components + mock pole in assembly

$fn = 48;

// ---- Process / line width ---------------------------------------------------
line_w = 0.42;   // extrusion width for a 0.4 mm nozzle (drives wall multiples)

// ---- Build / fit parameters -------------------------------------------------
wall    = 6 * line_w;  // 2.52 mm -> whole 6 perimeters, no slicer gap-fill
floor_t = 2.4;   // floor thickness (12 layers)
lid_t   = 2.4;   // lid plate thickness
clr     = 1.5;   // clearance around components
margin  = 8;     // gap between components and outer walls (leaves room for bosses)
gap     = 6;     // gap between adjacent components
internal_h = 28; // internal cavity height (clears the 21 mm PMS5003 + cable room)
esp_standoff = 4;     // height the ESP32 board is lifted off the floor

// ---- Visual language: soften every visible edge -----------------------------
edge   = 2.0;   // outer vertical-corner radius (reused on base + lid)
top_ch = 1.5;   // outer top-edge chamfer (also forms the lid-seam reveal)

// ---- Clamp posts (on the lid, press boards onto the floor) -------------------
clamp_r       = 2.6;  // clamp-post radius
clamp_preload = 0.4;  // how far posts overshoot the board top (light press fit)

// ---- Monitor-arm clamp (snap-on C-clip for a VERTICAL pole) ------------------
// A sprung C-ring on the FLOOR exterior whose axis runs vertically along the
// pole. The pole sits ~one ring-radius behind the floor, so the floor never
// scrapes it. The ring wraps >180 deg (retains) with a funnelled lead-in mouth
// that cams the arms open on snap-on.  Friction carries the box weight; the long
// (~100 mm) grip carries the forward tilt. If it ever creeps, raise clamp_wall /
// lower clamp_clr for a tighter grip, or shrink mouth_frac for a deeper snap.
arm_mount  = true;   // add the snap clamp to the floor
pole_d     = 34;     // monitor-arm pole diameter (mm)
clamp_clr  = 0.4;    // radial slip clearance between ring bore and pole
clamp_wall = 3.2;    // C-ring wall thickness (springy but strong)
mouth_frac = 0.88;   // throat opening / pole_d  (<1 so the ring retains the pole)
clamp_end  = 8;      // inset of the clamp's ends from the box's top/bottom edges
clamp_neck = 29;     // width of the web tying the ring back into the floor

// ---- Component footprints (mm) ----------------------------------------------
// (length X, width Y, height Z) of the bodies, excluding loose wiring.
pms_l = 50; pms_w = 38; pms_h = 21;   // PMS5003 body
esp_l = 55; esp_w = 28; esp_h = 13;   // ESP32 DevKitC incl. pin headers
scd_l = 35; scd_w = 23; scd_h = 8;    // SCD30 breakout

// ---- Fasteners --------------------------------------------------------------
boss_r      = 3.5;   // corner screw-boss radius
pilot_r     = 1.25;  // M3 self-tap pilot hole radius
pilot_depth = 14;
lid_hole_r  = 1.7;   // M3 clearance in lid
csink_r     = 3.2;   // countersink top radius

// ---- Derived component positions (in cavity coordinates, origin at cavity FL)
esp_x = margin;                    esp_y = margin;
scd_x = margin + esp_l + gap;      scd_y = margin;
pms_x = margin;                    pms_y = margin + esp_w + gap;

// ---- Derived enclosure size -------------------------------------------------
internal_x = margin + esp_l + gap + scd_l + margin;
internal_y = margin + max(esp_w, scd_w) + gap + pms_w + margin;
outer_x = internal_x + 2*wall;
outer_y = internal_y + 2*wall;
wall_top_z = floor_t + internal_h;

// Boss centre positions (cavity coords)
boss_pos = [
    [boss_r,              boss_r],
    [internal_x - boss_r, boss_r],
    [boss_r,              internal_y - boss_r],
    [internal_x - boss_r, internal_y - boss_r]
];

// ---- Lid (cap) parameters ---------------------------------------------------
lid_wall = 5 * line_w;  // 2.1 mm -> whole 5 perimeters
skirt_h  = 6;     // how far the skirt drops over the box walls
lid_gap  = 0.4;   // slip-fit clearance between skirt and box
cw = lid_wall + wall;   // cavity-corner offset in lid coordinates

// Board top heights (cavity coords) -> used to size the lid clamp posts
esp_top = floor_t + esp_standoff + esp_h;
scd_top = floor_t + scd_h;
pms_top = floor_t + pms_h;

// ---- Clamp geometry (derived) -----------------------------------------------
clamp_ri  = pole_d/2 + clamp_clr;        // ring bore radius (slip fit)
clamp_ro  = clamp_ri + clamp_wall;       // ring outer radius
clamp_zc  = 1 - clamp_ro;                // ring axis Z (top fuses 1 mm into floor)
clamp_len = outer_x - 2*clamp_end;       // grip length along the pole (~100 mm)

// =============================================================================
// 2D helper: rounded-corner rectangle (radius r), and a soft outer box with
// rounded vertical edges + a 45 deg top-edge chamfer.
// =============================================================================
module rrect(sx, sy, r) offset(r) offset(-r) square([sx, sy]);

module soft_box(sx, sy, sz, r, ch) {
    hull() {
        linear_extrude(sz - ch) rrect(sx, sy, r);
        translate([ch, ch, sz - ch])
            linear_extrude(ch) rrect(sx - 2*ch, sy - 2*ch, max(r - ch, 0.1));
    }
}

// =============================================================================
// Vent helpers
// =============================================================================

// Slots cut through +Y (front / back walls). Local: width X, cut depth Y, stack Z.
module vent_y(w, h, t, slot = 2.5, bar = 2.5) {
    n = floor((h + bar) / (slot + bar));
    for (i = [0 : n - 1])
        translate([0, 0, i * (slot + bar)]) cube([w, t, slot]);
}

// Slots cut through +X (side walls). Local: cut depth X, width Y, stack Z.
module vent_x(d, h, t, slot = 2.5, bar = 2.5) {
    n = floor((h + bar) / (slot + bar));
    for (i = [0 : n - 1])
        translate([0, 0, i * (slot + bar)]) cube([t, d, slot]);
}

// Slots cut vertically through a horizontal plate (the lid). Local: width X,
// stack Y, depth Z.
module vent_top(w, d, t, slot = 3, bar = 3) {
    n = floor((d + bar) / (slot + bar));
    for (i = [0 : n - 1])
        translate([0, i * (slot + bar), 0]) cube([w, slot, t]);
}

// =============================================================================
// Component cradle: four L-brackets that locate a board on the floor.
// (px,py,pw,pd) is the footprint in cavity coords; built at z=0.
// =============================================================================
module cradle(px, py, pw, pd, h, t = 2, arm = 8) {
    x0 = px - clr;        y0 = py - clr;
    x1 = px + pw + clr;   y1 = py + pd + clr;
    // corner (x0,y0)
    translate([x0 - t, y0 - t, 0]) cube([arm + t, t, h]);
    translate([x0 - t, y0 - t, 0]) cube([t, arm + t, h]);
    // corner (x1,y0)
    translate([x1 - arm, y0 - t, 0]) cube([arm + t, t, h]);
    translate([x1,       y0 - t, 0]) cube([t, arm + t, h]);
    // corner (x0,y1)
    translate([x0 - t, y1,       0]) cube([arm + t, t, h]);
    translate([x0 - t, y1 - arm, 0]) cube([t, arm + t, h]);
    // corner (x1,y1)
    translate([x1 - arm, y1, 0]) cube([arm + t, t, h]);
    translate([x1,       y1 - arm, 0]) cube([t, arm + t, h]);
}

// =============================================================================
// Monitor-arm clamp.
// Built about a local Z axis (mouth toward +Y), then laid down so the axis runs
// along +X (= vertical, along the pole) and the mouth faces -Z (away from the
// floor, so the box presses straight onto the pole). Hangs below the floor.
// =============================================================================
module clamp_ring(len) {
    ri = clamp_ri;  ro = clamp_ro;
    ch = 1.2;                          // softened rims
    mw = pole_d * mouth_frac / 2;      // throat half-width (the snap constriction)
    fw = mw + 5;                       // flared lead-in half-width at the mouth
    difference() {
        // Chamfered tube
        rotate_extrude($fn = 96)
            polygon([
                [ri, 0], [ro - ch, 0], [ro, ch],
                [ro, len - ch], [ro - ch, len], [ri, len]
            ]);
        // Funnel mouth (+Y): narrow throat at centre, flaring open to cam-in.
        translate([0, 0, -1])
            linear_extrude(len + 2)
                polygon([[-mw, 0], [-fw, ro + 6], [fw, ro + 6], [mw, 0]]);
    }
}

module arm_clamp() {
    union() {
        // Lay the ring down: axis -> +X, mouth -> -Z, centred on the floor in Y.
        translate([clamp_end, outer_y/2, clamp_zc])
            rotate([-90, 0, 0]) rotate([0, 90, 0])
                clamp_ring(clamp_len);

        // Web tying the ring's back up into the floor along its full length.
        // Stops 0.5 mm short of the seated pole so it never fouls it.
        translate([clamp_end, outer_y/2 - clamp_neck/2, clamp_zc + clamp_ri + 0.5])
            cube([clamp_len, clamp_neck, (clamp_ro - clamp_ri) - 0.5 + 1]);
    }
}

// =============================================================================
// Base
// =============================================================================
module base() {
    union() {
        // --- Shell with cavity and vents -------------------------------------
        difference() {
            soft_box(outer_x, outer_y, wall_top_z, edge, top_ch);  // soft outer
            translate([wall, wall, floor_t])
                cube([internal_x, internal_y, internal_h + 1]);    // open-top cavity

            // PMS5003 exhaust/intake grille -> back wall (+Y), over PMS face
            translate([wall + pms_x, wall + internal_y - 1, floor_t + 3])
                vent_y(w = pms_l, h = 16, t = wall + 2);

            // SCD30 ambient vents -> right wall (+X)  (the TOP wall when mounted)
            translate([wall + internal_x - 1, wall + scd_y, floor_t + 3])
                vent_x(d = scd_w, h = 16, t = wall + 2);

            // Low intake vents -> front wall (-Y), full front for cross-flow
            translate([wall + 12, -1, floor_t + 3])
                vent_y(w = internal_x - 24, h = 8, t = wall + 2);

            // ESP32 USB port -> left wall (-X), flared outward to ease the cable
            // and avoid a sharp lip (also the bed-side edge when standing-printed)
            hull() {
                translate([wall - 0.5, wall + esp_y + esp_w/2 - 6.5, floor_t + 2])
                    cube([0.01, 13, 9]);
                translate([-1, wall + esp_y + esp_w/2 - 8, floor_t + 0.5])
                    cube([0.01, 16, 12]);
            }
        }

        // --- Mounting features (added after cavity is carved) ----------------
        // All features start 0.5 mm below the cavity floor so they fuse with
        // the floor solid (no coincident faces).
        embed = 0.5;

        // Corner screw bosses. The body is nudged 1 mm toward each corner so it
        // fuses into the adjacent walls, but the pilot hole stays on boss_pos so
        // it lines up with the lid screw holes.
        for (p = boss_pos) {
            nx = (p[0] < internal_x/2) ? -1 : 1;   // push toward nearest corner
            ny = (p[1] < internal_y/2) ? -1 : 1;
            difference() {
                translate([wall + p[0] + nx, wall + p[1] + ny, floor_t - embed])
                    cylinder(r = boss_r, h = internal_h + embed);
                translate([wall + p[0], wall + p[1], floor_t + internal_h - pilot_depth])
                    cylinder(r = pilot_r, h = pilot_depth + 1);
            }
        }

        // Component cradles
        translate([wall, wall, floor_t - embed]) {
            cradle(esp_x, esp_y, esp_l, esp_w, 6 + embed);   // ESP32
            cradle(scd_x, scd_y, scd_l, scd_w, 6 + embed);   // SCD30
            cradle(pms_x, pms_y, pms_l, pms_w, 10 + embed);  // PMS5003 (taller)
        }

        // Small standoffs to lift the ESP32 board so the USB lines up with cutout
        translate([wall, wall, floor_t - embed])
            for (sx = [esp_x + 5, esp_x + esp_l - 5])
                for (sy = [esp_y + 4, esp_y + esp_w - 4])
                    translate([sx, sy, 0]) cylinder(r = 2, h = esp_standoff + embed);

        // Snap-on clamp for the monitor-arm pole (on the floor exterior)
        if (arm_mount) arm_clamp();
    }
}

// =============================================================================
// Clamp posts: four pillars descending from the lid onto a board's corners,
// pressing it down onto the floor. (px,py,pw,pd) footprint in cavity coords,
// board_top = z of the board's top surface, (ex,ey) corner insets.
// Modelled in lid print orientation (rising +Z from the plate's inner face).
// =============================================================================
module clamp_posts(px, py, pw, pd, board_top, ex, ey) {
    len = wall_top_z - board_top + clamp_preload;
    for (sx = [px + ex, px + pw - ex])
        for (sy = [py + ey, py + pd - ey])
            translate([cw + sx, cw + sy, lid_t - 0.5])
                cylinder(r = clamp_r, h = len + 0.5);
}

// =============================================================================
// Lid (cap style) -- modelled in print orientation: plate on the bed, skirt up.
// Vertical edges rounded to match the base (one visual language).
// =============================================================================
module lid() {
    Lo = outer_x + 2 * lid_wall;
    Wo = outer_y + 2 * lid_wall;

    difference() {
        union() {
            linear_extrude(lid_t) rrect(Lo, Wo, edge);   // top plate, soft verticals
            difference() {                               // alignment skirt
                linear_extrude(lid_t + skirt_h) rrect(Lo, Wo, edge);
                translate([lid_wall - lid_gap/2, lid_wall - lid_gap/2, lid_t])
                    cube([outer_x + lid_gap, outer_y + lid_gap, skirt_h + 1]);
            }
            // Clamp posts hold each board down. ESP32 posts sit over its
            // standoffs (corners), so the PCB is sandwiched without flexing.
            clamp_posts(esp_x, esp_y, esp_l, esp_w, esp_top, 5, 4);
            clamp_posts(scd_x, scd_y, scd_l, scd_w, scd_top, 3, 3);
            clamp_posts(pms_x, pms_y, pms_l, pms_w, pms_top, 3, 3);
        }

        // Screw holes + countersinks at the boss centres
        for (p = boss_pos)
            translate([cw + p[0], cw + p[1], -1]) {
                cylinder(r = lid_hole_r, h = lid_t + skirt_h + 2);
                cylinder(r1 = csink_r, r2 = lid_hole_r, h = lid_t);  // countersink
            }

        // Lid vents over the ESP32 (lets its heat escape, away from the SCD30)
        translate([cw + esp_x + 6, cw + esp_y + 4, -1])
            vent_top(w = esp_l - 12, d = esp_w - 8, t = lid_t + 2);

        // Lid vents over the SCD30 for ambient exchange
        translate([cw + scd_x + 4, cw + scd_y + 3, -1])
            vent_top(w = scd_l - 8, d = scd_w - 6, t = lid_t + 2);
    }
}

// =============================================================================
// Mock components + mock pole (visualisation only)
// =============================================================================
module mock() {
    color("SteelBlue", 0.4)
        translate([wall + pms_x, wall + pms_y, floor_t])
            cube([pms_l, pms_w, pms_h]);
    color("DarkGreen", 0.5)
        translate([wall + esp_x, wall + esp_y, floor_t + esp_standoff])
            cube([esp_l, esp_w, esp_h]);
    color("Goldenrod", 0.5)
        translate([wall + scd_x, wall + scd_y, floor_t])
            cube([scd_l, scd_w, scd_h]);
}

module mock_pole() {
    color("Silver", 0.6)
        translate([-15, outer_y/2, clamp_zc])
            rotate([0, 90, 0]) cylinder(d = pole_d, h = outer_x + 30);
}

// =============================================================================
// Output selection.
//   base     -> emitted STANDING in print orientation (clamp axis vertical).
//   assembly -> shown in MOUNTED orientation on a vertical mock pole.
// rotate([0,-90,0]) maps the model's +X (the long, portrait axis) to vertical.
// =============================================================================
if (part == "base") {
    rotate([0, -90, 0]) base();
} else if (part == "lid") {
    lid();
} else {  // assembly, in mounted orientation
    rotate([0, -90, 0]) {
        base();
        if (show_mock) { mock(); mock_pole(); }
        // place the lid on top, flipped into closed orientation
        translate([-lid_wall, outer_y + lid_wall, wall_top_z + skirt_h + lid_t])
            rotate([180, 0, 0]) lid();
    }
}
