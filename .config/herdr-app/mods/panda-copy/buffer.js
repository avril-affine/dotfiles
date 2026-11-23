// Code-point columns keep cursor motion and inclusive selections from splitting
// surrogate pairs. Regex offsets are translated from JavaScript's UTF-16 indexes.
export class CopyBuffer {
  constructor(text) {
    this.text = text.replace(/\r\n/g, "\n").replace(/\r/g, "");
    this.lines = this.text.split("\n").map(line => Array.from(line));
    this.starts = [];
    this.offsets = [];
    this.chars = Array.from(this.text);
    let cp = 0, utf16 = 0;
    for (const line of this.lines) {
      this.starts.push(cp);
      this.offsets.push(utf16);
      cp += line.length + 1;
      utf16 += line.join("").length + 1;
    }
    this.cursor = { row: this.lines.length - 1, col: 0 };
    this.anchor = null;
    this.mode = null;
    this.pattern = null;
    this.matches = [];
    this.direction = 1;
  }

  go(row, col = this.cursor.col) {
    row = Math.max(0, Math.min(this.lines.length - 1, row));
    col = Math.max(0, Math.min(Math.max(0, this.lines[row].length - 1), col));
    this.cursor = { row, col };
  }

  move(key, page = 20) {
    const { row, col } = this.cursor;
    if (key === "h") this.go(row, col - 1);
    if (key === "l") this.go(row, col + 1);
    if (key === "j") this.go(row + 1);
    if (key === "k") this.go(row - 1);
    if (key === "0") this.go(row, 0);
    if (key === "$") this.go(row, this.lines[row].length - 1);
    if (key === "gg") this.go(0, 0);
    if (key === "G") this.go(this.lines.length - 1, 0);
    // These directions are intentional: the user's requested Ctrl+D / Ctrl+U.
    if (key === "ctrl-d") this.go(row - page);
    if (key === "ctrl-u") this.go(row + page);
    if (key === "b" || key === "w") this.word(key === "w" ? 1 : -1);
    if (key === "{" || key === "}") this.paragraph(key === "}" ? 1 : -1);
  }

  word(direction) {
    let pos = this.starts[this.cursor.row] + this.cursor.col;
    const kind = ch => ch === undefined || /\s/u.test(ch) ? 0 : /[\p{L}\p{N}_]/u.test(ch) ? 1 : 2;
    if (direction > 0) {
      const current = kind(this.chars[pos]);
      while (pos < this.chars.length && kind(this.chars[pos]) === current) pos++;
      while (pos < this.chars.length && kind(this.chars[pos]) === 0) pos++;
    } else {
      pos = Math.max(0, pos - 1);
      while (pos > 0 && kind(this.chars[pos]) === 0) pos--;
      const current = kind(this.chars[pos]);
      while (pos > 0 && kind(this.chars[pos - 1]) === current) pos--;
    }
    this.atCodePoint(Math.min(pos, this.chars.length));
  }

  paragraph(direction) {
    let row = this.cursor.row;
    const blank = i => !this.lines[i].join("").trim();
    if (blank(row)) {
      while (row + direction >= 0 && row + direction < this.lines.length && blank(row + direction)) row += direction;
    }
    row += direction;
    while (row > 0 && row < this.lines.length - 1 && !blank(row)) row += direction;
    this.go(row, 0);
  }

  atCodePoint(pos) {
    let row = this.starts.length - 1;
    while (row > 0 && this.starts[row] > pos) row--;
    this.go(row, pos - this.starts[row]);
  }

  atOffset(offset) {
    let row = this.offsets.length - 1;
    while (row > 0 && this.offsets[row] > offset) row--;
    this.go(row, Array.from(this.lines[row].join("").slice(0, offset - this.offsets[row])).length);
  }

  offset() {
    return this.offsets[this.cursor.row] + this.lines[this.cursor.row].slice(0, this.cursor.col).join("").length;
  }

  select(mode) {
    if (this.mode === mode) { this.mode = null; this.anchor = null; }
    else { this.anchor ??= { ...this.cursor }; this.mode = mode; }
  }

  range() {
    if (!this.anchor) return null;
    const a = this.anchor, b = this.cursor;
    return a.row < b.row || (a.row === b.row && a.col <= b.col) ? [a, b] : [b, a];
  }

  columns(row) {
    const range = this.range();
    if (!range || row < range[0].row || row > range[1].row) return null;
    const [a, b] = range;
    return [this.mode === "line" || row > a.row ? 0 : a.col,
      this.mode === "line" || row < b.row ? this.lines[row].length : b.col + 1];
  }

  selectedText() {
    const range = this.range();
    if (!range) return null;
    const [a, b] = range;
    const rows = [];
    for (let row = a.row; row <= b.row; row++) {
      const [start, end] = this.columns(row);
      rows.push(this.lines[row].slice(start, end).join(""));
    }
    return rows.join("\n") + (this.mode === "line" ? "\n" : "");
  }

  search(pattern, direction) {
    if (pattern !== this.pattern) {
      // Build before replacing the previous search, so an invalid regex leaves
      // n/N usable with the last successful pattern.
      const regex = new RegExp(pattern, "gmu"), matches = [];
      let match;
      while ((match = regex.exec(this.text)) !== null) {
        matches.push(match.index);
        if (match[0] === "") regex.lastIndex += this.text.codePointAt(regex.lastIndex) > 0xffff ? 2 : 1;
      }
      this.pattern = pattern;
      this.matches = matches;
    }
    this.direction = direction;
    return this.repeat(false);
  }

  repeat(opposite) {
    if (!this.matches.length) return false;
    const direction = this.direction * (opposite ? -1 : 1), from = this.offset();
    const match = direction > 0
      ? this.matches.find(pos => pos > from) ?? this.matches[0]
      : this.matches.slice().reverse().find(pos => pos < from) ?? this.matches[this.matches.length - 1];
    this.atOffset(match);
    return true;
  }
}
