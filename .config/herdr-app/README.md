# Herdr

Personal layout and mods for Herdr 0.1.16, cloned from `main`, `spaces`, `changes`,
and `pane`. Shipped files and generated app state stay in `~/.config/herdr-app`.

Install from this dotfiles checkout:

```sh
mkdir -p "$HOME/.config/herdr-app/layouts" "$HOME/.config/herdr-app/mods"
stow --simulate --verbose --target="$HOME" .
stow --target="$HOME" .
herdr-app do layout.switch --name panda
```

Run these commands from the dotfiles checkout. Keep Herdr's top-level config,
`layouts/`, and `mods/` directories real so its generated state and shipped files
stay outside the repo. Stow links each custom mod as a whole directory: Herdr's
module loader needs that for relative JavaScript imports. Use Stow's default
directory folding for these mods. `install.sh` uses the same setup.

Herdr can write editor support files through the custom mod links; those files
are ignored by Git and Stow. This README is linked into the config directory
so the setup instructions and shortcut reference are available there.

Stow preserves existing files and reports conflicts. Move any conflicting regular
config files aside before installing. If a custom mod directory already exists
as a real directory, move it aside so Stow can link the whole folder. Do not use
`--adopt` on Herdr's generated state. The tests are not needed to
install or run this config.

Use the `panda` layout. Press backtick, release it, then press the shortcut:

| Key after prefix | Action |
| --- | --- |
| b / g | Toggle spaces sidebar / changes panel |
| h / j / k / l | Focus left / down / up / right |
| \| / - / z | Split right / down / toggle pane zoom |
| n | New space |
| Tab / Shift+Tab | Next / previous space |
| a / A | Next / previous agent |
| w / W | New / open worktree dialog |
| [ | Copy mode |
| backtick | Type a literal backtick |

Existing Cmd shortcuts are retained. Backtick is reserved as a prefix in this
layout; type it twice to send one to the terminal.

Copy mode selects text directly in the currently selected terminal pane, keeping
its colors, contents, and scrollback. The pane header shows `COPY` and receives
copy-mode keys so they do not reach the program. Regex input appears in that same
header. Exiting clears the selection and returns typing to the same pane.
The copy cursor and native text selections use a bright blue highlight (`#2563eb`)
for stronger contrast against the terminal background.

Cursor movement, selection highlighting, scrolling, and copying use Herdr's native
terminal view. Word/paragraph movement and regex search use a read-only text index
(up to 100,000 history lines), mapped back to terminal cells. Alternate-screen
programs are read with `--lines 0`, which reads their screen without scrolling the
program. Switching panes or clicking back into terminal input ends copy mode.

| Copy-mode key | Action |
| --- | --- |
| h / j / k / l | Move left / down / up / right |
| H / M / L | Top / middle / bottom row of the visible screen, at column zero |
| b / w | Previous / next word, with Vim punctuation boundaries |
| { / } | Previous / next blank-line boundary |
| 0 / $ | Start / end of line |
| gg / G | First / last line |
| Ctrl+D / Ctrl+U | Page up / down, as requested |
| v / V | Toggle character / line selection |
| / / ? then Enter | Forward / backward JavaScript regex search (multiline, Unicode) |
| n / N | Repeat in original / opposite search direction, wrapping |
| y / Enter | Copy the selection and stay in copy mode |
| Esc / q / Ctrl+C | Exit without copying |

Clicking a changed file opens `$EDITOR` in a new right-hand terminal split.
The launcher uses `$SHELL` on the space's machine (falling back to `sh`), loads
its login/interactive configuration, and supports arguments and quoted paths in
`$EDITOR`. It works with POSIX-style shells and fish. File paths are passed
separately from shell code.
The Changes panel keeps its diff preview and commit controls.

Spaces that have nested worktree spaces show a chevron before the name. Click
it to collapse/expand their children; the choice persists. Folding changes the
sidebar display, so prefix+Tab can still select a folded worktree.

Validate with `node --test tests/herdr-app.test.mjs` and
`herdr-app check .config/herdr-app/mods/<name>` for each custom mod. If the checker
cannot reach macOS GUI services from a sandbox, use
`hc exec herdr-app check /absolute/path/to/the/mod`.
