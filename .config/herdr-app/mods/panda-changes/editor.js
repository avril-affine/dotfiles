// Let the user's shell parse EDITOR (including quoted arguments). Keep the
// filename in a quoted variable in the evaluated command, never in its source.
export const EDITOR_SCRIPT = [
  'test -n "$EDITOR" || printf \'%s\\n\' \'Set $EDITOR in your shell configuration to open changed files.\' >&2',
  'test -n "$EDITOR" && eval \'exec \'"$EDITOR"\' -- "$HERDR_EDITOR_FILE"\'',
].join("\n");

export function editorArgv(file) {
  // Resolve SHELL where the new pane runs, including a remote space. sh is
  // only a bootstrap; the login/interactive shell loads the user's config.
  return ["env", "HERDR_EDITOR_FILE=" + file, "sh", "-c",
    'exec "${SHELL:-sh}" -lic "$1"', "herdr-editor", EDITOR_SCRIPT];
}
