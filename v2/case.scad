include <../vendor/RaspberryPi5.scad>;

githash = "githash";
serial = "0001";

// width  = along x axis
// length = along y axis
// height = along z axis

rpi_width = 85;
rpi_length = 56;
rpi_height = 17.6; // from bottom of board to top lip of USB A ports

rpi_hangs_south = 0.5;
rpi_hangs_left = 2;
rpi_hangs_right = 3;

pcb_thick = 1.6;

$fn = 36;

radius = 6;
outer = 68.70;
shelf = 1.2;
ridge = 1;

length = 68;
extended = 30;

curvature = 300;

gpio_length = 55;
gpio_width = 6;
gpio_x = 10;
gpio_y = 12;

inner_width = 90;
inner_length = 107.4;

outer_radius = 4;
lid_height = 2;
lid_dip = 5;
lid_tolerance = 0; // may need to be negative for materials with more flex
wall = 2.5;

overall_width = inner_width + wall + lid_height;
overall_length = inner_length + wall * 2;

// rpi_lift = from "ground" to bottom of rpi board
ground_to_ups = 2.0; // pads glued to bottom of ups board
ups_standoffs = 4.4;
extra_lift = 0.15; // knob to adjust for errors in measurement
rpi_lift = ground_to_ups + pcb_thick + ups_standoffs + extra_lift;

x1001_nominal_height = 7.7; // from bottom of x1001 to top of power port
x1001_to_ssd_top = 6.85;
ssd_heatsink_height = 0; // no heatsink in v2.0
x1001_height = max(x1001_nominal_height, x1001_to_ssd_top + ssd_heatsink_height);

x1001_standoffs = 16.75; // from top of rpi board to bottom of x1001 board

// the board and m2 stick out further than the rpi's over the usb/rj
// so we cut out a two-layer slot in the inner left wall
x1001_length = 24;
x1001_slots_extra_y = 1;   // extra length either side
x1001_slots_extra_z = 0.15; // extra height either side
x1001_pcb_slot_depth = wall - 1;
x1001_edge_to_m2 = 0.9;
x1001_m2_slot_depth = x1001_pcb_slot_depth - x1001_edge_to_m2;

// all assembled components, from "ground" to topmost point
assembly_height = rpi_lift + max(rpi_height, pcb_thick + x1001_standoffs + x1001_height);

breathing_room = 0.5; // height to leave above assembly
inner_height = assembly_height + breathing_room;

overall_height = inner_height + wall * 2;
echo(assembly_height=assembly_height, inner_height=inner_height, overall_height=overall_height);

rpi_hole_offset_left = 3.5;
rpi_hole_offset_right = 58 + rpi_hole_offset_left;
rpi_hole_offset_south = 3.5;
rpi_hole_offset_north = 3.5;

module rounded_rect(width, height, corner_r) {
	minkowski() {
		square([width-(corner_r * 2), height-(corner_r * 2)]);
		translate([corner_r, corner_r]) circle(r=corner_r);
	}
}

rpi_bottom_of_board = wall + rpi_lift;
rpi_left_of_board = overall_width - rpi_width - rpi_hangs_right;
rpi_south_of_board = rpi_hangs_south + wall;

module right_branding() {
	linear_extrude(0.2)
	translate([overall_length - wall*2, 10.5])
	scale(0.5) translate([0, 32]) {
		font = "FiraCode:style=Medium";
		text("TAMANU ITI", size = 5, font=font, halign = "right");
		translate([0, -6]) text("2024 • BES", size = 4, font=font, halign = "right");
		translate([0, -15]) text("RATING: 5.1V==5A", size = 4, font=font, halign = "right");
		translate([0, -20]) text("BATTERY: Li-ion 3.6V 6360mAh", size = 4, font=font, halign = "right");
		translate([0, -28]) text("Made in New Zealand", size = 4, font=font, halign = "right");
		translate([0, -32]) text(str("rev: ", githash, " • ser: ", serial, " • www: bes.au"), size = 3, font=font, halign = "right");
	}
}

module outer_casing() {
	translate([0, 0, overall_height]) rotate([0, 90, 0]) difference() {
		linear_extrude(overall_width)
		rounded_rect(overall_height, overall_length, outer_radius);

		translate([wall, wall, -0.01]) linear_extrude(overall_width - wall + 0.01)
		square([inner_height, inner_length]);
	}
}

cutouts_bottom = rpi_bottom_of_board + pcb_thick - 0.4;
cutouts_radius = 2;
cutouts_thick = wall*5;

module north_cutouts() {
	air_offset_start = overall_width*0.1 - 0.5;
	air_offset_end = overall_width*0.9;
	air_offset_gap = 3;
	
	air_height = 2*overall_height/7;
	air_width = 2;
	air_bottom2 = overall_height/7;
	air_bottom1 = 4*overall_height/7;
	
	*for (air_offset1 = [air_offset_start : air_width + air_offset_gap : air_offset_end ])
	translate([air_offset1, 0, air_bottom1])
	rotate([90, 0, 0])
	linear_extrude(cutouts_thick)
	rounded_rect(air_width, air_height, 0.5);

	*for (air_offset2 = [air_offset_start - (air_offset_gap + air_width)/2 : air_width + air_offset_gap : air_offset_end + (air_offset_gap + air_width)/2 ])
	translate([air_offset2, 0, air_bottom2])
	rotate([90, 0, 0])
	linear_extrude(cutouts_thick)
	rounded_rect(air_width, air_height, 0.5);
}

module south_cutouts() {
	usb_c_width = 10;
	usb_c_height = 4.3;
	usb_c_offset = 11.2;
	left_of_usb_c = rpi_left_of_board + (usb_c_offset - usb_c_width/2);
	translate([left_of_usb_c, 0, cutouts_bottom])
	rotate([90, 0, 0])
	linear_extrude(cutouts_thick)
	rounded_rect(usb_c_width, usb_c_height, cutouts_radius);

	hdmi_width = 8.2;
	hdmi_height = 4.8;
	hdmi1_offset = 25.8;
	left_of_hdmi1 = rpi_left_of_board + (hdmi1_offset - hdmi_width/2);
	translate([left_of_hdmi1, 0, cutouts_bottom])
	rotate([90, 0, 0])
	linear_extrude(cutouts_thick)
	rounded_rect(hdmi_width, hdmi_height, cutouts_radius);

	hdmi2_offset = 39.2;
	left_of_hdmi2 = rpi_left_of_board + (hdmi2_offset - hdmi_width/2);
	translate([left_of_hdmi2, 0, cutouts_bottom])
	rotate([90, 0, 0])
	linear_extrude(cutouts_thick)
	rounded_rect(hdmi_width, hdmi_height, cutouts_radius);
}

module left_cutouts() {
	led_d = 3;
	led_v_offset = 1;
	led_h_offset = 13.3;
	south_of_led = rpi_south_of_board + led_h_offset;
	translate([cutouts_thick/6, south_of_led, cutouts_bottom + led_v_offset])
	rotate([0, -90, 0])
	linear_extrude(cutouts_thick)
	circle(d = led_d);
	
	power_v_offset = 2.15;
	power_h_offset = 18.4;
	south_of_power = rpi_south_of_board + power_h_offset;
	translate([0, south_of_power, cutouts_bottom + power_v_offset])
	rotate([0, -90, 0])
	linear_extrude(cutouts_thick)
	circle(0.5);
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
	#translate([
		0 - wall*3 - 0.01,
		south_of_x1001 - x1001_slots_extra_y,
		wall + rpi_lift + pcb_thick + x1001_standoffs - x1001_slots_extra_z
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
	
	translate([-wall*2-0.1, 0, 0])
	rotate([90, 0, 90])
	right_branding();
}

*translate([0, 0, 0.2]) rotate([0, 180, -90]) right_branding();

translate([0, 0, overall_width]) rotate([0, 90, 0])
{
	// main body
	difference() {
		outer_casing();

		translate([0, wall*2]) south_cutouts();
		translate([overall_width + wall*2, 0]) right_cutouts();
		translate([0, overall_length + wall*2]) north_cutouts();
		
		// for reference only
		#translate([wall*2, 0]) left_cutouts();
	}

	// for reference only
	#translate([rpi_left_of_board, rpi_south_of_board, rpi_bottom_of_board])
	translate([rpi_width/2, rpi_length/2, 0]) // bring board to 0,0,0
	rpi5();
}