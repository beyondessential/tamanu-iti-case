// Geekworm/Suptronics X1207-C1 metal case (for Raspberry Pi 5 + X1207/X1208 UPS)
// Communication model: shows sticker surface vs. vent/port holes. NOT dimensionally exact.
// OpenSCAD + BOSL2.
//   openscad -D 'part="base"' -o renders/base.stl case.scad     part = both | base | lid
//
// Source: overall size 92.8 x 90.8 x 42.8 mm and hanging-hole spacing 65 mm are the published
// specs (wiki.geekworm.com/X1207-C1). Hole positions/sizes are traced by eye from the wiki and
// product photos, so expect errors of a few mm. All of them are parameters below.
//
// Axes: origin at the centre of the footprint, z=0 at the bottom of the case.
//   -Y = PORT FACE (Ethernet, 2x USB3, 2x USB2, UPS USB-C in)
//   +Y = rear (slots only)
//   -X = "side A": Pi USB-C + 2x micro-HDMI (rear end), SD slot, power button, LEDs, vents
//   +X = "side B": vents only
//   bottom: 4 rubber pads, 2 plus-shaped hanging holes (65 mm apart), 2 groups of slots
//   top: staggered grid of short slots
// Split: the lid is the top plate plus ~5 mm flanges on sides A and B (seam seen on side A in
// the photos). Front and rear walls belong to the base and run the full height.
include <BOSL2/std.scad>

part = "both";

/* [Body] */
wx      = 90.8;   // X, across the port face
wy      = 92.8;   // Y, depth
hgt     = 42.8;   // Z
t       = 1.0;    // sheet thickness
corner_r = 1.0;   // vertical-edge rounding
lid_drop = 5.0;   // lid flange depth on sides A/B
explode  = 0;     // preview gap between parts

/* [Top slots: staggered grid] */
top_slot_l = 11;
top_slot_w = 2.2;
top_cols   = 5;
top_col_pitch = 13;
top_rows   = 11;
top_row_pitch = 6.2;

/* [Bottom] */
pad_d = 9;  pad_h = 2;
pad_xy = [37, 39];                 // pad centre offsets (+/-)
plus_x = 6;  plus_y = 32.5;        // hanging holes at (plus_x, +/-plus_y) -> 65 mm apart
plus_arm = 9; plus_w = 2.5;
bot_groupA = [-14, 6, 4.5, 30];    // [x centre, slot count, pitch, slot length], slots run along Y
bot_groupB = [ 26, 3, 4.5, 30];
bot_slot_w = 2.2;

/* [Port face, -Y] */
port_z   = 25;
eth      = [-34.5, 16, 14];        // [x, w, h]
usb3     = [-16.4, 15, 16];
usb2     = [  1.8, 15, 16];
usbc_in  = [ 17.2, 10, 4];         // UPS USB-C power in

/* [Side A, -X] */
sa_usbc = [33.2, 10, 4,  21];      // [y, w, h, z]  Pi USB-C (do not power from it)
sa_hdmi = [[18.4, 7, 4, 21], [4.9, 7, 4, 21]];
sa_sd   = [-31, 12, 2.5, 18];      // TF slot
sa_btn  = [-12, 5, 30];            // power button hole [y, d, z]
sa_led  = [-22, 2.5, 31];          // SSD LED hole [y, d, z]

/* [Side vents] */
vent_l = 8; vent_w = 2.2;
vent_rows_z = [hgt - 12, hgt - 19];        // rows on sides B and rear
vent_cols_b   = [-27, -13.5, 0, 13.5, 27]; // Y centres on side B
vent_cols_rear = [-27, -13.5, 0, 13.5, 27];// X centres on rear
vent_rows_a_z = [hgt - 12, 9];             // side A (between the port holes)
vent_cols_a   = [-40, 0, 12];              // Y centres on side A rows

/* [Colours] */
base_color = "#2f3b4a";
lid_color  = "#c8cdd2";

$fn = 40;
eps = 0.05;

module slot(l, w, h=3*t) { cuboid([l, w, h], rounding=w/2 - 0.001, edges="Z"); }
module rrect(sz) { cuboid(sz, rounding=min(sz[0], sz[1])/2 - 0.01, edges="Z"); }

// ---- hole cutters ----
module top_cutters() {
    for (r = [0:top_rows-1], c = [0:top_cols-1]) {
        stagger = (r % 2) * top_col_pitch / 2;
        x = (c - (top_cols-1)/2) * top_col_pitch + (r % 2 == 0 ? -1 : 1) * top_col_pitch / 4;
        y = (r - (top_rows-1)/2) * top_row_pitch;
        translate([x, y, hgt - t/2]) slot(top_slot_l, top_slot_w);
    }
}

module plus() { cuboid([plus_arm, plus_w, 3*t]); cuboid([plus_w, plus_arm, 3*t]); }

module bottom_cutters() {
    for (g = [bot_groupA, bot_groupB], i = [0:g[1]-1])
        translate([g[0] + (i - (g[1]-1)/2) * g[2], 0, t/2]) rotate(90) slot(g[3], bot_slot_w);
    for (s = [-1, 1]) translate([plus_x, s*plus_y, t/2]) plus();
}

// holes through the wall at +/-X: orient a cutter's long axis along Y (slot) at (side, y, z)
module xwall_slot(side, y, z, l=vent_l, w=vent_w) {
    translate([side*(wx/2 - t/2), y, z]) rotate([90, 0, 90]) slot(l, w, 3*t);
}
module ywall_slot(side, x, z, l=vent_l, w=vent_w) {
    translate([x, side*(wy/2 - t/2), z]) rotate([90, 0, 0]) slot(l, w, 3*t);
}

module wall_cutters() {
    // port face (-Y)
    for (p = [eth, usb3, usb2]) translate([p[0], -(wy/2 - t/2), port_z]) rotate([90,0,0]) cuboid([p[1], p[2], 3*t], rounding=0.8, edges="Y");
    translate([usbc_in[0], -(wy/2 - t/2), port_z + 2]) rotate([90,0,0]) slot(usbc_in[1], usbc_in[2]);
    // rear (+Y) vents
    for (z = vent_rows_z, x = vent_cols_rear) ywall_slot(1, x, z);
    // side B (+X) vents
    for (z = vent_rows_z, y = vent_cols_b) xwall_slot(1, y, z);
    // side A (-X): connectors, SD, button, LED, vents
    translate([-(wx/2 - t/2), sa_usbc[0], sa_usbc[3]]) rotate([90,0,90]) slot(sa_usbc[1], sa_usbc[2]);
    for (h = sa_hdmi) translate([-(wx/2 - t/2), h[0], h[3]]) rotate([90,0,90]) slot(h[1], h[2]);
    translate([-(wx/2 - t/2), sa_sd[0], sa_sd[3]]) rotate([90,0,90]) cuboid([sa_sd[1], sa_sd[2], 3*t]);
    translate([-(wx/2 - t/2), sa_btn[0], sa_btn[2]]) rotate([0,90,0]) cyl(d=sa_btn[1], h=3*t);
    translate([-(wx/2 - t/2), sa_led[0], sa_led[2]]) rotate([0,90,0]) cyl(d=sa_led[1], h=3*t);
    for (z = vent_rows_a_z, y = vent_cols_a) xwall_slot(-1, y, z);
}

// ---- body ----
module body() {
    difference() {
        union() {
            difference() {
                cuboid([wx, wy, hgt], rounding=corner_r, edges="Z", anchor=BOT);
                up(t) cuboid([wx - 2*t, wy - 2*t, hgt - 2*t], rounding=max(corner_r - t, 0.1), edges="Z", anchor=BOT);
            }
            // rubber pads
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*pad_xy[0], sy*pad_xy[1], 0]) cyl(d=pad_d, h=pad_h, anchor=TOP);
        }
        top_cutters();
        bottom_cutters();
        wall_cutters();
    }
}

// lid region: top slab spanning the full X, only between the front and rear walls
module lid_region() {
    translate([0, 0, hgt - lid_drop])
        cuboid([wx + 2, wy - 2*t, lid_drop + 1], anchor=BOT);
}

module lid()  { color(lid_color)  intersection() { body(); lid_region(); } }
module base() { color(base_color) difference()   { body(); lid_region(); } }

if (part == "base") base();
else if (part == "lid") lid();
else { base(); up(explode) lid(); }
