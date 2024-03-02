include <../vendor/RaspberryPi5.scad>;

rpi_width = 85;
rpi_length = 56;
rpi_hangs_south = 0.5;
rpi_hangs_left = 2;
rpi_hangs_right = 3;
rpi_board_thick = 1.5;

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

overall_width = 95;
overall_length = 95;
overall_height = 40; // can't be lower for tonga's with the spikes
outer_radius = 4;
lid_height = 2;
lid_dip = 5;
lid_tolerance = 0; //0.1;
bottom_plate_height = 3;
wall = 2.5;

inner_width = overall_width - wall * 2;
inner_length = overall_length - wall * 2;
inner_height = overall_height - lid_height - bottom_plate_height;

rpi_lift = 5;

rpi_pillar_tip_h = 0.5;
rpi_pillar_tip_d = 2;
rpi_pillar_top_d = 5;
rpi_pillar_bottom_d = 7;

rpi_hole_offset_left = 3.5;
rpi_hole_offset_right = 58 + rpi_hole_offset_left;
rpi_hole_offset_south = 3.5;
rpi_hole_offset_north = 3.5;

fixing_dome_d = 6;
fixing_dome_y = wall + inner_length - 15;

module rounded_rect(width, height, corner_r) {
	minkowski() {
		square([width-(corner_r * 2), height-(corner_r * 2)]);
		translate([corner_r, corner_r]) circle(r=corner_r);
	}
}

module branding() {
	way_down = 0.25;
	
	linear_extrude(lid_height)
	translate([0.75*overall_length, overall_width*way_down, 0]) {
		translate([-0.5, -14, 0])
		mirror([1, 0, 0])
		text("iti", size = 14, font="BetecknaLowerCase:style=Medium");
	
		translate([0, 4, 0])
		mirror([1, 0, 0])
		text("tamanu", size = 16, font="BetecknaLowerCase:style=Medium");
	}
	
	// TODO: slant this vertically to avoid colours being disjoint
	translate([0, overall_length*way_down])
	cube([overall_width, 1.3, lid_height]);
}

// text inlay
// change * to ! to render it
*branding();

// lid
// change * to ! to render it
*difference() {
	union() {
		difference() {
			translate([wall + lid_tolerance, wall + lid_tolerance, lid_height])
			linear_extrude(lid_dip)
			rounded_rect(overall_width - (wall + lid_tolerance)*2, overall_length - (wall + lid_tolerance)*2, outer_radius);
			
			translate([wall*3, wall*3, lid_height+lid_dip]) minkowski() {
				translate([wall, wall]) sphere(lid_dip);
				cube([overall_width - wall*4-lid_dip*2, overall_length - wall*4-lid_dip*2, lid_dip]);
			}
		}

		difference() {
			translate([0, 0, 0])
			linear_extrude(lid_height)
			rounded_rect(overall_width, overall_length, outer_radius);
			
			branding();
		}
	}
}

rpi_bottom_of_board = bottom_plate_height + rpi_lift;
rpi_left_of_board = overall_width - rpi_width - rpi_hangs_right;
rpi_south_of_board = rpi_hangs_south + wall;

// board for reference only
#translate([rpi_left_of_board, rpi_south_of_board, rpi_bottom_of_board])
translate([rpi_width/2, rpi_length/2, 0]) // bring board to 0,0,0
rpi5();

module pillar() {
	union() {
		translate([0, 0, rpi_lift/2])
		cylinder(h = rpi_lift, d1 = rpi_pillar_bottom_d, d2 = rpi_pillar_top_d, center = true);
		
		translate([0, 0, rpi_lift + rpi_pillar_tip_h/2])
		cylinder(h = rpi_pillar_tip_h, d = rpi_pillar_tip_d, center = true);
		
		translate([0, 0, rpi_lift + rpi_pillar_tip_h])
		sphere(d = rpi_pillar_tip_d);
	}
}

// add * to render main case, and replace with ! to make light pipe / rtc holder
union() {
	// rtc battery holder
	rtc_offset_north = overall_length - wall - 20;
	rtc_pillar_d = 1.5;
	rtc_offset_left = 2.6 + rtc_pillar_d/2; // rtc = 2.5 thick
	rtc_height = 15;
	rtc_spacing = 10;
	rtc_pane = 0.4;
	translate([wall + rtc_offset_left, rtc_offset_north, bottom_plate_height]) {
		for (rtc_offset = [0 : rtc_spacing : rtc_spacing])
		translate([0,  rtc_offset, rtc_height / 2]) cylinder(h = rtc_height, d = rtc_pillar_d, center = true);
		translate([-rtc_pane/2, 0, 0]) cube([rtc_pane, rtc_spacing, rtc_height]);
	}
	
	// power led light pipe
	translate([0, rpi_south_of_board + 13.3, bottom_plate_height + rpi_lift + 2.1])
	rotate([0, 90, 0])
	linear_extrude(wall + rpi_south_of_board + 1)
	circle(d = 3);
}

// outer casing
difference() {
	linear_extrude(overall_height - lid_height)
	rounded_rect(overall_width, overall_length, outer_radius);

	difference() {
		translate([wall, wall, bottom_plate_height])
		linear_extrude(overall_height - lid_height - bottom_plate_height + 0.01)
		rounded_rect(overall_width - wall*2, overall_length - wall*2, outer_radius);
		
		// power led light pipe support
		translate([0, rpi_south_of_board + 13.3 - 1.5, bottom_plate_height])
		cube([rpi_left_of_board-0.5, 3, rpi_lift + 2]);
		
		// component cubes fixing domes
		for(fixing_dome_x = [28.5 : 40 : 70])
		translate([fixing_dome_x, fixing_dome_y, bottom_plate_height])
		sphere(d = fixing_dome_d);
		
		// pillars

		// south left
		translate([rpi_left_of_board + rpi_hole_offset_left, rpi_south_of_board + rpi_hole_offset_south, bottom_plate_height]) pillar();

		// north left
		translate([rpi_left_of_board + rpi_hole_offset_left, rpi_south_of_board + rpi_length - rpi_hole_offset_north, bottom_plate_height]) pillar();

		// south right
		translate([rpi_left_of_board + rpi_hole_offset_right, rpi_south_of_board + rpi_hole_offset_south, bottom_plate_height]) pillar();

		// north right
		translate([rpi_left_of_board + rpi_hole_offset_right, rpi_south_of_board + rpi_length - rpi_hole_offset_north, bottom_plate_height]) pillar();
	}

	// cutouts
	cutouts_bottom = rpi_bottom_of_board + rpi_board_thick - 0.4;
	cutouts_radius = 2;
	cutouts_thick = wall*5;

	// south cutouts
	translate([0, wall*2]) {
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

	// left cutouts
	translate([wall*2, 0]) {
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

	// right cutouts
	translate([wall*2, 0]) {
		offset_correction = 0.5;
		
		rj_width = 16.5;
		rj_height = 14.5;
		rj_offset = 10.2 + offset_correction;
		south_of_rj = rpi_south_of_board + (rj_offset - rj_width/2) - 0.5;
		translate([overall_width, south_of_rj, cutouts_bottom])
		rotate([0, -90, 0])
		translate([rj_height, 0, 0])
		rotate([0, 0, 90])
		linear_extrude(cutouts_thick)
		square([rj_width, rj_height]);
		
		usb_a_width = 15;
		usb_a_height = 17;
		usb_a1_offset = 29.1 + offset_correction;
		south_of_usb_a1 = rpi_south_of_board + (usb_a1_offset - usb_a_width/2) - 0.5;
		translate([overall_width, south_of_usb_a1, cutouts_bottom])
		rotate([0, -90, 0])
		translate([usb_a_height, 0, 0])
		rotate([0, 0, 90])
		linear_extrude(cutouts_thick)
		rounded_rect(usb_a_width, usb_a_height, cutouts_radius);
		
		usb_a2_offset = 47 + offset_correction;
		south_of_usb_a2 = rpi_south_of_board + (usb_a2_offset - usb_a_width/2) - 0.5;
		translate([overall_width, south_of_usb_a2, cutouts_bottom])
		rotate([0, -90, 0])
		translate([usb_a_height, 0, 0])
		rotate([0, 0, 90])
		linear_extrude(cutouts_thick)
		rounded_rect(usb_a_width, usb_a_height, cutouts_radius);
	}

	// north cutouts - for air
	translate([0, wall*2]) {
		air_offset_start = overall_width*0.1 - 0.5;
		air_offset_end = overall_width*0.9;
		air_offset_gap = 3;
		
		air_height = 2*overall_height/7;
		air_width = 2;
		air_bottom2 = overall_height/7;
		air_bottom1 = 4*overall_height/7;
		
		for (air_offset1 = [air_offset_start : air_width + air_offset_gap : air_offset_end ])
		translate([air_offset1, overall_length, air_bottom1])
		rotate([90, 0, 0])
		linear_extrude(cutouts_thick)
		rounded_rect(air_width, air_height, 0.5);

		for (air_offset2 = [air_offset_start - (air_offset_gap + air_width)/2 : air_width + air_offset_gap : air_offset_end + (air_offset_gap + air_width)/2 ])
		translate([air_offset2, overall_length, air_bottom2])
		rotate([90, 0, 0])
		linear_extrude(cutouts_thick)
		rounded_rect(air_width, air_height, 0.5);
	}
}