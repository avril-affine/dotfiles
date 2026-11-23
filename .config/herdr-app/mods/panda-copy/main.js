// A pane's header, for layouts that frame their panes:
//   { "tab": "active", "pane": { "header": { "content": { "mod": "pane" } } } }
// Shows the program's icon (the app's program table), the agent's name or
// the terminal's title, the folder, and the agent's status; buttons split, zoom and close
// this pane. Props from the app: { pane, terminal }. Click: focus the pane.

import { View, div, svg, image } from "gpui-kit";
import { h_flex, InputState, Input } from "gpui-base";
import { panes, props, run, theme, home, layout, focused, terminals, nextCommand, hc, checking } from "herdr";
import { NativeSelection } from "./selection.js";
import { TerminalText } from "./grid.js";

// Match the first visible tab frame, including the active child of a stack.
function paneFrame(node) {
  if (!node || node.hidden) return null;
  if (node.content?.tab && node.content.pane) return node.content.pane;
  let children = node.children ?? [];
  if (node.type === "stack") {
    const visible = children.filter(child => !child.hidden);
    children = [visible.find(child => child.id === node.active) ?? visible[0]];
  }
  for (const child of children) {
    const frame = paneFrame(child);
    if (frame) return frame;
  }
  return null;
}

function icon(p, size, color) {
  if (!p?.icon) return null;
  return p.tint ? svg(p.icon).size(size).flex_none().text_color(color) : image(p.icon).w(size).h(size).flex_none();
}

function folder(cwd) {
  if (!cwd) return "";
  const h = home();
  return cwd === h ? "~" : cwd.startsWith(h + "/") ? "~" + cwd.slice(h.length) : cwd;
}

export default class Pane extends View {
  init(_props, cx) {
    this.hovered = false;
    this.handle = cx.focus_handle();
    this.input = InputState.new({ placeholder: "Regex · Enter to search" });
    this.input.on("submit", (_e, cx) => this.enqueue("search", cx));
    this.jobs = [];
    this.copy = new NativeSelection({
      run,
      selection: address => terminals().find(t => t.address === address)?.selection ?? null,
      page: () => this.me()?.scroll?.len ?? terminals().find(t => t.address === this.copy.terminal)?.rows ?? 20,
      viewport: () => {
        const scroll = this.me()?.scroll;
        const terminal = terminals().find(t => t.address === this.copy.terminal);
        const len = scroll?.len ?? terminal?.rows ?? 20;
        return { offset: scroll?.offset ?? 0, len, total: scroll?.total ?? len, cols: terminal?.cols };
      },
      focus: () => run("pane.focus", { pane: props().pane }),
    });
    if (checking()) return;
    cx.spawn(async cx => {
      for (;;) {
        const command = await nextCommand();
        if (command === "enter" && focused()?.pane === props().pane) {
          if (this.copy.active) this.stop(cx);
          else {
            this.handle.focus();
            this.enqueue("enter", cx);
          }
        } else if (this.copy.active) {
          const keys = { left: "h", down: "j", up: "k", right: "l", visual: "v", line: "V", first: "gg", last: "G", "screen-top": "H", "screen-middle": "M", "screen-bottom": "L", "page-up": "ctrl-d", "page-down": "ctrl-u", "word-next": "w", "word-prev": "b", "paragraph-next": "}", "paragraph-prev": "{", copy: "y" };
          if (command === "exit") this.stop(cx);
          else if (keys[command]) this.enqueue(keys[command], cx);
        }
        cx.notify();
      }
    });
  }

  stop(cx, refocus = true) {
    this.jobs = [];
    this.searching = false;
    this.copy.exit(refocus);
    cx.notify();
  }

  enqueue(key, cx) {
    this.jobs.push(key);
    if (this.running) return;
    this.running = true;
    cx.spawn(async cx => {
      try {
        while (this.jobs.length) {
          const key = this.jobs.shift();
          try { await this.command(key, cx); }
          catch (error) {
            if (this.copy.active) this.message = String(error.message ?? error);
            else if (key === "enter") this.message = "Cannot enter copy mode";
          }
          cx.notify();
        }
      } finally { this.running = false; }
    });
  }

  key(e, cx) {
    if (!this.copy.active) return;
    const key = e.key_char || (e.modifiers.shift && e.key.length === 1 ? e.key.toUpperCase() : e.key);
    if (e.key === "escape" || e.keystroke === "ctrl-c" || (!this.searching && key === "q")) {
      cx.stop_propagation();
      this.stop(cx);
      return;
    }
    if (this.searching) return;
    cx.stop_propagation();
    if (key === "/" || key === "?") {
      this.pendingG = false;
      this.searchDirection = key === "/" ? 1 : -1;
      this.searching = true;
      this.input.set_value("");
      this.input.focus();
      cx.notify();
      return;
    }
    const motion = key === "g" && this.pendingG ? "gg" : e.keystroke === "ctrl-d" || e.keystroke === "ctrl-u" ? e.keystroke : e.key === "enter" ? "y" : key;
    this.pendingG = key === "g" && !this.pendingG;
    this.enqueue(motion, cx);
  }

  async index(cx) {
    const p = this.me();
    // Never ask hc to stitch an alternate-screen app by scrolling it. --lines 0
    // reads its displayed screen without sending any input to the program.
    const lines = p?.scroll ? String(Math.min(100000, p.scroll.total)) : "0";
    const result = await hc(["read", this.copy.terminal, "--json", "--lines", lines]);
    if (result.code !== 0) throw new Error(result.stderr || result.stdout);
    if (!this.copy.active) throw new Error("Copy mode ended");
    const text = JSON.parse(result.stdout).text;
    const last = await this.copy.lastCell(cx);
    return new TerminalText(text, this.copy.cols, last);
  }

  async command(key, cx) {
    this.message = "";
    if (key === "enter") {
      const f = focused();
      if (f?.pane !== props().pane || !f.terminal) return;
      await this.copy.enter(f.terminal, cx);
      return;
    }
    if (!this.copy.active) return;
    if (["H", "M", "L"].includes(key)) return this.copy.screen(key, cx);
    if (key === "v" || key === "V") return this.copy.select(key === "V" ? "line" : "character", cx);
    if (key === "y") { this.message = this.copy.copy() ? "Copied · selection kept" : "Press v or V to select"; return; }
    const direction = { h: "left", j: "down", k: "up", l: "right", "0": "line_start", "$": "line_end", gg: "home", G: "end", "ctrl-d": "page_up", "ctrl-u": "page_down" }[key];
    if (direction) return this.copy.move(direction, cx);
    if (!["b", "w", "{", "}", "search", "n", "N"].includes(key)) return;
    if (key === "search") {
      const pattern = this.input.value() || this.pattern;
      if (!pattern) return;
      new RegExp(pattern, "gmu");
      this.pattern = pattern;
      this.direction = this.searchDirection;
    }
    if (["n", "N"].includes(key) && !this.pattern) { this.message = "Search with / or ? first"; return; }
    const index = await this.index(cx);
    index.at(this.copy.cursor);
    if (["b", "w", "{", "}"].includes(key)) {
      index.buffer.move(key);
    } else {
      const direction = (this.direction ?? 1) * (key === "N" ? -1 : 1);
      if (!index.buffer.search(this.pattern, direction)) { this.message = "No matches"; }
      else await this.copy.go(index.point(), cx);
      if (key === "search") { this.searching = false; this.handle.focus(); }
      return;
    }
    await this.copy.go(index.point(), cx);
  }

  close() { this.copy?.exit(false); }

  me() {
    return panes().find((p) => p.pane === props()?.pane);
  }

  button(t, id, icon, command, args) {
    return div()
      .id(id)
      .p(3)
      .rounded(4)
      .text_color(t.dim)
      .hover((s) => s.bg(t.hover).text_color(t.foreground))
      .on_click((_e, cx) => {
        cx.stop_propagation();
        run(command, args);
      })
      .child(svg(`mods/pane/${icon}.svg`).size(14));
  }

  render(cx) {
    const t = theme();
    const p = this.me();
    const active = this.copy.active;
    if (active && (focused()?.pane !== props().pane || (!this.searching && !this.handle.is_focused()))) {
      // Clicking another pane or returning to terminal input ends copy mode.
      this.copy.exit(false);
      this.jobs = [];
      this.searching = false;
    }
    if (!p) return div();
    const name = ((p.program?.agent || p.program?.shell) && p.program.name) || p.title || p.program?.name || "shell";
    const pic = icon(p.program, 14, t.dim);
    const st = p.status;
    const pane = p.pane;
    const bottom = paneFrame(layout())?.header?.position === "bottom";
    return h_flex()
      .id(`pane-head-${pane}`)
      .size_full()
      .px(10)
      .gap(8)
      .items_center()
      .track_focus(this.handle).on_key_down((e, cx) => this.key(e, cx))
      .bg(t.background)
      .when(bottom, el => el.border_t(1))
      .when(!bottom, el => el.border_b(1))
      .border_color(t.border)
      .text_size(12)
      .on_hover((hovered, cx) => { this.hovered = hovered; cx.notify(); })
      .on_click((_e, cx) => { if (this.copy.active) this.stop(cx); else run("pane.focus", { pane }); })
      .when(Boolean(pic), (el) => el.child(pic))
      .child(div().flex_none().truncate().max_w(260).font_medium().text_color(t.foreground).child(name))
      .when(!this.copy.active, el => el.child(div().flex_1().truncate().text_color(t.dim).child(folder(p.cwd))))
      .when(this.copy.active, el => el
        .child(div().flex_none().px(6).py(1).rounded(4).bg(t.selected).text_color(t.accent).font_semibold()
          .child(this.copy.mode === "line" ? "COPY · LINE" : this.copy.mode ? "COPY · VISUAL" : "COPY"))
        .when(this.searching, el => el
          .child(div().text_color(t.accent).child(this.searchDirection === 1 ? "/" : "?"))
          .child(Input.new(this.input).flex_1().h(24).px(6).rounded(4).border_1().border_color(t.accent).text_size(12).text_color(t.foreground)))
        .when(!this.searching, el => el.child(div().flex_1().truncate().text_color(t.muted)
          .child(this.message || "hjkl · H/M/L screen · v/V select · /? search · y/Enter copy · Esc/q exit")))
        .child(div().id(`copy-exit-${pane}`).px(6).text_color(t.dim).cursor_pointer()
          .on_click((_e, cx) => { cx.stop_propagation(); this.stop(cx); }).child("Esc")))
      .when(st === "working", el => el.child(svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900)))
      .when(st === "blocked", el => el.child(div().flex_none().px(6).h(18).flex().items_center().rounded(5).bg(t.blocked + "26").text_size(10.5).font_semibold().text_color(t.blocked).child("Needs you")))
      .when(st === "done", el => el.child(div().size(7).flex_none().rounded(4).bg(t.done)))
      .when(this.hovered, el => el
        .child(this.button(t, `ph-r-${pane}`, "split-right", "pane.split", { direction: "right", pane }))
        .child(this.button(t, `ph-d-${pane}`, "split-down", "pane.split", { direction: "down", pane }))
        .child(this.button(t, `ph-z-${pane}`, p.zoomed ? "unzoom" : "zoom", "pane.zoom", { pane }))
        .child(this.button(t, `ph-x-${pane}`, "close", "pane.close", { pane })));
  }
}
