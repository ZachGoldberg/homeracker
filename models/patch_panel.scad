include <BOSL2/std.scad>
include <core/lib/constants.scad>
include <core/lib/support.scad>

/* [Grid] */
// Number of keystone columns
columns = 6; // [1:24]
// Number of keystone rows
rows = 2; // [1:12]
// Keystone opening width in mm
keystone_width = 14.5; // [13:0.1:16]
// Keystone opening height in mm
keystone_height = 16; // [14:0.1:20]
// Horizontal spacing between keystones (center-to-center) in mm
col_pitch = 15; // [15:0.5:30]
// Vertical spacing between keystones (center-to-center) in mm
row_pitch = 30; // [20:0.5:45]
// Panel thickness at keystone area in mm
panel_depth = 2; // [1:0.5:15]

/* [Ears] */
// HomeRacker squares on top edge
ear_units_top = 1; // [0:10]
// HomeRacker squares on bottom edge
ear_units_bottom = 1; // [0:10]
// HomeRacker squares on left edge
ear_units_left = 1; // [0:10]
// HomeRacker squares on right edge
ear_units_right = 1; // [0:10]
// Ear thickness (depth behind panel face)
ear_strength = 2; // [1:0.5:15]

/* [Hidden] */
$fn = 100;
EPSILON = 0.01;

// Panel dimensions — snap to BASE_UNIT grid for clean ear alignment
panel_width = ceil(columns * col_pitch / BASE_UNIT) * BASE_UNIT;
panel_height = ceil(rows * row_pitch / BASE_UNIT) * BASE_UNIT;
panel_thickness = panel_depth;

// Ear dimensions
ear_top_height = ear_units_top * BASE_UNIT;
ear_bottom_height = ear_units_bottom * BASE_UNIT;
ear_left_width = ear_units_left * BASE_UNIT;
ear_right_width = ear_units_right * BASE_UNIT;

// Total outer dimensions including ears
total_width = ear_left_width + panel_width + ear_right_width;
total_height = ear_bottom_height + panel_height + ear_top_height;

module patch_panel() {
  ear_y_offset = (ear_strength - panel_thickness) / 2;

  difference() {
    union() {
      // Main panel plate
      color(HR_CHARCOAL)
      cuboid([panel_width, panel_thickness, panel_height]);

      // Ear frame — single piece surrounding the panel
      if(ear_units_top > 0 || ear_units_bottom > 0 || ear_units_left > 0 || ear_units_right > 0)
        color(HR_YELLOW)
        translate([(ear_left_width - ear_right_width) / 2, ear_y_offset, (ear_bottom_height - ear_top_height) / 2])
        difference() {
          cuboid([total_width, ear_strength, total_height], chamfer=BASE_CHAMFER);
          cuboid([panel_width, ear_strength + EPSILON*2, panel_height]);
        }
    }

    // Keystone cutouts — xcopies for columns, zcopies for rows
    xcopies(spacing=col_pitch, n=columns)
      zcopies(spacing=row_pitch, n=rows)
        cuboid([keystone_width, panel_thickness + EPSILON*2, keystone_height]);

    // Lock pin holes — full frame grid, holes in the center cutout area just cut air
    if(ear_units_top > 0 || ear_units_bottom > 0 || ear_units_left > 0 || ear_units_right > 0) {
      _w_units = floor(total_width / BASE_UNIT);
      _h_units = floor(total_height / BASE_UNIT);
      translate([(ear_left_width - ear_right_width) / 2, ear_y_offset, (ear_bottom_height - ear_top_height) / 2])
        xcopies(spacing=BASE_UNIT, n=_w_units)
          zcopies(spacing=BASE_UNIT, n=_h_units)
            xrot(90) lock_pin_hole();
    }
  }
}

patch_panel();
