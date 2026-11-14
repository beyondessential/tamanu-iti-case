// Sticker designs shown in the viewer. To add one, append an entry to STICKERS.
//   id, name  : key and label in the control panel
//   face      : "top" (on the lid) or "bottom" (on the base)
//   cx, cy    : centre of the sticker in case coordinates, mm (X, Y; origin at the footprint centre)
//   w, h      : sticker size in mm, w along X and h along Y, as seen from outside the face with +Y up
//   draw(ctx, w, h): paint it with the canvas 2D API; ctx units are millimetres, (0,0) is the top left.
//                    May return a Promise (e.g. when loading an image).
// Keep stickers inside a green zone. Coordinates are from case.scad: top front zone x 11.7..42.4, y 6.6..34.7;
// top rear zone x 11.7..42.4, y -41.4..1.6; bottom zone x 4.3..44.9, between the feet.
const QR_TEXT = "K7QXMZ4TWBN2RD9HVCEJ5YAFPG3LU8SX";   // 32 uppercase characters, placeholder content
const FONT = "system-ui, 'Helvetica Neue', Arial, sans-serif";

function drawQR(ctx, text, x, y, size) {
  const q = qrcode(0, 'L'); q.addData(text); q.make();
  const n = q.getModuleCount(), m = size / (n + 2);   // one module of quiet zone each side
  ctx.fillStyle = '#fff'; ctx.fillRect(x, y, size, size);
  ctx.fillStyle = '#000';
  for (let r = 0; r < n; r++) for (let c = 0; c < n; c++) if (q.isDark(r, c)) ctx.fillRect(x + (c + 1) * m, y + (r + 1) * m, m + .02, m + .02);
}
function fitText(ctx, text, font, maxW, startPx) {
  let px = startPx; do { ctx.font = font(px); px -= .1; } while (ctx.measureText(text).width > maxW && px > 1);
}
function wrap(ctx, text, maxW) {
  const lines = []; let line = '';
  for (const word of text.split(' ')) {
    const t = line ? line + ' ' + word : word;
    if (ctx.measureText(t).width > maxW && line) { lines.push(line); line = word; } else line = t;
  }
  if (line) lines.push(line); return lines;
}

const LOGO_SRC = "__LOGO__";   // data URI of tools/stickers/tamanu-logo.(svg|png) if present, else empty

const STICKERS = [
  { id: 'qr', name: 'Bottom: QR code and ID', face: 'bottom', cx: 20, cy: 0, w: 30, h: 50,
    draw(ctx, w, h) {
      ctx.fillStyle = '#fff'; ctx.fillRect(0, 0, w, h);
      drawQR(ctx, QR_TEXT, 0, 0, 30);
      ctx.fillStyle = '#000'; ctx.textAlign = 'center'; ctx.textBaseline = 'alphabetic';
      fitText(ctx, 'ABC1', px => `bold ${px}px ${FONT}`, w - 3, 12);
      ctx.fillText('ABC1', w / 2, 30 + 11);
      ctx.font = `2.8px ${FONT}`;
      ctx.fillText('Tamanu Iti v4.0', w / 2, 30 + 17);
    } },
  { id: 'logo', name: 'Top front: Tamanu logo', face: 'top', cx: 27, cy: 20.65, w: 28, h: 26,
    draw(ctx, w, h) {
      ctx.fillStyle = '#fff'; ctx.fillRect(0, 0, w, h);
      if (LOGO_SRC) return new Promise(res => { const i = new Image(); i.onload = () => {
        const s = Math.min((w - 4) / i.width, (h - 4) / i.height); ctx.drawImage(i, (w - i.width * s) / 2, (h - i.height * s) / 2, i.width * s, i.height * s); res(); };
        i.src = LOGO_SRC; });
      // placeholder until the official logo file is added as tools/stickers/tamanu-logo.svg or .png
      ctx.fillStyle = '#1f5fbf'; ctx.beginPath(); ctx.arc(w / 2, h / 2 - 4, 6, 0, 7); ctx.fill();
      ctx.fillStyle = '#fff'; ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.font = `bold 8px ${FONT}`; ctx.fillText('T', w / 2, h / 2 - 3.6);
      ctx.fillStyle = '#1f5fbf'; fitText(ctx, 'Tamanu', px => `bold ${px}px ${FONT}`, w - 4, 7);
      ctx.fillText('Tamanu', w / 2, h / 2 + 7);
    } },
  { id: 'lorem', name: 'Top rear: sample text', face: 'top', cx: 27, cy: -19.9, w: 28, h: 41,
    draw(ctx, w, h) {
      ctx.fillStyle = '#1f5fbf'; ctx.fillRect(0, 0, w, h);
      ctx.fillStyle = '#fff'; ctx.textAlign = 'left'; ctx.textBaseline = 'top'; ctx.font = `2.7px ${FONT}`;
      const text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';
      wrap(ctx, text, w - 4).forEach((l, i) => { if (3.4 * i + 2 < h - 3) ctx.fillText(l, 2, 2 + 3.4 * i); });
    } },
];
