include <BOSL2/std.scad>;
zz = 0.01;

bat_to_plate = 5.8;
bat_contact_w = 9;

bat_d = 21;
bat_h = 70;

blk_h = 12;
blk_w = 21;
blk_l = 74;

cell_h = 3.5; // cell + sticker
cell_w = 24;

difference() {
	cuboid([blk_w, blk_l, blk_h], anchor = TOP, chamfer=1);
	up(bat_d/2-bat_to_plate) back((blk_l-bat_h)/2+zz)
		cyl(d = bat_d, h = bat_h, orient = FRONT, chamfer1=-1);
	up(zz) fwd((blk_l-(blk_l-bat_h))/2+zz)
		cuboid(
			[bat_contact_w, (blk_l-bat_h)+zz*5, blk_h+zz*2],
			anchor = TOP, chamfer=-1
		);
	down(6/2+0.5) xcopies(blk_w+6-1.2)
		cyl(d = 6, h = blk_l+zz*2, orient = FRONT);
	down(blk_h-cell_h) cuboid(
		[blk_w+1, cell_w, cell_h+zz], anchor = TOP,
		chamfer=cell_h/2, edges=[TOP+FRONT, TOP+BACK]
	);
	
	back(blk_l/3) down(blk_h+zz) linear_extrude(0.4) yrot(180) {
		back(2) text("ITI", size = 6, halign = "center");
		fwd(8) text("v4.0", size = 6, halign = "center");
		fwd(47) text("bes", size = 6, halign = "center");
	}
}