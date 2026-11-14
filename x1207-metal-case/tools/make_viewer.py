#!/usr/bin/env python3
"""Embed renders/base.stl + lid.stl (ASCII) as binary STL in a standalone three.js viewer."""
import base64, re, struct, sys, pathlib
root = pathlib.Path(__file__).resolve().parent.parent

def to_binary(path):
    txt = path.read_text()
    v = [tuple(map(float, m)) for m in re.findall(r'vertex\s+(\S+)\s+(\S+)\s+(\S+)', txt)]
    n = len(v) // 3
    out = bytearray(80) + struct.pack('<I', n)
    for i in range(n):
        out += struct.pack('<12fH', 0, 0, 0, *v[3*i], *v[3*i+1], *v[3*i+2], 0)
    return base64.b64encode(bytes(out)).decode()

tpl = (root / 'tools' / 'viewer.template.html').read_text()
v = root / 'tools' / 'vendor'
three = '\n'.join((v / f).read_text() for f in ('three.min.js', 'STLLoader.js', 'TrackballControls.js'))
# use a function so backslashes/regex chars in the JS are not interpreted
scad = (root / 'case.scad').read_text()
dim = {k: float(re.search(r'^%s\s*=\s*([\d.]+)' % k, scad, re.M).group(1)) for k in ('wx', 'wy', 'hgt', 't')}
import json
zones = {f'{k}_{o}': to_binary(root / 'renders' / 'zones' / f'{k}_{o}.stl') for k in ('hard', 'soft', 'free') for o in ('lid', 'base')}
import mimetypes
logo = next((f for f in (root / 'tools' / 'stickers').glob('tamanu-logo.*')), None)
logo_uri = ('data:%s;base64,' % mimetypes.guess_type(logo.name)[0] + base64.b64encode(logo.read_bytes()).decode()) if logo else ''
stickers = (v / 'qrcode.js').read_text() + '\n' + (root / 'tools' / 'stickers.js').read_text().replace('__LOGO__', logo_uri)
html = tpl.replace('/*__STICKERS__*/', stickers).replace('__ZONES__', json.dumps(zones)).replace('__DIM__', json.dumps(dim)).replace('/*__THREE__*/', three).replace('__BUTTON__', to_binary(root / 'renders' / 'button.stl')).replace('__BASE__', to_binary(root / 'renders' / 'base.stl')) \
          .replace('__LID__', to_binary(root / 'renders' / 'lid.stl'))
(root / 'viewer.html').write_text(html)
print('wrote viewer.html', len(html) // 1024, 'KiB')
