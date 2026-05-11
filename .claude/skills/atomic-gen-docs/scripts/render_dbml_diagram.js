/**
 * render_dbml_diagram.js
 * Render a DBML file to PNG using @napi-rs/canvas (server-side, no browser needed).
 *
 * Usage: node render_dbml_diagram.js <input.dbml> <output.png>
 *
 * Logic ported from dbml-diagram.bundle.html (parser / layout / router / renderer).
 */

'use strict';

const fs = require('fs');
const path = require('path');

// @napi-rs/canvas installed globally — use absolute path for reliability
const CANVAS_PATHS = [
  path.join(process.env.APPDATA || '', 'npm/node_modules/@napi-rs/canvas'),
  path.join(process.env.HOME || process.env.USERPROFILE || '', '.npm-global/lib/node_modules/@napi-rs/canvas'),
  '@napi-rs/canvas',
];
let createCanvas;
for (const p of CANVAS_PATHS) {
  try { ({ createCanvas } = require(p)); break; } catch (_) {}
}
if (!createCanvas) {
  console.error('ERROR: @napi-rs/canvas not found. Install with: npm install -g @napi-rs/canvas --strict-ssl=false');
  process.exit(1);
}

// ─── Constants ────────────────────────────────────────────────────────────────
const BOX    = { W: 172, H: 46, HDR: 20 };
const COL_GAP = 68, ROW_GAP = 40, ORIGIN_X = 40, ORIGIN_Y = 40;
const TARGET_RATIO = 2.0;
const PADDING = 44;

const STYLE = {
  hdr:    '#555251',
  fill:   '#f0efeb',
  stroke: '#b0ada8',
  text:   '#333130',
  hdrTxt: '#ffffff',
  bg:     '#ffffff',
};

// ─── Parser ───────────────────────────────────────────────────────────────────
function parse(src) {
  src = src.replace(/\/\/[^\n]*/g, '');
  return { tables: parseTables(src), refs: parseRefs(src), groups: parseGroups(src) };
}

function parseGroups(src) {
  const groups = [];
  const re = /TableGroup\s+"?([^"{\n]+)"?\s*\{([^}]*)\}/gi;
  let m;
  while ((m = re.exec(src)) !== null) {
    const label   = m[1].trim();
    const members = (m[2].match(/"?[\w_]+"?/g) || []).map(s => s.replace(/"/g, '').trim());
    groups.push({ label, members });
  }
  return groups;
}

function parseTables(src) {
  const tables = [];
  const re = /Table\s+"?([\w_]+)"?(?:\s*\[.*?\])?\s*\{[^}]*\}/gi;
  let m;
  while ((m = re.exec(src)) !== null) {
    tables.push({ id: m[1], label: m[1], x: 0, y: 0 });
  }
  return tables;
}

function parseRefs(src) {
  const refs = [];
  const re = /Ref\s*(?:"?[\w_]+"?)?\s*:\s*"?([\w_]+)"?\."?([\w_]+)"?\s*[<>-]+\s*"?([\w_]+)"?\."?([\w_]+)"?/gi;
  let m;
  while ((m = re.exec(src)) !== null) {
    refs.push({ from: m[1], to: m[3] });
  }
  return refs;
}

// ─── Layout ───────────────────────────────────────────────────────────────────
function layoutGrid(tables, refs, groups) {
  if (!tables.length) return;
  const tmap   = tableMap(tables);
  const degree = computeDegree(tables, refs, tmap);
  const cols   = bestCols(tables.length);
  const rows   = Math.ceil(tables.length / cols);
  const ordered = orderByGroups(tables, groups);
  const centreIdx = Math.floor(rows / 2) * cols + Math.floor(cols / 2);
  const topNode   = [...ordered].sort((a, b) => degree[b.id] - degree[a.id])[0];
  const rest      = ordered.filter(t => t.id !== topNode.id);
  rest.splice(Math.min(centreIdx, rest.length), 0, topNode);
  rest.forEach((t, i) => {
    t.x = ORIGIN_X + (i % cols)           * (BOX.W + COL_GAP);
    t.y = ORIGIN_Y + Math.floor(i / cols) * (BOX.H + ROW_GAP);
  });
}

function tableMap(tables) {
  const m = {};
  tables.forEach(t => (m[t.id] = t));
  return m;
}

function computeDegree(tables, refs, tmap) {
  const deg = {};
  tables.forEach(t => (deg[t.id] = 0));
  refs.forEach(r => {
    if (tmap[r.from]) deg[r.from]++;
    if (tmap[r.to])   deg[r.to]++;
  });
  return deg;
}

function bestCols(n) {
  let best = 1, bestScore = Infinity;
  for (let c = 1; c <= n; c++) {
    const r     = Math.ceil(n / c);
    const score = Math.abs((c * (BOX.W + COL_GAP)) / (r * (BOX.H + ROW_GAP)) - TARGET_RATIO);
    if (score < bestScore) { bestScore = score; best = c; }
  }
  return best;
}

function orderByGroups(tables, groups) {
  const seen = new Set(), ordered = [];
  groups.forEach(g => {
    g.members.forEach(mid => {
      const t = tables.find(x => x.id === mid);
      if (t && !seen.has(t.id)) { ordered.push(t); seen.add(t.id); }
    });
  });
  tables.forEach(t => { if (!seen.has(t.id)) { ordered.push(t); seen.add(t.id); } });
  return ordered;
}

// ─── Router ───────────────────────────────────────────────────────────────────
function buildPorts(tables, refs) {
  const tmap = tableMap(tables);
  const ports = refs.map(() => ({ from: null, to: null }));
  const sideBuckets = {};
  tables.forEach(t => { sideBuckets[t.id] = { left: [], right: [], top: [], bottom: [] }; });

  refs.forEach((r, i) => {
    const a = tmap[r.from], b = tmap[r.to];
    if (!a || !b) return;
    if (r.from === r.to) {
      sideBuckets[a.id].top.push(  { i, other: b, isFrom: true  });
      sideBuckets[b.id].right.push({ i, other: a, isFrom: false });
    } else {
      sideBuckets[a.id][preferredSide(a, b)].push({ i, other: b, isFrom: true  });
      sideBuckets[b.id][preferredSide(b, a)].push({ i, other: a, isFrom: false });
    }
  });

  tables.forEach(t => {
    assignHPorts(t, sideBuckets[t.id], ports);
    assignVPorts(t, sideBuckets[t.id], ports);
  });
  return ports;
}

function preferredSide(a, b) {
  const dx = (b.x + BOX.W / 2) - (a.x + BOX.W / 2);
  const dy = (b.y + BOX.H / 2) - (a.y + BOX.H / 2);
  if (Math.abs(dx) >= Math.abs(dy) * 0.55 && Math.abs(dx) > 8)
    return dx > 0 ? 'right' : 'left';
  return dy > 0 ? 'bottom' : 'top';
}

function assignHPorts(t, buckets, ports) {
  ['left', 'right'].forEach(side => {
    const list = buckets[side];
    if (!list.length) return;
    list.sort((a, b) => (a.other.y + BOX.H / 2) - (b.other.y + BOX.H / 2));
    const px   = side === 'right' ? t.x + BOX.W : t.x;
    const yTop = t.y + BOX.HDR + 3;
    const span = BOX.H - BOX.HDR - 6;
    list.forEach((e, k) => {
      const py = yTop + span * (k + 1) / (list.length + 1);
      const pt = { x: px, y: py, hz: true };
      if (e.isFrom) ports[e.i].from = pt; else ports[e.i].to = pt;
    });
  });
}

function assignVPorts(t, buckets, ports) {
  ['top', 'bottom'].forEach(side => {
    const list = buckets[side];
    if (!list.length) return;
    list.sort((a, b) => (a.other.x + BOX.W / 2) - (b.other.x + BOX.W / 2));
    const py   = side === 'bottom' ? t.y + BOX.H : t.y;
    const xL   = t.x + 10;
    const span = BOX.W - 20;
    list.forEach((e, k) => {
      const px = xL + span * (k + 1) / (list.length + 1);
      const pt = { x: px, y: py, hz: false };
      if (e.isFrom) ports[e.i].from = pt; else ports[e.i].to = pt;
    });
  });
}

function routeEdge(portPair, tables, srcId, dstId) {
  if (!portPair?.from || !portPair?.to) return [];
  const { from: fp, to: tp } = portPair;
  const x1 = fp.x, y1 = fp.y, x2 = tp.x, y2 = tp.y;

  if (srcId === dstId) {
    const t = tables.find(t => t.id === srcId);
    const loopX = (t ? t.x + BOX.W : Math.max(x1, x2)) + 22;
    const loopY = (t ? t.y : Math.min(y1, y2)) - 22;
    return [{ x: x1, y: y1 }, { x: x1, y: loopY }, { x: loopX, y: loopY },
            { x: loopX, y: y2 }, { x: x2, y: y2 }];
  }
  if (Math.abs(x1 - x2) < 2 && Math.abs(y1 - y2) < 2) return [];
  if (fp.hz && tp.hz) {
    if (Math.abs(y1 - y2) < 2) return [{ x: x1, y: y1 }, { x: x2, y: y2 }];
    const mx = avoidBoxesV((x1 + x2) / 2, y1, y2, tables, srcId, dstId);
    return [{ x: x1, y: y1 }, { x: mx, y: y1 }, { x: mx, y: y2 }, { x: x2, y: y2 }];
  }
  if (!fp.hz && !tp.hz) {
    if (Math.abs(x1 - x2) < 2) return [{ x: x1, y: y1 }, { x: x2, y: y2 }];
    const my = avoidBoxesH((y1 + y2) / 2, x1, x2, tables, srcId, dstId);
    return [{ x: x1, y: y1 }, { x: x1, y: my }, { x: x2, y: my }, { x: x2, y: y2 }];
  }
  if (fp.hz) return [{ x: x1, y: y1 }, { x: tp.x, y: y1  }, { x: tp.x, y: y2 }];
  return             [{ x: x1, y: y1 }, { x: x1,   y: tp.y }, { x: x2,   y: tp.y }];
}

function avoidBoxesV(mx, y1, y2, tables, srcId, dstId) {
  const yLo = Math.min(y1, y2) + 2, yHi = Math.max(y1, y2) - 2;
  for (let i = 0; i < 16; i++) {
    const b = tables.find(t => t.id !== srcId && t.id !== dstId &&
      mx > t.x + 2 && mx < t.x + BOX.W - 2 && yHi > t.y + 2 && yLo < t.y + BOX.H - 2);
    if (!b) break;
    const toR = b.x + BOX.W + 10, toL = b.x - 10;
    mx = Math.abs(toR - mx) < Math.abs(toL - mx) ? toR : toL;
  }
  return mx;
}

function avoidBoxesH(my, x1, x2, tables, srcId, dstId) {
  const xLo = Math.min(x1, x2) + 2, xHi = Math.max(x1, x2) - 2;
  for (let i = 0; i < 16; i++) {
    const b = tables.find(t => t.id !== srcId && t.id !== dstId &&
      my > t.y + 2 && my < t.y + BOX.H - 2 && xHi > t.x + 2 && xLo < t.x + BOX.W - 2);
    if (!b) break;
    const toB = b.y + BOX.H + 10, toT = b.y - 10;
    my = Math.abs(toB - my) < Math.abs(toT - my) ? toB : toT;
  }
  return my;
}

// ─── Renderer ─────────────────────────────────────────────────────────────────
function drawTable(ctx, t) {
  const { x, y } = t;
  const { W: BW, H: BH, HDR } = BOX;

  // Shadow
  ctx.shadowColor   = 'rgba(0,0,0,0.09)';
  ctx.shadowBlur    = 4;
  ctx.shadowOffsetY = 2;
  rrPath(ctx, x, y, BW, BH, 6);
  ctx.fillStyle = STYLE.fill;
  ctx.fill();
  ctx.shadowColor = 'transparent';

  // Header
  ctx.beginPath();
  ctx.moveTo(x + 6, y); ctx.lineTo(x + BW - 6, y);
  ctx.arcTo(x + BW, y, x + BW, y + 6, 6);
  ctx.lineTo(x + BW, y + HDR); ctx.lineTo(x, y + HDR);
  ctx.lineTo(x, y + 6); ctx.arcTo(x, y, x + 6, y, 6);
  ctx.closePath();
  ctx.fillStyle = STYLE.hdr;
  ctx.fill();

  // Border
  rrPath(ctx, x, y, BW, BH, 6);
  ctx.strokeStyle = STYLE.stroke;
  ctx.lineWidth   = 0.8;
  ctx.stroke();

  // Divider
  ctx.beginPath();
  ctx.moveTo(x, y + HDR); ctx.lineTo(x + BW, y + HDR);
  ctx.strokeStyle = STYLE.stroke;
  ctx.lineWidth   = 0.4;
  ctx.stroke();

  // "Table" label
  ctx.textAlign    = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillStyle    = STYLE.hdrTxt;
  ctx.font         = `bold 11px Arial`;
  ctx.fillText('Table', x + BW / 2, y + HDR / 2);

  // Table name
  ctx.fillStyle = STYLE.text;
  ctx.font      = `400 11px Arial`;
  let lbl = t.label;
  while (ctx.measureText(lbl).width > BW - 14 && lbl.length > 4) lbl = lbl.slice(0, -1);
  if (lbl !== t.label) lbl = lbl.slice(0, -1) + '…';
  ctx.fillText(lbl, x + BW / 2, y + HDR + (BH - HDR) / 2);
}

function drawEdge(ctx, pts) {
  if (!pts?.length || pts.length < 2) return;
  ctx.strokeStyle = STYLE.stroke;
  ctx.lineWidth   = 1.0;
  ctx.lineJoin    = 'miter';
  ctx.beginPath();
  ctx.moveTo(pts[0].x, pts[0].y);
  pts.slice(1).forEach(p => ctx.lineTo(p.x, p.y));
  ctx.stroke();
  const sq = 3;
  [pts[0], pts[pts.length - 1]].forEach(p => {
    ctx.fillStyle = STYLE.stroke;
    ctx.fillRect(p.x - sq / 2, p.y - sq / 2, sq, sq);
  });
}

function rrPath(ctx, x, y, w, h, r) {
  ctx.beginPath();
  ctx.moveTo(x + r, y); ctx.lineTo(x + w - r, y); ctx.arcTo(x + w, y, x + w, y + r, r);
  ctx.lineTo(x + w, y + h - r); ctx.arcTo(x + w, y + h, x + w - r, y + h, r);
  ctx.lineTo(x + r, y + h); ctx.arcTo(x, y + h, x, y + h - r, r);
  ctx.lineTo(x, y + r); ctx.arcTo(x, y, x + r, y, r);
  ctx.closePath();
}

// ─── Main ─────────────────────────────────────────────────────────────────────
function renderToPNG(dbmlSrc, outputPath) {
  const { tables, refs, groups } = parse(dbmlSrc);

  if (!tables.length) {
    console.error('ERROR: No tables found in DBML input.');
    process.exit(1);
  }

  layoutGrid(tables, refs, groups);
  const portPairs = buildPorts(tables, refs);

  // Compute canvas size from bounding box
  const xs  = tables.map(t => t.x);
  const ys  = tables.map(t => t.y);
  const minX = Math.min(...xs) - PADDING;
  const minY = Math.min(...ys) - PADDING;
  const W   = Math.max(...xs) + BOX.W + PADDING - minX;
  const H   = Math.max(...ys) + BOX.H + PADDING - minY;

  const canvas = createCanvas(Math.ceil(W), Math.ceil(H));
  const ctx    = canvas.getContext('2d');

  // Background
  ctx.fillStyle = STYLE.bg;
  ctx.fillRect(0, 0, W, H);

  // Translate so minX/minY maps to PADDING
  ctx.translate(-minX, -minY);

  // Draw edges first (behind tables)
  refs.forEach((r, i) => {
    const pts = routeEdge(portPairs[i], tables, r.from, r.to);
    drawEdge(ctx, pts);
  });

  // Draw tables
  tables.forEach(t => drawTable(ctx, t));

  // Write PNG
  const buf = canvas.toBuffer('image/png');
  fs.writeFileSync(outputPath, buf);
  console.error(`OK: ${tables.length} tables, ${refs.length} refs → ${outputPath}`);
}

// ─── Entry point ──────────────────────────────────────────────────────────────
const [,, inputFile, outputFile] = process.argv;
if (!inputFile || !outputFile) {
  console.error('Usage: node render_dbml_diagram.js <input.dbml> <output.png>');
  process.exit(1);
}

const src = fs.readFileSync(inputFile, 'utf8');
renderToPNG(src, outputFile);
