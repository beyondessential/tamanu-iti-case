include <../vendor/RaspberryPi5.scad>;

rpi_width = 85;
rpi_length = 56;
rpi_hangs_south = 1.5;
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
overall_height = 50;
outer_radius = 4;
lid_height = 2;
lid_dip = 2;
lid_tolerance = -0.1;
bottom_plate_height = 3;
wall = 1;

rpi_lift = 15;

rpi_hole_d = 2.7;
rpi_pillar_dip = 1.5;
rpi_pillar_bore_top_d = 4;
rpi_pillar_top_d = 4;
rpi_pillar_bottom_d = 8;
rpi_pillar_wall = 1;
rpi_hole_offset_left = 3.5;
rpi_hole_offset_right = 58 + rpi_hole_offset_left;
rpi_hole_offset_south = 3.5;
rpi_hole_offset_north = 3.5;

// TODO: add middle horiz bar to air vent for stability
// TODO: tighten usb a and rj port holes
// TODO: add perpendicular support columns between usb a1 a2 and rj port
// TODO: add crosshair support columns to pillars
// TODO: adjust lid tolerance for tight fit
// TODO: adjust lift for bottom SSD board
// TODO: raise or change power button hole to align

module rounded_rect(width, height, corner_r) {
	minkowski() {
		square([width-(corner_r * 2), height-(corner_r * 2)]);
		translate([corner_r, corner_r]) circle(r=corner_r);
	}
}

module branding() {
	way_down = 0.2;
	
	linear_extrude(lid_height)
	translate([0.75*overall_length, overall_width*way_down, 0]) {
		translate([-0.5, -11, 0])
		mirror([1, 0, 0])
		text("iti", size = 10, font="BetecknaLowerCase:style=Medium");
	
		translate([0, 4, 0])
		mirror([1, 0, 0])
		text("tamanu", size = 12, font="BetecknaLowerCase:style=Medium");
	}
	
	translate([0, overall_length*way_down])
	cube([overall_width, 1.2, lid_height]);
}

// text inlay
// change * to ! to render it
*branding();


rpi_left_of_board = overall_width - rpi_width - rpi_hangs_right;

// board for reference only
#translate([rpi_left_of_board, rpi_hangs_south, rpi_lift])
translate([rpi_width/2, rpi_length/2, 0]) // bring board to 0,0,0
rpi5();

// holes

module pillar_bore() {
	translate([0, 0, -rpi_pillar_wall])
	cylinder(h = rpi_lift - rpi_pillar_dip + 0.01, r1 = rpi_pillar_bottom_d/2-rpi_pillar_wall, r2 = max(rpi_pillar_top_d/2-rpi_pillar_wall, rpi_pillar_bore_top_d/2), center = true);
}

module pillar_hole() {
	cylinder(h = rpi_lift + rpi_board_thick, r = rpi_hole_d/2, center = true);
	pillar_bore();
}

module pillar() {
	difference() {
		union() {
			cylinder(h = rpi_lift - rpi_pillar_dip + 0.01, r1 = rpi_pillar_bottom_d/2, r2 = max(rpi_pillar_top_d, rpi_pillar_bore_top_d+rpi_pillar_wall*2)/2, center = true);
			translate([0, 0, rpi_lift/2])
			cylinder(h = rpi_pillar_dip, r = max(rpi_pillar_top_d, rpi_pillar_bore_top_d+rpi_pillar_wall*2)/2, center = true);
		}

		pillar_hole();
	}
}

// pillars

// south left
translate([rpi_left_of_board + rpi_hole_offset_left, rpi_hangs_south + rpi_hole_offset_south, (rpi_lift - rpi_pillar_dip)/2]) pillar();

// north left
translate([rpi_left_of_board + rpi_hole_offset_left, rpi_hangs_south + rpi_length - rpi_hole_offset_north, (rpi_lift - rpi_pillar_dip)/2]) pillar();

// south right
translate([rpi_left_of_board + rpi_hole_offset_right, rpi_hangs_south + rpi_hole_offset_south, (rpi_lift - rpi_pillar_dip)/2]) pillar();

// north right
translate([rpi_left_of_board + rpi_hole_offset_right, rpi_hangs_south + rpi_length - rpi_hole_offset_north, (rpi_lift - rpi_pillar_dip)/2]) pillar();

// outer casing
difference() {
	linear_extrude(overall_height - lid_height)
	rounded_rect(overall_width, overall_length, outer_radius);

	translate([wall, wall, bottom_plate_height])
	linear_extrude(overall_height - lid_height - bottom_plate_height + 0.01)
	rounded_rect(overall_width - wall*2, overall_length - wall*2, outer_radius);

	// cutouts
	cutouts_bottom = rpi_lift + rpi_board_thick - 0.4;
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
		power_width = 8.3;
		power_height = 3.0;
		power_offset = 18.4;
		power_led_offset = 13.3;
		south_of_power = wall + power_led_offset;
		translate([0, south_of_power, cutouts_bottom])
		rotate([0, -90, 0])
		translate([power_height, 0, 0])
		rotate([0, 0, 90])
		linear_extrude(cutouts_thick)
		rounded_rect(power_width, power_height, 1);
	}

	// right cutouts
	translate([wall*2, 0]) {
		offset_correction = 0.5;
		
		rj_width = 18;
		rj_height = 15;
		rj_offset = 10.2 + offset_correction;
		south_of_rj = wall + (rj_offset - rj_width/2);
		translate([overall_length, south_of_rj, cutouts_bottom])
		rotate([0, -90, 0])
		translate([rj_height, 0, 0])
		rotate([0, 0, 90])
		linear_extrude(cutouts_thick)
		rounded_rect(rj_width, rj_height, 1);
		
		usb_a_width = 16;
		usb_a_height = 18;
		usb_a1_offset = 29.1 + offset_correction;
		south_of_usb_a1 = wall + (usb_a1_offset - usb_a_width/2);
		translate([overall_length, south_of_usb_a1, cutouts_bottom])
		rotate([0, -90, 0])
		translate([usb_a_height, 0, 0])
		rotate([0, 0, 90])
		linear_extrude(cutouts_thick)
		rounded_rect(usb_a_width, usb_a_height, 1);
		
		usb_a2_offset = 47 + offset_correction;
		south_of_usb_a2 = wall + (usb_a2_offset - usb_a_width/2);
		translate([overall_length, south_of_usb_a2, cutouts_bottom])
		rotate([0, -90, 0])
		translate([usb_a_height, 0, 0])
		rotate([0, 0, 90])
		linear_extrude(cutouts_thick)
		rounded_rect(usb_a_width, usb_a_height, 1);
	}

	// north cutouts - for air
	translate([0, wall*2]) {
		air_offset_start = overall_width*0.1 - 0.5;
		air_offset_end = overall_width*0.9;
		air_offset_gap = 3;
		
		air_height = 3*overall_height/4;
		air_width = 2;
		air_bottom = overall_height/8;
		
		for (air_offset = [air_offset_start : air_width + air_offset_gap : air_offset_end ])
		translate([air_offset, overall_width, air_bottom])
		rotate([90, 0, 0])
		linear_extrude(cutouts_thick)
		rounded_rect(air_width, air_height, 0.5);
	}

	// pillar holes
	// south left
	translate([rpi_left_of_board + rpi_hole_offset_left, rpi_hangs_south + rpi_hole_offset_south, rpi_lift/2]) pillar_hole();
	// north left
	translate([rpi_left_of_board + rpi_hole_offset_left, rpi_hangs_south + rpi_length - rpi_hole_offset_north, rpi_lift/2]) pillar_hole();
	// south right
	translate([rpi_left_of_board + rpi_hole_offset_right, rpi_hangs_south + rpi_hole_offset_south, rpi_lift/2]) pillar_hole();
	// north right
	translate([rpi_left_of_board + rpi_hole_offset_right, rpi_hangs_south + rpi_length - rpi_hole_offset_north, rpi_lift/2]) pillar_hole();
}

// lid
// change * to ! to render it
*difference() {
	union() {
		translate([wall + lid_tolerance, wall + lid_tolerance, lid_height])
		linear_extrude(lid_dip)
		rounded_rect(overall_width - (wall + lid_tolerance)*2, overall_length - (wall + lid_tolerance)*2, outer_radius);

		difference() {
			translate([0, 0, 0])
			linear_extrude(lid_height)
			rounded_rect(overall_width, overall_length, outer_radius);
			
			branding();
		}
	}
}
