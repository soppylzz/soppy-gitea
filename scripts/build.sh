#!/usr/bin/env bash
# Build the soppy theme CSS (D-013): concatenate the src/ sections into one
# override-layer file per variant. Deterministic and safe to re-run.
# Output: dist/theme-soppy-light.css, dist/theme-soppy-dark.css
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
src="$repo_root/src"
dist="$repo_root/dist"

section() {
  # section <file> <label>: emit a section file, or fail loudly if it is missing.
  local file="$1" label="$2"
  if [ ! -f "$file" ]; then
    echo "build.sh: missing section file for $label: $file" >&2
    exit 1
  fi
  cat "$file"
  printf '\n'
}

meta_block() {
  # meta_block <display-name> <color-scheme>: Gitea parses this block out of the
  # CSS for theme discovery and auto light/dark switching (webtheme.go).
  cat <<EOF
gitea-theme-meta-info {
  --theme-display-name: "$1";
  --theme-color-scheme: "$2";
}
EOF
  printf '\n'
}

variant() {
  # variant <name> <display-name> <color-scheme> <palette-file>
  local out="$dist/theme-$1.css"
  {
    section "$src/fonts.css" "fonts (T-004)"
    meta_block "$2" "$3"
    section "$src/$4" "palette (T-003)"
    section "$src/components.css" "components (T-005)"
  } > "$out"
  echo "build.sh: wrote $out"
}

mkdir -p "$dist"

# Order per D-013: fonts, meta info, palette, components.
variant soppy-light "Soppy Light" light palette-light.css
variant soppy-dark "Soppy Dark" dark palette-dark.css
