<h1 align="center"><img width="60%" src="./assets/wordmark.png" alt="soppy-gitea" /></h1>
<p align="center">
  <a href="https://github.com/soppylzz/soppy-gitea/releases"><img src="https://img.shields.io/github/v/release/soppylzz/soppy-gitea" alt="Latest GitHub release" /></a>
  <img src="https://img.shields.io/badge/Gitea-1.27.3-609926" alt="Gitea 1.27.3" />
  <img src="https://img.shields.io/badge/CSS-theme-1572B6" alt="CSS theme" />
</p>

<div align="center">

[English](README.md) | [简体中文](README.zh-cn.md)

</div>

A pixel-art theme for **Gitea 1.27.3**, with light and dark variants. It uses CSS overrides without changing JavaScript, templates, or Go code.

## Features

- **Pixel typography** — the Ark Pixel 12px Monospaced face (CJK included) across the
  whole UI, with Fira Code / Fira Mono for code
- **Two complete palettes** — cool neutral light surfaces, a deep dark variant, each
  filling Gitea's entire `:root` token ladder so no upstream default leaks through
- **Square geometry** — zero radii, 1px borders, hard offset shadows and raised/pressed
  bevels in place of Gitea's soft corners and blurred elevation
- **Contrast-aware colored controls** — adjusts text on status badges and buttons in the
  dark variant, where Gitea's hardcoded white text would fall below AA contrast
- **Brand art** — a landing-page hero and wordmark, plus a matching favicon

## Installation

### From a release

Every [release](https://github.com/soppylzz/soppy-gitea/releases) ships `soppy-<version>.zip`, laid out to mirror a Gitea
instance's `custom/public/` directory, so installing it is one copy:

```sh
unzip soppy-<version>.zip -d /tmp/soppy
cp -r /tmp/soppy/public/. /path/to/gitea/custom/public/   # $GITEA_CUSTOM
```

The archive contains both theme files, the pixel font, the landing-page art, the
licenses and the two SVG brand wrappers.

### From source

```sh
scripts/build.sh    # -> dist/theme-soppy-light.css, dist/theme-soppy-dark.css
scripts/package.sh  # -> dist/soppy-<version>.zip (the same layout as a release)
```

Copy the two CSS files into `<custom>/public/assets/css/` **together with** the `assets/`
directory as `<custom>/public/assets/soppy/` — the stylesheet references
`/assets/soppy/…` for the pixel font and the landing-page art, so a CSS-only copy will
404 on those.

### Register the theme

In `app.ini`, then restart Gitea:

```ini
[ui]
THEMES = gitea-auto,gitea-light,gitea-dark,soppy-light,soppy-dark
DEFAULT_THEME = soppy-dark   ; optional
```

Pick the theme under **Settings → Appearance**.

## Notes

- The code font (Fira Code / Fira Mono) is loaded from Google Fonts via `@import`; when
  the browser cannot reach Google Fonts, code falls back to the system monospace stack.
  The body face is bundled and always available.
- Gitea caches `/assets/*` for 6 hours; a theme that "does not change" after an update is
  usually the browser cache.
- Uninstall: delete the two `theme-soppy-*.css` files, drop the `soppy-*` entries from
  `THEMES`, restart.

## License

MIT — see [LICENSE](LICENSE).

The bundled pixel font (Ark Pixel 12px Monospaced) is redistributed under the **SIL Open
Font License 1.1** — see `assets/OFL.txt`, which must travel with the font.
