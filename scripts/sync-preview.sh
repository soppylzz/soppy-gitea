#!/usr/bin/env bash
# Sync the built theme into the preview instance (T-007, ground-truth loop 1).
# Custom assets are served from disk per request and the theme list re-scans
# every second, so after this a browser refresh suffices — no Gitea restart.
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
assets_dir="$repo_root/gitea-root/work/custom/public/assets"

"$repo_root/scripts/build.sh"

link() {
  # link <symlink-path> <target>: idempotent; refuses to touch real files/dirs.
  local path="$1" target="$2"
  if [ -e "$path" ] && [ ! -L "$path" ]; then
    echo "sync-preview.sh: refusing to replace non-symlink $path" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$path")"
  if [ -L "$path" ] && [ "$(readlink "$path")" = "$target" ]; then
    echo "sync-preview.sh: ok        $path -> $target"
  else
    ln -sfn "$target" "$path"
    echo "sync-preview.sh: linked    $path -> $target"
  fi
}

# Gitea discovers themes in <CustomPath>/public/assets/css/theme-<name>.css.
link "$assets_dir/css" "$repo_root/dist"
# /assets/soppy/ namespace for our own font and image files (D-013).
link "$assets_dir/soppy" "$repo_root/assets"

# Shadow built-in /assets/img/ brand files. The img dir must stay a REAL
# directory: a symlink there would hide every other built-in img asset
# (gitea.svg, avatar_default.png, ...).
img_dir="$assets_dir/img"
if [ -L "$img_dir" ]; then
  echo "sync-preview.sh: $img_dir is a symlink; it must be a real directory" >&2
  exit 1
fi
mkdir -p "$img_dir"

brand_file() {
  # brand_file <name> <target>: file symlink plus a clear failure when the
  # source (generated wrapper SVG) is missing.
  local name="$1" target="$2"
  if [ ! -f "$target" ]; then
    echo "sync-preview.sh: missing source for img/$name: $target" >&2
    exit 1
  fi
  link "$img_dir/$name" "$target"
}

unlink_stale() {
  # unlink_stale <name>: drop a brand symlink we no longer ship, so the
  # built-in img asset underneath it is served again. Symlinks only — the
  # custom layer shadows built-ins, so a dangling link would 404, not fall back.
  local path="$img_dir/$1"
  if [ -L "$path" ]; then
    rm -f "$path"
    echo "sync-preview.sh: unlinked  $path (no longer shipped)"
  fi
}

# Our brand set is SVG-only: favicon.svg for rel=icon (head.tmpl:16) and
# logo.svg for the navbar logo (head_navbar.tmpl:5) and the PWA manifest icon
# (misc.go:40-41). Everything else stays upstream: the PNGs that head.tmpl:17
# (rel=alternate icon), misc.go:40 (manifest 512x512) and the /favicon.ico and
# /apple-touch-icon*.png 301s (web.go:280-282) point at are Gitea's own.
brand_file favicon.svg "$repo_root/assets/generated/favicon.svg"
brand_file logo.svg "$repo_root/assets/generated/logo.svg"
unlink_stale favicon.png
unlink_stale logo.png
unlink_stale apple-touch-icon.png
