#!/usr/bin/env bash
# Package the built theme as a drop-in archive for a Gitea instance (D-018).
# The archive root mirrors <custom>/public/, so installation is one unzip.
# Usage: scripts/package.sh [version]   -> dist/soppy-<version>.zip
# Needs: bash, coreutils, zip/unzip (all present on GitHub runners).
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
dist="$repo_root/dist"
version="${1:-$(tr -d '[:space:]' < "$repo_root/version.txt")}"
version="${version#v}"   # accept the tag form (v1.2.3) as well as the bare one
out="$dist/soppy-$version.zip"

# Build first: the archive content is derived from dist/, never from src/.
"$repo_root/scripts/build.sh"

staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT

css_dir="$staging/public/assets/css"
soppy_dir="$staging/public/assets/soppy"
img_dir="$staging/public/assets/img"
mkdir -p "$css_dir" "$soppy_dir" "$img_dir"

cp "$dist"/theme-soppy-light.css "$dist"/theme-soppy-dark.css "$css_dir/"

# Exactly the files the shipped CSS references (grep 'url("/assets/' in dist/),
# plus the font license: the OFL requires it to travel with the font.
cp "$repo_root/assets/ark-pixel-12px-monospaced-zh_cn.ttf.woff2" \
   "$repo_root/assets/brand.png" \
   "$repo_root/assets/landscape.png" \
   "$repo_root/assets/OFL.txt" \
   "$soppy_dir/"

# The two SVG wrappers that shadow Gitea's built-in /assets/img/ brand files.
cp "$repo_root/assets/generated/favicon.svg" "$repo_root/assets/generated/logo.svg" "$img_dir/"

# Licenses travel with the redistribution: the font's OFL (above, next to the font)
# and this repo's MIT notice, which MIT requires in every copy.
cp "$repo_root/LICENSE" "$staging/LICENSE"
cp "$repo_root/RELEASE.md" "$staging/INSTALL.md"

( cd "$staging" && zip -qr "$out" . )

# The archive is what users install, so verify it carries the themes and the
# licenses before it can become a release asset. The listing goes to a file rather
# than a pipe: `grep -q` exits on the first match, which SIGPIPEs unzip, and
# `set -o pipefail` would read that as a failed check.
listing="$staging/.listing"
unzip -Z1 "$out" > "$listing"

for want in \
  public/assets/css/theme-soppy-light.css \
  public/assets/css/theme-soppy-dark.css \
  public/assets/soppy/ark-pixel-12px-monospaced-zh_cn.ttf.woff2 \
  public/assets/soppy/OFL.txt \
  LICENSE INSTALL.md; do
  if ! grep -qxF "$want" "$listing"; then
    echo "package.sh: archive is missing $want" >&2
    exit 1
  fi
done

echo "package.sh: wrote $out ($(du -h "$out" | cut -f1))"
