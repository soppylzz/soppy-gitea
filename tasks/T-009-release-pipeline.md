# T-009 — Release pipeline: packaging, CI and bilingual README

- Status: review
- Owner: orchestrator
- Branch: main
- Depends: D-018, T-002 (build pipeline)

## Spec

Ship the theme as a downloadable artifact instead of a source checkout (D-018, resolving
D-009): a tag push must produce a GitHub release carrying a drop-in archive, CI must fail
on a broken build, and the READMEs must document installation in English and Chinese.

## Acceptance criteria

- [x] `scripts/check.sh` verifies determinism, the per-variant meta block, `@import`
      first, brace balance, and that every `/assets/soppy/` reference exists
- [x] `scripts/package.sh` emits `dist/soppy-<version>.zip` mirroring `<custom>/public/`
- [x] `.github/workflows/ci.yml` runs the checks on push/PR and uploads the archive
- [x] `.github/workflows/release.yml` resolves `version.txt`, tags and publishes (D-021)
- [x] `README.md` (en) and `README.zh-cn.md` (zh) document release and source installs
- [x] `RELEASE.md` ships as `INSTALL.md` inside the archive
- [x] `assets/OFL.txt` travels with the bundled font (license obligation)
- [x] `LICENSE` (MIT, D-019) added so the release can be public
- [x] `version.txt` is the release source of truth; the workflow creates the tag, so
      nobody tags by hand (D-021)

## Handoff log

- 2026-09-28 orchestrator: archive root mirrors the instance layout
  (`assets/css/`, `assets/soppy/`, `assets/img/`) so installation is one `cp -r`; the
  asset-existence check in `check.sh` was added after three brand symlinks in the preview
  instance dangled (deleted `assets/favicon.png`, `assets/logo.png`) — the custom asset
  layer *shadows* built-ins, so a dangling link 404s instead of falling back. Verified
  the guard fails on a deliberately missing reference.
- 2026-09-28 orchestrator: D-008 resolved by D-019 (MIT); no gitea-github-theme code was
  copied, so no Apache-2.0/NOTICE obligation applies.
- 2026-09-28 orchestrator: the brand set is SVG-only; `sync-preview.sh` now prunes the
  stale `img/` symlinks it used to create. Verified against the running instance
  (127.0.0.1:6300): the two SVG wrappers serve our art, the PNG paths fall back to
  upstream's. Consequence recorded in `gitea-root/README.md`: browsers that ignore SVG
  favicons show Gitea's default icon.
- 2026-09-28 orchestrator: the human renamed the Chinese README to `README.zh-cn.md`
  (switcher label 简体中文). D-018 keeps its original filename, per the D-011 precedent
  that historical entries are not rewritten.
