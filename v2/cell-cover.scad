include <BOSL2/std.scad>;

board_depth = 85;

// https://industrial.panasonic.com/ww/products/pt/lithium-ion/models/NCR18650BD
cell_diameter = 18.5;
cell_depth = 65.3 + 0.7;
cell_rounding = 1.2;
cell_spacing = 0.5;

module cells() {
	yrot(90)
	ycopies(cell_diameter+cell_spacing, n=2)
	cyl(l=cell_depth, d=cell_diameter, rounding=cell_rounding);
}

corners = 1;

overcase_up = 4.1;
overcase_dl = 5.5;
overcase_dw = 2;

overhead_up = 2;

module cell_cover() {
	down(overcase_up + overhead_up)
	difference() {
		up((overcase_up + overhead_up)/2)
		cuboid([
			cell_depth + overcase_dl*2,
			cell_diameter*2 + cell_spacing + overcase_dw*2,
			overcase_up + overhead_up
		], rounding=corners, except=[TOP,RIGHT]);

		cell_offset = 1;
		down(overcase_up + cell_offset)
		cells();
	}
}

screen_overall_y = 38;
screen_overall_z = 30;
screen_corners = 5;
screen_posts_d = 4.0;
screen_posts_x = 2.5;
screen_posts_inset = 3;
module screen_back() {
down(screen_overall_z/2) back(screen_overall_y/2) {
	// board plane for reference only
	*cuboid(
		[0.1, screen_overall_y, screen_overall_z],
		anchor=[-1, 1,-1],
		rounding=screen_corners,
		except=[LEFT,RIGHT],
	);

	for (pos = [
		[screen_posts_inset, screen_posts_inset],
		[screen_overall_y - screen_posts_inset, screen_posts_inset],
		[screen_overall_y - screen_posts_inset, screen_overall_z - screen_posts_inset],
		[screen_posts_inset, screen_overall_z - screen_posts_inset],
	]) {
		$fn = 20;
		fwd(pos[0]) up(pos[1])
		xcyl(screen_posts_x, d=screen_posts_d, anchor=[-1, 0, 0]);
	}

	chips_x = 1.1;
	chips_at_y = 9;
	chips_y = 8.5;
	chips_at_z = 5;
	chips_z = 20;
	up(chips_at_z) fwd(chips_at_y)
	cuboid(
		[chips_x, chips_y, chips_z],
		anchor=[-1, 1, -1],
		rounding=0.5,
		except=[LEFT]
	);

	jst_x = 3.6;
	jst_at_y = 20;
	jst_y = 12;
	jst_at_z = 6;
	jst_z = 18;
	up(jst_at_z) fwd(jst_at_y)
	cuboid(
		[jst_x, jst_y, jst_z],
		anchor=[-1, 1, -1],
		rounding=0.5,
		except=[LEFT]
	);

	wires_x = 6;
	wires_y = 8;
	wires_at_y = jst_at_y + jst_y - wires_y;
	wires_at_z = jst_at_z;
	wires_z = jst_z;
	up(wires_at_z) fwd(wires_at_y)
	cuboid(
		[wires_x, wires_y, wires_z],
		anchor=[-1, 1, -1],
		rounding=0.5,
		except=[LEFT]
	);

	via_x = 11;
	via_y = 8;
	via_at_y = jst_at_y + jst_y - via_y;
	via_at_z = jst_at_z;
	via_z = jst_z/3-corners;
	up(via_at_z) fwd(via_at_y)
	cuboid(
		[via_x, via_y, via_z],
		anchor=[-1, 1, -1],
		rounding=0.5,
		except=[LEFT]
	);
}
}

//!screen_back();

overall_x = cell_depth + overcase_dl*2;
overall_y = cell_diameter*2 + cell_spacing + overcase_dw*2;

// for reference when needed
board_top_to_zero_z = 22;
*down(board_top_to_zero_z) cuboid([100, 100, 0.1]);

union() {
	cell_cover();

	// right top of cover
	up(corners/2) right(overall_x/4 - corners)
	cuboid([
		overall_x/2 + corners*2,
		overall_y,
		corners,
	], rounding=corners, except=[BOTTOM,LEFT,RIGHT]);

	// left top of cover
	left_top = 13;
	difference() {
		up(left_top/2) left(overall_x/4)
		cuboid([
			overall_x/2,
			overall_y,
			left_top,
		], rounding=corners, except=[BOTTOM]);

		// pocket for rtc battery
		pocket_wall = 5;
		pocket_x = max(32, overall_x/2 - pocket_wall);
		pocket_y = max(22, overall_y/2);
		pocket_z = 3;
		up(pocket_z-corners/2) right(-pocket_x/2+0.01)
		cuboid([
			pocket_x,
			pocket_y,
			pocket_z,
		], rounding=corners, except=[RIGHT]);
	}

	// right bar to hold cables
	bar_z = left_top/2;
	up(corners*3.25 + bar_z)
	right(overall_x/4 - corners)
	back(overall_y/2-bar_z/2)
	cuboid([
		overall_x/2 + corners*4,
		bar_z,
		bar_z,
	], rounding=corners, except=[LEFT,RIGHT]);

	// linkage for corners-chamfers
	up(-(overcase_up + overhead_up + corners)/2 + corners)
	right(overall_x/2+corners/2)
	cuboid([
		corners,
		overall_y,
		overcase_up + overhead_up + corners,
	], rounding=corners, except=[LEFT,RIGHT]);

	// screen holder panel
	panel_bot = 20;
	panel_top = left_top;
	panel_thk = 7.1;
	up(-(panel_bot + panel_top)/2 + panel_top)
	right(overall_x/2+panel_thk/2)
	difference() {
		cuboid(
			[panel_thk, overall_y, panel_bot + panel_top],
			rounding=corners,
		);

		// cutout for power button on ups
		pwr_cutout_y = 6.0;
		pwr_cutout_z = 8.0;
		xcopies(0.01) ycopies(0.01) zcopies(0.01)
		down(-(panel_bot + panel_top)/2 + panel_top) down(board_top_to_zero_z) up(pwr_cutout_z/2) // adjust to rest on top of board
		fwd(overall_y/2 - pwr_cutout_y/2)
		cuboid([panel_thk, pwr_cutout_y, pwr_cutout_z]);

		// cutout for screen bits
		xcopies(0.01)
		xflip() left(panel_thk/2)
		up(0.5) back(3.4)
		xrot(180) screen_back();
	}
}