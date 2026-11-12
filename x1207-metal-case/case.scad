// Geekworm/Suptronics X1207-C1 metal case (for Raspberry Pi 5 + X1207/X1208 UPS)
// Communication model: shows sticker surface vs. vent/port holes. NOT dimensionally exact.
// OpenSCAD + BOSL2.   openscad -D 'part="base"' -o renders/base.stl case.scad     part = both | base | lid
//
// Overall size 92.8 x 90.8 x 42.8 mm and the 65 mm hanging-hole spacing are published specs
// (wiki.geekworm.com/X1207-C1). Hole positions/sizes are traced by eye from the wiki, product
// and teardown photos: expect errors of a few mm. All of them are parameters below.
//
// PARTS
//   lid  = L-shaped: top plate + the PORT FACE (Ethernet/USB), 90 deg bend, 4 corner screw holes.
//          Its rear edge has a joggled strip, one sheet thickness below the plate and 5 mm
//          narrower on each side, which slots UNDER the rear flange of the base.
//   base = bottom + the other three walls (side A, side B, rear), with a small inward flange
//          along the top of each wall. Side flanges are one thickness below the top plane (the
//          lid plate sits on them); the rear flange is flush with the top plane.
//   Assembly: tilt the lid, slide the strip under the rear flange, pivot the plate down onto
//          the side flanges, then screw through the port face.
// AXES (origin = footprint centre, z=0 = bottom)
//   -Y port face (Eth, 2xUSB3/2.0 stacks, UPS USB-C in)      +Y rear: LED hole, TF slot, power button
//   -X side A: Pi USB-C + 2x micro-HDMI at the rear end       +X side B: vents only
include <BOSL2/std.scad>

part = "both";

/* [Body] */
wx      = 90.8;   // X, across the port face
wy      = 92.8;   // Y, depth
hgt     = 42.8;   // Z
t       = 1.0;    // sheet thickness
corner_r = 1.0;   // vertical-edge rounding
flange_w = 4;     // width of the inward flanges
strip_inset = 5;  // lid rear strip is this much narrower than the lid on each side
strip_gap = 0.3;  // clearance between lid plate end and rear flange
explode  = 0;     // preview gap between parts

/* [Staggered slot pattern (top and sides)] */
// Rows of long slots, alternate rows shifted half a period. Slots are clipped to the region:
// a clipped slot becomes a shorter slot, or a dot when almost nothing is left, so edges line up.
top_region_x = 72;   top_rows = 13;  top_row_pitch = 5.8;
top_L = 14; top_gap = 5; top_w = 2.4;       // slot length, gap along the row, slot width
side_L = 12; side_gap = 5; side_w = 2.2;

/* [Bottom] */
foot_d = 7;                        // domed rubber feet (hemispheres)
foot_xy = [37, 39];
plus_x = 6;  plus_y = 32.5;        // hanging holes at (plus_x, +/-plus_y) -> 65 mm apart
plus_arm = 9; plus_w = 2.5;
bot_groupA = [-14, 6, 4.5, 38];    // [x centre, slot count, pitch, slot length]; slots run along Y
bot_groupB = [ 26, 4, 4.5, 34];
bot_slot_w = 2.2;

/* [Port face, -Y: in the lid] */
port_z   = 25;
eth      = [-34.5, 16, 14];        // [x, w, h]
usb3     = [-16.4, 15, 16];
usb2     = [  1.8, 15, 16];
usbc_in  = [ 17.2, 10, 4];         // UPS USB-C power in
screw_d  = 3; screw_in = 4; screw_z_in = 4.5;  // corner screws: inset from the face edges

/* [Side A, -X: connectors at the rear end] */
sa_usbc = [33.2, 10, 4, 19];       // [y, w, h, z] Pi USB-C (do not power from it)
sa_hdmi = [[18.4, 7, 4, 19], [4.9, 7, 4, 19]];
sa_region = [4, 68, 2, hgt - 10]; // staggered vents [centre y, length, rows, z of first row]

/* [Rear, +Y: Pi microSD end] */
// positions read off the labelled wiki photo (case upside down): z counts up from the bottom plate
rr_led = [[-36.6, 2.5, 16], [-33.5, 2, 12]];   // SSD LED hole + a small neighbour [x, d, z]
rr_tf  = [-21, 13, 3.2, 12];       // TF slot [x, w, h, z] (obround)
rr_btn = [-4.1, 5.5, 35.7];        // power button hole [x, d, z]
rr_region = [-7.5, 66, 2, 24.5];   // staggered vents [centre x, length, rows, z of row centre]

/* [Side B, +X: vents only] */
sb_region = [0, 70, 4, hgt - 8];

/* [Colours] */
base_color = "#2f3b4a";
lid_color  = "#c8cdd2";

$fn = 40;

module obround2d(l, w) hull() { for (s = [-1, 1]) translate([s*(l - w)/2, 0]) circle(d=w); }

// 2D staggered slot pattern. u = along the slots, v = across the rows. Centred on the origin.
module stagger2d(Wu, nrows, rp, L, g, w) {
    p = L + g;
    n = ceil(Wu/p) + 1;
    for (r = [0:nrows-1], k = [-n:n]) {
        c = k*p + (r % 2) * p/2;
        lo = max(c - L/2, -Wu/2);  hi = min(c + L/2, Wu/2);
        len = hi - lo;  v = (r - (nrows-1)/2) * rp;
        if (len >= 1.5*w) translate([(lo+hi)/2, v]) obround2d(len, w);
        else if (len >= 0.6*w) translate([(lo+hi)/2, v]) circle(d=w);
    }
}

// extrude a 2D cutter through a wall; (u,v) = (along wall, height)
module wallx(side, u, v) {   // side wall at +/-X, u along Y
    translate([side > 0 ? wx/2 - 2*t : -wx/2 - t, u, v]) rotate([90, 0, 90]) linear_extrude(3*t) children();
}
module wally(side, u, v) {   // front/rear wall at -/+Y, u along X
    translate([u, side > 0 ? wy/2 + t : -wy/2 + 2*t, v]) rotate([90, 0, 0]) linear_extrude(3*t) children();
}
// vents on a wall from a [centre, length, rows, z-of-first-row] region (rows go down from z)
module wall_pattern(reg, L, g, w, rp=5.5) {
    translate([reg[0], 0]) translate([0, reg[3] - (reg[2]-1)*rp/2]) stagger2d(reg[1], reg[2], rp, L, g, w);
}

// ---- cutters ----
module lid_cutters() {
    translate([0, 0, hgt - 2*t]) linear_extrude(3*t) stagger2d(top_region_x, top_rows, top_row_pitch, top_L, top_gap, top_w);
    for (p = [eth, usb3, usb2]) wally(-1, p[0], port_z) offset(r=0.8) square([p[1]-1.6, p[2]-1.6], center=true);
    wally(-1, usbc_in[0], port_z + 2) obround2d(usbc_in[1], usbc_in[2]);
    for (sx = [-1, 1], z = [screw_z_in, hgt - screw_in - 1]) wally(-1, sx*(wx/2 - screw_in), z) circle(d=screw_d);
}

module plus() { cuboid([plus_arm, plus_w, 3*t]); cuboid([plus_w, plus_arm, 3*t]); }

module base_cutters() {
    // bottom
    for (g = [bot_groupA, bot_groupB], i = [0:g[1]-1])
        translate([g[0] + (i - (g[1]-1)/2) * g[2], 0, -t]) linear_extrude(3*t) rotate(90) obround2d(g[3], bot_slot_w);
    for (s = [-1, 1]) translate([plus_x, s*plus_y, t/2]) plus();
    // side A: connectors + vents
    wallx(-1, sa_usbc[0], sa_usbc[3]) obround2d_rot(sa_usbc[1], sa_usbc[2]);
    for (h = sa_hdmi) wallx(-1, h[0], h[3]) obround2d_rot(h[1], h[2]);
    wallx(-1, sa_region[0], 0) wall_pattern([0, sa_region[1], sa_region[2], sa_region[3]], side_L, side_gap, side_w);
    // side B: vents
    wallx(1, sb_region[0], 0) wall_pattern([0, sb_region[1], sb_region[2], sb_region[3]], side_L, side_gap, side_w);
    // rear: LED, TF, button, vents
    for (l = rr_led) wally(1, l[0], l[2]) circle(d=l[1]);
    wally(1, rr_tf[0], rr_tf[3]) obround2d(rr_tf[1], rr_tf[2]);
    wally(1, rr_btn[0], rr_btn[2]) circle(d=rr_btn[1]);
    wally(1, rr_region[0], 0) wall_pattern([0, rr_region[1], rr_region[2], rr_region[3]], side_L, side_gap, side_w);
}
// connector holes on side walls: u runs along Y, so a "w x h" obround is w along Y
module obround2d_rot(w, h) obround2d(w, h);

// ---- parts ----
module outer() cuboid([wx, wy, hgt], rounding=corner_r, edges="Z", anchor=BOT);
module inner() up(t) cuboid([wx - 2*t, wy - 2*t, hgt - 2*t], rounding=max(corner_r - t, 0.1), edges="Z", anchor=BOT);

module lid_solid() {
    y_end = wy/2 - t - flange_w - strip_gap;      // where the flat plate stops, in front of the rear flange
    intersection() {
        outer();
        union() {
            translate([-wx/2 - 1, -wy/2 - 1, hgt - t]) cube([wx + 2, y_end + wy/2 + 1, t + 1]);   // top plate
            translate([-wx/2 - 1, -wy/2 - 1, -1]) cube([wx + 2, t + 1, hgt + 2]);                  // port face
            // joggle: step down one thickness, then a flat strip that runs under the rear flange
            translate([-(wx/2 - strip_inset), y_end - t, hgt - 2*t]) cube([wx - 2*strip_inset, t, 2*t]);
            translate([-(wx/2 - strip_inset), y_end - t, hgt - 2*t]) cube([wx - 2*strip_inset, flange_w + strip_gap + t - 0.3, t]);
        }
    }
}

module base_solid() {
    union() {
        intersection() {
            difference() { outer(); inner(); }
            translate([-wx/2 - 1, -wy/2 + t, -1]) cube([wx + 2, wy, hgt]);          // below the lid plate, behind the port face
        }
        // rear wall runs to the full height and folds in as a flange flush with the top plane
        intersection() {
            outer();
            translate([-wx/2 - 1, wy/2 - t - flange_w, hgt - t]) cube([wx + 2, flange_w + t + 1, t]);
        }
        // inward flanges along the top of side A, side B and rear
        translate([0, 0, hgt - 2*t]) difference() {
            translate([-wx/2 + t/2, -wy/2 + t, 0]) cube([wx - t, wy - t - t/2, t]);
            translate([-wx/2 + t + flange_w, -wy/2, -1]) cube([wx - 2*t - 2*flange_w, wy + 2, t + 2]);
        }
        // domed rubber feet
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*foot_xy[0], sy*foot_xy[1], 0]) intersection() {
                scale([1, 1, 0.45]) sphere(d=foot_d);
                translate([-foot_d, -foot_d, -foot_d]) cube([2*foot_d, 2*foot_d, foot_d]);
            }
    }
}

module lid()  { color(lid_color)  difference() { lid_solid();  lid_cutters(); } }
module base() { color(base_color) difference() { base_solid(); base_cutters(); } }

if (part == "base") base();
else if (part == "lid") lid();
else { base(); up(explode) lid(); }
