// Drive the existing terminal view. run() queues app commands, so a batch must
// yield before reading the selection published by the native view.
export class NativeSelection {
  constructor(host) {
    this.host = host;
    this.active = false;
    this.mode = null;
    this.anchor = null;
  }

  async batch(commands, cx) {
    if (!this.active) throw new Error("Copy mode ended");
    for (const [name, args = {}] of commands) this.host.run(name, { terminal: this.terminal, ...args });
    await cx.sleep(1);
    if (!this.active) throw new Error("Copy mode ended");
  }

  selection() { return this.host.selection(this.terminal); }

  viewport() {
    const view = this.host.viewport?.() ?? {};
    const len = Math.max(1, view.len ?? this.host.page());
    const total = Math.max(len, view.total ?? (this.cursor?.row ?? 0) + 1);
    return { offset: Math.max(0, Math.min(view.offset ?? 0, total - len)), len, total, cols: view.cols };
  }

  rowMoves(from, to) {
    const rows = to - from, page = this.viewport().len;
    const direction = rows < 0 ? "up" : "down";
    const commands = [];
    for (let i = 0; i < Math.floor(Math.abs(rows) / page); i++) commands.push(["terminal.adjust_selection", { direction: "page_" + direction }]);
    for (let i = 0; i < Math.abs(rows) % page; i++) commands.push(["terminal.adjust_selection", { direction }]);
    return commands;
  }

  async enter(terminal, cx) {
    this.terminal = terminal;
    this.active = true;
    this.mode = null;
    this.anchor = null;
    await this.batch([["terminal.select", { at: "cursor" }]], cx);
    const selected = this.selection();
    if (!selected) throw new Error("This terminal has no attached selection view");
    this.cursor = { ...selected.end };
    this.cols = this.viewport().cols;
    if (!this.cols) {
      await this.batch([["terminal.adjust_selection", { direction: "line_end" }]], cx);
      this.cols = this.selection().end.col + 1;
    }
    await this.paint(cx);
  }

  async move(direction, cx) {
    const view = this.viewport();
    const delta = { up: -1, down: 1, page_up: -view.len, page_down: view.len }[direction];
    if (delta !== undefined && this.mode !== "character") {
      // Moving a lone cursor must not first display a range to its old cell.
      return this.go({ row: Math.max(0, Math.min(view.total - 1, this.cursor.row + delta)), col: this.cursor.col }, cx);
    }
    // Line selection paints whole rows, but navigation keeps its own cell cursor.
    if (this.mode === "line") await this.batch([["terminal.select", { at: this.cursor }]], cx);
    await this.batch([["terminal.adjust_selection", { direction }]], cx);
    this.cursor = { ...this.selection().end };
    if (this.mode !== "character") await this.paint(cx);
  }

  async screen(position, cx) {
    const view = this.viewport();
    const top = view.offset, bottom = Math.min(view.total - 1, top + view.len - 1);
    const row = position === "H" ? top : position === "M" ? top + Math.floor((bottom - top) / 2) : bottom;
    return this.go({ row, col: 0 }, cx);
  }

  async select(mode, cx) {
    if (this.mode === mode) { this.mode = null; this.anchor = null; }
    else { this.anchor ??= { ...this.cursor }; this.mode = mode; }
    await this.paint(cx);
  }

  async endpoint(target, cx) {
    let current = this.selection().end;
    const commands = this.rowMoves(current.row, target.row);
    if (commands.length) await this.batch(commands, cx);
    current = this.selection().end;
    // Read the actual result: a page's native size can change when resized.
    if (current.row !== target.row) {
      const corrections = [];
      for (let i = 0; i < Math.abs(target.row - current.row); i++) corrections.push(["terminal.adjust_selection", { direction: target.row < current.row ? "up" : "down" }]);
      await this.batch(corrections, cx);
      current = this.selection().end;
    }
    const direct = Math.abs(target.col - current.col);
    if (target.col + 1 < direct) {
      await this.batch([["terminal.adjust_selection", { direction: "line_start" }]], cx);
      current = this.selection().end;
    } else if (this.cols - target.col < direct) {
      await this.batch([["terminal.adjust_selection", { direction: "line_end" }]], cx);
      current = this.selection().end;
    }
    // Native left/right skip wide glyphs. Count actual cells after each move
    // instead of assuming one keypress always advances one column.
    for (let i = 0; current.col !== target.col && i < this.cols; i++) {
      await this.batch([["terminal.adjust_selection", { direction: target.col < current.col ? "left" : "right" }]], cx);
      const next = this.selection().end;
      if (next.row !== target.row || next.col === current.col) break;
      current = next;
    }
  }

  async paint(cx) {
    const same = (a, b) => a?.row === b.row && a.col === b.col;
    const selected = this.selection();
    if (!this.mode) {
      const commands = [];
      if (!same(selected?.start, this.cursor) || !same(selected?.end, this.cursor)) commands.push(["terminal.select", { at: this.cursor }]);
      const view = this.viewport();
      const lines = this.cursor.row < view.offset ? this.cursor.row - view.offset
        : this.cursor.row >= view.offset + view.len ? this.cursor.row - (view.offset + view.len - 1) : 0;
      // Scroll only at a viewport edge. Reversible cursor steps briefly move
      // the viewport at column zero and were the source of navigation flicker.
      if (lines) commands.push(["terminal.scroll", { lines }]);
      if (commands.length) await this.batch(commands, cx);
      return;
    }
    let start = this.anchor;
    let end = this.cursor;
    if (this.mode === "line") {
      const forward = this.cursor.row >= this.anchor.row;
      start = { row: this.anchor.row, col: forward ? 0 : this.cols - 1 };
      end = { row: this.cursor.row, col: forward ? this.cols - 1 : 0 };
      const commands = [];
      let from = selected?.end;
      if (!same(selected?.start, start)) {
        commands.push(["terminal.select", { at: start }]);
        from = start;
      }
      commands.push(...this.rowMoves(from.row, end.row));
      if (from.col !== end.col) commands.push(["terminal.adjust_selection", { direction: end.col === 0 ? "line_start" : "line_end" }]);
      // Publish the complete line range together, without yielding on a
      // temporary single-cell anchor between navigation frames.
      if (commands.length) await this.batch(commands, cx);
      if (!same(this.selection()?.end, end)) await this.endpoint(end, cx);
      return;
    }
    await this.batch([["terminal.select", { at: start }]], cx);
    await this.endpoint(end, cx);
  }

  async go(point, cx) {
    if (!point) return;
    const view = this.viewport();
    this.cols = view.cols ?? this.cols;
    this.cursor = { row: Math.max(0, Math.min(view.total - 1, point.row)), col: Math.max(0, Math.min(this.cols - 1, point.col)) };
    if (this.mode === "character") await this.endpoint(this.cursor, cx);
    else await this.paint(cx);
  }

  async lastCell(cx) {
    await this.batch([["terminal.select", { at: this.cursor }], ["terminal.adjust_selection", { direction: "end" }]], cx);
    const last = { ...this.selection().end };
    await this.paint(cx);
    return last;
  }

  copy() {
    if (!this.mode || !this.selection()) return false;
    // App command preserves selection, unlike the terminal's normal Copy key.
    this.host.run("terminal.copy");
    return true;
  }

  exit(refocus = true) {
    if (!this.active) return;
    this.active = false;
    this.host.run("terminal.clear_selection", { terminal: this.terminal });
    if (refocus) this.host.focus();
    this.mode = null;
    this.anchor = null;
  }
}
