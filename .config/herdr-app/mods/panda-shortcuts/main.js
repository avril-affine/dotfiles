import { View, div } from "gpui-kit";
import { nextCommand, spaces, focused, layout, run, openOverlay, theme, checking } from "herdr";

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
