import { CopyBuffer } from "./buffer.js";

const mark = char => /\p{M}/u.test(char) || /[\uFE00-\uFE0F\u{1F3FB}-\u{1F3FF}]/u.test(char);
const regional = char => { const n = char.codePointAt(0); return n >= 0x1f1e6 && n <= 0x1f1ff; };

function clusters(chars) {
  const out = [];
  for (let i = 0; i < chars.length;) {
    const start = i++;
    if (regional(chars[start]) && i < chars.length && regional(chars[i])) i++;
    while (i < chars.length) {
      if (mark(chars[i])) i++;
      else if (chars[i] === "\u200D" && i + 1 < chars.length) i += 2;
      else break;
    }
    out.push([start, i]);
  }
  return out;
}

function width(chars) {
  const n = chars[0].codePointAt(0);
  if (mark(chars[0])) return 0;
  if (chars.includes("\uFE0F") || chars.includes("\u20E3") || regional(chars[0])) return 2;
  return n >= 0x1100 && (n <= 0x115f || n === 0x2329 || n === 0x232a ||
    (n >= 0x2e80 && n <= 0xa4cf && n !== 0x303f) || (n >= 0xac00 && n <= 0xd7a3) ||
    (n >= 0xf900 && n <= 0xfaff) || (n >= 0xfe10 && n <= 0xfe19) ||
    (n >= 0xfe30 && n <= 0xfe6f) || (n >= 0xff00 && n <= 0xff60) ||
    (n >= 0xffe0 && n <= 0xffe6) || (n >= 0x1f300 && n <= 0x1faff) ||
    (n >= 0x20000 && n <= 0x3fffd)) ? 2 : 1;
}

// hc's plain text joins soft wraps. Reconstruct cell coordinates for text-only
// motions, while the native terminal remains the source of cursor and selection.
export class TerminalText {
  constructor(text, cols, last) {
    this.cols = cols;
    this.buffer = new CopyBuffer(text);
    this.points = [];
    this.ends = [];
    let row = 0;
    for (const chars of this.buffer.lines) {
      let col = 0;
      const points = [];
      for (const [start, end] of clusters(chars)) {
        const cells = width(chars.slice(start, end));
        if (col >= cols || col + cells > cols) { row++; col = 0; }
        for (let i = start; i < end; i++) points.push({ row, col });
        col += cells;
      }
      points.push({ row, col: Math.min(col, cols - 1) });
      this.points.push(points);
      this.ends.push(row);
      row++;
    }
    this.base = last ? last.row - (row - 1) : 0;
  }

  at(point) {
    let logical = 0, col = 0;
    const row = point.row - this.base;
    for (let i = 0; i < this.points.length; i++) {
      if (this.points[i][0].row > row) break;
      logical = i;
    }
    for (let i = 0; i < this.points[logical].length; i++) {
      const cell = this.points[logical][i];
      const previous = this.points[logical][i - 1];
      if (previous?.row === cell.row && previous.col === cell.col) continue;
      if (cell.row < row || (cell.row === row && cell.col <= point.col)) col = i;
      else break;
    }
    // Keep an end-of-line cursor for blank terminal cells; b/w then handle the
    // newline as whitespace rather than moving from inside the preceding word.
    this.buffer.cursor = { row: logical, col };
  }

  point() {
    const { row, col } = this.buffer.cursor;
    const p = this.points[row][Math.min(col, this.points[row].length - 1)];
    return p.row + this.base < 0 ? null : { row: p.row + this.base, col: p.col };
  }
}
