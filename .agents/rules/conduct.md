# Conduct — rules for style, comments and commits

Binding core: `AGENTS.md` (non-negotiables) and `.agents/decisions.md` (decisions). This
file expands both into concrete rules; a decision wins over any rule here.

## 1. Comments

- English only.
- Sparse by default: only where intent is non-obvious — ordering constraints, why an
  override exists, an upstream quirk defended against, a link to the decision that
  forced a workaround.
- Never narrate the next line; no TODOs without a task reference (`T-###`).

## 2. Scope

- CSS only. JS, template or Go changes require an accepted decision entry first — if a
  styling goal seems to need one, stop and record the reason in the task file.
- No new dependencies, build steps or top-level directories without a decision entry.
- The override layer may only contain: the `gitea-theme-meta-info` block, `:root` token
  definitions, rules on existing Gitea selectors, `@font-face`, `@keyframes`.

## 3. Ground truth and naming

- Verify-then-write: before a selector or variable lands in the source, it was found by
  a grep in the pinned tree (recipes in `.agents/references/ground-truth.md`). Cite file:line in the
  task log for anything subtle.
- Order of authority for names: (1) Gitea pinned source, (2) gitea-github-theme,
  (3) this theme's own tokens — `--soppy-*` prefix exclusively.
- Gitea's vocabulary first: exhaust `--color-*`, `--fonts-*`, `--border-radius*` before
  inventing a token. Add `--soppy-*` tokens only for what Gitea does not parameterize
  (pixel shadow offsets, outline widths, palette extensions).
- No new classes: a theme cannot change markup. Attribute selectors (e.g.
  `.emoji[aria-label="..."]`) are allowed — upstream uses the same trick.
- `!important`: last resort, must carry a comment naming the exact upstream rule it
  defends against.
- Cascade discipline: our file loads after base `index.css` (D-004), so equal
  specificity wins by source order. Prefer order over specificity inflation; escalate
  only when a documented upstream rule forces it.
- Templates may carry Tailwind utility classes upstream — grep the real markup before
  writing a selector; never style from memory of another product.

## 4. Pixel style rules

- Palette discipline: all colors live in the `:root` layer; component rules reference
  vars, never raw hex. Every Gitea palette var that exists must be given a value in both
  variants — a half-filled ladder shows up as random blue accents.
- Geometry: zero radii, 1px borders, hard offset shadows (0 blur). Radii go through
  `--border-radius*` overrides; shadows and outline widths are `--soppy-*` tokens defined
  next to the palette so both variants can tune them.
- Typography: pixel/bitmap-style families via `--fonts-proportional` / `--fonts-monospace`
  (or the `--fonts-override` hook); ship WOFF2 with a redistributable license recorded in
  `.agents/decisions.md`.
- Imagery: `image-rendering: pixelated` where art is intentionally upscaled; never on
  user-uploaded photos/avatars where it degrades quality.
- Motion: near-zero transitions — instant state changes fit the aesthetic; keep focus
  outlines clearly visible (accessibility over aesthetics).
- Parity: every rule is checked in BOTH light and dark variants; `--is-dark-theme` may
  branch component rules only when palette vars cannot express the difference.
- Contrast: WCAG AA (4.5:1) for text in both variants — pixel fonts read worse than
  their metrics suggest, so do not trade contrast for style.

## 5. Formatting

- 2-space indent, LF, final newline (`.editorconfig`).
- One selector per line in comma lists; properties grouped logically (layout → box →
  typography → paint); long override sections separated by short banner comments
  (`/* ---- buttons ---- */`) — these count as structural, not narrative, comments.
- Match the surrounding file's style when editing an existing file.

## 6. Git

- Conventional Commits, English: `type(scope): summary` — types: `feat`, `fix`, `style`,
  `refactor`, `docs`, `build`, `chore`. Scope is the area touched, e.g.
  `feat(palette): ...`, `docs(workflow): ...`.
- One logical change per commit; commit only after the applicable verification gates pass
  (`.agents/rules/workflow.md`).
