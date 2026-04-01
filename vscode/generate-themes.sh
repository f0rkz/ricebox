#!/bin/bash
# Generate VS Code color themes from ricebox theme files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="${1:-$SCRIPT_DIR/../themes}"
OUT_DIR="$SCRIPT_DIR/themes"

mkdir -p "$OUT_DIR"

for theme_file in "$THEME_DIR"/*.sh; do
  name=$(basename "$theme_file" .sh)
  [ "$name" = "current-colors" ] && continue

  source "$theme_file"

  cat > "$OUT_DIR/ricebox-${name}-color-theme.json" << JSONEOF
{
  "name": "Ricebox ${name}",
  "type": "dark",
  "colors": {
    "editor.background": "${BG_DARK}",
    "editor.foreground": "${FG}",
    "editor.lineHighlightBackground": "${BG_ALT}",
    "editor.selectionBackground": "${BG_ALT}",
    "editor.selectionHighlightBackground": "${BG_ALT}",
    "editor.findMatchBackground": "${YELLOW}44",
    "editor.findMatchHighlightBackground": "${YELLOW}22",
    "editor.wordHighlightBackground": "${PRIMARY}22",
    "editorCursor.foreground": "${CURSOR}",
    "editorLineNumber.foreground": "${DISABLED}",
    "editorLineNumber.activeForeground": "${PRIMARY}",
    "editorIndentGuide.background1": "${BG_ALT}",
    "editorIndentGuide.activeBackground1": "${DISABLED}",
    "editorBracketMatch.background": "${BG_ALT}",
    "editorBracketMatch.border": "${PRIMARY}",
    "editorGutter.addedBackground": "${GREEN}",
    "editorGutter.modifiedBackground": "${YELLOW}",
    "editorGutter.deletedBackground": "${RED}",
    "editorError.foreground": "${RED}",
    "editorWarning.foreground": "${YELLOW}",
    "editorInfo.foreground": "${BLUE}",

    "activityBar.background": "${BG}",
    "activityBar.foreground": "${FG}",
    "activityBar.inactiveForeground": "${DISABLED}",
    "activityBarBadge.background": "${PRIMARY}",
    "activityBarBadge.foreground": "${BG}",

    "sideBar.background": "${BG}",
    "sideBar.foreground": "${FG}",
    "sideBar.border": "${BG_ALT}",
    "sideBarTitle.foreground": "${FG}",
    "sideBarSectionHeader.background": "${BG_ALT}",
    "sideBarSectionHeader.foreground": "${FG}",

    "titleBar.activeBackground": "${BG}",
    "titleBar.activeForeground": "${FG}",
    "titleBar.inactiveBackground": "${BG}",
    "titleBar.inactiveForeground": "${DISABLED}",

    "statusBar.background": "${BG_ALT}",
    "statusBar.foreground": "${FG}",
    "statusBar.debuggingBackground": "${RED}",
    "statusBar.debuggingForeground": "${FG}",
    "statusBar.noFolderBackground": "${BG_ALT}",

    "tab.activeBackground": "${BG_DARK}",
    "tab.activeForeground": "${FG}",
    "tab.inactiveBackground": "${BG}",
    "tab.inactiveForeground": "${DISABLED}",
    "tab.border": "${BG}",
    "tab.activeBorderTop": "${PRIMARY}",
    "editorGroupHeader.tabsBackground": "${BG}",

    "panel.background": "${BG}",
    "panel.border": "${BG_ALT}",
    "panelTitle.activeBorder": "${PRIMARY}",
    "panelTitle.activeForeground": "${FG}",
    "panelTitle.inactiveForeground": "${DISABLED}",

    "terminal.background": "${BG_DARK}",
    "terminal.foreground": "${FG}",
    "terminal.ansiBlack": "${BLACK}",
    "terminal.ansiBrightBlack": "${BLACK_BRIGHT}",
    "terminal.ansiRed": "${RED}",
    "terminal.ansiBrightRed": "${RED_BRIGHT}",
    "terminal.ansiGreen": "${GREEN}",
    "terminal.ansiBrightGreen": "${GREEN_BRIGHT}",
    "terminal.ansiYellow": "${YELLOW}",
    "terminal.ansiBrightYellow": "${YELLOW_BRIGHT}",
    "terminal.ansiBlue": "${BLUE}",
    "terminal.ansiBrightBlue": "${BLUE_BRIGHT}",
    "terminal.ansiMagenta": "${MAGENTA}",
    "terminal.ansiBrightMagenta": "${MAGENTA_BRIGHT}",
    "terminal.ansiCyan": "${CYAN}",
    "terminal.ansiBrightCyan": "${CYAN_BRIGHT}",
    "terminal.ansiWhite": "${WHITE}",
    "terminal.ansiBrightWhite": "${WHITE_BRIGHT}",

    "input.background": "${BG_ALT}",
    "input.foreground": "${FG}",
    "input.border": "${DISABLED}",
    "input.placeholderForeground": "${DISABLED}",
    "focusBorder": "${PRIMARY}",

    "dropdown.background": "${BG_ALT}",
    "dropdown.foreground": "${FG}",
    "dropdown.border": "${DISABLED}",

    "list.activeSelectionBackground": "${BG_ALT}",
    "list.activeSelectionForeground": "${PRIMARY}",
    "list.hoverBackground": "${BG_ALT}",
    "list.inactiveSelectionBackground": "${BG_ALT}",
    "list.highlightForeground": "${PRIMARY}",

    "button.background": "${PRIMARY}",
    "button.foreground": "${BG}",
    "button.hoverBackground": "${BLUE_BRIGHT}",

    "badge.background": "${PRIMARY}",
    "badge.foreground": "${BG}",

    "scrollbar.shadow": "${BG_DARK}",
    "scrollbarSlider.background": "${DISABLED}44",
    "scrollbarSlider.hoverBackground": "${DISABLED}88",
    "scrollbarSlider.activeBackground": "${DISABLED}",

    "gitDecoration.addedResourceForeground": "${GREEN}",
    "gitDecoration.modifiedResourceForeground": "${YELLOW}",
    "gitDecoration.deletedResourceForeground": "${RED}",
    "gitDecoration.untrackedResourceForeground": "${GREEN_BRIGHT}",
    "gitDecoration.conflictingResourceForeground": "${RED_BRIGHT}",
    "gitDecoration.ignoredResourceForeground": "${DISABLED}",

    "peekView.border": "${PRIMARY}",
    "peekViewEditor.background": "${BG}",
    "peekViewResult.background": "${BG_ALT}",
    "peekViewTitle.background": "${BG_ALT}",

    "minimap.findMatchHighlight": "${YELLOW}44",
    "minimap.selectionHighlight": "${PRIMARY}44"
  },
  "tokenColors": [
    { "scope": "comment", "settings": { "foreground": "${DISABLED}", "fontStyle": "italic" } },
    { "scope": "string", "settings": { "foreground": "${GREEN}" } },
    { "scope": "constant.numeric", "settings": { "foreground": "${CYAN}" } },
    { "scope": "constant.language", "settings": { "foreground": "${CYAN}" } },
    { "scope": "constant.character", "settings": { "foreground": "${CYAN}" } },
    { "scope": "variable", "settings": { "foreground": "${FG}" } },
    { "scope": "variable.language", "settings": { "foreground": "${RED}" } },
    { "scope": "variable.parameter", "settings": { "foreground": "${FG}", "fontStyle": "italic" } },
    { "scope": "keyword", "settings": { "foreground": "${MAGENTA}" } },
    { "scope": "keyword.control", "settings": { "foreground": "${MAGENTA}" } },
    { "scope": "keyword.operator", "settings": { "foreground": "${FG_ALT}" } },
    { "scope": "storage", "settings": { "foreground": "${MAGENTA}" } },
    { "scope": "storage.type", "settings": { "foreground": "${YELLOW}" } },
    { "scope": "entity.name.function", "settings": { "foreground": "${BLUE}" } },
    { "scope": "entity.name.type", "settings": { "foreground": "${YELLOW}" } },
    { "scope": "entity.name.class", "settings": { "foreground": "${YELLOW}" } },
    { "scope": "entity.name.tag", "settings": { "foreground": "${PRIMARY}" } },
    { "scope": "entity.other.attribute-name", "settings": { "foreground": "${BLUE}" } },
    { "scope": "entity.other.inherited-class", "settings": { "foreground": "${SECONDARY}" } },
    { "scope": "support.function", "settings": { "foreground": "${BLUE}" } },
    { "scope": "support.type", "settings": { "foreground": "${YELLOW}" } },
    { "scope": "support.class", "settings": { "foreground": "${YELLOW}" } },
    { "scope": "support.constant", "settings": { "foreground": "${CYAN}" } },
    { "scope": "punctuation", "settings": { "foreground": "${FG_ALT}" } },
    { "scope": "meta.tag", "settings": { "foreground": "${FG}" } },
    { "scope": "meta.brace", "settings": { "foreground": "${FG_ALT}" } },
    { "scope": "markup.heading", "settings": { "foreground": "${PRIMARY}", "fontStyle": "bold" } },
    { "scope": "markup.bold", "settings": { "fontStyle": "bold" } },
    { "scope": "markup.italic", "settings": { "fontStyle": "italic" } },
    { "scope": "markup.inline.raw", "settings": { "foreground": "${GREEN}" } },
    { "scope": "markup.deleted", "settings": { "foreground": "${RED}" } },
    { "scope": "markup.inserted", "settings": { "foreground": "${GREEN}" } },
    { "scope": "markup.changed", "settings": { "foreground": "${YELLOW}" } },
    { "scope": "markup.list", "settings": { "foreground": "${FG}" } },
    { "scope": "markup.quote", "settings": { "foreground": "${SECONDARY}", "fontStyle": "italic" } }
  ]
}
JSONEOF

  echo "  generated ricebox-${name}"
done

# Generate package.json for the extension
cat > "$SCRIPT_DIR/package.json" << 'PKGEOF'
{
  "name": "ricebox-themes",
  "displayName": "Ricebox Themes",
  "description": "Color themes generated from ricebox dotfiles",
  "version": "1.0.0",
  "publisher": "ricebox",
  "engines": { "vscode": "^1.60.0" },
  "categories": ["Themes"],
  "contributes": {
    "themes": [
PKGEOF

first=true
for f in "$OUT_DIR"/ricebox-*-color-theme.json; do
  name=$(basename "$f" -color-theme.json | sed 's/ricebox-//')
  label="Ricebox $(echo "$name" | sed 's/-/ /g; s/\b\(.\)/\u\1/g')"
  if [ "$first" = true ]; then
    first=false
  else
    echo "," >> "$SCRIPT_DIR/package.json"
  fi
  printf '      { "label": "%s", "uiTheme": "vs-dark", "path": "./themes/%s" }' "$label" "$(basename "$f")" >> "$SCRIPT_DIR/package.json"
done

cat >> "$SCRIPT_DIR/package.json" << 'PKGEOF'

    ]
  }
}
PKGEOF

echo "done - $(ls "$OUT_DIR"/*.json | wc -l) themes generated"
