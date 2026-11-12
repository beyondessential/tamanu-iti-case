// Tamanu Iti v4 case: the Geekworm/Suptronics X1207-C1 metal case (Raspberry Pi 5 + X1207/X1208 UPS)
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
//   -Y "REAR" = the port face (Eth, 2xUSB3/2.0 stacks, UPS USB-C in)   [code calls it the port face / -Y]
//   +Y "FRONT" = LED hole, TF slot, power button                       [code calls it rr_*, +Y]
//   (team terms: rear = ports, front = power button; the variable names predate that)
//   -X side A: Pi USB-C + 2x micro-HDMI at the rear end       +X side B: vents only
include <BOSL2/std.scad>

part = "both";

/* [Body] */
wx      = 92.8;   // X, across the port face (92.8 = length of the lid's bend line, from the scan)
wy      = 90.8;   // Y, depth
hgt     = 42.8;   // Z
t       = 1.0;    // sheet thickness
corner_r = 1.0;   // vertical-edge rounding
flange_w = 4;     // width of the inward flanges
strip_inset = 8.8;  // lid rear strip is this much narrower than the lid on each side (scan: 75.2 of 92.8 mm)
strip_gap = 0.3;  // clearance between lid plate end and rear flange
explode  = 0;     // preview gap between parts

/* [Vent pattern (top and every side) - measured from a 300 dpi flatbed scan of the lid] */
// Columns of slots that taper: each column is 6 cells along the slot axis, separated by a constant
// gap: a dot and slots of 7, 9, 11, 13 and 15 mm. Neighbouring columns run in opposite directions
// (the long end alternates), so the pattern ends flush on both sides with a dot at one end.
// Slot axis = u. Columns are stacked across v at a fixed pitch.
vent_w   = 2.55;                    // slot width
vent_dot = 2.3;                     // dot diameter
vent_gap = 3.0;                     // gap between cells along a column
vent_lens = [vent_dot, 7, 9, 11, 13, 15];  // cell lengths, ascending along +u for "A" columns
vent_pitch = 5.0;                   // column-to-column distance
// patches: top = [centre along Y, columns]; side faces = [centre along the face, columns, z of centre]
top_patch = [-1.0, 12];             // 12 columns, centred about 1 mm toward the port face from the middle

/* [Bottom] */
foot_d = 7;                        // domed rubber feet (hemispheres)
// Bottom positions below were measured by un-warping (homography) the product photo of the underside
// against the case outline, so they are good to roughly +/-1 mm.
foot_xy = [35.9, 33.7];            // feet at (+/-x, +/-y)
plus_x = -0.9;  plus_y = 32.4;     // hanging holes at (plus_x, +/-plus_y) -> 65 mm apart
plus_arm = 9; plus_w = 2.5;
bot_slot_x = [-30, -25, -20, -15, -10, -5, 0,  15.5, 20.5, 25.5];  // two groups of slots running along Y
bot_slot_len = 43.6;  bot_slot_y = 1.0;  bot_slot_w = 2.55;
screw_x = [-42.3, 7.4];  screw_y = [40.6, -17.4];  // 4 bottom screws: the Pi 5 mounting pattern (49 x 58)
bot_screw_d = 3.2;
bot_hole_xy = [[12, 28.6], [12, -27.4]];           // two small round holes (light pipes / test points)
bot_hole_d = 2.5;

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
sa_region = [2, 2, hgt - 11];  // side A vents [centre y, columns, z of patch centre]

/* [Rear, +Y: Pi microSD end] */
// positions read off the labelled wiki photo (case upside down): z counts up from the bottom plate
rr_led = [-33.8, 2.2, 14.5];       // SSD LED hole [x, d, z] (the dot at the end of the lower vent row is part of the pattern)
rr_tf  = [-20, 13.5, 4.6, 11];     // TF slot [x, w, h, z] (obround)
rr_btn = [-3.9, 6, 35.2];          // power button hole [x, d, z]
rr_region = [-1.4, 2, 23];    // rear vents [centre x, columns, z of patch centre]

btn_stick = 3;                     // the power button protrudes this far from the front face
btn_d     = rr_btn[1] - 0.8;       // slightly smaller than its hole

/* [Side B, +X: vents only] */
sb_region = [0, 2, hgt - 11];   // side B vents

/* [Colours] */
// outside light, inside dark (the viewer darkens inner faces; OpenSCAD previews are single-colour)
base_color = "#8aa4c0";
lid_color  = "#e1e4e8";

$fn = 40;

module obround2d(l, w) hull() { for (s = [-1, 1]) translate([s*(l - w)/2, 0]) circle(d=w); }

// The one vent helper (2D), used by the top and every side. u = along the slots, v = across the
// columns, centred on the origin. Column 0 is at +v and is an "A" column (long end at +u);
// columns then alternate A, B, A, ... where B is A reversed.
function vent_total() = let(c = len(vent_lens)) vent_gap*(c-1) + (vent_lens[0] + vent_lens[1] + vent_lens[2] + vent_lens[3] + vent_lens[4] + vent_lens[5]);
module vent_column(rev) {
    c = len(vent_lens);
    lens = rev ? [for (i = [c-1:-1:0]) vent_lens[i]] : vent_lens;
    for (i = [0:c-1]) {
        before = i == 0 ? 0 : (let(q = [for (k = [0:i-1]) lens[k] + vent_gap]) q * [for (k = [0:i-1]) 1]);
        u = -vent_total()/2 + before + lens[i]/2;
        translate([u, 0]) if (lens[i] == vent_dot) circle(d=vent_dot); else obround2d(lens[i], vent_w);
    }
}
module vent_grid(ncols, swap=false) {
    for (r = [0:ncols-1]) translate([0, ((ncols-1)/2 - r) * vent_pitch]) vent_column((r + (swap ? 1 : 0)) % 2 == 1);
}

// extrude a 2D cutter through a wall; (u,v) = (along wall, height)
module wallx(side, u, v) {   // side wall at +/-X, u along Y
    translate([side > 0 ? wx/2 - 2*t : -wx/2 - t, u, v]) rotate([90, 0, 90]) linear_extrude(3*t) children();
}
module wally(side, u, v) {   // front/rear wall at -/+Y, u along X
    translate([u, side > 0 ? wy/2 + t : -wy/2 + 2*t, v]) rotate([90, 0, 0]) linear_extrude(3*t) children();
}
// ---- cutters ----
module lid_cutters() {
    translate([0, 0, hgt - 2*t]) translate([0, top_patch[0]]) linear_extrude(3*t) vent_grid(top_patch[1]);
    for (p = [eth, usb3, usb2]) wally(-1, p[0], port_z) offset(r=0.8) square([p[1]-1.6, p[2]-1.6], center=true);
    wally(-1, usbc_in[0], port_z + 2) obround2d(usbc_in[1], usbc_in[2]);
    for (sx = [-1, 1], z = [screw_z_in, hgt - screw_in - 1]) wally(-1, sx*(wx/2 - screw_in), z) circle(d=screw_d);
}

module plus() { cuboid([plus_arm, plus_w, 3*t]); cuboid([plus_w, plus_arm, 3*t]); }

module base_cutters() {
    // bottom
    for (x = bot_slot_x) translate([x, bot_slot_y, -t]) linear_extrude(3*t) rotate(90) obround2d(bot_slot_len, bot_slot_w);
    for (x = screw_x, y = screw_y) translate([x, y, -t]) cylinder(d=bot_screw_d, h=3*t);
    for (h = bot_hole_xy) translate([h[0], h[1], -t]) cylinder(d=bot_hole_d, h=3*t);
    for (s = [-1, 1]) translate([plus_x, s*plus_y, t/2]) plus();
    // side A: connectors + vents
    wallx(-1, sa_usbc[0], sa_usbc[3]) obround2d_rot(sa_usbc[1], sa_usbc[2]);
    for (h = sa_hdmi) wallx(-1, h[0], h[3]) obround2d_rot(h[1], h[2]);
    wallx(-1, sa_region[0], sa_region[2]) vent_grid(sa_region[1]);
    // side B: vents
    wallx(1, sb_region[0], sb_region[2]) vent_grid(sb_region[1]);
    // rear: LED, TF, button, vents
    wally(1, rr_led[0], rr_led[2]) circle(d=rr_led[1]);
    wally(1, rr_tf[0], rr_tf[3]) obround2d(rr_tf[1], rr_tf[2]);
    wally(1, rr_btn[0], rr_btn[2]) circle(d=rr_btn[1]);
    wally(1, rr_region[0], rr_region[2]) vent_grid(rr_region[1], swap=true);   // upper row long->short toward +X, lower row the reverse
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
            difference() { outer(); translate([0, -(t + 2)/2, t]) cuboid([wx - 2*t, wy - t + 2, hgt], rounding=max(corner_r - t, 0.1), edges="Z", anchor=BOT); }   // cavity open at the top and through the port-face wall (that wall belongs to the lid)
            translate([-wx/2 - 1, -wy/2 + t, -1]) cube([wx + 2, wy, hgt]);          // cut the walls at hgt - t, below the lid plate and behind the port face
        }
        // rear wall runs to the full height and folds in as a flange flush with the top plane
        intersection() {
            outer();
            translate([-wx/2 - 1, wy/2 - t - flange_w, hgt - t - 0.01]) cube([wx + 2, flange_w + t + 1, t + 0.01]);
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

module button() color("cyan") translate([rr_btn[0], wy/2 - t, rr_btn[2]]) rotate([-90, 0, 0]) cylinder(d=btn_d, h=t + btn_stick);

module lid()  { color(lid_color)  difference() { lid_solid();  lid_cutters(); } }
module base() { color(base_color) difference() { base_solid(); base_cutters(); } }

// ---- keepout / sticker zones (thin slabs standing 0.4 mm proud of each face, for the viewer) ----
/* [Zones] */
km        = 3;     // margin kept clear around holes and vents
edge_m    = 1.5;   // width of the "don't wrap over the edge" band round each face
free_edge = 4;     // suggested sticker areas stay this far from edges
screw_zone_d = 8;  // zone drawn round a screw head
function vent_extent(n) = (n - 1) * vent_pitch + vent_w;   // size of a vent patch across its columns

// face-local 2D (u,v) -> 3D slab on the outside of a face. top/bottom: u=X v=Y; rear/front: u=X v=Z; A/B: u=Y v=Z
module face_extrude(face, h=0.4) {
    if (face == "top")         translate([0, 0, hgt + 0.02]) linear_extrude(h) children();
    else if (face == "bottom") translate([0, 0, -0.02 - h]) linear_extrude(h) children();
    else if (face == "rear")   translate([0, -wy/2 - 0.02, 0]) rotate([90, 0, 0]) linear_extrude(h) children();
    else if (face == "front")  translate([0, wy/2 + 0.02 + h, 0]) rotate([90, 0, 0]) linear_extrude(h) children();
    else if (face == "A")      translate([-wx/2 - 0.02 - h, 0, 0]) rotate([90, 0, 90]) linear_extrude(h) children();
    else if (face == "B")      translate([wx/2 + 0.02, 0, 0]) rotate([90, 0, 90]) linear_extrude(h) children();
}
module rect2(u0, u1, v0, v1) translate([(u0+u1)/2, (v0+v1)/2]) square([u1-u0, v1-v0], center=true);
module circ2(u, v, d) translate([u, v]) circle(d=d);
module frame2(w, h, vc=0) translate([0, vc]) difference() { square([w, h], center=true); square([w - 2*edge_m, h - 2*edge_m], center=true); }
module vent_rect2(uc, vc, ncols) rect2(uc - vent_total()/2 - km, uc + vent_total()/2 + km, vc - vent_extent(ncols)/2 - km, vc + vent_extent(ncols)/2 + km);
module hole_rect2(u, v, w, h, m=km) rect2(u - w/2 - m, u + w/2 + m, v - h/2 - m, v + h/2 + m);
pi_x = [-45.8, 10.2];   // X extent of the Raspberry Pi 5 board (56 mm wide, from the 49 mm screw pattern); the active cooler sits over it
seam_m = 3;             // half-width of the keep-clear band over a lid/base seam
tamper_screw = [screw_x[1], screw_y[1]];
// A keep-clear band across the sticker-allowed part of the top, snapped to the vent row nearest this distance
// from one edge. top_keep_from "rear" measures from the port face edge (-Y), "front" from the button face edge (+Y).
top_keep_dist = 41;  top_keep_from = "rear";
top_keep_target = top_keep_from == "front" ? wy/2 - top_keep_dist : -wy/2 + top_keep_dist;
top_row0 = top_patch[0] + (top_patch[1] - 1)/2 * vent_pitch;                       // Y of the first vent row, at +Y
top_keep_row = top_row0 - round((top_row0 - top_keep_target) / vent_pitch) * vent_pitch;   // Y of the snapped row   // the bottom screw a tamper-evident sticker should cover

y_seam = wy/2 - t - flange_w - strip_gap;   // where the lid's top plate ends, in front of the rear flange

module bottom_main_vent_rect() rect2(bot_slot_x[0] - bot_slot_w/2 - km, bot_slot_x[6] + bot_slot_w/2 + km, bot_slot_y - bot_slot_len/2 - km, bot_slot_y + bot_slot_len/2 + km);

// kind: "hard" (keep clear), "soft" (avoid), "free" (suggested sticker area); owner: "lid" or "base"
module zones(kind, owner) {
    if (kind == "hard" && owner == "lid") {
        // top: only the vents above the Pi need airflow; the far side has none, so stickers may cover it
        face_extrude("top") {
            rect2(-vent_total()/2 - km, pi_x[1] + 1.5, top_patch[0] - vent_extent(top_patch[1])/2 - km, top_patch[0] + vent_extent(top_patch[1])/2 + km);
            rect2(-wx/2, wx/2, y_seam - seam_m, y_seam + seam_m);       // the gap between lid and base: never cover
            rect2(pi_x[1] + 1.5, wx/2 - free_edge, top_keep_row - vent_pitch/2, top_keep_row + vent_pitch/2);   // the whole vent row near top_keep_dist, across the sticker-allowed side
        }
        face_extrude("rear") {
            for (p = [eth, usb3, usb2]) hole_rect2(p[0], port_z, p[1], p[2]);
            hole_rect2(usbc_in[0], port_z + 2, usbc_in[1], usbc_in[2], 1);   // sticker may wrap this one with a cut-out
        }
    }
    if (kind == "hard" && owner == "base") {
        face_extrude("front") {
            vent_rect2(rr_region[0], rr_region[2], rr_region[1]);
            circ2(rr_led[0], rr_led[2], rr_led[1] + 2*km);               // SD slot is blocked in this design: no zone for it
            circ2(rr_btn[0], rr_btn[2], rr_btn[1] + 2*km);
        }
        face_extrude("A") {
            vent_rect2(sa_region[0], sa_region[2], sa_region[1]);
            hole_rect2(sa_usbc[0], sa_usbc[3], sa_usbc[1], sa_usbc[2]);
            for (h = sa_hdmi) hole_rect2(h[0], h[3], h[1], h[2]);
        }
        face_extrude("B") vent_rect2(sb_region[0], sb_region[2], sb_region[1]);
        face_extrude("bottom") {   // main vent group and the hanging crosses; the 3-slot group and small holes are unused
            bottom_main_vent_rect();
            for (sy = [-1, 1]) circ2(plus_x, sy*plus_y, plus_arm + 2*km);
        }
        for (f = ["A", "B"]) face_extrude(f) {                           // seams: never cover (it would stop the lid coming off)
            rect2(-wy/2, wy/2, hgt - 1 - seam_m, hgt);
            rect2(-wy/2, -wy/2 + t + seam_m, 0, hgt);
        }
    }
    if (kind == "soft" && owner == "lid") {
        face_extrude("top") frame2(wx, wy);
        face_extrude("rear") {
            frame2(wx, hgt, hgt/2);
            for (sx = [-1, 1], z = [screw_z_in, hgt - screw_in - 1]) circ2(sx*(wx/2 - screw_in), z, screw_zone_d);
        }
    }
    if (kind == "soft" && owner == "base") {
        face_extrude("bottom") {
            frame2(wx, wy);
            for (x = screw_x, y = screw_y) if (x != tamper_screw[0] || y != tamper_screw[1]) circ2(x, y, screw_zone_d);
            for (sx = [-1, 1], sy = [-1, 1]) circ2(sx*foot_xy[0], sy*foot_xy[1], foot_d + 3);
        }
        face_extrude("front") frame2(wx, hgt, hgt/2);
        for (f = ["A", "B"]) face_extrude(f) frame2(wy, hgt, hgt/2);
    }
    if (kind == "free" && owner == "lid") {
        face_extrude("top") {
            rect2(-wx/2 + free_edge, wx/2 - free_edge, -wy/2 + free_edge, top_patch[0] - vent_extent(top_patch[1])/2 - km);   // strip by the rear edge
            difference() {                                                                                                     // the side without the Pi: vents may be covered, except the keep-clear row
                rect2(pi_x[1] + 1.5, wx/2 - free_edge, -wy/2 + free_edge, y_seam - seam_m);
                rect2(pi_x[1] + 1.5, wx/2 - free_edge, top_keep_row - vent_pitch/2, top_keep_row + vent_pitch/2);
            }
        }
        face_extrude("rear") {
            rect2(-37, 37, free_edge, port_z - 8 - km);                                                                       // strip under the ports
            difference() {                                                                                                     // right of the USB stacks: wrap the UPS USB-C, with a cut-out
                rect2(usb2[0] + usb2[1]/2 + km, wx/2 - screw_in - screw_zone_d/2, free_edge, hgt - free_edge);
                hole_rect2(usbc_in[0], port_z + 2, usbc_in[1], usbc_in[2], 1);
            }
        }
    }
    if (kind == "free" && owner == "base") {
        face_extrude("B") rect2(-wy/2 + free_edge + 2, wy/2 - free_edge, free_edge, sb_region[2] - vent_extent(sb_region[1])/2 - km);
        face_extrude("A") {
            rect2(-wy/2 + free_edge + 2, wy/2 - free_edge, free_edge, sa_usbc[3] - sa_usbc[2]/2 - km);                       // band under the connectors
            rect2(-wy/2 + free_edge + 2, sa_hdmi[1][0] - sa_hdmi[1][1]/2 - km, free_edge, sa_region[2] - vent_extent(sa_region[1])/2 - km);   // empty block between vents and band, rear end
        }
        face_extrude("front") {
            difference() {                                                                                                     // bottom area up to the vents, over the (blocked) SD slot, with a cut-out for the LED
                rect2(-wx/2 + free_edge, wx/2 - free_edge, free_edge, rr_region[2] - vent_extent(rr_region[1])/2 - km);
                circ2(rr_led[0], rr_led[2], rr_led[1] + 4);
            }
            difference() {                                                                                                     // above the vents, with a cut-out round the button
                rect2(-wx/2 + free_edge, wx/2 - free_edge, rr_region[2] + vent_extent(rr_region[1])/2 + km, hgt - free_edge);
                circ2(rr_btn[0], rr_btn[2], rr_btn[1] + 4);
            }
        }
        face_extrude("bottom") difference() {                      // tamper-evident sticker: everything on the 3-slot side of the main vent, out to the edge bands
            rect2(bot_slot_x[6] + bot_slot_w/2 + km, wx/2 - edge_m, -wy/2 + edge_m, wy/2 - edge_m);
            for (sy = [-1, 1]) circ2(plus_x, sy*plus_y, plus_arm + 2*km);                                       // not the hanging crosses
            for (sx = [-1, 1], sy = [-1, 1]) circ2(sx*foot_xy[0], sy*foot_xy[1], foot_d + 3);                   // not the feet
            for (x = screw_x, y = screw_y) if (x != tamper_screw[0] || y != tamper_screw[1]) circ2(x, y, screw_zone_d);   // not the other screws
        }
    }
}

if (len(part) > 2 && part[0] == "z") {   // part = "z_<kind>_<owner>", e.g. z_hard_lid
    zones(part == "z_hard_lid" || part == "z_hard_base" ? "hard" : (part == "z_soft_lid" || part == "z_soft_base" ? "soft" : "free"),
          (part == "z_hard_lid" || part == "z_soft_lid" || part == "z_free_lid") ? "lid" : "base");
}
else if (part == "base") base();
else if (part == "button") button();
else if (part == "lid") lid();
else { base(); up(explode) lid(); button(); }
