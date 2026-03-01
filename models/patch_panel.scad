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
// Depth of keystone openings in mm
keystone_depth = 5; // [1:0.5:15]

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
// Notch corners to fit around HomeRacker connectors
connector_notch = true;
// Center keystone grid within the full panel (including margins)
center_keystones = false;
// Enable lock pin holes on top edge
pins_top = true;
// Enable lock pin holes on bottom edge
pins_bottom = true;
// Enable lock pin holes on left edge
pins_left = true;
// Enable lock pin holes on right edge
pins_right = true;

/* [Hidden] */
$fn = 100;
EPSILON = 0.01;

// Panel dimensions — snap to BASE_UNIT grid for clean ear alignment
panel_width = ceil(columns * col_pitch / BASE_UNIT) * BASE_UNIT;
panel_height = ceil(rows * row_pitch / BASE_UNIT) * BASE_UNIT;
// Ear strip width per side = 1 BASE_UNIT (lock pin row) + margin, or 0 if pins disabled
_ear_left = pins_left ? BASE_UNIT + margin_left : 0;
_ear_right = pins_right ? BASE_UNIT + margin_right : 0;
_ear_top = pins_top ? BASE_UNIT + margin_top : 0;
_ear_bottom = pins_bottom ? BASE_UNIT + margin_bottom : 0;

// Total outer dimensions
total_width = _ear_left + panel_width + _ear_right;
total_height = _ear_bottom + panel_height + _ear_top;

// Offset of panel center relative to frame center
frame_offset_x = (_ear_left - _ear_right) / 2;
frame_offset_z = (_ear_bottom - _ear_top) / 2;

module patch_panel() {
  _n_top = floor(total_width / BASE_UNIT);
  _n_side = floor(total_height / BASE_UNIT);

  difference() {
    union() {
      // Main slab
      translate([frame_offset_x, 0, frame_offset_z])
      cuboid([total_width, ear_strength, total_height], chamfer=BASE_CHAMFER);

      // Keystone wells — protrude from back if deeper than slab
      _kx = center_keystones ? frame_offset_x : 0;
      _kz = center_keystones ? frame_offset_z : 0;
      color(HR_CHARCOAL)
      translate([_kx, -ear_strength/2 + keystone_depth/2, _kz])
      xcopies(spacing=col_pitch, n=columns)
        zcopies(spacing=row_pitch, n=rows)
          cuboid([keystone_width + 2, keystone_depth, keystone_height + 2]);
    }

    // Keystone cutouts — punch through the wells
    _kx = center_keystones ? frame_offset_x : 0;
    _kz = center_keystones ? frame_offset_z : 0;
    translate([_kx, -ear_strength/2 + keystone_depth/2, _kz])
    xcopies(spacing=col_pitch, n=columns)
      zcopies(spacing=row_pitch, n=rows)
        cuboid([keystone_width, keystone_depth + EPSILON, keystone_height]);

    // Corner notches for HomeRacker connectors
    if(connector_notch) {
      _notch_size = [BASE_UNIT + 1, ear_strength + EPSILON*2, BASE_UNIT + 0.5];
      translate([frame_offset_x, 0, frame_offset_z]) {
        // Top-left
        translate([-total_width/2 + BASE_UNIT/2, 0, total_height/2 - BASE_UNIT/2])
          cuboid(_notch_size);
        // Top-right
        translate([total_width/2 - BASE_UNIT/2, 0, total_height/2 - BASE_UNIT/2])
          cuboid(_notch_size);
        // Bottom-left
        translate([-total_width/2 + BASE_UNIT/2, 0, -total_height/2 + BASE_UNIT/2])
          cuboid(_notch_size);
        // Bottom-right
        translate([total_width/2 - BASE_UNIT/2, 0, -total_height/2 + BASE_UNIT/2])
          cuboid(_notch_size);
      }
    }

    // Lock pin holes — one row on each outer edge
    translate([frame_offset_x, 0, frame_offset_z]) {
      if(pins_top)
        translate([0, 0, total_height / 2 - BASE_UNIT / 2])
          xcopies(spacing=BASE_UNIT, n=_n_top)
            xrot(90) lock_pin_hole();
      if(pins_bottom)
        translate([0, 0, -total_height / 2 + BASE_UNIT / 2])
          xcopies(spacing=BASE_UNIT, n=_n_top)
            xrot(90) lock_pin_hole();
      if(pins_left)
        translate([-total_width / 2 + BASE_UNIT / 2, 0, 0])
          zcopies(spacing=BASE_UNIT, n=_n_side)
            xrot(90) lock_pin_hole();
      if(pins_right)
        translate([total_width / 2 - BASE_UNIT / 2, 0, 0])
          zcopies(spacing=BASE_UNIT, n=_n_side)
            xrot(90) lock_pin_hole();
    }
  }
}

patch_panel();
