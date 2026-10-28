include <BOSL2/std.scad>;
zz = 0.01;
$fn = 20;

case_x = 92.1;
case_y = 43.4;

slot_center_x = 61;
slot_center_y = 33;
slot_x = 10;
slot_y = 3;
slot_h = 3;

button_h = 3;
button_d = 5;
button_x = 46.3;
button_y = 9.7;

gap = 1;
thick_xy = 0.6;
thick_h = button_h + thick_xy;
r = 1;

hole_x = case_x + gap * 2;
hole_y = case_y + gap * 2;
hole_h = 11.5;

cap_x = hole_x + thick_xy * 2;
cap_y = hole_y + thick_xy * 2;
cap_h = hole_h + thick_h;

lock_center_x = 46.3;
lock_center_y = hole_y;
lock_x = 2.5;
lock_y = 2;
lock_h = 5;

difference() {
	cuboid([cap_x, cap_y, cap_h], anchor=TOP, rounding=r, except=TOP);

	up(zz)
		cuboid([hole_x, hole_y, cap_h - thick_h], anchor=TOP, rounding=r, except=TOP);
	
	move([-(cap_x/2)+button_x, -(cap_y/2)+button_y, -(hole_h+button_h-zz)])
		cyl(d=button_d, h=button_h, anchor=BOTTOM, rounding1=r, rounding2=-r);
}

move([-(cap_x/2)+slot_center_x, -(cap_y/2)+slot_center_y, -hole_h])
	cuboid([slot_x, slot_y, slot_h], anchor=BOTTOM, rounding=r, except=BOTTOM);

move([-(cap_x/2)+lock_center_x, -(cap_y/2)+lock_center_y, -lock_h])
	cuboid([lock_x, lock_y, lock_h], anchor=BOTTOM, rounding=r, except=[BACK,BOTTOM]);
