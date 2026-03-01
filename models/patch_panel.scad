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
// Extra margin on left side in mm
margin_left = 0; // [0:1:300]
// Extra margin on right side in mm
margin_right = 0; // [0:1:300]
// Extra margin on top in mm
margin_top = 0; // [0:1:300]
// Extra margin on bottom in mm
margin_bottom = 0; // [0:1:300]
// Ear thickness (depth behind panel face)
ear_strength = 2; // [1:0.5:15]

/* [Hidden] */
$fn = 100;
EPSILON = 0.01;

// Panel dimensions — snap to BASE_UNIT grid for clean ear alignment
panel_width = ceil(columns * col_pitch / BASE_UNIT) * BASE_UNIT;
panel_height = ceil(rows * row_pitch / BASE_UNIT) * BASE_UNIT;
panel_thickness = panel_depth;

// Ear strip width per side = 1 BASE_UNIT (lock pin row) + margin
_ear_left = BASE_UNIT + margin_left;
_ear_right = BASE_UNIT + margin_right;
_ear_top = BASE_UNIT + margin_top;
_ear_bottom = BASE_UNIT + margin_bottom;

// Total outer dimensions
total_width = _ear_left + panel_width + _ear_right;
total_height = _ear_bottom + panel_height + _ear_top;

// Offset of panel center relative to frame center
frame_offset_x = (_ear_left - _ear_right) / 2;
frame_offset_z = (_ear_bottom - _ear_top) / 2;

module patch_panel() {
  ear_y_offset = (ear_strength - panel_thickness) / 2;

  difference() {
    union() {
      // Main panel plate (keystone grid area only)
      color(HR_CHARCOAL)
      cuboid([panel_width, panel_thickness, panel_height]);

      // Ear frame — outer ring including margins
      color(HR_YELLOW)
      translate([frame_offset_x, ear_y_offset, frame_offset_z])
      difference() {
        cuboid([total_width, ear_strength, total_height], chamfer=BASE_CHAMFER);
        cuboid([panel_width, panel_thickness + EPSILON*2, panel_height]);
      }
    }

    // Keystone cutouts
    xcopies(spacing=col_pitch, n=columns)
      zcopies(spacing=row_pitch, n=rows)
        cuboid([keystone_width, panel_thickness + EPSILON*2, keystone_height]);

    // Lock pin holes — one row on each outer edge
    _pw = panel_width / 2;
    _ph = panel_height / 2;
    _n_top = floor(total_width / BASE_UNIT);
    _n_side = floor(total_height / BASE_UNIT);
    // Top row
    translate([frame_offset_x, ear_y_offset, total_height / 2 - BASE_UNIT / 2])
      xcopies(spacing=BASE_UNIT, n=_n_top)
        xrot(90) lock_pin_hole();
    // Bottom row
    translate([frame_offset_x, ear_y_offset, -total_height / 2 + BASE_UNIT / 2])
      xcopies(spacing=BASE_UNIT, n=_n_top)
        xrot(90) lock_pin_hole();
    // Left column
    translate([-total_width / 2 + BASE_UNIT / 2 + frame_offset_x, ear_y_offset, frame_offset_z])
      zcopies(spacing=BASE_UNIT, n=_n_side)
        xrot(90) lock_pin_hole();
    // Right column
    translate([total_width / 2 - BASE_UNIT / 2 + frame_offset_x, ear_y_offset, frame_offset_z])
      zcopies(spacing=BASE_UNIT, n=_n_side)
        xrot(90) lock_pin_hole();
  }
}

patch_panel();
