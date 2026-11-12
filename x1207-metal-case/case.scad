// Suptronics X1207/X1208 metal case - communication model (NOT dimensionally exact).
// Purpose: show where sticker/branding surface is available and where vents must stay clear.
// OpenSCAD + BOSL2.  Render one part at a time:  openscad -D 'part="base"' -o base.stl case.scad
//   part = "both" (coloured preview) | "base" | "lid" | "vents" (hole cutters only)
//
// !! PLACEHOLDER HOLE LAYOUT !!  Overall size 92.8 x 90.8 x 42.8 is the published size of the
// Geekworm X1207-C1 case. Sheet thickness and slot size come from ../v4/case-switch-shim.scad.
// Split line height and the hole *layout* are estimates, not yet checked against the wiki
// drawings - edit the parameters below.
include <BOSL2/std.scad>

part = "both";

/* [Body] */
len      = 92.8;   // X
wid      = 90.8;   // Y
hgt      = 42.8;   // Z total
t        = 0.9;    // sheet thickness
corner_r = 1.5;
lid_drop = 14.0;   // how far the lid's side flanges come down over the base (split line height)
explode  = 0;      // mm gap between parts, for preview

/* [Slots - top and bottom plates] */
slot_w    = 2.55;
slot_l    = 15;
row_pitch = 10.01; // Y pitch between slot rows
top_cols  = [-30, -10, 10, 30];     // X centres of slots, top
top_rows  = [-3, -2, -1, 0, 1, 2, 3];             // multiples of row_pitch
bot_cols  = [-20, 0, 20];           // X centres, bottom
bot_rows  = [-3, -2, -1, 0, 1, 2, 3];

/* [Slots - side walls] */
side_slot_l = 8;
side_slot_w = 2.55;
long_side_cols = [-30, -15, 0, 15, 30];  // X centres on the two long (front/back) walls
short_side_rows = [-30, -15, 0, 15, 30];            // Y centres on the two short (end) walls
side_slot_z = 12.0;   // slot centre height above the bottom (in the base)

/* [Colours] */
base_color = "#2f3b4a";
lid_color  = "#c8cdd2";

$fn = 48;

split_z = hgt - lid_drop;   // z of split line, from the bottom (z=0)

module shell(h, bottom=true, top=true) {
    // thin-walled box; open at whichever of top/bottom is false
    difference() {
        cuboid([len, wid, h], rounding=corner_r, edges="Z", anchor=BOT);
        up(bottom ? t : -0.01)
            cuboid([len - 2*t, wid - 2*t, h - (bottom?t:0) - (top?t:0) + (bottom?0:0.02)],
                   rounding=max(corner_r - t, 0.1), edges="Z", anchor=BOT);
    }
}

module slot(l, w, h=t*4) { cuboid([l, w, h], rounding=w/2 - 0.001, edges="Z"); }

module plate_slots(cols, rows) {
    for (x = cols, r = rows) translate([x, r*row_pitch, 0]) slot(slot_l, slot_w);
}

module base_vents() {
    // bottom plate
    translate([0, 0, t/2]) plate_slots(bot_cols, bot_rows);
    // long walls (front/back), slots run along X
    for (s = [-1, 1], x = long_side_cols)
        translate([x, s*(wid/2 - t/2), side_slot_z]) rotate([90, 0, 0]) slot(side_slot_l, side_slot_w);
    // short walls (ends), slots run along Y
    for (s = [-1, 1], y = short_side_rows)
        translate([s*(len/2 - t/2), y, side_slot_z]) rotate([90, 0, 90]) slot(side_slot_l, side_slot_w);
}

module lid_vents() {
    translate([0, 0, lid_h() - t/2]) plate_slots(top_cols, top_rows);
}

function lid_h() = lid_drop + 0;

module base() {
    color(base_color) difference() {
        shell(split_z, bottom=true, top=false);
        base_vents();
    }
}

module lid() {
    // lid is the top plate plus short flanges; flange slightly larger so it slides over the base
    color(lid_color) difference() {
        down(0) shell(lid_drop, bottom=false, top=true);
        lid_vents();
    }
}

if (part == "base")  base();
else if (part == "lid")  up(split_z) lid();
else if (part == "vents") { base_vents(); }
else { base(); up(split_z + explode) lid(); }
