#!/bin/sh
# Regenerate STLs, coloured preview PNG and the standalone viewer. Needs openscad + BOSL2 (+ xvfb-run for the PNG).
set -e
cd "$(dirname "$0")"
mkdir -p renders/zones
for p in base lid; do openscad -D "part=\"$p\"" -o "renders/$p.stl" case.scad; done
for k in hard soft free; do for o in lid base; do openscad -D "part=\"z_${k}_${o}\"" -o "renders/zones/${k}_${o}.stl" case.scad; done; done
python3 tools/make_viewer.py
xvfb-run -a openscad -D explode=25 --camera=0,0,20,60,0,35,260 --imgsize=1400,1000 --viewall --autocenter -o renders/preview.png case.scad || true
