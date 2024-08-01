include <BOSL2/std.scad>;
include <../vendor/RaspberryPi5.scad>;

// width  = along x axis
// length = along y axis
// height = along z axis

layer = 0.2;

rpi_width = 85;
rpi_length = 56;
rpi_height = 17.6; // from bottom of board to top lip of USB A ports

rpi_hangs_south = 1.5;
rpi_hangs_left = 2;
rpi_hangs_right = 3;

pcb_thick = 1.6;

$fn = 36;

outer = 68.70;
shelf = 1.2;
ridge = 1;

gpio_length = 55;
gpio_width = 6;
gpio_x = 10;
gpio_y = 12;

inner_width = 85.5;
inner_length = 107.4 + rpi_hangs_south;

outer_radius = 2;
lid_dip = 5;
lid_tolerance = 0; // may need to be negative for materials with more flex
wall = 2.5;

overall_width = inner_width + wall * 2;
overall_length = inner_length + wall * 2;

// the board and m2 stick out further than the rpi's over the usb/rj
// so we cut out a two-layer slot in the inner left wall
x1001_length = 24;
x1001_slots_extra_y = 1;   // extra length either side
x1001_slots_extra_z = 0.15; // extra height either side
x1001_pcb_slot_depth = wall - 1;
x1001_edge_to_m2 = 0.9;
x1001_m2_slot_depth = x1001_pcb_slot_depth - x1001_edge_to_m2;

// rpi_lift = from "ground" to bottom of rpi board
ground_to_ups = 2.0; // pads glued to bottom of ups board
ups_standoffs = 4.4;
extra_lift = 0.15; // knob to adjust for errors in measurement
rpi_lift = ground_to_ups + pcb_thick + ups_standoffs + extra_lift;

x1001_nominal_height = 7.7; // from bottom of x1001 to top of power port
x1001_to_ssd_top = 6.85;
ssd_heatsink_height = 4.6;
x1001_height = max(x1001_nominal_height, x1001_to_ssd_top + ssd_heatsink_height);

x1001_standoffs = 16.75; // from top of rpi board to bottom of x1001 board

// all assembled components, from "ground" to topmost point
assembly_height = rpi_lift + max(rpi_height, pcb_thick + x1001_standoffs + x1001_height);

breathing_room = 0.8; // height to leave above assembly
inner_height = assembly_height + breathing_room;

overall_height = inner_height + wall * 2;
echo(assembly_height=assembly_height, inner_height=inner_height, overall_height=overall_height);

// 44mm == 1U
assert(overall_height <= 44);
// current height is 43.75, leaving space for a 0.2mm bit of steel for a bracket

module rounded_rect(width, height, corner_r) {
	minkowski() {
		square([width-(corner_r * 2), height-(corner_r * 2)]);
		translate([corner_r, corner_r]) circle(r=corner_r);
	}
}

rpi_bottom_of_board = wall + rpi_lift;
rpi_left_of_board = overall_width - rpi_width - rpi_hangs_right;
rpi_south_of_board = wall + rpi_hangs_south;

branding_cut = layer * 2;
module right_branding() {
	linear_extrude(branding_cut)
	translate([overall_length - wall*1.2, wall])
	translate([0, 34]) {
		font = "FiraCode:style=Bold";
		text("TAMANU ITI", size = 4.5, font=font, halign = "right");
		translate([0, -4.5]) text("2024 ♥ BES", size = 3.5, font=font, halign = "right");
		translate([0, -10.5]) text("RATING 5▪1V=5A", size = 3, font=font, halign = "right");
		translate([0, -14.5]) text("BATTERY Li-ion", size = 3, font=font, halign = "right");
		translate([0, -18.5]) text("3▪6V 6360mAh", size = 3, font=font, halign = "right");
		translate([0, -26]) text("w w w.bes.au", size = 4, font=font, halign = "right");
		translate([0, -31]) text("made in    ", size = 2.6, font=font, halign = "right");
		translate([0, -34]) text("new zealand", size = 2.6, font=font, halign = "right");
	}
}

module outer_casing() {
	move([(inner_width + wall)/2, overall_length/2, overall_height/2])
	difference() {
		cuboid(
			[inner_width + wall, overall_length, overall_height],
			rounding=outer_radius,
			except=[RIGHT]
		);
		
		right(wall/2)
		cuboid(
			[inner_width + 0.01, inner_length, inner_height],
			rounding=0.5,
			except=[RIGHT]
		);
	}
}

rpi_hole_offset_left = 3.5;
rpi_hole_offset_right = 58 + rpi_hole_offset_left;
rpi_hole_offset_south = 3.5;
rpi_hole_offset_north = rpi_length - 3.5;
rpi_hole_d = 2.75;

top_cutout_depth = layer;

module top_cutouts() {
	translate([overall_width*.75, overall_length*.4])
	rotate([0, 0, -90])
	linear_extrude(top_cutout_depth)
	import("tamanu_logo.svg", center = true);

	air_offset_gap = 3;
	air_height = 2 * overall_height / 7;
	air_width = 2;
	air_spacing = air_width + air_offset_gap;
	air_n = overall_width / air_spacing - 3;

	back(22)
	right(air_spacing * (air_n/2 + 1))
	xcopies(air_spacing, air_n)
	cuboid([air_width, air_height, cutouts_thick], rounding=0.5);
}

module bottom_cutouts() {
	screw_head_d = 7;
	screw_head_h = 0.8;

	translate([
		rpi_left_of_board + rpi_hole_offset_right,
		rpi_south_of_board + rpi_hole_offset_north,
		-0.01
	]) {
		cylinder(d = rpi_hole_d, h = wall + 0.02);
		cylinder(d = screw_head_d, h = screw_head_h);
	}

	pad_d = 11;
	pad_h = 0.2;
	pad_inset = 12;

	for (pad_offset = [
		[pad_inset, pad_inset],
		[overall_width - pad_inset, pad_inset],
		[overall_width - pad_inset, overall_length - pad_inset],
		[pad_inset, overall_length - pad_inset],
	])
		translate([pad_offset[0], pad_offset[1], -0.01])
		cylinder(d = pad_d, h = pad_h + 0.01);
}

cutouts_bottom = rpi_bottom_of_board + pcb_thick - 0.4;
cutouts_radius = 2;
cutouts_thick = wall*5;

module south_cutouts() { translate([0, -wall, 0]) {
	usb_c_width = 10;
	usb_c_height = 4.8;

	dip_out = 1.2;
	dip_in = 0.6;
	usb_c_dip_width = 13;
	usb_c_dip_height = 8;
	usb_c_dip_r = 3;

	usb_c_offset = 11.2;
	left_of_usb_c = rpi_left_of_board + (usb_c_offset - usb_c_width/2);
	translate([left_of_usb_c, 0, cutouts_bottom])
	rotate([90, 0, 0]) {
		linear_extrude(cutouts_thick)
		rounded_rect(usb_c_width, usb_c_height, cutouts_radius);

		translate([
			(usb_c_width - usb_c_dip_width)/2,
			(usb_c_height - usb_c_dip_height)/2,
			wall - dip_out
		])
		linear_extrude(cutouts_thick)
		rounded_rect(usb_c_dip_width, usb_c_dip_height, usb_c_dip_r);

		translate([
			(usb_c_width - usb_c_dip_width)/2,
			(usb_c_height - usb_c_dip_height)/2,
			0
		])
		linear_extrude(dip_in)
		rounded_rect(usb_c_dip_width, usb_c_dip_height, usb_c_dip_r);
	}

	hdmi_width = 8.2;
	hdmi_height = 4.8;
	hdmi_dip_width = 12;
	hdmi_dip_height = 8;
	hdmi_dip_r = 3;
	
	for (hdmi_offset = [25.8, 39.2]) {
		left_of_hdmi = rpi_left_of_board + (hdmi_offset - hdmi_width/2);
		translate([left_of_hdmi, 0, cutouts_bottom])
		rotate([90, 0, 0]) {
			linear_extrude(cutouts_thick)
			rounded_rect(hdmi_width, hdmi_height, cutouts_radius);
			
			translate([
				(hdmi_width - hdmi_dip_width)/2,
				(hdmi_height - hdmi_dip_height)/2,
				wall - dip_out
			])
			linear_extrude(cutouts_thick)
			rounded_rect(hdmi_dip_width, hdmi_dip_height, hdmi_dip_r);
			
			translate([
				(hdmi_width - hdmi_dip_width)/2,
				(hdmi_height - hdmi_dip_height)/2,
				0
			])
			linear_extrude(dip_in)
			rounded_rect(hdmi_dip_width, hdmi_dip_height, hdmi_dip_r);
		}
	}

	usb_power_offset = 52;
	usb_power_bottom = ground_to_ups + pcb_thick - 1;
	left_of_usb_power = rpi_left_of_board + (usb_power_offset - usb_c_width/2);
	translate([left_of_usb_power, 0, usb_power_bottom + usb_c_height/2])
	rotate([90, 0, 0]) {
		linear_extrude(cutouts_thick)
		rounded_rect(usb_c_width, usb_c_height, cutouts_radius);

		translate([
			(usb_c_width - usb_c_dip_width)/2,
			(usb_c_height - usb_c_dip_height)/2,
			wall - dip_out
		])
		linear_extrude(cutouts_thick)
		rounded_rect(usb_c_dip_width, usb_c_dip_height, usb_c_dip_r);
		
		translate([
			(usb_c_width - usb_c_dip_width)/2,
			(usb_c_height - usb_c_dip_height)/2,
			0
		])
		linear_extrude(dip_in)
		rounded_rect(usb_c_dip_width, usb_c_dip_height, usb_c_dip_r);

		label_h = 0.6;
		label_x_offset = 0;
		label_z_offset = 5;
		translate([
			usb_c_width/2 + label_x_offset,
			usb_c_height + label_z_offset,
			wall*2 - label_h
		])	linear_extrude(label_h + 0.01)
			text("⚡", size = 7, font = "Symbola", halign = "center");
	}

	air_offset_start = overall_width*0.1 + wall;
	air_offset_end = overall_width*0.9 + wall;
	air_offset_gap = 3;
	
	air_height = 2*overall_height/7;
	air_width = 2;
	air_bottom2 = overall_height/7;
	air_bottom1 = 4*overall_height/7;

	for (air_offset1 = [air_offset_start : air_width + air_offset_gap : air_offset_end])
	translate([air_offset1, 0, air_bottom1])
	rotate([90, 0, 0])
	linear_extrude(cutouts_thick)
	rounded_rect(air_width, air_height, 0.5);
} }

module left_leds() {
	led_d = 3;

	rpi_led_v_offset = 1;
	rpi_led_h_offset = 13.3;
	south_of_rpi_led = rpi_south_of_board + rpi_led_h_offset;
	translate([0, south_of_rpi_led, cutouts_bottom + rpi_led_v_offset])
	rotate([0, -90, 0])
	cylinder(h = wall, d = led_d);

	x1201_led_v_offset = -pcb_thick - ups_standoffs + 1;
	x1201_led_h_offset = 58.4;
	south_of_x1201_led = rpi_south_of_board + x1201_led_h_offset;
	translate([0, south_of_x1201_led, cutouts_bottom + x1201_led_v_offset])
	rotate([0, -90, 0])
	cylinder(h = wall, d = led_d);
}

module left_cutouts() {
	power_v_offset = 2;
	power_h_offset = 18.4;
	south_of_power = rpi_south_of_board + power_h_offset;
	translate([0, south_of_power, cutouts_bottom + power_v_offset])
	rotate([0, -90, 0]) {
		cylinder(h = wall, d = 1.5);
		cylinder(h = 0.6, d = 2.5);
	}

	screen_x = 10;
	screen_y = 40;
	screen_at_y = rpi_south_of_board + rpi_length - 2;
	screen_z = 32.5;
	screen_at_z = overall_height - wall - screen_z;
	screen_corners = 5;
	back(screen_at_y) up(screen_at_z) left(5)
	cuboid(
		[screen_x, screen_y, screen_z],
		rounding=screen_corners,
		except=[LEFT,RIGHT],
		anchor=[-1, -1, -1]
	);

	x1201_button_v_offset = -1.3;
	x1201_button_h_offset = 96;
	x1201_button_bottom_d = 5.4;
	x1201_button_top_d = 4.2;
	south_of_x1201_button = rpi_south_of_board + x1201_button_h_offset;
	translate([0, south_of_x1201_button, cutouts_bottom + x1201_button_v_offset])
	rotate([0, -90, 0])
	cylinder(h = wall, d1 = x1201_button_bottom_d, d2 = x1201_button_top_d);

	sd_v_offset = -3;
	sd_height = 2;
	sd_h_offset = 25;
	sd_width = 15;
	sd_hang = -2;
	translate([sd_hang, sd_h_offset, cutouts_bottom + sd_v_offset])
	cube([abs(sd_hang), sd_width, sd_height]);
}

module right_cutouts() {
	offset_correction = 0.5;
	
	rj_width = 16.5;
	rj_height = 14.5;
	rj_offset = 10.2 + offset_correction;
	south_of_rj = rpi_south_of_board + (rj_offset - rj_width/2) - 0.5;
	translate([0, south_of_rj, cutouts_bottom])
	rotate([0, -90, 0])
	translate([rj_height, 0, 0])
	rotate([0, 0, 90])
	linear_extrude(cutouts_thick)
	square([rj_width, rj_height]);
	
	usb_a_width = 15;
	usb_a_height = 17;
	usb_a1_offset = 29.1 + offset_correction;
	south_of_usb_a1 = rpi_south_of_board + (usb_a1_offset - usb_a_width/2) - 0.5;
	translate([0, south_of_usb_a1, cutouts_bottom])
	rotate([0, -90, 0])
	translate([usb_a_height, 0, 0])
	rotate([0, 0, 90])
	linear_extrude(cutouts_thick)
	rounded_rect(usb_a_width, usb_a_height, cutouts_radius);

	usb_a2_offset = 47 + offset_correction;
	south_of_usb_a2 = rpi_south_of_board + (usb_a2_offset - usb_a_width/2) - 0.5;
	translate([0, south_of_usb_a2, cutouts_bottom])
	rotate([0, -90, 0])
	translate([usb_a_height, 0, 0])
	rotate([0, 0, 90])
	linear_extrude(cutouts_thick)
	rounded_rect(usb_a_width, usb_a_height, cutouts_radius);

	south_of_x1001 = rpi_south_of_board + 7;
	translate([
		-(wall + 0.01),
		south_of_x1001 - x1001_slots_extra_y,
		wall + rpi_lift + pcb_thick + x1001_standoffs - x1001_slots_extra_z - 0.01
	]) {
		cube([
			x1001_pcb_slot_depth + 0.01,
			x1001_length + x1001_slots_extra_y * 2,
			pcb_thick + x1001_slots_extra_z * 2
		]);
		cube([
			x1001_m2_slot_depth + 0.01,
			x1001_length + x1001_slots_extra_y * 2,
			x1001_to_ssd_top + x1001_slots_extra_z * 2
		]);
	}
}


// light-pipes
color("silver")
translate([0, 0, overall_width - wall]) rotate([0, 90, 0]) left_leds();

// main-body
translate([0, 0, overall_width]) rotate([0, 90, 0]) {
	// main body
	color("white")
	difference() {
		outer_casing();

		bottom_cutouts();
		translate([0, 0, overall_height - top_cutout_depth + 0.01]) top_cutouts();
		translate([0, wall*2]) ycopies(0.01) south_cutouts();
		//translate([0, overall_length + wall*2]) north_cutouts();
		translate([wall, 0]) xcopies(0.01) left_cutouts();
		translate([wall, 0]) xcopies(0.01) left_leds();

		// for reference only
		*translate([overall_width + wall*2, 0]) right_cutouts();
	}

	// for reference only
	#translate([rpi_left_of_board, rpi_south_of_board, rpi_bottom_of_board])
	translate([rpi_width/2, rpi_length/2, 0]) // bring board to 0,0,0
	rpi5();
}

// lid
union() {
	difference() {
		linear_extrude(wall)
		rounded_rect(overall_height, overall_length, outer_radius);

		zcopies(0.01)
		rotate([0, 90, 0]) {
			right_cutouts();

			translate([-branding_cut, 0, 0])
			rotate([90, 0, 90])
			right_branding();
		}
	}

	// TODO: parametrise these from ssd, pcb, etc dimensions
	south_lip = 24;
	north_lip = 30;
	top_right_lip = 8;
	top_left_lip = 55;
	bottom_lip = 65;
	bottom_lip_h = 1.5;

	translate([0, 0, wall]) {
		anch=[-1,-1,-1];
		translate([overall_height - south_lip - wall, wall]) cuboid([south_lip, wall, wall], anchor=anch, rounding=0.5, except=[BOTTOM]);
		translate([overall_height - north_lip - wall, overall_length - wall*2]) cuboid([north_lip, wall, wall], anchor=anch, rounding=0.5, except=[BOTTOM]);
		translate([overall_height - wall*2, overall_length - top_right_lip - wall]) cuboid([wall, top_right_lip, wall], anchor=anch, rounding=0.5, except=[BOTTOM]);
		translate([overall_height - wall*2, wall]) cuboid([wall, top_left_lip, wall], anchor=anch, rounding=0.5, except=[BOTTOM]);
		translate([wall, wall]) cuboid([bottom_lip_h, bottom_lip, wall], anchor=anch, rounding=0.5, except=[BOTTOM]);
	}

	// tie
	difference() {
		tie_sides = 5;
		translate([
			wall,
			rpi_south_of_board + rpi_hole_offset_north - tie_sides - rpi_hole_d/2,
			wall,
		]) cube([
			bottom_lip_h,
			rpi_hole_d + tie_sides*2,
			overall_width - rpi_hole_offset_right + rpi_hole_d/2 + tie_sides - wall*2,
		]);

		rotate([0, -90]) translate([
			overall_width - rpi_hole_offset_right - wall,
			rpi_south_of_board + rpi_hole_offset_north,
			-wall*2
		]) cylinder(d = rpi_hole_d, h = wall);
	}
}

// right-text-inlay
up(branding_cut) rotate([0, 180, -90]) color("blue") right_branding();

// transparent text shield
color("#ffffff44")
down(0.4) difference() {
	linear_extrude(0.4)
	rounded_rect(overall_height, overall_length, outer_radius);

	zcopies(0.01)
	rotate([0, 90, 0]) {
		right_cutouts();
	}
}