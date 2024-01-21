//include <../vendor/RaspberryPi5.scad>;
//translate([0,0,-15])
//rpi5();

$fn = 36;

radius = 6;
outer = 68.70;
shelf = 1.2;
ridge = 1;
wall_thick = 1;

length = 68;
extended = 30;

curvature = 300;

gpio_length = 55;
gpio_width = 6;
gpio_x = 10;
gpio_y = 12;

module rounded_rect(width, height, corner_r) {
	minkowski() {
		square([width-(corner_r * 2), height-(corner_r * 2)]);
		translate([corner_r, corner_r]) circle(r=corner_r);
	}
}

module branding() {
	rotate([0, 0, -90]) {
		linear_extrude(2.4)
		translate([-10, 25, 0]) {
			translate([-38.5, 0, 0])
			mirror([1, 0, 0])
			text("iti", size = 10, font="BetecknaLowerCase:style=Medium");
			translate([0, 14, 0])
			mirror([1, 0, 0])
			text("tamanu", size = 12, font="BetecknaLowerCase:style=Medium");
		}
		
		translate([-59, 35, 0])
		cube([50, 1.5, 0.8]);
	}
}

difference() {
	union() {
		// wall
		translate([0, 0, -30])
		linear_extrude(30)
		difference() {
			rounded_rect(length + extended, outer, radius);
			
			translate([shelf, shelf])
			rounded_rect(length - shelf*2 + extended, outer - shelf*2, radius);
		}
		
		// bottom rails
		difference() {
			linear_extrude(2)
			difference()
			{
				union() {
					// outer rail
					difference() {
						rounded_rect(length + extended, outer, radius);

						translate([shelf, shelf])
						rounded_rect(length - shelf*2 + extended, outer - shelf*2, radius);
					}

					// inner rail
					difference() {
						translate([shelf + ridge, shelf + ridge])
						rounded_rect(length - (shelf + ridge)*2 + extended, outer - (shelf + ridge)*2, radius);
						
						translate([shelf*2 + ridge, shelf*2 + ridge])
						rounded_rect(length - (shelf*2 + ridge)*2 + extended, outer - (shelf*2 + ridge)*2, radius);
					}
				}
				
				// back cutout
				translate([length, 0, 0])
				square([extended, outer+1]);
			}

			// lateral v-curves
			translate([outer/2, outer+1, curvature+0.5])
			rotate([90, 0, 0])
			cylinder(h = outer+2, r = curvature, $fn = 200);
			
			// front v-curve
			translate([0, length/2, curvature+0.5])
			rotate([90, 0, 90])
			cylinder(h = shelf*4, r = curvature, $fn = 200);
		}
		
		// bottom plate
		translate([0, 0, -1]) linear_extrude(1) {
			translate([1+radius+length-extended/3, 0, 0])
			rounded_rect(extended, outer, radius);
			
			// rail support
			difference() {
				rounded_rect(length + extended, outer, radius);

				translate([shelf*2 + ridge, shelf*2 + ridge])
				rounded_rect(length - (shelf*2 + ridge)*2 + extended, outer - (shelf*2 + ridge)*2, radius);
			}
		}

		// mid plate
		translate([0, 0, -10])
		difference() {
			linear_extrude(1)
			rounded_rect(length + extended/2, outer, radius);
			
			// gps
			translate([25, 25, -1.5])
			cube([18, 18, 3]);
		}
		
		// top plate
		translate([0, 0, -30])
		difference() {
			// plate
			linear_extrude(2.5) // thicker so it gets infill for structural
			rounded_rect(length + extended/4, outer, radius);
			
			// text cutout
			branding();
		}
	}

	// box for gpio pins, with headroom for connectors
	translate([gpio_x, gpio_y, -25])
	rotate([0, 0, -90])
	cube([gpio_width, gpio_length, 30]);
		
	translate([length, -1, 0])
	rotate([-90, 0, 0])
	linear_extrude(outer+2)
	polygon([[0, 30], [32, 30], [32, 0], [20, 0], [0, 30]]);
}

// text inlay
// change * to ! to render it
*translate([0, 0, -30]) branding();
