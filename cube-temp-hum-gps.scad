$fn = 36;

width = 25.4;
length = 25.4;
total_height = 37; // to fit just under lid

hole_d = 2.5;
hole_to_side = 1.3;

d_mount_tip = 2.4;
d_mount_base = hole_d + hole_to_side * 2;
width_gap = width - d_mount_base;

board_thick = 1.6;

th_thick = 4.8;
th_length = 17.8;
gap = -1; // cell holder goes in gap between stemma qt connectors
gps_thick = 12;
gps_length = 25.5;
gps_cell_thick = 4;

assembly_height = th_thick + gap + gps_thick;
gps_bottom_of_board = th_thick + gap + gps_cell_thick;

tip_above_gps_board = 2;
uppermost_tip = gps_bottom_of_board + board_thick + tip_above_gps_board;

base_height = total_height - assembly_height;

fixing_dome_d = 6.1;

module pin(tip, base) {
	union() {
		cylinder(d = d_mount_tip, h = tip);
		cylinder(d = d_mount_base, h = base);
	}
}

difference() {
	cube([width, length, base_height]);
	translate([width/2, length/2]) sphere(d = fixing_dome_d);
	
	// hole for temp sensor
	translate([width/2, length/3, base_height]) sphere(d = fixing_dome_d);
}

translate([d_mount_base/2, d_mount_base/2, base_height]) {
	for(offset = [0 : width_gap : width_gap]) translate([offset, 0, 0]) {
		pin(uppermost_tip, 0);
		
		translate([0, th_length - d_mount_base])
		pin(gps_bottom_of_board, 0);
		
		translate([0, gps_length - d_mount_base])
		pin(uppermost_tip, gps_bottom_of_board);
	}
}

// spacer
translate([width*0.2, -10])
cube([width*0.6, gps_bottom_of_board - board_thick, 3.6]);
// printed on its side to be more accurate dimensionally
