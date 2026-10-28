// Slide-lock shim for 0.9 mm perforated cover — v9 (wedge hooks, prints flat, no overhangs)
// OpenSCAD + BOSL2. Rename to .scad to open.
// PRINT FLAT, hooks up, no supports. With hook_style = "wedge" every surface of the
// hook heads is at 45 deg or steeper, so nothing sags. As the shim slides home, the
// slot end rides down the wedge toward the stem and gets pinched.
// (hook_style = "ledge" is the old flat-bottomed head; set print_ready = true to
//  export it standing on edge.)
//
// HOW IT FITS
//   1. Hold the shim under the cover about 2 mm to the LEFT (-X) of its final spot,
//      push the two hooks up through the long slots. The bump under the round hole
//      area gets pushed down - the tongue flexes (do this before the shim sits on
//      anything below it, the tongue needs ~1.5 mm to dip).
//   2. Slide the shim RIGHT (+X) along the slots. The hook heads ride over the metal
//      past the slot ends, then the bump clicks up into the round hole.
//   3. To remove: push the bump down through the round hole with a pin, slide left.
//
// Axes: X runs along the slots (left/right in your photos), Y across the rows.
// Origin = original shim centre, in the FINAL (locked) position (body is offset by shim_cx).

include <BOSL2/std.scad>

/* [Shim body] */
shim_x     = 15;
shim_cx    = 2.5;        // shim centre offset: 5 mm trimmed off the left (-X) end
shim_y     = 15;
shim_t     = 1.5;
shim_round = 1;

/* [Metal cover] */
metal_t = 0.9;
fit_gap = 0.15;          // room between shim top / hook underside and the sheet

/* [Hole geometry] */
slot_w     = 2.55;       // long slot width (caliper)
slot_len   = 15.0;       // long slot length (photo estimate)
row_pitch  = 10.01;      // long slot centre-to-centre (caliper: 7.46 inner + 2.55)
slot_tip_x = 5.5;        // X of the RIGHT tip of the long slots (photo estimate)
round_d    = 2.4;        // round hole (caliper)
round_pos  = [slot_tip_x - round_d/2, 0];  // right edge lines up with the slot tips
short_slot = [7.3, 2.55];
short_pos  = [-3.3, 0];

/* [Hooks] */
hook_style = "wedge";    // "wedge" (prints flat) or "ledge" (old style)
wedge_gap  = 0.05;       // wedge underside vs sheet top at the slot end when locked
                         // (lower / negative = tighter pinch)
side_clear = 0.2;        // stem/head to slot wall, per side
end_clear  = 0.2;        // stem tip to slot tip when locked
stem_len   = 4;          // stem length along the slot
head_t     = 0.9;        // head thickness above the sheet
flat_over  = 0.9;        // flat-bottomed grip past the stem (prints as a small overhang)
                         // beyond that, the underside rises at 45 deg (support-free)

/* [Detent tongue] */
use_bump    = true;
tongue_root = -3.5;      // X where the tongue joins the shim
tongue_w    = 3.0;
tongue_t    = 1.1;       // thinner than the shim = more flex
tongue_gap  = 0.8;       // U-shaped cut around the tongue
bump_d      = 1.6;       // in a 2.4 hole: +/-0.4 mm position tolerance
bump_h      = 1.6;       // height above shim top (sheet is 0.9, so ~0.55 mm pokes out above it)

/* [Preview / export] */
print_ready    = false;  // true = stand on edge for printing; false = lying flat for viewing
show_metal     = true;
show_insert    = false;  // true = ghost metal shown at the insertion position
max_peg_h      = 3;

$fn = 64;

// ---------- derived ----------
hw         = slot_w - 2*side_clear;       // hook width
stem_h     = metal_t + fit_gap;
hook_h     = stem_h + head_t;
stem_right = slot_tip_x - end_clear;
stem_left  = stem_right - stem_len;
wedge_z0   = metal_t + wedge_gap - end_clear;   // height where the wedge starts on the stem face
head_right = hook_style == "wedge" ? stem_right + (hook_h - wedge_z0)
                                   : stem_right + flat_over + head_t;
slide      = head_right - slot_tip_x + end_clear + 0.3;   // how far to slide on insert
hook_pos_y = [row_pitch/2, -row_pitch/2];
tongue_end = round_pos.x + bump_d/2 + 0.7;
bump_top   = shim_t + bump_h;

assert(bump_h <= max_peg_h, "Bump too tall");
assert(tongue_t < shim_t, "Tongue must be thinner than the shim");
assert(tongue_root > shim_cx - shim_x/2 + 1, "Tongue root too close to the shim end");
assert(wedge_z0 > 0.3, "wedge starts too low on the stem");
assert(hook_h <= max_peg_h, str("Hook height ", hook_h, " exceeds ", max_peg_h));
assert(head_right - stem_left + slide <= slot_len, "Head won't fit through the slot on insertion");
assert(tongue_w/2 + tongue_gap < row_pitch/2 - hw/2, "Tongue cut runs into a hook");

// ---------- modules ----------
// plan shape with a rounded right end matching the slot end
module rounded_bar(x0, x1, w, h) {
    hull() {
        translate([x0, -w/2, 0]) cube([0.01, w, h]);
        translate([x1 - w/2, 0, 0]) cylinder(d=w, h=h);
    }
}

module hook() {
    if (hook_style == "wedge") {
        // straight stem up to the wedge start
        rounded_bar(stem_left, stem_right, hw, wedge_z0 + 0.01);
        // 45 deg sweep of the rounded end out to the top
        hull() {
            up(wedge_z0) rounded_bar(stem_left, stem_right, hw, 0.01);
            up(hook_h - 0.01) rounded_bar(stem_left, head_right, hw, 0.01);
        }
    } else {
        rounded_bar(stem_left, stem_right, hw, stem_h + 0.01);
        up(stem_h) intersection() {
            rounded_bar(stem_left, head_right, hw, head_t);
            rotate([90, 0, 0])
                linear_extrude(hw + 2, center=true)
                    polygon([[stem_left, 0],
                             [stem_right + flat_over, 0],
                             [stem_right + flat_over + head_t, head_t],
                             [stem_left, head_t]]);
        }
    }
}

module tongue_cut() {
    // U-shaped slot through the shim, open toward the root
    difference() {
        translate([tongue_root, -(tongue_w/2 + tongue_gap), -1])
            cube([tongue_end - tongue_root + tongue_gap, tongue_w + 2*tongue_gap, shim_t + 2]);
        translate([tongue_root - 1, -tongue_w/2, -2])
            cube([tongue_end - tongue_root + 1, tongue_w, shim_t + 4]);
    }
    // thin the tongue from the top
    translate([tongue_root, -tongue_w/2, tongue_t])
        cube([tongue_end - tongue_root + 0.01, tongue_w, shim_t]);
}

module bump() {
    translate([round_pos.x, round_pos.y, tongue_t - 0.01])
        cyl(d=bump_d, h=bump_top - tongue_t + 0.01, chamfer2=0.2, anchor=BOT);
}

module obround(len, w, h) {
    cuboid([len, w, h], rounding=w/2 - 0.001, edges="Z");
}

// ---------- model ----------
module part() {
    difference() {
        right(shim_cx) cuboid([shim_x, shim_y, shim_t], rounding=shim_round, edges="Z", anchor=BOT);
        if (use_bump) tongue_cut();
    }
    for (y = hook_pos_y) translate([0, y, shim_t]) hook();
    if (use_bump) bump();
}

if (print_ready)
    up(shim_y/2) xrot(90) part();   // the -Y long edge sits on the bed
else
    part();

// ghost of the metal (preview only)
if (show_metal && !print_ready)
    %translate([show_insert ? slide : 0, 0, shim_t + fit_gap]) difference() {
        right(shim_cx) cuboid([shim_x + 14, shim_y + 10, metal_t], anchor=BOT);
        up(metal_t/2) {
            for (y = hook_pos_y) translate([slot_tip_x - slot_len/2, y]) obround(slot_len, slot_w, metal_t + 1);
            translate(short_pos) obround(short_slot[0], short_slot[1], metal_t + 1);
            translate(round_pos) cyl(d=round_d, h=metal_t + 1);
        }
    }

echo(str("Hook height above shim: ", hook_h, " mm; bump: ", bump_h,
         " mm; slide distance on insert: ", slide, " mm"));