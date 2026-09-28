# Ground truth — pinned sources, verified mechanics, grep recipes

Verified against the pinned checkouts on 2026-09-28; both are READ-ONLY. If a task's
findings contradict this, re-verify against the source and propose a correction here.

## Pinned versions and paths

| What | Path | Role |
|---|---|---|
| Gitea source | `/Users/soppylzz/code/reference/gitea` | ground truth for tokens, selectors, markup, theme mechanics |
| gitea-github-theme | `/Users/soppylzz/code/reference/gitea-github-theme` | structural reference for a theme project; also targets 1.27.3 (`package.json` version) |

The gitea checkout is a shallow clone pinned by the human as 1.27.3. Treat both repos as
one compatibility target; re-pinning is a decision (D-001), not a task habit.

## Gitea theme mechanics (verified in 1.27.3 source)

### Load order — themes are override layers
`templates/base/head_style.tmpl`:

```
{{AssetCSSLinks "web_src/js/index.ts" "web_src/css/index.css"}}
<link rel="stylesheet" href="{{ctx.CurrentWebTheme.PublicAssetURI}}">
```

The full base bundle (`web_src/css/index.css`) is always linked first; the theme file is
linked after it and only needs to override. Canonical example:
`web_src/css/themes/theme-gitea-dark.css` — about 334 lines: one meta-info block, one
`:root` palette ladder, a handful of targeted rules (e.g. emoji invert filters).

### Theme discovery — file name and mandatory meta block
`services/webtheme/webtheme.go` scans for files named `theme-<name>.css` and parses this
block out of the CSS itself:

```css
gitea-theme-meta-info {
  --theme-display-name: "Soppy";
  --theme-color-scheme: "light"; /* or "dark"; drives auto switching */
}
```

A custom theme without this block falls back to filename-derived defaults and can break
appearance switching. Include it in every output file.

### Install and registration
- Custom themes live in `<CustomPath>/public/assets/css/theme-<name>.css`
  (`modules/public/public.go:26` layers `{CustomPath}/public` over built assets).
- `app.ini` `[ui] THEMES = gitea-auto,gitea-light,gitea-dark,<name>` filters the picker
  (`setting.UI.Themes`, `modules/setting/ui.go:29`); `[ui] DEFAULT_THEME` defaults to
  `gitea-auto` (`modules/setting/ui.go:97`).
- The picker reads display name / color scheme from the meta block above.

### Design token vocabulary (`web_src/css/base.css`, `:root`)
- Fonts: `--fonts-proportional`, `--fonts-monospace`, `--fonts-emoji`; composite
  `--fonts-regular`; hook `--fonts-override` (base.css:64) prepends a family to
  `--fonts-regular` without redefining the whole stack.
- Radii: `--border-radius` (4px), `--border-radius-medium` (6px), `--border-radius-full`.
- Colors (see `theme-gitea-dark.css` for the full ladder): `--color-primary` with
  `-dark-1..7`, `-light-1..7`, `-alpha-10..90`, `-hover`, `-active` companions; the grey
  ladder is `--color-secondary*`; `--is-dark-theme` is a boolean var components rely on.
- Component CSS lives in `web_src/css/` per area (`modules/` for Fomantic-flavored
  primitives, `features/`, `repo/`, `home.css`, ...), imported by `index.css`.

### Tailwind caveat
`tailwind.config.ts` exists — utility classes are being adopted upstream. Never assume a
template's markup from memory: grep `templates/**/*.tmpl` for the real classes of the
page you are styling.

## gitea-github-theme anatomy (structural reference)

- Stack: Bun + Vite 8 + `@vanilla-extract/css` (adapter hijacked for build-time
  CSS-in-TS) + lightningcss minify + vitest snapshot tests on build output.
- Layers (see its `ARCHITECTURE.md`): `theme.config.ts` → color definitions
  (`themes/*.ts`, Primer tokens from `@primer/primitives`) → palette transforms
  (`src/palette/`) → core framework (`src/core/`) → style overrides
  (`styles/public|components|templates|common`) → Vite plugin → `dist/theme-github-*.css`.
- `src/selectors.ts` is a curated inventory of the Gitea selectors the theme touches —
  the discipline this repo borrows (our version: the task-file audit, see
  `.agents/rules/workflow.md` gate G1).
- License: Apache-2.0 with a `NOTICE` file. Copying code from it (as opposed to taking
  inspiration) triggers attribution obligations — record any adaptation in
  `.agents/decisions.md`.

## Grep recipes (BSD grep, macOS)

```sh
G=/Users/soppylzz/code/reference/gitea

# where is a variable defined / what is its default value
grep -rn -e '--border-radius:' "$G/web_src/css"

# which stylesheet touches a class
grep -rln -e '.diff-file-box' "$G/web_src/css"

# where is a class used in real markup
grep -rn -e 'repo-header' "$G/templates" | head -20

# what does upstream's own dark theme override
sed -n '1,40p' "$G/web_src/css/themes/theme-gitea-dark.css"
```

## Dev preview loops (verified 2026-09-28)

Ordered by liveness; pick per task stage.

1. **Deployment shape + F5** — theme CSS in `<custom>/public/assets/css/`. Custom assets
   are served from disk per request (`modules/public/public.go:26`) and the theme list
   re-scans every second (`services/webtheme/webtheme.go`, `getAvailableThemes`), so a CSS
   edit needs only a browser refresh — no Gitea restart. It is exactly the deployed shape.
2. **Vite dev HMR** — run Gitea from a separate source clone (NOT the pinned reference):
   `TAGS="sqlite sqlite_unlock_notify" make watch` (`tools/watch.sh` = backend air + vite
   dev on :3001; Go serves HTML and proxies assets, `vite.config.ts` `appType: 'custom'`).
   In vite dev mode themes are served straight from `web_src/css/themes/`
   (`services/webtheme/webtheme.go`, `isViteDevMode` branch), so symlink our built CSS
   there — editing our source hot-reloads the browser. The `/devtest` route
   (`routers/web/devtest/`) renders most components on one page.
3. **Reference theme's loop** (for contrast): no watcher — `bun bundle` (`.env`
   `DEV_THEME` compiles a single theme for speed) then `sync:theme` scp's
   `dist/*.css` to a server; refresh manually. Loops 1 and 2 both beat it.
