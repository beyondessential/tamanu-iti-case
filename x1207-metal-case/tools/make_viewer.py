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
three = '\n'.join((v / f).read_text() for f in ('three.min.js', 'STLLoader.js', 'OrbitControls.js'))
# use a function so backslashes/regex chars in the JS are not interpreted
html = tpl.replace('/*__THREE__*/', three).replace('__BASE__', to_binary(root / 'renders' / 'base.stl')) \
          .replace('__LID__', to_binary(root / 'renders' / 'lid.stl'))
(root / 'viewer.html').write_text(html)
print('wrote viewer.html', len(html) // 1024, 'KiB')
