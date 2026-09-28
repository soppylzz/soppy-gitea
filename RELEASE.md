# soppy — pixel-art theme for Gitea

Light and dark variants of a pixel-art theme for **Gitea 1.27.3**. CSS only: it
overrides Gitea's own styles, adds no JavaScript and touches no templates.

This archive is laid out to mirror a Gitea instance's `custom/public/` directory, so
installing it is a single copy.

## Contents

```
public/assets/css/theme-soppy-light.css   the two theme files Gitea loads
public/assets/css/theme-soppy-dark.css
public/assets/soppy/…                     pixel font, landing-page art, font license
public/assets/img/favicon.svg             browser-tab icon
public/assets/img/logo.svg                navbar logo + PWA manifest icon
INSTALL.md, LICENSE                       these instructions and the theme license
```

## Install

1. Copy the `public/` directory from this archive over your instance's custom
   directory (default `$GITEA_CUSTOM`, usually `<gitea>/custom/`):

   ```sh
   unzip soppy-<version>.zip -d /tmp/soppy
   cp -r /tmp/soppy/public/. /path/to/gitea/custom/public/
   ```

2. Register the themes in `app.ini`:

   ```ini
   [ui]
   THEMES = gitea-auto,gitea-light,gitea-dark,soppy-light,soppy-dark
   DEFAULT_THEME = soppy-dark   ; optional
   ```

3. Restart Gitea and pick the theme under **Settings → Appearance**.

Only `/assets/img/favicon.svg` and `/assets/img/logo.svg` are shadowed; every other
icon path keeps Gitea's built-in art.

## Notes

- The code font (Fira Code / Fira Mono) is fetched from Google Fonts at runtime. On a
  server with no outbound network access, code falls back to the system monospace font;
  everything else is bundled.
- Gitea caches `/assets/*` for 6 hours. A theme that "does not change" after an update
  is usually the browser cache — hard-refresh, or restart Gitea to pick up the CSS.
- To uninstall: delete the two `theme-soppy-*.css` files, remove the `soppy` entry from
  `THEMES`, and restart. The `soppy/` directory and the two SVGs can go too.

## License

The theme is **MIT**-licensed (see the project repository).

The bundled pixel font (Ark Pixel 12px Monospaced, `public/assets/soppy/`) is
redistributed under the **SIL Open Font License 1.1** — see `OFL.txt`, which must stay
with the font.
