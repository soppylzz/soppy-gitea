# Backlog — claim board

To claim: copy `TEMPLATE.md` to `T-###-<slug>.md` (continue the numbering), fill spec +
acceptance criteria, then set owner/status here AND in the task file — claim before
work. Split a row into per-concern tasks when it grows (see T-006).

| ID | Title | Owner | Status |
|----|-------|-------|--------|
| T-001 | Decide theme name + token prefix (feeds D-005) | orchestrator | done |
| T-002 | Scaffold source layout + build pipeline (closes D-006) | orchestrator | done |
| T-003 | Pixel palette: light + dark `:root` ladders | agent-palette | in-progress |
| T-004 | Pixel font: selection, license, integration (feeds D-007) | agent-fonts | review |
| T-005 | Geometry pass: radii, borders, hard shadows | agent-components | review |
| T-006 | Component passes (buttons, labels, navbar, cards, diff, forms, ...) | - | draft |
| T-007 | Test harness: local Gitea instance + visual checklist | agent-preview | in-progress |
| T-008 | Pixel grid font-size snap pass (needs G3 feedback) | agent-components | review |
| T-009 | Release pipeline: packaging, CI and bilingual README | orchestrator | review |
| T-010 | Review fixes: fill contrast, diff code size, missed overrides | orchestrator | review |
| T-011 | Prepare atomic history and verify GitHub delivery | codex | done |

## Notes (expand into the task file when claiming)

- **Open decision** — license (D-008): original work keeps the choice open; adapting
  gitea-github-theme code triggers Apache-2.0/NOTICE obligations.
- **T-003** — foundation task; components consume vars only. Fill every existing Gitea
  palette var in both variants (incomplete ladders leak upstream defaults), validate
  WCAG AA contrast, define `--soppy-*` geometry/extension tokens alongside. Blocks
  T-005/T-006.
- **T-004** — pixel/bitmap font, WOFF2, redistributable license, `@font-face` +
  `--fonts-proportional`/`--fonts-monospace` override (see `--fonts-override` hook,
  base.css:64). Falls back gracefully when the font fails to load.
- **T-005** — zero radii via `--border-radius*`, 1px borders, hard offset shadows as
  `--soppy-*` tokens; audit hard-coded radii/shadows upstream and override each with
  cited selectors. Depends on T-003.
- **T-006** — one component per claimed task; always grep template + stylesheet first
  (gate G1). Depends on T-003 (and T-005 for geometry-heavy components).
- **T-007** — wire up BOTH preview loops verified in
  `.agents/references/ground-truth.md` ("Dev preview loops"): (a) local binary
  instance under `gitea-root/` with its custom dir pointing into this repo
  (deployment shape + F5), and (b) a vite-dev Gitea clone OUTSIDE the reference
  paths with our CSS symlinked into `web_src/css/themes/` (HMR). Then walk the G3
  page list in `.agents/rules/workflow.md` in light + dark.
