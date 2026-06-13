# Expansion Jaw Mount

A parametric, FDM-tuned recreation of the Onshape **"Expansion jaw"** — a
wedge-driven 2-jaw spreader — repurposed as a **reusable slot-mounting system**.

The intended use: a horizontal slot behind a ledge (e.g. a bathroom shelf
reveal). The collapsed jaws slide into the slot; a screw drives a wedge that
forces the jaws apart until their outer faces clamp the slot's top and bottom.
A face plate on the front carries a **dovetail interface** so any accessory can
be dropped onto the mount and removed without tools — no adhesive, no drilling,
no damage to the wall.

> **Status:** the mechanism geometry, the dovetail mounting standard, and the
> per-part printability are done and verified manifold. A single countersunk M4
> closes the clamp force loop (spread + clamp in one fastener), so there are no
> separate anchor screws. What's left depends on your measured slot — see
> [Open decisions](#7-open-decisions-finalize-with-a-real-slot).

---

## 1. How the mechanism works

```
        FRONT (room side, -Y)                BACK (into slot, +Y)
   accessory │ face plate │   jaws + wedge
   ──────────┼────────────┼──────────────────────────────►  Y (insertion)
                                                   
        ┌───────────────┐   ← TOP JAW   outer face clamps slot ceiling  (+Z)
        │░░░░░░░░░░░░░░░░│
         \   wedge      /   ← inclined 10° faces (the "V-channel")
          \____________/    ← WEDGE rides here; driving it -Y spreads the jaws
          /            \
        │░░░░░░░░░░░░░░░░│
        └───────────────┘   ← BOTTOM JAW outer face clamps slot floor    (-Z)
```

- Two **identical jaws** (top + bottom, mirrored across `Z = 0`). Each jaw's
  inner face is an **inclined plane**; together they form a symmetric V-channel
  that is narrow at the front and wider at the back.
- A **tapered wedge** sits in the V. Its top and bottom faces share the **same
  10° incline** (`Angle_jaws = 80°` measured from the base ⇒ `90 − 80 = 10°`
  half-V). At the nominal position the wedge faces are *exactly coincident* with
  the jaw faces (verified: zero offset along the full length) — so the contact
  is full-face, not a line, and the spread is purely a function of wedge travel.
- **Driving the wedge forward (−Y, toward the operator)** feeds its thicker rear
  section into the jaw zone, which **forces the jaws apart along Z**. This is the
  "expansion" that clamps the slot. Backing the wedge off (+Y) releases it.
- An **M4 screw** through the centre of the face plate threads into the wedge's
  front face; tightening it draws the wedge forward → jaws spread → clamp.
- The **face plate** is held on by that same screw (head countersunk in its
  front) and presents the dovetail interface to the room.
- A **dovetail joint** keys removable accessories onto the face plate.

**Moving group:** {top jaw, bottom jaw, wedge}.
**Mounting group:** {face plate, accessory}.

### Why the wedge is thick at the *back*

To clamp, tightening must increase spread. The screw pulls the wedge **toward
the front**. The cross-section that moves *into* the fixed jaw zone as the wedge
travels forward is the one that was behind it — so that incoming section must be
**thicker**. Hence the wedge tapers thin-at-front, thick-at-back (matching the
original). Tighten → thick part enters the jaws → spread increases. ✔

---

## 2. The original part (faithful reference)

The source is the Onshape document *"Expansion jaw"* (5 solid bodies). Captured
here so the recreation stays honest. All units mm; frame: **X = width across
jaws, Y = depth (−Y front), Z = height / expansion axis**.

| Part          | Outer size (mm)      | Role |
|---------------|----------------------|------|
| Top jaw       | 20 × 25 × 16.65      | upper clamp half, inclined inner face |
| Bottom jaw    | 20 × 25 × 16.65      | mirror of top jaw |
| Wedge         | 23 × 15 × 18.29      | tapered driver, 10° faces, end retainer tabs |
| Face plate    | 40 × 7.5 × 41        | front plate, 2× M5 c-bore + 2× female dovetail |
| Dovetail male | 31 × 11.5 × 23       | accessory base with 2 male tenons |

Driving parameters (kept as variables): `Jaws_width=20`, `Jaws_depth=25`,
`Jaws_height=41`, `Angle_jaws=80`, `wedge_depth=15`. The inclined faces rise
`tan(10°) × 25 ≈ 4.41 mm` over the jaw depth — the origin of the per-part Z
numbers. Threads in the original are modeled as plain holes (visual fidelity);
M4 drives the wedge, 2× M5 fix the face plate.

---

## 3. What I changed for FDM (and why)

Recreated faithfully, then tuned as an FDM part per the repo design philosophy.

| Enhancement | Why |
|---|---|
| **PETG + named fits** (`fit_slip/snug/press`, `insert_d`) | A flexing clamp in a humid bathroom wants PETG's toughness; fits derive from material so PLA still works via one variable. |
| **Slip clearance on the wedge** (`fit_slip` off the inclined faces) | Nominal wedge/jaw faces are *coincident* — a printed wedge must be undersized to actually slide. |
| **ONE screw closes the force loop** (`drive_*`, `screw_head`) | A single countersunk M4 — head flush in the plate front, shaft through the centre gap, thread into the wedge — both **spreads the jaws and clamps the stack together**. So the original's separate face-plate bolts are gone: one fastener, no anchoring problem. |
| **Countersunk head** (`screw_head="flat"` default, or `"socket"`) | Flush 90° countersink like the original, so nothing protrudes behind the accessory. `"socket"` gives a counter-bore for a cap screw instead (needs a wider `dt_pitch`). |
| **Dovetail tuned for FDM with CHAMFERS** (`dt_cham`, `dt_lead`) | Every corner is **chamfered, not rounded** — the locking flanks stay dead straight (full-face contact, solid lock) while 45° chamfers relieve the slot roots (printable) and break the tenon tips. A faceted funnel on the slot + lead-in point on the tenon **self-align it as it drops in**. |
| **Dovetail runs vertically (Z), open top & bottom** | Accessories **drop in from the top**, held by gravity + locked in X & Y. Printed Z-up the dovetail is a constant-section extrusion ⇒ zero overhang. |
| **Grip teeth OFF by default** (`grip_teeth=false`) | Honest call: on a **hard** slot (tile/stone/metal) PETG teeth can't bite — they just cut contact area and *reduce* friction grip. A flat face holds better. Teeth are an opt-in for a **soft** slot (wood/plaster); a TPU pad pocket is the real upgrade if a hard slot is slippery. |
| **Centred jaws on X** | The original built jaws from `X=0`; centring on `X=0` makes the whole assembly symmetric so dimensions reflow cleanly. |
| **Softened visible edges** (`edge` radius on face plate + accessory; `cham` lead-in on the jaw insertion edge) | Calm show face toward the room; chamfered insertion edge slides into the slot and dodges elephant's-foot. |
| **Wedge end-tabs as retainers + self-tap drive** (`drive_pilot`) | Tabs cap the wedge ends so it can't slide out along X; the M4 self-taps the wedge once (set-and-forget). Swap to a heat-set insert if you'll re-adjust often. |

---

## 4. The mounting standard (dovetail interface)

**This is the reusable part.** Every accessory keys onto the mount through one
shared dovetail spec. Keep these identical between the mount and every accessory:

```
dt_pitch = 20    // centre-to-centre of the two tails  (=> X = ±10)
dt_mouth = 5.2   // narrow (mouth) width
dt_base  = 12.0  // wide (deep) width
dt_depth = 4.1   // depth into the plate (+Y)
dt_cham  = 0.7   // 45° corner chamfer (relief + tip break; flanks stay straight)
dt_lead  = 1.8   // 45° lead-in (slot funnel + tenon point) for drop-in
```

- The **face plate** carries two **female** slots (full height, open top &
  bottom). The mouth is narrow at the front face and widens into the plate — the
  undercut that locks the accessory in Y.
- An **accessory** carries two **male** tenons (same profile, minus `fit_slip`
  per side for a slip fit) and **slides down from the top** into the slots.
  Result: locked in X (dovetail flanks) and Y (undercut), free only along Z, and
  gravity seats it. Add a bottom stop or a small set-screw if you want positive
  retention.

### Making a new accessory

```scad
// my_accessory.scad
include <../Expansion jaw mount/expansion_jaw.scad>;

module my_thing() { /* ... your soap dish / hook / shelf ... */ }

my_thing();
accessory_base();   // <- the two male dovetail tenons + backing plate
```

`accessory_base()`, `dovetail_profile_2d()` and the `dt_*` variables are exposed
for exactly this. Build your object, drop `accessory_base()` on its back, print,
slide it onto the mounted clamp. (When we build the first real one together I'll
wire your object's back directly to the tenons rather than the generic plate.)

---

## 5. Rendering & exporting

`part` selects what to emit:

| `part` value      | What you get |
|-------------------|--------------|
| `assembly`        | all parts positioned (default); `explode=N` to pull apart, `show_slot` for a mock slot |
| `top_jaw` / `bottom_jaw` / `jaws` | the jaw(s) |
| `wedge`           | the wedge |
| `face_plate`      | the mount face plate |
| `accessory`       | the generic dovetail accessory base |
| `interface_test`  | face plate + accessory seated, to check the dovetail fit |

```bash
# preview the whole thing
openscad "Expansion jaw mount/expansion_jaw.scad"

# export a part for printing (bump $fn for the final)
openscad -o top_jaw.stl  -D 'part="top_jaw"'  -D '$fn=96' "Expansion jaw mount/expansion_jaw.scad"
openscad -o wedge.stl    -D 'part="wedge"'     -D '$fn=96' "Expansion jaw mount/expansion_jaw.scad"

# retarget to YOUR slot once measured
openscad -o face_plate.stl -D 'slot_gap=12' -D 'Jaws_depth=18' ... "Expansion jaw mount/expansion_jaw.scad"
```

---

## 6. Print orientation & assembly

**Print orientation (per part):**

- **Jaws** — stand each on its **front (−Y) face** so the inclined inner face
  and the outer clamping face print as near-vertical walls (support-free incline,
  clean faces).
- **Wedge** — lay it on a **long inclined face**; both 10° faces come off clean
  and the self-tap pocket prints horizontally (bore it slightly under and tap, or
  add a heat-set insert).
- **Face plate** — stand it **Z-up (on its bottom edge)**, *not* flat. The
  dovetail then prints as a constant-section vertical extrusion (perfect flanks,
  zero overhang) and the funnel mouth ends up at the top where you want it. The
  flat front/back become clean vertical show faces.
- **Accessory** — depends on the object; orient so the dovetail tenons run
  vertically (along the slide axis) and don't need support.

**Assembly (one screw, no other hardware):**

1. Seat the wedge between the jaws, inclined faces matched, tabs outboard.
2. Hold the face plate against the jaw fronts and run the single countersunk M4
   through the plate centre, between the jaws, and self-tap it into the wedge.
   The screw now loosely captures the whole stack (head ↔ plate ↔ jaws ↔ wedge).
3. With the screw backed off, the jaws sit collapsed — slide the unit into the
   slot, then **tighten the M4**: it draws the wedge forward, spreading the jaws
   until they bite, and simultaneously cinches the plate against the jaw fronts.
4. Drop your accessory onto the dovetail from the top — done.

---

## 7. Open decisions (finalize with a real slot)

These are deliberately deferred — they depend on your measured slot and the
first accessory:

1. **Slot dimensions.** `slot_gap` (vertical opening) and `Jaws_depth` (how deep
   it runs) currently default to the original 41 × 25 mm envelope. Measure the
   bathroom slot and override; the whole model reflows.
2. **X-location of the jaws during assembly.** The single screw closes the force
   loop, but until the unit is clamped in the slot the jaws can slide sideways
   (X) on the wedge. It's a set-and-forget mount so this is just mild assembly
   fiddliness; if it annoys you, I can add shallow locating ribs on the plate
   back. (The *anchoring* problem itself is solved — one screw does it.)
3. **Expansion range vs. grip force.** With a 10° wedge the travel-to-spread ratio
   is gentle (good mechanical advantage, small range, self-locking so it won't
   vibrate loose). If your slot tolerance is loose, lengthen `wedge_depth` or
   pre-shim the collapsed gap.
4. **Grip face.** Default is a flat clamping face (max friction on a hard slot).
   If your slot is soft, `grip_teeth=true`. If a hard slot proves slippery, the
   real fix is a TPU pad pocket on the outer faces — say the word and I'll add it.

---

## Files

- `expansion_jaw.scad` — the parametric model (mount + generic accessory base +
  reusable dovetail interface modules).
