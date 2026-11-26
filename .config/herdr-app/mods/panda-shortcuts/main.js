import { View, div } from "gpui-kit";
import { nextCommand, spaces, focused, panes, layout, run, openOverlay, theme, checking, hc, notify } from "herdr";
import { recentUrls, readArgs, LOOKBACK_LINES, MAX_URLS } from "./urls.js";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
}

export default class Shortcuts extends View {
  init(_props, cx) {
    if (checking()) return;
    cx.spawn(async (cx) => {
      for (;;) {
        const command = await nextCommand();
        if (command === "changes") {
          const root = layout();
          if (!find(root, "panel")?.hidden && find(root, "panel-body")?.active === "changes") {
            run("layout.hide", { id: "panel" });
          } else {
            run("layout.select", { stack: "panel-body", child: "changes" });
            run("layout.show", { id: "panel" });
          }
        } else if (command === "urls" || command === "url-last") {
          const target = focused();
          if (target?.terminal) {
            try {
              const pane = panes().find(p => p.terminal === target.terminal && (!target.pane || p.pane === target.pane));
              const result = await hc(readArgs(target.terminal, pane?.scroll));
              if (result.code !== 0) throw new Error(result.stderr || result.stdout || "Cannot read the terminal.");
              const urls = recentUrls(JSON.parse(result.stdout).text);
              if (command === "url-last") {
                if (urls[0]) cx.open_url(urls[0]);
                else notify({ title: "No recent URLs", body: "No URLs found in this terminal's recent output.", timeout: 3000 });
              } else openOverlay({
                mod: "panda-urls", kind: "window", key: "panda.recent-urls", width: 760, height: 480,
                props: { terminal: target.terminal, urls, lookback: LOOKBACK_LINES, limit: MAX_URLS },
              });
            } catch (error) {
              notify({ title: "Cannot read terminal URLs", body: String(error.message ?? error), level: "error" });
            }
          }
        } else if (command === "worktree-new" || command === "worktree-open") {
          const space = spaces().find(s => s.active);
          if (space) openOverlay({
            mod: "worktree", kind: "dialog", width: 560,
            props: { space: space.id, folder: focused()?.cwd || space.folder, action: command === "worktree-new" ? "new" : "open" },
          });
        }
        cx.notify();
      }
    });
  }

  render() {
    const t = theme();
    return div().id("prefix-help").size_full().flex().items_center().justify_center()
      .bg(t.chrome).border_t(1).border_color(t.border).text_color(t.dim).text_size(12)
      .tooltip("Prefix: ` · press twice to type a backtick · click for shortcuts")
      .cursor_pointer().hover(s => s.text_color(t.foreground))
      .on_click(() => run("app.help")).child("`");
  }
}
