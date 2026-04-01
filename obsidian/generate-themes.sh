#!/bin/bash
# Generate Obsidian CSS snippets from ricebox theme files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="${1:-$SCRIPT_DIR/../themes}"
OUT_DIR="$SCRIPT_DIR/snippets"

mkdir -p "$OUT_DIR"

for theme_file in "$THEME_DIR"/*.sh; do
  name=$(basename "$theme_file" .sh)
  [ "$name" = "current-colors" ] && continue

  source "$theme_file"

  cat > "$OUT_DIR/ricebox-${name}.css" << CSSEOF
/* ricebox-${name} */
.theme-dark.ricebox-${name} {
  --background-primary: ${BG_DARK};
  --background-primary-alt: ${BG};
  --background-secondary: ${BG};
  --background-secondary-alt: ${BG_ALT};
  --background-modifier-border: ${BG_ALT};
  --background-modifier-form-field: ${BG_ALT};
  --background-modifier-form-field-highlighted: ${BG_ALT};
  --background-modifier-box-shadow: rgba(0, 0, 0, 0.3);
  --background-modifier-success: ${GREEN};
  --background-modifier-error: ${RED};
  --background-modifier-error-rgb: 230, 60, 60;
  --background-modifier-cover: rgba(0, 0, 0, 0.6);

  --text-normal: ${FG};
  --text-muted: ${FG_ALT};
  --text-faint: ${DISABLED};
  --text-error: ${RED};
  --text-accent: ${PRIMARY};
  --text-accent-hover: ${BLUE_BRIGHT};
  --text-on-accent: ${BG};
  --text-selection: ${BG_ALT};
  --text-highlight-bg: ${YELLOW}33;

  --interactive-normal: ${BG_ALT};
  --interactive-hover: ${DISABLED};
  --interactive-accent: ${PRIMARY};
  --interactive-accent-rgb: $(python3 -c "print(','.join(str(int('${PRIMARY}'[i:i+2], 16)) for i in (1,3,5)))");
  --interactive-accent-hover: ${BLUE_BRIGHT};

  --scrollbar-bg: ${BG};
  --scrollbar-thumb-bg: ${DISABLED}44;
  --scrollbar-active-thumb-bg: ${DISABLED};

  --titlebar-background: ${BG};
  --titlebar-background-focused: ${BG};

  --nav-item-color: ${FG};
  --nav-item-color-hover: ${PRIMARY};
  --nav-item-color-active: ${PRIMARY};
  --nav-item-background-hover: ${BG_ALT};
  --nav-item-background-active: ${BG_ALT};

  --tag-color: ${SECONDARY};
  --tag-background: ${BG_ALT};

  --h1-color: ${PRIMARY};
  --h2-color: ${BLUE};
  --h3-color: ${CYAN};
  --h4-color: ${GREEN};
  --h5-color: ${YELLOW};
  --h6-color: ${FG_ALT};

  --bold-color: ${FG};
  --italic-color: ${FG};
  --link-color: ${BLUE};
  --link-color-hover: ${BLUE_BRIGHT};
  --link-external-color: ${CYAN};
  --link-external-color-hover: ${CYAN_BRIGHT};

  --code-normal: ${GREEN};
  --code-background: ${BG_ALT};
  --code-comment: ${DISABLED};
  --code-function: ${BLUE};
  --code-keyword: ${MAGENTA};
  --code-string: ${GREEN};
  --code-tag: ${PRIMARY};
  --code-value: ${CYAN};
  --code-property: ${CYAN};
  --code-important: ${RED};

  --blockquote-border-color: ${PRIMARY};

  --table-header-background: ${BG_ALT};
  --table-row-even-background: ${BG};
  --table-row-odd-background: ${BG_DARK};

  --checkbox-color: ${PRIMARY};
  --checkbox-marker-color: ${BG};
  --checklist-done-color: ${DISABLED};

  --graph-line: ${DISABLED};
  --graph-node: ${PRIMARY};
  --graph-node-focused: ${BLUE_BRIGHT};
  --graph-node-tag: ${SECONDARY};
  --graph-node-attachment: ${GREEN};
}
CSSEOF

  echo "  generated ricebox-${name}.css"
done

echo "done - $(ls "$OUT_DIR"/*.css | wc -l) snippets generated"
