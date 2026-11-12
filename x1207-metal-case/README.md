# X1207-C1 metal case (communication model)

Geekworm/Suptronics X1207-C1 case for Raspberry Pi 5 + X1207/X1208 UPS, modelled to show which
surfaces are free for sticker branding and which holes must stay clear for airflow and ports.
Not dimensionally exact: overall size (92.8 x 90.8 x 42.8 mm) and the 65 mm hanging-hole spacing
are published specs; hole positions are traced by eye from the wiki/product photos.

- `viewer.html` - standalone two-colour 3D viewer (open in a browser; loads three.js from cdnjs)
- `renders/base.stl`, `renders/lid.stl` - one colour each (GitHub's STL viewer is single-colour)
- `renders/preview.png` - exploded preview
- `case.scad` - parametric OpenSCAD + BOSL2 source; `./build.sh` regenerates everything

Assumed split: lid = top plate + ~5 mm flanges on the two sides without ports; base = bottom plus
front/rear walls to full height. Check against a real unit.
