import test from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, writeFileSync, readFileSync, existsSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { spawnSync } from "node:child_process";
import { runInNewContext } from "node:vm";
import { CopyBuffer } from "../.config/herdr-app/mods/panda-copy/buffer.js";
import { NativeSelection } from "../.config/herdr-app/mods/panda-copy/selection.js";
import { TerminalText } from "../.config/herdr-app/mods/panda-copy/grid.js";
import { EDITOR_SCRIPT, editorArgv } from "../.config/herdr-app/mods/panda-changes/editor.js";
import { recentUrls, readArgs, LOOKBACK_LINES, MAX_URLS } from "../.config/herdr-app/mods/panda-shortcuts/urls.js";
import { markUnread } from "../.config/herdr-app/mods/panda-agents/unread.js";

// Exercise event handlers with their host boundaries stubbed; native rendering
// is checked separately by herdr-app check and in the running window.
function loadView(name, exports) {
  const source = readFileSync(new URL(`../.config/herdr-app/mods/${name}/main.js`, import.meta.url), "utf8")
    .replace(/^import .*;\n/gm, "").replace(/export function /g, "function ")
    .replace(/export default class (\w+)/, "class $1");
  const className = /class (\w+) extends View/.exec(source)[1];
  return runInNewContext(source + `\n${className};`, { View: class {}, ...exports });
}

function sidebarFixture({ status = "idle", turn = 7, reply } = {}) {
  const calls = [], commands = [], notices = [], jobs = [], nodes = new Map();
  const element = () => {
    const node = { parent: null, click: null };
    const result = new Proxy({}, { get(_object, key) {
      if (key === "node") return node;
      if (key === "id") return id => { nodes.set(id, node); return result; };
      if (key === "when") return (on, apply) => on ? apply(result) : result;
      if (key === "on_click") return handler => { node.click = handler; return result; };
      if (key === "child") return child => { if (child?.node) child.node.parent = node; return result; };
      if (key === "children") return children => { for (const child of children) if (child?.node) child.node.parent = node; return result; };
      return () => result;
    } });
    return result;
  };
  const list = [
    { address: "remote/t7", pane: "clicked-pane", tab: "clicked-tab", space: "space", space_name: "Project", status, seq: 1, program: { agent: true, name: "Codex", key: "codex" } },
    { address: "t8", pane: "focused-pane", tab: "other-tab", space: "space", space_name: "Project", status: "idle", seq: 2, focused: true, program: { agent: true, name: "Codex", key: "codex" } },
  ];
  const Agents = loadView("panda-agents", {
    div: element, h_flex: element, v_flex: element, svg: element, image: element,
    markUnread, checking: () => false, props: () => ({}), agents: () => list,
    panes: () => list.map(a => ({ ...a, terminal: a.address })),
    terminals: () => list.map(a => ({ ...a, state: "live" })),
    spaces: () => [{ id: "space", tabs: list.map(a => ({ id: a.tab, name: "Agent" })) }],
    focused: () => ({ agent: "t8", pane: "focused-pane" }),
    layout: () => ({ id: "sidebar", size: { px: 268 } }),
    shared: () => null, setAgentOrder() {},
    theme: () => ({ dim: "#777777", idle: "#888888", done: "#96b2d7" }),
    localStorage: { getItem: () => null, setItem() {}, removeItem() {} },
    hc: async args => {
      calls.push(Array.from(args));
      return reply ? reply(args) : { code: 0, stdout: JSON.stringify({ turn }), stderr: "" };
    },
    run: (name, args) => commands.push([name, structuredClone(args)]), notify: value => notices.push(structuredClone(value)),
  });
  const cx = {
    notify() {}, timer: { every() {} },
    spawn: fn => { const job = fn(cx); jobs.push(job); return job; },
  };
  const view = new Agents();
  view.init({}, cx);
  view.hovered = "remote/t7";
  view.render(cx);
  const click = id => {
    let node = nodes.get(id), stopped = false;
    assert.ok(node, `Missing sidebar control ${id}`);
    const clickCx = { ...cx, stop_propagation: () => { stopped = true; } };
    while (node) {
      node.click?.({}, clickCx);
      if (stopped) break;
      node = node.parent;
    }
  };
  return { view, calls, commands, notices, click, flush: () => Promise.all(jobs.splice(0)) };
}

test("clicking a sidebar status dot marks only that agent unread without opening its pane", async () => {
  for (const status of ["idle", "done"]) {
    const f = sidebarFixture({ status, turn: 12 });
    f.click("agent-unread-remote/t7");
    f.click("agent-unread-remote/t7"); // Ignore duplicate clicks while the write is pending.
    await f.flush();
    assert.deepEqual(f.calls, [["get", "remote/t7", "--json"], ["label", "remote/t7", "herdr.seen=11"]]);
    assert.deepEqual(f.commands, [], "the dot click must not bubble into pane focus or pinning");
    assert.equal(f.view.markingUnread.size, 0);
    assert.deepEqual(f.notices, []);
  }
});

test("sidebar row and pin clicks keep their own actions", () => {
  const f = sidebarFixture();
  f.click("ag-remote/t7");
  f.click("pin-remote/t7");
  assert.deepEqual(f.commands, [["pane.focus", { pane: "clicked-pane" }], ["terminal.pin", { terminal: "remote/t7", pinned: true }]]);
  assert.deepEqual(f.calls, []);
});

test("sidebar unread failures show an error without opening the agent", async () => {
  const f = sidebarFixture({
    reply: args => args[0] === "get" ? { code: 0, stdout: '{"turn":3}' } : { code: 1, stderr: "Machine disconnected" },
  });
  f.click("agent-unread-remote/t7");
  await f.flush();
  assert.equal(f.notices[0].body, "Machine disconnected");
  assert.equal(f.view.markingUnread.size, 0);
  assert.deepEqual(f.commands, []);
});

test("an agent with no finished turn is not assigned an invalid unread label", async () => {
  const f = sidebarFixture({ turn: 0 });
  f.click("agent-unread-remote/t7");
  await f.flush();
  assert.deepEqual(f.calls, [["get", "remote/t7", "--json"]]);
  assert.equal(f.notices[0].title, "Nothing to mark unread");
});

test("recent URLs are newest first and deduplicated by normalized address", () => {
  assert.deepEqual(recentUrls("https://example.com/older\nhttps://example.com/newer\nHTTPS://EXAMPLE.COM/older"),
    ["HTTPS://EXAMPLE.COM/older", "https://example.com/newer"]);
  assert.deepEqual(recentUrls("http://localhost:3000/a https://example.com/b"),
    ["https://example.com/b", "http://localhost:3000/a"]);
});

test("URL extraction trims prose and Markdown wrappers while preserving balanced URL punctuation", () => {
  assert.deepEqual(recentUrls("[docs](https://example.com/docs). See https://example.com/Foo_(bar). `http://[::1]:3000/a?q=1#x`"),
    ["http://[::1]:3000/a?q=1#x", "https://example.com/Foo_(bar)", "https://example.com/docs"]);
  assert.deepEqual(recentUrls("ftp://example.com javascript:alert(1) https://[invalid"), []);
});

test("URL collection and terminal lookback remain bounded without scrolling alternate-screen programs", () => {
  const urls = recentUrls(Array.from({ length: 500 }, (_, i) => `https://example.com/${i}`).join("\n"));
  assert.equal(urls.length, MAX_URLS);
  assert.equal(urls[0], "https://example.com/499");
  assert.equal(urls.at(-1), "https://example.com/400");
  assert.deepEqual(readArgs("remote/t7", { total: 1000000, len: 40 }), ["read", "remote/t7", "--json", "--lines", String(LOOKBACK_LINES)]);
  assert.deepEqual(readArgs("t1", { total: 60, len: 40 }), ["read", "t1", "--json", "--lines", "20"]);
  assert.deepEqual(readArgs("t1", null), ["read", "t1", "--json", "--lines", "0"]);
});

async function urlShortcut(command, { text = "https://example.com/older\nhttps://example.com/newer", code = 0 } = {}) {
  const opened = [], overlays = [], notices = [], reads = [];
  let delivered = false, focus = { pane: "source-pane", terminal: "remote/t7" };
  let complete, fail;
  const done = new Promise((resolve, reject) => { complete = resolve; fail = reject; });
  const Shortcuts = loadView("panda-shortcuts", {
    recentUrls, readArgs, LOOKBACK_LINES, MAX_URLS, checking: () => false,
    nextCommand: () => {
      if (delivered) return new Promise(() => {});
      delivered = true; return Promise.resolve(command);
    },
    focused: () => focus,
    panes: () => [{ pane: "source-pane", terminal: "remote/t7", scroll: { total: 10000, len: 40 } }],
    hc: async args => {
      reads.push(Array.from(args));
      focus = { pane: "other-pane", terminal: "t9" }; // Focus may change while reading.
      return { code, stdout: JSON.stringify({ text }), stderr: code ? "Cannot reach machine" : "" };
    },
    openOverlay: value => overlays.push(structuredClone(value)), notify: value => notices.push(structuredClone(value)),
  });
  const cx = { notify: () => complete(), open_url: url => opened.push(url), spawn: fn => fn(cx).catch(fail) };
  new Shortcuts().init({}, cx);
  await done;
  return { opened, overlays, notices, reads };
}

test("prefix+u opens a URL window for the original terminal with latest URLs first", async () => {
  const f = await urlShortcut("urls");
  assert.deepEqual(f.opened, []);
  assert.equal(f.overlays[0].mod, "panda-urls");
  assert.equal(f.overlays[0].kind, "window");
  assert.equal(f.overlays[0].props.terminal, "remote/t7");
  assert.deepEqual(f.overlays[0].props.urls, ["https://example.com/newer", "https://example.com/older"]);
  assert.deepEqual(f.reads, [["read", "remote/t7", "--json", "--lines", "2000"]]);
});

test("prefix+U opens only the newest URL and never opens a floating window", async () => {
  const f = await urlShortcut("url-last");
  assert.deepEqual(f.opened, ["https://example.com/newer"]);
  assert.deepEqual(f.overlays, []);
  assert.deepEqual(f.notices, []);
});

test("the direct URL shortcut reports missing URLs or read errors without opening anything", async () => {
  for (const options of [{ text: "No links here" }, { code: 1 }]) {
    const f = await urlShortcut("url-last", options);
    assert.deepEqual(f.opened, []);
    assert.deepEqual(f.overlays, []);
    assert.equal(f.notices.length, 1);
  }
});

test("the floating URL list opens the keyboard-selected URL and Escape closes without opening", () => {
  for (const cancel of [false, true]) {
    const opened = [], closed = [];
    const Urls = loadView("panda-urls", {
      props: () => ({ overlay: "url-window", urls: ["https://example.com/new", "https://example.com/old"] }),
      closeOverlay: id => closed.push(id), ScrollHandle: { new: () => ({ scroll_to_item() {} }) },
    });
    const cx = { focus_handle: () => ({ focus() {} }), open_url: url => opened.push(url), notify() {}, stop_propagation() {} };
    const view = new Urls();
    view.init({}, cx);
    view.key({ key: "j" }, cx);
    view.key({ key: "down" }, cx); // Stop at the final URL.
    assert.equal(view.at, 1);
    view.key({ key: cancel ? "escape" : "enter" }, cx);
    assert.deepEqual(opened, cancel ? [] : ["https://example.com/old"]);
    assert.deepEqual(closed, ["url-window"]);
  }
});

test("motions clamp to rows and preserve Unicode characters", () => {
  const b = new CopyBuffer("a😀c\nxy\n");
  b.move("gg");
  b.move("l");
  b.select("character");
  assert.equal(b.selectedText(), "😀");
  b.move("j");
  assert.deepEqual(b.cursor, { row: 1, col: 1 });
  assert.equal(b.selectedText(), "😀c\nxy");
  b.move("$"); b.move("l");
  assert.equal(b.cursor.col, 1);
  b.move("G"); b.move("j");
  assert.deepEqual(b.cursor, { row: 2, col: 0 });
  b.move("k"); b.move("0"); b.move("h");
  assert.deepEqual(b.cursor, { row: 1, col: 0 });
});

test("word motion follows punctuation and crosses newlines", () => {
  const b = new CopyBuffer("one.two  three\n\nfour");
  b.move("gg");
  for (const expected of [{ row: 0, col: 3 }, { row: 0, col: 4 }, { row: 0, col: 9 }, { row: 2, col: 0 }]) {
    b.move("w"); assert.deepEqual(b.cursor, expected);
  }
  b.move("b"); assert.deepEqual(b.cursor, { row: 0, col: 9 });
  b.move("b"); assert.equal(b.cursor.col, 4);
  b.move("b"); assert.equal(b.cursor.col, 3);
  b.move("b"); assert.equal(b.cursor.col, 0);
  b.move("b"); assert.equal(b.cursor.col, 0);
});

test("blank-line motions stop at adjacent boundaries and skip blank runs", () => {
  const b = new CopyBuffer("one\ntwo\n\n \nthree\nfour\n\nfive");
  b.move("gg");
  b.move("}"); assert.equal(b.cursor.row, 2);
  b.move("}"); assert.equal(b.cursor.row, 6);
  b.move("{"); assert.equal(b.cursor.row, 3);
  b.move("{"); assert.equal(b.cursor.row, 0);
  b.move("{"); assert.equal(b.cursor.row, 0);
  b.move("G"); b.move("}"); assert.equal(b.cursor.row, 7);
});

test("Ctrl+D pages up and Ctrl+U pages down by the viewport", () => {
  const b = new CopyBuffer(Array.from({ length: 60 }, (_, i) => String(i)).join("\n"));
  b.move("ctrl-d", 20); assert.equal(b.cursor.row, 39);
  b.move("ctrl-u", 20); assert.equal(b.cursor.row, 59);
  b.move("gg"); b.move("ctrl-d", 20); assert.equal(b.cursor.row, 0);
});

test("character selections are inclusive, reversible, and remain after copying", () => {
  const b = new CopyBuffer("alpha\nbeta");
  assert.equal(b.selectedText(), null);
  b.go(1, 2); b.select("character"); b.go(0, 1);
  assert.equal(b.selectedText(), "lpha\nbet");
  assert.equal(b.selectedText(), "lpha\nbet");
  b.select("character");
  assert.equal(b.selectedText(), null);
});

test("line selection includes full lines and a final newline in either direction", () => {
  const b = new CopyBuffer("alpha\nbeta\ngamma");
  b.go(1, 2); b.select("line"); b.go(0, 3);
  assert.equal(b.selectedText(), "alpha\nbeta\n");
  b.go(2, 1);
  assert.equal(b.selectedText(), "beta\ngamma\n");
  b.select("character");
  assert.equal(b.selectedText(), "ta\nga");
});

test("regex search wraps; n/N retain the original direction", () => {
  const b = new CopyBuffer("a1 x a22\nz\na333");
  b.move("gg");
  assert.equal(b.search("a\\d+", 1), true);
  assert.deepEqual(b.cursor, { row: 0, col: 5 });
  b.repeat(false); assert.deepEqual(b.cursor, { row: 2, col: 0 });
  b.repeat(true); assert.deepEqual(b.cursor, { row: 0, col: 5 });
  b.repeat(false); assert.deepEqual(b.cursor, { row: 2, col: 0 });
  b.repeat(false); assert.deepEqual(b.cursor, { row: 0, col: 0 });
  b.search("a\\d+", -1); assert.deepEqual(b.cursor, { row: 2, col: 0 });
  b.repeat(false); assert.deepEqual(b.cursor, { row: 0, col: 5 });
  b.repeat(true); assert.deepEqual(b.cursor, { row: 2, col: 0 });
});

test("Unicode and multiline regex offsets map to the right cursor cell", () => {
  const b = new CopyBuffer("😀 word\nsecond\n😀 word");
  b.move("gg"); b.search("word", 1);
  assert.deepEqual(b.cursor, { row: 0, col: 2 });
  b.search("^second$", 1);
  assert.deepEqual(b.cursor, { row: 1, col: 0 });
  b.search("😀", -1); b.select("character");
  assert.equal(b.selectedText(), "😀");
});

test("zero-length regexes finish and invalid patterns preserve the previous search", () => {
  const b = new CopyBuffer("😀\nabc\n");
  b.move("gg"); b.search("^", 1);
  assert.deepEqual(b.cursor, { row: 1, col: 0 });
  assert.throws(() => b.search("[", 1), SyntaxError);
  assert.equal(b.pattern, "^");
  b.repeat(false); assert.deepEqual(b.cursor, { row: 2, col: 0 });
  assert.equal(b.search("unmatched", 1), false);
  assert.equal(b.repeat(false), false);
  b.search("(?:)", 1);
  assert.ok(b.matches.length > 1);
});

test("empty terminal snapshots support every motion and selection", () => {
  const b = new CopyBuffer("");
  for (const key of ["h", "j", "k", "l", "b", "w", "{", "}", "0", "$", "gg", "G", "ctrl-d", "ctrl-u"]) {
    b.move(key); assert.deepEqual(b.cursor, { row: 0, col: 0 });
  }
  b.select("line"); assert.equal(b.selectedText(), "\n");
});

function editorFixture(dir) {
  const editor = join(dir, "fake editor"), output = join(dir, "args.json"), marker = join(dir, "executed");
  writeFileSync(editor, '#!/usr/bin/env node\nrequire("fs").writeFileSync(process.env.HERDR_TEST_OUTPUT, JSON.stringify(process.argv.slice(2)));\n', { mode: 0o755 });
  const file = join(dir, 'a "quote"; $(touch ' + marker + ') `false`.txt');
  const env = { ...process.env, EDITOR: '"' + editor + '" --flag "two words"', HERDR_EDITOR_FILE: file, HERDR_TEST_OUTPUT: output };
  const verify = result => {
    assert.equal(result.status, 0, result.stderr);
    assert.deepEqual(JSON.parse(readFileSync(output, "utf8")), ["--flag", "two words", "--", file]);
    assert.equal(existsSync(marker), false);
  };
  return { env, file, verify };
}

for (const [shell, options] of [["sh", ["-c"]], ["bash", ["--noprofile", "--norc", "-c"]], ["zsh", ["-f", "-c"]], ["dash", ["-c"]], ["fish", ["--no-config", "-c"]]]) {
  const found = spawnSync("sh", ["-c", 'command -v "$1"', "herdr-test-shell", shell], { encoding: "utf8" });
  test(`EDITOR preserves arguments and treats filenames as data in ${shell}`, { skip: found.status !== 0 }, () => {
    const dir = mkdtempSync(join(tmpdir(), "herdr-editor-"));
    try {
      const f = editorFixture(dir);
      f.verify(spawnSync(found.stdout.trim(), [...options, EDITOR_SCRIPT], { env: f.env, encoding: "utf8" }));
      const missing = spawnSync(found.stdout.trim(), [...options, EDITOR_SCRIPT], { env: { ...f.env, EDITOR: "" }, encoding: "utf8" });
      assert.notEqual(missing.status, 0);
      assert.match(missing.stderr, /Set \$EDITOR/);
    } finally { rmSync(dir, { recursive: true, force: true }); }
  });
}

test("editor launcher resolves SHELL at runtime and requests its login/interactive configuration", () => {
  const dir = mkdtempSync(join(tmpdir(), "herdr-editor-shell-"));
  try {
    const f = editorFixture(dir), shell = join(dir, "current shell"), flags = join(dir, "shell-flags");
    // The test shell records startup flags, then runs the command without loading
    // this machine's personal profiles. Production invokes the selected shell.
    writeFileSync(shell, '#!/bin/sh\nprintf "%s" "$1" > "$HERDR_TEST_SHELL_FLAGS"\nshift\nexec sh -c "$1"\n', { mode: 0o755 });
    const argv = editorArgv(f.file);
    f.verify(spawnSync(argv[0], argv.slice(1), { env: { ...f.env, SHELL: shell, HERDR_TEST_SHELL_FLAGS: flags }, encoding: "utf8" }));
    assert.equal(readFileSync(flags, "utf8"), "-lic");
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test("folding worktrees hides only children and keeps the space order", () => {
  const main = { id: "main", folder: "/repo", tabs: [] }, child = { id: "child", folder: "/tree", tabs: [] };
  let folded = {};
  const moved = [];
  const Spaces = loadView("panda-spaces", {
    spaces: () => [main, child], panes: () => [], machines: () => [], checking: () => false,
    shared: key => key === "panda.worktrees.folded" ? folded : {}, run: (...args) => moved.push(args),
  });
  const view = new Spaces();
  view.shown = new Set(["main", "child"]);
  view.born = {};
  view.git = {
    '[null,"/repo"]': { repo: "same-repo", linked: false },
    '[null,"/tree"]': { repo: "same-repo", linked: true },
  };
  assert.deepEqual(Array.from(view.ordered(), row => row.w.id), ["main", "child"]);
  assert.equal(view.ordered()[0].children, 1);
  folded = { main: true };
  assert.deepEqual(Array.from(view.ordered(), row => row.w.id), ["main"]);
  assert.deepEqual(moved, []);
  folded = { main: false };
  assert.deepEqual(Array.from(view.ordered(), row => row.w.id), ["main", "child"]);
});

function nativeFixture({ cols = 12, rows = 20, height = 4, offset = 0, alternate = false, cursor = { row: 5, col: 4 }, bottom = rows - 1, text = "one two\nalpha beta\nlast" } = {}) {
  let selection = null, focused = false, inputValue = "";
  const viewport = { offset, len: height, total: rows };
  const queued = [], calls = [], copied = [], jobs = [], focusedPanes = [], frames = [], reads = [];
  const run = (name, args) => { calls.push([name, args]); queued.push([name, args]); };
  const cx = {
    notify() {}, stop_propagation() {},
    focus_handle: () => ({ focus: () => { focused = true; }, is_focused: () => focused }),
    spawn: fn => { const job = fn(cx); jobs.push(job); return job; },
    sleep: async () => {
      while (queued.length) {
        const [name, args] = queued.shift();
        if (name === "terminal.select") {
          const at = args.at === "cursor" ? cursor : args.at;
          selection = { start: { ...at }, end: { ...at } };
        } else if (name === "terminal.clear_selection") selection = null;
        else if (name === "terminal.copy") copied.push(structuredClone(selection));
        else if (name === "pane.focus") { focusedPanes.push(args.pane); focused = false; }
        else if (name === "terminal.adjust_selection") {
          assert.ok(selection, "native adjustments require a selection");
          const p = selection.end;
          const d = args.direction;
          if (d === "left") p.col = Math.max(0, p.col - 1);
          if (d === "right") p.col = Math.min(cols - 1, p.col + 1);
          if (d === "up") p.row = Math.max(0, p.row - 1);
          if (d === "down") p.row = Math.min(rows - 1, p.row + 1);
          if (d === "page_up") p.row = Math.max(0, p.row - viewport.len);
          if (d === "page_down") p.row = Math.min(rows - 1, p.row + viewport.len);
          if (d === "line_start") p.col = 0;
          if (d === "line_end") p.col = cols - 1;
          if (d === "home") { p.row = 0; p.col = 0; }
          if (d === "end") { p.row = bottom; p.col = cols - 1; }
          if (p.row < viewport.offset) viewport.offset = p.row;
          else if (p.row >= viewport.offset + viewport.len) viewport.offset = p.row - viewport.len + 1;
        } else if (name === "terminal.scroll") {
          viewport.offset = Math.max(0, Math.min(rows - viewport.len, viewport.offset + args.lines));
        } else assert.fail("Unexpected operation in copy mode: " + name);
      }
      frames.push({ selection: structuredClone(selection), viewport: { ...viewport } });
    },
  };
  const CopyPane = loadView("panda-copy", {
    NativeSelection, TerminalText, run, checking: () => true,
    props: () => ({ pane: "current-pane" }),
    focused: () => ({ pane: "current-pane", terminal: "t1" }),
    terminals: () => [{ address: "t1", selection: structuredClone(selection), cols, rows: viewport.len }],
    panes: () => [{ pane: "current-pane", scroll: alternate ? null : { ...viewport } }],
    hc: async args => {
      assert.equal(args[0], "read", "text navigation must never send input to the program");
      reads.push(args);
      return { code: 0, stdout: JSON.stringify({ text, how: "history", complete: true }) };
    },
    InputState: { new: () => ({ on() {}, value: () => inputValue, set_value: value => { inputValue = value; }, focus() {} }) },
  });
  const view = new CopyPane();
  view.init({}, cx);
  view.handle.focus();
  const flush = async () => { await Promise.all(jobs.splice(0)); await cx.sleep(); };
  const press = async key => {
    view.key({ key, key_char: key.length === 1 ? key : undefined, keystroke: key, modifiers: { shift: false } }, cx);
    await flush();
  };
  return {
    view, cx, press, flush, calls, copied, focusedPanes, frames, viewport, reads,
    setText: value => { text = value; }, selection: () => selection,
    resize: (nextCols, nextRows, selected) => { cols = nextCols; rows = nextRows; viewport.total = nextRows; selection = structuredClone(selected); },
  };
}

test("copy mode moves and selects in the original native terminal view", async () => {
  const f = nativeFixture();
  await f.view.command("enter", f.cx);
  assert.deepEqual(f.view.copy.cursor, { row: 5, col: 4 });
  await f.press("h");
  assert.deepEqual(f.selection(), { start: { row: 5, col: 3 }, end: { row: 5, col: 3 } });
  await f.press("v"); await f.press("l"); await f.press("l");
  assert.deepEqual(f.selection(), { start: { row: 5, col: 3 }, end: { row: 5, col: 5 } });
  await f.press("y"); await f.press("enter");
  assert.equal(f.copied.length, 2);
  assert.equal(f.view.copy.active, true);
  assert.deepEqual(f.copied[0], f.copied[1]);
  assert.deepEqual(f.selection(), f.copied[0]);
  assert.ok(f.calls.filter(([name]) => name !== "terminal.copy").every(([, args]) => args.terminal === "t1"));
  assert.deepEqual(f.focusedPanes, []);
});

test("copy-mode exits clear selection, restore the same pane, and never copy", async () => {
  for (const key of ["q", "escape", "ctrl-c"]) {
    const f = nativeFixture();
    await f.view.command("enter", f.cx);
    await f.press("v"); await f.press("l");
    await f.press(key);
    assert.equal(f.view.copy.active, false);
    assert.equal(f.selection(), null);
    assert.deepEqual(f.focusedPanes, ["current-pane"]);
    assert.deepEqual(f.copied, []);
  }
});

test("native line selection paints full rows in either direction", async () => {
  const f = nativeFixture();
  await f.view.command("enter", f.cx);
  await f.press("V"); await f.press("j");
  assert.deepEqual(f.selection(), { start: { row: 5, col: 0 }, end: { row: 6, col: 11 } });
  await f.press("k"); await f.press("k");
  assert.deepEqual(f.selection(), { start: { row: 5, col: 11 }, end: { row: 4, col: 0 } });
  await f.press("V");
  assert.equal(f.view.copy.mode, null);
  assert.deepEqual(f.selection().start, f.selection().end);
});

test("native first/last and page motions retain the current terminal", async () => {
  const f = nativeFixture();
  await f.view.command("enter", f.cx);
  await f.press("ctrl-d"); assert.equal(f.view.copy.cursor.row, 1);
  await f.press("ctrl-u"); assert.equal(f.view.copy.cursor.row, 5);
  await f.press("g"); await f.press("g"); assert.equal(f.view.copy.cursor.row, 0);
  await f.press("G"); assert.equal(f.view.copy.cursor.row, 19);
  assert.deepEqual(f.focusedPanes, []);
});

test("normal vertical motion never displays a range or scrolls a visible cursor away", async () => {
  const f = nativeFixture({ rows: 200, height: 4, offset: 100, cursor: { row: 101, col: 0 } });
  await f.view.command("enter", f.cx);
  f.frames.length = 0;
  for (const key of ["j", "j", "k", "k", "k"]) await f.press(key);
  assert.deepEqual(f.view.copy.cursor, { row: 100, col: 0 });
  for (const frame of f.frames) {
    assert.deepEqual(frame.selection.start, frame.selection.end, "a navigation frame must not flash a text range");
    assert.equal(frame.viewport.offset, 100, "moving within the viewport must not move its top edge");
  }
  f.frames.length = 0;
  await f.press("k");
  assert.deepEqual(f.view.copy.cursor, { row: 99, col: 0 });
  for (const frame of f.frames) {
    assert.deepEqual(frame.selection.start, frame.selection.end);
    assert.equal(frame.viewport.offset, 99, "crossing the top scrolls exactly one line");
  }
});

test("H/M/L use the current visible viewport rather than the full scrollback", async () => {
  const f = nativeFixture({ rows: 500, height: 5, offset: 100, cursor: { row: 102, col: 7 } });
  await f.view.command("enter", f.cx);
  for (const [key, row] of [["H", 100], ["M", 102], ["L", 104]]) {
    f.frames.length = 0;
    await f.press(key);
    assert.deepEqual(f.view.copy.cursor, { row, col: 0 });
    assert.equal(f.viewport.offset, 100);
    for (const frame of f.frames) assert.deepEqual(frame.selection.start, frame.selection.end);
  }
  // Reading the viewport again must honor scrolling and resizing since entry.
  f.viewport.offset = 120; f.viewport.len = 4;
  for (const [key, row] of [["H", 120], ["M", 121], ["L", 123]]) {
    await f.press(key);
    assert.deepEqual(f.view.copy.cursor, { row, col: 0 });
    assert.equal(f.viewport.offset, 120);
  }
});

test("H/M/L extend visual selections from the same anchor", async () => {
  const f = nativeFixture({ rows: 500, height: 5, offset: 100, cursor: { row: 102, col: 7 } });
  await f.view.command("enter", f.cx);
  await f.press("v");
  for (const [key, row] of [["H", 100], ["M", 102], ["L", 104]]) {
    await f.press(key);
    assert.deepEqual(f.selection(), { start: { row: 102, col: 7 }, end: { row, col: 0 } });
    assert.equal(f.viewport.offset, 100);
  }
});

test("line motions paint whole rows without intermediate collapsed selections", async () => {
  const f = nativeFixture({ rows: 500, height: 5, offset: 100, cursor: { row: 102, col: 7 } });
  await f.view.command("enter", f.cx);
  await f.press("V");
  f.frames.length = 0;
  for (const key of ["j", "k", "k", "H", "M", "L"]) await f.press(key);
  for (const { selection } of f.frames) {
    assert.notDeepEqual(selection.start, selection.end);
    assert.deepEqual([selection.start.col, selection.end.col].sort((a, b) => a - b), [0, 11]);
  }
});

test("H/M/L also stay on the visible alternate screen without scrollback", async () => {
  const f = nativeFixture({ rows: 6, height: 6, alternate: true, cursor: { row: 2, col: 3 } });
  await f.view.command("enter", f.cx);
  for (const [key, row] of [["H", 0], ["M", 2], ["L", 5]]) {
    await f.press(key);
    assert.deepEqual(f.view.copy.cursor, { row, col: 0 });
    assert.equal(f.viewport.offset, 0);
  }
  assert.equal(f.calls.some(([name]) => name === "terminal.scroll"), false);
});

test("word navigation and regex search map text back to native cells", async () => {
  const f = nativeFixture({ cursor: { row: 1, col: 0 }, bottom: 2 });
  await f.view.command("enter", f.cx);
  await f.press("w");
  assert.deepEqual(f.view.copy.cursor, { row: 1, col: 6 });
  await f.press("b");
  assert.deepEqual(f.view.copy.cursor, { row: 1, col: 0 });
  f.view.input.set_value("beta");
  f.view.searchDirection = 1; f.view.searching = true;
  await f.view.command("search", f.cx);
  assert.deepEqual(f.view.copy.cursor, { row: 1, col: 6 });
  assert.equal(f.view.searching, false);
  await f.press("v");
  f.view.input.set_value("last"); f.view.searchDirection = 1;
  await f.view.command("search", f.cx);
  assert.deepEqual(f.selection(), { start: { row: 1, col: 6 }, end: { row: 2, col: 0 } });
  assert.equal(f.view.copy.active, true);
  assert.equal(f.copied.length, 0);
});

test("word motions keep the viewport and never flash a range or probe the terminal end", async () => {
  const f = nativeFixture({ rows: 200, height: 5, offset: 100, cursor: { row: 102, col: 0 }, text: Array(200).fill("one two").join("\n") });
  await f.view.command("enter", f.cx);
  assert.equal(f.viewport.offset, 100, "preparing the snapshot must preserve the viewport");
  f.calls.length = 0; f.frames.length = 0;
  for (const [key, col] of [["w", 4], ["b", 0], ["w", 4], ["b", 0]]) {
    await f.press(key);
    assert.deepEqual(f.view.copy.cursor, { row: 102, col });
  }
  assert.equal(f.reads.length, 1, "motions reuse the entry snapshot");
  assert.equal(f.calls.some(([name]) => name === "terminal.adjust_selection"), false);
  for (const frame of f.frames) {
    assert.deepEqual(frame.selection.start, frame.selection.end, "word navigation must not display an intermediate range");
    assert.equal(frame.viewport.offset, 100, "word navigation must not jump to the bottom and back");
  }
});

test("word motions scroll only when the destination crosses the viewport edge", async () => {
  const f = nativeFixture({ rows: 200, height: 4, offset: 100, cursor: { row: 103, col: 4 }, text: Array(200).fill("one two").join("\n") });
  await f.view.command("enter", f.cx);
  f.frames.length = 0;
  await f.press("w");
  assert.deepEqual(f.view.copy.cursor, { row: 104, col: 0 });
  for (const frame of f.frames) assert.equal(frame.viewport.offset, 101);
  f.frames.length = 0;
  await f.press("b");
  assert.deepEqual(f.view.copy.cursor, { row: 103, col: 4 });
  for (const frame of f.frames) assert.equal(frame.viewport.offset, 101);
});

test("visual word motions retain their anchor without collapsing or selecting unrelated rows", async () => {
  for (const mode of ["v", "V"]) {
    const f = nativeFixture({ rows: 200, height: 5, offset: 100, cursor: { row: 102, col: 0 }, text: Array(200).fill("one two").join("\n") });
    await f.view.command("enter", f.cx);
    await f.press(mode);
    f.frames.length = 0; f.calls.length = 0;
    await f.press("w");
    const selection = f.selection();
    assert.deepEqual(selection.start, { row: 102, col: 0 });
    assert.deepEqual(selection.end, { row: 102, col: mode === "v" ? 4 : 11 });
    for (const frame of f.frames) {
      assert.deepEqual(frame.selection.start, selection.start);
      assert.equal(frame.selection.end.row, 102);
      assert.notDeepEqual(frame.selection.start, frame.selection.end);
      assert.equal(frame.viewport.offset, 100);
    }
    assert.equal(f.calls.some(([, args]) => args.direction === "end"), false);
  }
});

test("word motions use a fresh snapshot after leaving and re-entering copy mode", async () => {
  const f = nativeFixture({ rows: 3, height: 3, cursor: { row: 1, col: 0 }, text: "one two\nalpha beta\nlast" });
  await f.view.command("enter", f.cx);
  await f.press("w");
  assert.deepEqual(f.view.copy.cursor, { row: 1, col: 6 });
  await f.press("q");
  f.setText("one two\none two\nlast");
  f.view.handle.focus();
  await f.view.command("enter", f.cx);
  await f.press("w");
  assert.deepEqual(f.view.copy.cursor, { row: 1, col: 4 });
  assert.equal(f.reads.length, 2);
});

test("word motions reflow the snapshot around the native selection after resizing", async () => {
  for (const visual of [false, true]) {
    const f = nativeFixture({ cols: 20, rows: 5, height: 5, cursor: { row: 1, col: 0 }, bottom: 2, text: "first\nalpha beta gamma\nlast" });
    await f.view.command("enter", f.cx);
    if (visual) await f.press("v");
    await f.press("w");
    assert.deepEqual(f.view.copy.cursor, { row: 1, col: 6 });
    f.resize(6, 5, { start: { row: visual ? 1 : 2, col: 0 }, end: { row: 2, col: 0 } });
    f.calls.length = 0; f.frames.length = 0;
    await f.press("w");
    assert.deepEqual(f.view.copy.cursor, { row: 2, col: 5 });
    assert.deepEqual(f.selection().start, { row: visual ? 1 : 2, col: visual ? 0 : 5 });
    assert.equal(f.reads.length, 1, "resizing must not re-probe the buffer");
    assert.equal(f.calls.some(([, args]) => args.direction === "end"), false);
    for (const frame of f.frames) assert.equal(frame.viewport.offset, 0);
  }
});

test("text indexes account for soft wraps, history offsets, and wide glyphs", () => {
  const index = new TerminalText("hello world\n日本😀 z\nlast", 10, { row: 103, col: 9 });
  index.at({ row: 100, col: 0 });
  index.buffer.search("world", 1);
  assert.deepEqual(index.point(), { row: 100, col: 6 });
  index.buffer.search("日本😀", 1);
  assert.deepEqual(index.point(), { row: 102, col: 0 });
  index.buffer.search("z", 1);
  assert.deepEqual(index.point(), { row: 102, col: 7 });
  const emoji = new TerminalText("e\u0301 😀👩‍💻x\nlast", 12, { row: 1, col: 11 });
  emoji.at({ row: 0, col: 0 });
  assert.equal(emoji.buffer.cursor.col, 0, "cursor must not land inside a grapheme");
  emoji.buffer.search("x", 1);
  assert.deepEqual(emoji.point(), { row: 0, col: 6 });
});

test("prefix enters the pane header instead of opening a copy overlay", () => {
  const keys = JSON.parse(readFileSync(new URL("../.config/herdr-app/keys.json", import.meta.url), "utf8"));
  assert.equal(keys["layout:panda"]["` ["], "panda-copy.enter");
  const mod = JSON.parse(readFileSync(new URL("../.config/herdr-app/mods/panda-copy/mod.json", import.meta.url), "utf8"));
  assert.equal(mod.overlay, undefined);
});
