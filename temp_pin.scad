// Temp Pin - Temporary Lock Pin for HomeRacker
//
// A temporary, tool-free lock pin featuring:
// - Large circular handle extending in the pin plane (easy to grab)
// - Split prong snap-fit barbed end for medium strength hold
// - Tapered prong tips for easy insertion
//
// Prints flat on the build plate with no supports needed.
// Insert by pushing through a lockpin hole until barbs snap past.
// Remove by squeezing prong tips together and pulling out.

include <BOSL2/std.scad>
include <models/core/lib/constants.scad>

$fn = 64;

// Shaft cross-section: fits through 4mm square lockpin hole
pin_side = LOCKPIN_HOLE_SIDE_LENGTH - TOLERANCE;

// Circular handle (flat disc in the same plane, same thickness as shaft)
handle_diameter = 20;

// Shaft length past the handle edge
shaft_length = 12;

// Split prong snap-fit end
prong_length = 8;
prong_gap = 1.4;           // gap between prongs for flex
barb_overhang = 0.6;       // outward barb extension per side
barb_ramp_length = 4;      // gradual insertion ramp
taper_length = 1.5;        // lead-in taper at prong tips

chamfer = PRINTING_LAYER_WIDTH;

// Render
temp_pin();

// Handle hole diameter
handle_hole_diameter = 8;

module temp_pin() {
    shaft_end_x = shaft_length;

    // Circular handle disc (right edge meets shaft start, with center hole)
    color(HR_YELLOW)
    translate([-handle_diameter / 2 + 1, 0, 0])
    difference() {
        cyl(d = handle_diameter, h = pin_side, chamfer = chamfer);
        cyl(d = handle_hole_diameter, h = pin_side + 1);
    }

    // Shaft from X=0 to prong start
    color(HR_BLUE)
    translate([shaft_end_x / 2, 0, 0])
    cuboid([shaft_end_x, pin_side, pin_side], chamfer = chamfer, except = RIGHT);

    // Split prong barbed end
    color(HR_GREEN)
    translate([shaft_end_x, 0, 0])
    split_prongs();
}

module split_prongs() {
    prong_width = (pin_side - prong_gap) / 2;
    transition_length = 2;
    straight_length = prong_length - barb_ramp_length - taper_length - transition_length;

    for (side = [-1, 1]) {
        y_off = side * (prong_gap / 2 + prong_width / 2);

        // Smooth fork from full shaft to individual prong
        hull() {
            cuboid([0.01, pin_side, pin_side], chamfer = chamfer, except = [LEFT, RIGHT]);
            translate([transition_length, y_off, 0])
            cuboid([0.01, prong_width, pin_side]);
        }

        translate([transition_length, y_off, 0]) {
            // Straight prong body
            translate([straight_length / 2, 0, 0])
            cuboid([straight_length, prong_width, pin_side]);

            // Barb ramp: tapers outward toward tip for snap retention
            translate([straight_length, 0, 0])
            hull() {
                cuboid([0.01, prong_width, pin_side]);
                translate([barb_ramp_length, side * barb_overhang / 2, 0])
                cuboid([0.01, prong_width + barb_overhang, pin_side]);
            }

            // Insertion taper: narrows to a point for easy hole entry
            translate([straight_length + barb_ramp_length, side * barb_overhang / 2, 0])
            hull() {
                cuboid([0.01, prong_width + barb_overhang, pin_side]);
                translate([taper_length, -side * barb_overhang / 2, 0])
                cuboid([0.01, prong_width * 0.5, pin_side * 0.5]);
            }
        }
    }
}
