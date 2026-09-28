#!/usr/bin/env bash
# Sanity checks on the built theme (gate G2). Run by CI and usable locally.
# Needs: bash, coreutils, python3 (present on GitHub runners; macOS ships python3).
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

fail() { echo "check.sh: FAIL: $*" >&2; exit 1; }

scripts/build.sh >/dev/null

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# 1. Deterministic output: a second build must be byte-identical.
mkdir -p "$work/rebuild"
for f in dist/theme-soppy-*.css; do cp "$f" "$work/$(basename "$f").first"; done
scripts/build.sh >/dev/null
for f in dist/theme-soppy-*.css; do
  cmp -s "$f" "$work/$(basename "$f").first" || fail "build is not deterministic: $f"
done
echo "check.sh: ok  build is deterministic"

# 2. One meta block per file, with the scheme matching the variant.
for variant in light dark; do
  f="dist/theme-soppy-$variant.css"
  [ -f "$f" ] || fail "missing $f"
  grep -q '^gitea-theme-meta-info {' "$f" || fail "$f has no gitea-theme-meta-info block"
  grep -q -- "--theme-color-scheme: \"$variant\"" "$f" || fail "$f has the wrong color scheme"
done
echo "check.sh: ok  meta blocks present and correct"

# 3. @import must precede every other statement (CSS requires it; fonts.css is first
#    in the assembly order, so a section reorder would silently break the webfont).
for f in dist/theme-soppy-*.css; do
  first_statement="$(python3 - "$f" <<'PY'
import re, sys
css = re.sub(r"/\*.*?\*/", "", open(sys.argv[1], encoding="utf-8").read(), flags=re.S)
for stmt in css.split(";"):
    if stmt.strip():
        print(stmt.strip().split()[0] if stmt.strip().split() else "")
        break
PY
)"
  [ "$first_statement" = "@import" ] || fail "$f: first statement is '$first_statement', expected @import"
done
echo "check.sh: ok  @import is the first statement"

# 4. Balanced braces (a truncated section file would show up here, not in the browser).
for f in dist/theme-soppy-*.css; do
  o="$(tr -cd '{' < "$f" | wc -c | tr -d ' ')"
  c="$(tr -cd '}' < "$f" | wc -c | tr -d ' ')"
  [ "$o" = "$c" ] || fail "$f: unbalanced braces ({ $o, } $c)"
done
echo "check.sh: ok  braces balanced"

# 5. Every bundled asset the CSS references must exist, under the path Gitea serves it
#    from (/assets/soppy/ maps to the repo's assets/ directory).
missing=0
for ref in $(grep -oh 'url("/assets/soppy/[^"]*"' dist/theme-soppy-*.css | sed 's|url("/assets/soppy/||; s|"$||' | sort -u); do
  if [ ! -f "assets/$ref" ]; then
    echo "check.sh: missing bundled asset: assets/$ref (referenced by dist/)" >&2
    missing=1
  fi
done
[ "$missing" = 0 ] || fail "the CSS references assets that are not in assets/"
echo "check.sh: ok  all referenced assets are present"

# 6. The release version is data (D-021); a typo there would break the release workflow.
if ! tr -d '[:space:]' < version.txt | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  fail "version.txt is not MAJOR.MINOR.PATCH: '$(tr -d '[:space:]' < version.txt)'"
fi
echo "check.sh: ok  version.txt is well-formed"

echo "check.sh: all checks passed"
