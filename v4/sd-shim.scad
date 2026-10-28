// microSD slot blocker for OpenSCAD + BOSL2: a card-shaped shim that sits
// in the Pi's slot, with a tab that the case traps so it can't be removed.
// Card outline follows the SD Association microSD spec (nominal, mm).
// Modelled label side up with the tab hanging below the card.
// For printing, flip it so the flat label side is on the bed.
//
// Generated with help from Claude

include <BOSL2/std.scad>

/* [Card] */
card_w   = 11.0;   // full card width
narrow_w = 9.7;    // width at the insertion end
step_y0  = 6.4;    // where the narrow section ends (from insertion edge)
step_y1  = 7.6;    // where the side reaches full width
front_r  = 0.3;    // corner radius at insertion end
t_thin   = 0.7;    // card thickness
body_len = 12.0;   // card length, up to the tab

/* [Side notch] */
notch    = true;
notch_y  = 8.4;    // start of notch (from insertion edge)
notch_l  = 0.8;    // notch length
notch_d  = 0.4;    // notch depth

/* [Tab] */
tab_w     = 20.0;  // tab width, centered on the card
tab_len   = 2.0;   // tab thickness along the card
tab_h     = 8.0;   // tab height
tab_r_out = 0.8;   // rounding on the rear corners
tab_r_in  = 0.5;   // rounding on the front corners
side_fillet = 0.5; // fillet where the card's sides meet the tab
under_fillet = 1.0; // fillet between the card's underside and the tab,
                   // stiffens the joint against prying
                   // (keep it shorter than the part outside the socket)

/* [Printing] */
fit = 0;           // shrinks the card outline on every side, in mm, if
                   // your printer prints outer dimensions oversize

$fa = 2;
$fs = 0.15;

function card_region() =
    let(
        outline = round_corners(
            [[0, 0], [narrow_w, 0], [narrow_w, step_y0], [card_w, step_y1],
             [card_w, body_len + 0.01], [0, body_len + 0.01]],
            radius=[front_r, front_r, 0, 0, 0, 0], method="circle"),
        cut = move([card_w, notch_y + notch_l/2], rect([notch_d*2, notch_l])),
        reg = notch ? difference(outline, cut) : [outline]
    )
    fit > 0 ? offset(reg, delta=-fit, closed=true) : reg;

function tab_path() =
    move([card_w/2, body_len + tab_len/2],
         rect([tab_w, tab_len],
              rounding=[tab_r_out, tab_r_out, tab_r_in, tab_r_in]));

function side_fillets() =
    let(f = side_fillet, e = 0.01, y0 = body_len - f)
    union(
        difference(move([-f, y0], square([f + e, f + e])),
                   move([-f, y0], circle(r=f))),
        difference(move([card_w - e, y0], square([f + e, f + e])),
                   move([card_w + f, y0], circle(r=f))));

module under_fillet() {
    f = under_fillet;
    translate([0, body_len + 0.01, 0.01])
        rotate([90, 0, 90])
            linear_extrude(card_w)
                difference() {
                    translate([-f, -f]) square(f);
                    translate([-f, -f]) circle(r=f);
                }
}

module microsd() {
    card = side_fillet > 0 ? union(card_region(), side_fillets())
                           : card_region();
    linear_sweep(card, height=t_thin);
    // Tab is flush with the card's top face and hangs down below it
    down(tab_h - t_thin) linear_sweep(tab_path(), height=tab_h);
    if (under_fillet > 0) under_fillet();
}

microsd();