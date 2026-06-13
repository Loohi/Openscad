# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

OpenSCAD source (`.scad`) for parametric CAD models intended for 3D printing. Models are defined as code, rendered to a mesh, then exported to STL (or 3MF) for slicing.

> Update this file with model-specific architecture as the design grows.

## Design philosophy

Approach every model as an **elite industrial designer who works natively in FDM**. The goal is an object that looks considered and refined on a shelf at home, yet prints reliably on a consumer printer and earns its keep functionally. Beauty and practicality are not in tension by default — good FDM design makes them the same move. But when they do conflict, **practicality and printability win**, and the compromise should be deliberate and noted, not accidental.

**Aesthetic standards** (the "looks great at home" half):

- **Soften every visible edge.** Sharp exterior edges look like a default cube and chip in the hand. Chamfer or fillet outer edges and corners (`minkowski`, `offset`, `hull` of small spheres/cylinders, or a swept profile). A consistent edge treatment across a part reads as intentional design; mixed/absent treatment reads as a part bin.
- **One visual language per object.** Pick a corner radius, a wall rhythm, a chamfer angle (45° reads as "machined," shallow reads as "soft product") and reuse it everywhere. Derive these from named variables so the language stays consistent when dimensions reflow.
- **Hide the function, express the form.** Screw bosses, ribs, and standoffs live inside; the outside stays calm. Vents, grilles, and seams become deliberate design features (even spacing, aligned to edges/centerlines) rather than apologetic holes.
- **Proportion matters.** Avoid arbitrary thicknesses and offsets. Relate dimensions (golden-ish ratios, equal margins, repeated modules) so the eye reads order.
- **Plan the seam and the show face.** Decide which face the customer sees and orient/lay out detail so the nicest surface is the one that prints cleanest (see below). Put the part line where it disappears.

**Print-optimization judgment** (the "practical and optimized" half):

- **Design for a print orientation.** Pick how the part sits on the bed before detailing it, then shape geometry to that choice. The bottom face is flattest and least pretty; the top and walls are the show surfaces.
- **Overhangs ≤ ~45° from vertical, or redesign them.** Prefer chamfers over fillets on *downward*-facing features, teardrop holes for horizontal bores, and self-supporting bridges. Treat support material as a design failure to be engineered out, not a default to lean on. When support is truly unavoidable, keep it off show faces.
- **Walls in multiples of line width.** Default to ~0.4 mm nozzle / ~0.42 mm line width; make walls ~0.8/1.2/1.6/2.0 mm so the slicer fills them with whole perimeters and no gap fill. Floors/ceilings ≥ 3–4 solid layers (~0.8 mm).
- **Respect the grain.** FDM is anisotropic and weakest between layers. Orient so loads pull *along* layers, not peel them apart; add fillets at stress risers; thicken cantilevers and snap features.
- **Tune fit to the process, not to CAD-ideal.** Real clearances for press/slip/clearance fits (commonly ~0.1–0.4 mm depending on feature and printer) belong in named tolerance variables, never baked into geometry. First-layer squish and elephant's-foot eat the bottom ~0.2 mm — chamfer bottom edges of mating features to compensate.
- **Minimize and integrate hardware.** Prefer printed-in living hinges, snap-fits, captive nuts, and heat-set insert pockets over loose fasteners where it improves the result — but reach for real M-series screws/inserts when they make the object more serviceable or durable. Choose, don't default.

**When to compromise (and how):** flag the trade-off in a comment at the point of compromise. Typical calls: split a part or add a deliberate seam rather than force long support-heavy overhangs; flatten a curve that would print poorly face-up; accept a slightly thicker wall to land on a whole perimeter count; expose a screw on a back/bottom face to keep the front clean. The rule of thumb: **never ship a feature that prints badly just because it models nicely.**

## Print profile (house defaults)

Concrete machine/process assumptions every model inherits unless it overrides them at the top of its own file. These exist so models stop re-deriving the same numbers — copy the standard header below into each new `.scad`.

| Parameter | Default | Notes |
|---|---|---|
| Nozzle | 0.4 mm | line width `line_w = 0.42 mm` |
| Layer height | 0.2 mm | `layer_h`; all "N layers" math assumes this |
| Build volume | 220 × 220 × 250 mm (Ender class) | keep any single part ≤ ~210 mm in X/Y; **split or add a deliberate seam past that** |
| Walls | whole multiples of `line_w` | 0.84 / 1.26 / 1.68 / 2.10 / 2.52 mm |
| Floors / ceilings | ≥ 4 solid layers (0.8 mm); 2.0–2.4 mm typical | |
| First layer | elephant's-foot eats the bottom ~0.2 mm | chamfer bottom mating edges 0.4–0.6 mm @45° to compensate |

### Material — one filament per object (PLA *or* PETG, never mixed)

Each model declares `material = "PLA"` or `"PETG"` at the top and derives its fit clearances from it. Pick per the part's job:

- **PLA** — stiff, low-shrink (~0.3 %), holds tight tolerances, best surface finish, easiest to print. **Brittle**: avoid load-bearing snap-fits, living hinges, and thin cantilevers that flex repeatedly. Default for dimensional / decorative / indoor static parts.
- **PETG** — tough and springy (the right pick for snap arms, clips, living hinges, outdoor/UV-exposed parts). **Oozes and "grows"**, so bores print ~0.1–0.15 mm undersize and mating clearances want to run looser. Weaker layer adhesion — keep loads *along* layers, not across them.

### Canonical fit tolerances

Put these in named variables; never bake them into geometry. Values are **per side** (radial) unless noted. They are printer-specific — dial them in once with a tolerance test print, then trust them.

| Fit | PLA | PETG | Use |
|---|---|---|---|
| Clearance / slip (moving, easy assembly) | 0.20 | 0.30 | lids, sliding parts |
| Locating / snug (light push) | 0.10 | 0.20 | skirts, alignment pins |
| Press / interference | 0.00 to −0.05 | 0.05 | dowels, captive pins |
| M3 screw, free clearance | hole Ø3.4 | Ø3.4 | through-holes |
| M3 self-tap pilot | Ø2.5 | Ø2.5 | corner bosses |
| M3 heat-set insert bore | Ø4.0 | Ø4.2 | depth = insert length + 0.5 |
| M3 captive nut pocket | 5.6 AF × 2.6 tall | 5.8 AF × 2.6 | hex across-flats |
| Living hinge thickness | (avoid — brittle) | 0.4–0.6 | single-material flex |

### Standard model header

Start every new `.scad` from this block so the visual/process language stays consistent and `-D` overrides stay predictable:

```scad
// ---- Process / machine ----
nozzle_d = 0.4;
line_w   = 0.42;
layer_h  = 0.2;
material = "PETG";            // "PLA" | "PETG"  -> drives the fits below
$fn      = 48;               // raise to 96+ for final export

// ---- Walls / shells ----
wall    = 6 * line_w;        // whole-perimeter multiple (2.52 mm)
floor_t = 2.4;               // >= 4 layers

// ---- Fits (per side; auto-loosened for PETG) ----
fit_slip  = (material == "PETG") ? 0.30 : 0.20;
fit_snug  = (material == "PETG") ? 0.20 : 0.10;
fit_press = (material == "PETG") ? 0.05 : 0.00;
insert_d  = (material == "PETG") ? 4.2  : 4.0;   // M3 heat-set bore
```

## Models

- `aqi_enclosure.scad` — Air quality sensor enclosure for an ESP32 DevKit + PMS5003 +
  SCD30, wired with jumper cables (no PCB). Two printed parts selected via the `part`
  variable (`"base"` / `"lid"` / `"assembly"`). Component footprints and fit tolerances
  are top-level variables; layout positions and enclosure size derive from them, so
  changing a board dimension reflows the whole box. Closes with 4× M3 self-tapping
  screws into corner bosses. Render parts with e.g. `-D 'part="base"'`.
  - **Pole mount:** snaps onto a vertical pole (`pole_d`, default 34 mm) via an
    integrated snap-on C-clamp on the floor exterior, whose axis runs vertically
    *along* the pole so the box hangs portrait with its floor parallel to the pole
    and the vented lid facing the room. Clamp tunables (`clamp_clr`, `clamp_wall`,
    `mouth_frac`, `clamp_end`) are top-level; `arm_mount=false` removes it.
  - **Orientation matters:** `part="base"` is emitted already rotated into its print
    pose (standing on the USB-end wall) so the clamp axis is vertical — the C-ring
    prints support-free, but the internal cradles/bosses then want light support.
    `part="assembly"` is shown in the mounted pose on a mock pole (`show_mock`).
  - **Visual language:** outer vertical edges are rounded (`edge`) and the top edge
    chamfered (`top_ch`, which also forms the lid-seam reveal); walls are whole
    perimeter multiples of `line_w` (`wall`/`lid_wall`). Keep new features consistent.

- `Desk organizer/desk_organizer.scad` — Single-piece desk caddy + MagSafe phone
  stand. Holds an Apple MagSafe puck + iPhone 15 Pro (laid-back ~50° StandBy
  angle), 3 tools, 2 pens, 3 USB drives, 1 SD card, and a TV remote (laid flat in
  a front tray). PLA. `part` selects `"print"` (the part) or `"assembly"` (+ mock
  phone/puck/remote via `show_items`).
  - **Form = ascending terrace:** low remote tray at the FRONT steps up to the
    USB/SD bank, then the deep tool/pen wells at back-left; the MagSafe wedge
    rises at back-right. Tall items at the back keep the sightline calm. Item
    sizes and clearances are top-level vars; row positions derive cumulatively.
  - **Orientation matters:** modelled already in print pose — prints FLAT on its
    base, every well vertical ⇒ support-free. The ONE managed overhang is the
    puck recess (bored into the 50° face): a 2 mm 45° chamfered lead-in + shallow
    depth lets it bridge; lowering `phone_angle` rotates the rim toward vertical.
  - **MagSafe wedge depth is load-bearing geometry:** `stand_d` must keep the
    50° face long enough to fully contain the puck pocket (centre is ~83 mm
    up-slope) — too shallow and the recess clips off the back as a crescent.
  - **Note:** the wedge is currently a solid triangle (light at 15% infill but
    bulky); the reclined phone cantilevers ~50 mm behind the back edge, so leave
    clearance from a wall. Visual language: single `edge` radius + chamfered
    rims (`rim_ch`) on every mouth; zone gaps read as deliberate reveals.

## Toolchain

- OpenSCAD `2021.01` is installed at `/usr/bin/openscad`. This is the *stable* release: it does **not** include the newer `2019.05+` development features unless they shipped in 2021.01. Notably it lacks `Customizer`-only syntax extensions and some `list comprehension` niceties from nightly builds — prefer language features documented for 2021.01.

## Common commands

Render and export a model to STL (headless, no GUI):

```bash
openscad -o output.stl model.scad
```

Pass/override parameters from the command line (overrides top-level variable assignments in the file):

```bash
openscad -o part.stl -D 'wall=2.4' -D 'height=40' model.scad
```

Export to 3MF (preserves units/metadata; preferred for PrusaSlicer/Bambu):

```bash
openscad -o output.3mf model.scad
```

Export other formats by changing the output extension (`.off`, `.dxf`/`.svg` for 2D, `.png`):

```bash
openscad -o preview.png --imgsize=1024,1024 --colorscheme=Tomorrow model.scad
```

Generate a high-quality render preview image (uses full CGAL render, not fast preview):

```bash
openscad -o preview.png --render model.scad
```

Quick syntax/geometry check without writing output — render to a throwaway file and inspect stderr for warnings/errors:

```bash
openscad -o /dev/null model.scad
```

Watch the GUI live-reload a file while editing (manual, interactive):

```bash
openscad model.scad
```

## Conventions for printable models

When creating or editing models, keep them *manifold* and print-ready:

- **`$fn` for round geometry.** Set a sensible facet count (e.g. `$fn = 64;` at the top, or per-object) so cylinders/spheres are smooth enough to print but not so high that CGAL render is slow. Use lower `$fn` (e.g. 24) during design, raise it for final export.
- **Avoid zero-thickness / coincident faces.** When subtracting with `difference()`, make the cutting tool extend slightly beyond the surface (overshoot by ~0.01–1mm) so faces don't perfectly coincide — coincident faces produce non-manifold STLs that slicers reject.
- **Parametrize dimensions** as named top-level variables (so they can be overridden with `-D`). Group tunables at the top of the file.
- **Real-world units are millimeters.** OpenSCAD is unitless, but the entire slicing pipeline assumes 1 unit = 1 mm.
- **Watch for non-manifold warnings** in stderr after rendering — they indicate the STL may not slice cleanly.

## Verifying a change

After editing a `.scad` file, render it headless and check that stderr is clean (no `WARNING`/`ERROR`):

```bash
openscad -o /dev/null path/to/model.scad
```

A successful render with no warnings means the geometry is manifold and exportable.
