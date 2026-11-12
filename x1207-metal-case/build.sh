#!/bin/sh
# Regenerate STLs, coloured preview PNG and the standalone viewer. Needs openscad + BOSL2 (+ xvfb-run for the PNG).
set -e
cd "$(dirname "$0")"
for p in base lid; do openscad -D "part=\"$p\"" -o "renders/$p.stl" case.scad; done
python3 tools/make_viewer.py
xvfb-run -a openscad -D explode=25 --camera=0,0,20,60,0,35,260 --imgsize=1400,1000 --viewall --autocenter -o renders/preview.png case.scad || true
