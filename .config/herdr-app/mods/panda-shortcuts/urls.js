import { URL } from "url";

export const LOOKBACK_LINES = 2000;
export const MAX_URLS = 100;

export function readArgs(terminal, scroll) {
  // Asking for history in an alternate-screen program makes hc scroll that
  // program to collect it. With no history viewport, read only its screen.
  const history = scroll ? Math.max(0, scroll.total - scroll.len) : 0;
  return ["read", terminal, "--json", "--lines", String(Math.min(LOOKBACK_LINES, history))];
}

function trimUrl(value) {
  let previous;
  do {
    previous = value;
    value = value.replace(/[.,;:!?]+$/u, "");
    for (const [open, close] of [["(", ")"], ["[", "]"], ["{", "}"]]) {
      const count = char => Array.from(value).filter(c => c === char).length;
      while (value.endsWith(close) && count(close) > count(open)) value = value.slice(0, -1);
    }
  } while (value !== previous);
  return value;
}

export function recentUrls(text, limit = MAX_URLS) {
  const matches = Array.from(text.matchAll(/https?:\/\/[^\s<>"'`\u0000-\u001f\u007f“”‘’]+/giu));
  const seen = new Set(), result = [];
  for (let i = matches.length - 1; i >= 0 && result.length < limit; i--) {
    const value = trimUrl(matches[i][0]);
    try {
      const url = new URL(value);
      if (!url.hostname || !["http:", "https:"].includes(url.protocol) || seen.has(url.href)) continue;
      seen.add(url.href);
      result.push(value);
    } catch { /* A log can contain an incomplete or malformed URL. */ }
  }
  return result;
}
