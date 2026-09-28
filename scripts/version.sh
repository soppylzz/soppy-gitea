#!/usr/bin/env bash
# Resolve the version to release (D-021). version.txt is the single source of truth.
#
# If version.txt is ahead of the newest released tag, that is the release. If it is
# equal or behind - a forgotten bump, or a revert - fall back to a patch bump of the
# newest tag, so a release can never repeat a version or move backwards.
#
# Prints the tag name, e.g. v0.2.1. Needs the repo's tags (actions/checkout must use
# fetch-depth: 0).
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

declared="$(tr -d '[:space:]' < version.txt)"
if ! printf '%s' "$declared" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "version.sh: version.txt is not MAJOR.MINOR.PATCH: '$declared'" >&2
  exit 1
fi

# highest released version, by version sort; 0.0.0 when nothing is released yet
latest="$(git tag -l 'v*' | sed 's/^v//' | sort -V | tail -1)"
[ -n "$latest" ] || latest="0.0.0"

if [ "$declared" != "$latest" ] && [ "$(printf '%s\n%s\n' "$declared" "$latest" | sort -V | tail -1)" = "$declared" ]; then
  effective="$declared"
else
  IFS=. read -r major minor patch <<< "$latest"
  effective="$major.$minor.$((patch + 1))"
fi

echo "v$effective"
