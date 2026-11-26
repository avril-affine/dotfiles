import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, ScrollHandle } from "gpui-base";
import { props, closeOverlay, theme } from "herdr";

export default class Urls extends View {
  init(_props, cx) {
    this.urls = props()?.urls ?? [];
    this.at = 0;
    this.handle = cx.focus_handle();
    this.scroll = ScrollHandle.new();
    this.handle.focus();
  }

  open(i, cx) {
    const url = this.urls[i];
    if (!url) return;
    cx.open_url(url);
    closeOverlay(props()?.overlay);
  }

  key(e, cx) {
    if (e.key === "escape" || e.key === "q") closeOverlay(props()?.overlay);
    else if (e.key === "enter") this.open(this.at, cx);
    else if (e.key === "up" || e.key === "k") this.at = Math.max(0, this.at - 1);
    else if (e.key === "down" || e.key === "j") this.at = Math.min(Math.max(0, this.urls.length - 1), this.at + 1);
    else return;
    cx.stop_propagation();
    this.scroll.scroll_to_item(this.at);
    cx.notify();
  }

  render(cx) {
    const t = theme();
    const stop = (_e, cx) => cx.stop_propagation();
    return v_flex().id("panda-urls").size_full().min_h(0).p(12).gap(10).bg(t.popover)
      .track_focus(this.handle).on_key_down((e, cx) => this.key(e, cx))
      .child(h_flex().gap(10).items_center()
        .child(div().flex_1().text_size(14).font_semibold().text_color(t.foreground).child("Recent URLs"))
        .child(div().p(4).rounded(5).cursor_pointer().hover(s => s.bg(t.hover)).on_mouse_down("left", stop)
          .on_click(() => closeOverlay(props()?.overlay)).child(svg("mods/pane/close.svg").size(14).text_color(t.dim))))
      .child(div().text_size(11).text_color(t.dim)
        .child(`Newest first · up to ${(props()?.lookback ?? 2000).toLocaleString()} history lines · ${this.urls.length === props()?.limit ? "latest " : ""}${this.urls.length} URLs`))
      .child(v_flex().id("url-list").flex_1().min_h(0).gap(3).overflow_y_scrollbar().track_scroll(this.scroll)
        .when(this.urls.length === 0,
          el => el.child(div().p(10).text_color(t.muted).child("No URLs in recent terminal output.")))
        .children(this.urls.map((url, i) => h_flex().id(`url-${i}`).h(36).flex_none().px(9).gap(10).items_center().rounded(6)
          .text_size(12).text_color(t.foreground).cursor_pointer().tooltip(url)
          .when(i === this.at, el => el.bg(t.selected)).hover(s => s.bg(t.hover))
          .on_mouse_down("left", stop).on_click((_e, cx) => this.open(i, cx))
          .child(div().w(24).flex_none().text_color(t.dim).text_right().child(String(i + 1)))
          .child(div().flex_1().min_w(0).truncate().child(url)))))
      .child(div().text_size(11).text_color(t.dim).child("↑/↓ or j/k select · Enter opens · Esc closes"));
  }
}
