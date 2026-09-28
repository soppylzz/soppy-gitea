# T-005 — Pixel components: geometry, bevels, hero art

- Status: review (G3 feedback rounds 1-4, 6, 7 applied; round-8 type-scale refactor lives in T-008; 2026-09-28; awaiting human re-check; orchestrator commits)
- Owner: agent-components
- Branch: main (orchestrator commits after gates)
- Depends: T-003 (token contract is fixed in the T-003 task file — no need to wait)

## Spec
First-pass component overrides delivering the minecraft.net pixel feel on top of the
Gitea base. Scope (keep it shippable): global geometry, buttons, labels, inputs,
navbar, cards/segments, focus/selection, home hero.

## File ownership (do NOT touch anything else)
- `src/components.css` — shared by both variants; branch on `--is-dark-theme` only when
  palette vars cannot express the difference

## Constraints
- Consume palette only via vars: `--color-*` + contract tokens `--soppy-bevel-raised`,
  `--soppy-bevel-pressed`, `--soppy-shadow-hard`, `--soppy-border-strong` (defined in
  T-003's files; do not define them here)
- Zero radii (`--border-radius*` overrides), 1px borders, bevels via inset box-shadows
  (classic MC button look) on interactive elements
- G1 gate: EVERY selector verified against the pinned source first — grep
  `templates/**/*.tmpl` + `web_src/css/` (recipes in
  `.agents/references/ground-truth.md`). Log selector → citation in the task log.
- Home hero: apply `assets/landscape.png` as a CSS background on the real home page
  hero element (find it via `templates/home.tmpl` + `web_src/css/home.css`), URL
  `/assets/soppy/landscape.png`, `image-rendering: pixelated`, sensible sizing/placement.
  Avatars/photos are NEVER pixelated.
- Check base.css:77 (`font-size: 14px`) — snap body copy to the pixel grid if it can be
  done safely; log the decision either way.
- `!important` last resort with justification comment.

## Acceptance criteria
- [x] Selector audit logged with citations
- [x] No raw hex, no font-family declarations, no new classes
- [x] Hero art wired on the home page only

## Handoff log

### 2026-09-28 — agent-components — first pass complete (`src/components.css`, 26 rule blocks)

**Token contract — confirmed against T-003's landed files.** T-003 delivered
`--soppy-bevel-raised` / `--soppy-bevel-pressed` as full inset box-shadow lists
(raised = lit top-left, pressed = flipped) and `--soppy-shadow-hard` as a full hard
offset shadow (`4px 4px 0 0 ...`); only `--soppy-border-strong` is a color. This file
was first drafted against a colors-reading of the contract and corrected to bare
`box-shadow: var(--soppy-...)` consumption as soon as `src/palette-{light,dark}.css`
appeared — nothing in components.css composes offsets around the tokens anymore, so
palette-side retunes apply as-is. Consequences: bevel/elevation geometry (2px edges,
4px drop) is owned by T-003's values; the navbar active item uses the pressed bevel and
the toggle knob the raised bevel (proportionate to its 18px knob) instead of bespoke
offsets. T-003 files define no `--border-radius*`, so the geometry overrides here don't
collide with them.

**Selector audit (G1) — selector → pinned-source citation.** Every class name in the
file was additionally machine-checked: all 62 classes grep-hit in
`web_src/css` or `templates` of the pinned checkout. Vars used: `--color-primary`,
`--color-primary-contrast` (theme-gitea-light.css:9, used at button.css:186),
`--color-secondary`, plus the four contract tokens. No `--is-dark-theme` branching was
needed — everything is expressible through palette vars.

Geometry:
- `:root` `--border-radius/-medium/-full: 0` — base.css:25-27 (4px/6px/99999px); kills
  every var-driven radius upstream: `.ui.button` (button.css:14), `.ui.label`
  (label.css:17), `.ui.card` (card.css:24), avatars `img.ui.avatar...` (avatar.css:4 —
  avatars become square automatically, no image-rendering involved),
  `::file-selector-button` (base.css:245), `.btn` (button.css:289),
  `.ui.dropdown .menu` var corners (dropdown.css:75, 670).
- Fomantic hard-coded `0.28571429rem` family, killed per surface (mirrored selectors,
  so cascade ties break by source order): forms/inputs (input.css:19, 52, 74, 108, 116;
  form.css:55, 63), segments (segment.css:8, 22, 34, 61, 69, 74, 83, 100, 103, 144, 159),
  menus (menu.css:9, 45, 94, 106, 177, 180, 235, 238, 241, 291, 294, 342, 356, 446, 518,
  525), tables (table.css:8, 44, 47, 50, 66, 69, 165), dropdowns (dropdown.css:27, 188,
  220, 616), search results (search.css:17), attached header (header.css:90).
- Upstream `!important` radii mirrored with `!important` + comment: `.ui.tabular.menu
  .active.item` (menu.css:273), `.ui.secondary.vertical.menu > .item` (menu.css:367),
  `.ui.active.empty.selection.dropdown` (dropdown.css:318),
  `.ui.active.upward.selection.dropdown` (dropdown.css:630),
  `.ui.upward.selection.dropdown.visible` (dropdown.css:635),
  `.ui.floating.dropdown .menu` / `> .menu` (dropdown.css:730, 734).
- Misc hard-coded radii: navbar items (navbar.css:30), navbar badges
  (navbar.css:120 selector `#navbar a.item .notification_count` etc.), `.ui.circular.label`
  (label.css:209; used by projects board, templates/projects/view.tmpl:84),
  `.code-expander-buttons .code-comment-more` (review.css:90, mirrored `!important`),
  `.inline-code-block` (base.css:379), `.language-stats` (repo/home.css:91),
  `.indicator-dot::after` (helpers.css:45), editor lint markers
  (codeeditor.css:427, 435), EasyMDE toolbar buttons (easymde.css:269-279),
  native `input[type=radio]`/`[type=checkbox]` (checkbox.css:9, 25), toggle track/knob
  (checkbox.css:138, 152).

Buttons: `.ui.button` base (button.css:1-22 — border already 1px, radius var-driven);
bevel = two inset box-shadows on `.ui.button` + `::file-selector-button` (base.css:241);
pressed bevel (edges flipped) on `.ui.button:active, .ui.active.button` (upstream state
rules button.css:30-47, 160-177, 183-198, 216-275 only swap background/color vars, so
the bevel survives hover/active/primary/red/green untouched).

Labels: `.ui.label:not(.scope-parent) { border-width: 1px; border-color:
var(--color-secondary) }` — upstream `.ui.label` has `border: 0 solid transparent`
(label.css:16). Specificity deliberately kept LOW: colored variants
`.ui.ui.ui.<color>.label` (label.css:69+, 0,4,0) and `a.ui.label:hover` (label.css:51-55)
keep winning border-color; `.ui.basic.label` (label.css:57-61) therefore also picks up
`--color-secondary` instead of `--color-light-border` (accepted, more pixel-chip look);
scope-parent excluded or the composite two-tone label gets a stray rectangle.

Inputs: radius 0 + focus inset ring `inset 0 0 0 1px var(--color-primary)` on
`.ui.input > input:focus` (upstream border-color signal: input.css:29-31; upstream kills
the outline: input.css:14 — kept, since the border + ring carry focus indication),
same for `.ui.form input...`, `.ui.search > .prompt`, `.ui.form textarea` (form.css:44-64).

Navbar: `#navbar` bottom edge recolored via `--soppy-border-strong` (upstream 1px
`--color-secondary` border: navbar.css:1-7); active item pressed bottom edge
`inset 0 -2px 0 0 var(--soppy-bevel-pressed)` on `#navbar .item.active` (navbar.css:32-34);
items + badges squared (navbar.css:30, 111-120).

Cards/segments: radius only — no rest-state shadows on segments/cards (upstream
explicitly flattens many: segment.css:51, card.css:22, grid.css:63/213, repo.css:966/1121/1494).
Hard shadows reserved for floating surfaces (below).

Elevation (soft → hard 3px offset): dropdown menus incl. all state re-sets
(dropdown.css:25, 221, 277, 284, 294, 304, 309, 615, 622, 881; closed-dropdown glows
`0 0 2px/3px` → none: dropdown.css:626, 634, 639), tippy themes (tippy.css:44, 50, 80,
119), `.ui.modal` (modal.css:10), `.toastify` (toast.css:9), `.cm-command-palette`
(codeeditor.css:340), `text-expander .suggestions`/`.tribute-container`
(features/expander.css:10), `overflow-menu .overflow-menu-popup` (base.css:509-522),
`.ui.search > .results` (search.css:18), toggle knob (checkbox.css:143), migrate cards
hover (repo.css:1657, mirrored `!important`; smooth `transform: scale(105%)` disabled).

Focus/selection: focus ring 3px inset (upstream 2px/-2px: base.css:315-320; offset kept
negative so it cannot clip in overflow containers); `::selection` → primary fill +
`--color-primary-contrast` (upstream primary-light-1 + white: base.css:253-256).

Home hero: `.page-content.home div.hero` — the real tagline block, templates/home.tmpl:6;
`div` element-qualification is required because four `h1.hero` section headers exist on
the same page (home.tmpl:16, 24, 34, 42). `assets/landscape.png` is 1962x802 RGBA with a
fully transparent sky (corner/top pixels decoded: alpha 0), so it sits cleanly on both
variants: bottom-center, `background-size: min(100%, 760px) auto`, `padding-bottom: 240px`
reserves the ground strip below the tagline (140px / 100% width under 768px), 
`image-rendering: pixelated` on this brand art only. The `home` page-content class exists
only on the landing page (grep `page-content home` → home.tmpl:2 only) — hero art is
home-page-only as required.

**font-size decision (base.css:77): NOT snapped — logged why.** `html, body { font-size:
14px }` is also Gitea's rem basis (1rem = 14px): dropping it to 12px rescales every
rem-based padding/size/min-height app-wide (e.g. `.ui.button` padding `0.57em 1.43em` +
`min-height: 38px` at button.css:99-103 is tuned to the 14px base), and desyncs fixed
px companions that assume it: body `line-height: 20px` (base.css:81), `--line-height-code:
20px` (base.css:16), `--checkbox-size: 14px` (base.css:32). That is a global layout
change that cannot be eyeballed in this task (G3 harness is T-007, still in flight).
Also, ark-pixel ships as scalable outline WOFF2 (renders cleanly at any size, merely
off its native 12px grid), so nothing breaks at 14px today. A grid-snapping pass, if
wanted, should be a dedicated task with the preview instance up.

**Upstream quirks defended/logged.**
- `.ui.button.add-code-comment` is flattened upstream with `box-shadow: none !important;
  border: none !important` (review.css:1-10) — intentionally left alone; those floating
  mini buttons stay flat.
- Loading spinners kept round on purpose (dropdown.css:553, 568; codeeditor spinners):
  motion elements, not chrome.
- `.migrate-entry` rest shadow stays `none` (repo.css:1648 pins it with `!important`);
  only the hover is pixelized.
- Skipped as insignificant (log-only): colorpicker checkerboard swatch 2px
  (features/colorpicker.css:17), `.broken-code-point` 4px/2px (charescape.css:8, 20),
  swagger standalone page 4px (swagger-standalone.css:42, API-docs-only),
  search-result thumbnail 0.25em (search.css:53, photo imagery).
- `--border-radius-full: 0` also squares `.color-icon` (base.css:745) — intended.

**State left behind.** `src/components.css` only; nothing else touched, no git ops.
Gates: G1 pass (audit above), G2 n/a until the pipeline lands, G3 pending T-007 —
explore/home, repo home, diff and settings pages should be eyeballed in light AND dark
once the harness is up. In particular check that T-003's 4px hard drop shadow reads
well on dropdown menus and modals, and that the bevel on `.ui.button` at mini/tiny
sizes (30px/26px min-height, button.css:116-136) isn't too chunky — both are one-line
palette-file tweaks if not.

## G3 feedback round 1 (2026-09-28, human)
- Status reopened; T-008 claimed into this pass (fonts too small in both regular and
  code). Revisit the base.css:77 decision: raise the base font size (evaluate html
  14px -> 15px or 16px; audit the fixed-px companions base.css:16/32/81 and button
  metrics first, log the desync surface and your choice), and neutralize the 0.95em
  monospace compensation at base.css:107 — it is wrong for the proportional serif
  code face (aim 1em or slightly above).
- Home hero logo: `.page-content.home img.logo` (home.tmpl:5, width/height 220) — swap
  its content to url("/assets/soppy/brand.png"), image-rendering: pixelated. The
  header keeps the shadowed logo.svg handled by T-007, so scope the swap to the home
  page context only.
- That hero logo img needs padding (or margin) so it breathes against surrounding
  content; snap the value to the 12px pixel grid.

### 2026-09-28 — agent-components — round-1 fixes applied

**Font-size work moved to T-008** (claimed on the board): base raised 14px → 16px,
body line-height 20px → 24px, `--line-height-code` 20px → 24px, 0.95em code
compensation neutralized to 1em, mini/small button px sizes snapped to 12px. Full
desync-surface audit and the 15px-vs-16px reasoning: see
`tasks/T-008-pixel-grid-font-size.md`.

**Home hero logo (this task).** `.page-content.home img.logo` (home.tmpl:5 — the
`<img class="logo" width="220" height="220" src=".../logo.svg">` inside the landing
`.center` block; upstream sizing home.css:1-3 `.home .logo { max-width: 220px }`):

```css
.page-content.home img.logo {
  content: url("/assets/soppy/brand.png");
  width: 360px;
  max-width: 100%;
  height: 120px;
  object-fit: contain;
  image-rendering: pixelated;
  margin: 24px 0 12px;
}
```

- Scope: the `.page-content.home` prefix keeps it on the landing page only
  (grep `page-content home` hits home.tmpl:2 only); the navbar logo img is a
  different element (base/head_navbar.tmpl) and is untouched — T-007 owns it.
- Geometry: brand.png is 2172x724, exactly 3:1 — 360x120 keeps BOTH box dims on the
  12px grid (30×12, 10×12). `width`/`height` CSS override the 220x220 presentation
  hints; `max-width: 100%` lets it shrink fluidly below 360px viewports
  (letterboxed by object-fit, no distortion).
- `content: url()` is the img content swap — supported in Chromium/Firefox; Safari
  ignores it and keeps logo.svg, where `object-fit: contain` letterboxes the square
  svg inside 360x120 (graceful, no layout break). Logged as a known degrade.
- `image-rendering: pixelated` on brand art only (2172 → 360 is a ~6x downscale; if
  nearest-neighbor crunch shows in the next G3 pass, the options are a larger box,
  a pre-scaled asset, or dropping the pixelated flag — one-line change).
- Breathing room: `margin: 24px 0 12px` (2 + 1 grid units; margin not padding, so
  the replaced content paints edge-to-edge). 24px clears the navbar, 12px seats the
  wordmark above the tagline block.

Verification after the round-1 edits: 33 rule blocks, braces balanced, no raw hex,
no font-family declarations, 67 class names all grep-verified in the pinned tree.
Nothing outside `src/components.css`, `tasks/T-005-pixel-components.md` and
`tasks/T-008-pixel-grid-font-size.md` was touched; no git ops.

## G3 feedback round 2 (2026-09-28, human)
- Status reopened. Apply the pixel font as a DISPLAY face, mirroring how minecraft.net
  uses its pixel type: headings and stylized surfaces only, never body copy, inputs,
  or code. Consume the new `--soppy-font-pixel` token from T-004 (do not hardcode the
  family; if the token is not there yet, code against the name and note it — the
  fonts task lands in parallel). G1 audit every heading selector you touch. Suggested
  scope, decide tastefully and log: page-level h1/h2, home hero text, buttons and/or
  labels if they read well at 12px-grid sizes. Watch CJK rendering (ark-pixel zh_cn
  covers CJK) and line-height fit after the swap.

### 2026-09-28 — agent-components — round-2 display face applied

**Scope decision: page-level h1/h2, all `.ui.header` chrome headings, `.ui.label`.
Buttons excluded.** Reasoning per surface:

- `.page-content h1, .page-content h2` — the only raw h1/h2 in real pages are the
  home hero title, tagline and four section headers (templates/home.tmpl:7, 10, 16,
  24, 34, 42); every other raw h1/h2 lives in templates/devtest/*.tmpl (dev-only
  surface, pixel there is convenient for eyeballing). Cited.
- `.ui.header` — Gitea's structural heading component, used across install, org,
  projects, auth and repo pages as h1-h3 (e.g. templates/install.tmpl:5,
  templates/projects/new.tmpl:1, templates/user/auth/activate.tmpl:6), plus modal
  titles and `.ui.attached.header` boxes. Upstream pins the family here:
  header.css:9 `font-family: var(--fonts-regular)`, so the swap is a direct
  replacement (same 0,1,0 specificity, later source wins). `.sub.header`
  (header.css:27-35) inherits the family — pixel sub-headers, MC-like.
- `.ui.label` — runs at `--font-size-label: 12px` (base.css:42), which is exactly
  ark-pixel's native 12px grid: the one surface that renders 1:1 with no scaling.
- Buttons: excluded. `.ui.button` is `white-space: nowrap` (button.css:21) with long
  localized labels ("Create Pull Request") — overflow risk with a wide display face
  — and the 16px button size is off the native grid. Revisit as a dedicated pass if
  the human wants MC-style buttons.

**Anti-smear weight override.** Upstream sets `--font-weight-medium` on `.ui.header`
(header.css:10) and `.ui.label` (label.css:15); ark-pixel ships a single weight, so a
500/700 request triggers synthetic bold and blurs the bitmap outlines. All display-face
rules set `font-weight: var(--font-weight-normal)` (base.css:11 = 400).

**User-content exemption.** `.markup h1, .markup h2 { font-family:
var(--fonts-regular) }` placed after the apply rule — equal specificity
(0,1,1 vs 0,1,1), so source order decides (D-004 cascade). README/issue headings are
authored copy and wrap poorly in a display face; upstream styles them at
markup/content.css:65+. Markup h3-h6 were never pixelated, so no exemption needed.

**Line-height fit — no overrides, watch-item logged.** Kept upstream leading:
`.ui.header` 1.28571429 (header.css:11), `.sub.header` 1.2 (header.css:33), hero h1
inherits the 24px body leading (T-008) — same single-line model upstream already used
(77px glyphs on a 20px line box), so no layout change beyond the size. If the ark-pixel
metrics overflow visibly in G3, the fix is per-selector line-height, not a global one.

**CJK.** ark-pixel zh_cn covers CJK (D-013); unknown glyphs fall through the token's
stack, which is T-004's file. Nothing to do here.

**Token status.** Written against the token name before T-004 landed; now confirmed
on disk — src/fonts.css:24 defines `--soppy-font-pixel: "Ark Pixel 12 Monospace SC",
var(--fonts-proportional)` (ark-pixel first, reading-face ladder behind), so no
unresolved reference remains and the earlier not-yet-on-disk note is superseded.
Bonus: T-004 also repointed `--fonts-proportional` at LXGW WenKai Screen
(fonts.css:17), so the body/reading face is no longer ark-pixel and the
`.markup` exemption above inherits a genuine reading face — the round-2 model is
fully consistent now.

Verification after round-2 edits: 36 rule blocks, braces balanced, no raw hex, no
literal font-family (three `font-family: var(--*)` consumptions only), 68 class names
all grep-verified in the pinned tree. No git ops; nothing touched outside
`src/components.css` and the two task files.

### 2026-09-28 — agent-components — round-3 navigation display face applied

**Upstream fact that shapes everything below:** four upstream rules pin the reading
family directly on controls — `.ui.button` (button.css:7), `.ui.input > input`
(input.css:15), `textarea` (base.css:93), `.ui.menu` (menu.css:5). A direct
declaration beats inheritance, so buttons/inputs inside a pixel-faced block stay on
the reading face WITHOUT exemptions; only descendants with no upstream family
declaration actually inherit the pixel face. This decided which re-exemptions were
needed (fewer than the feedback assumed) — each logged below.

**1. Repo tab strip: `overflow-menu.ui.menu .item`.** Markup verified: every
`<overflow-menu class="ui ... menu">` instance carries the ui menu classes
(templates/repo/header.tmpl:96, org/menu.tmpl:2, explore/navbar.tmpl:1,
user/overview/header.tmpl:1, user/auth/signup_openid_navbar.tmpl:1,
user/auth/link_account.tmpl:3, repo/diff/image_diff.tmpl:14; styles base.css:560-567).
Descendant match on purpose: when tabs overflow, JS MOVES items into the sibling
`.overflow-menu-popup` (base.css:509), so a `.overflow-menu-items`-scoped rule would
half-lose the face; the popup items stay pixel with this shape. Blast radius beyond
the repo strip is all tab-strip navigation (org/explore/auth tabs) — consistent.
Count chips inside tabs are `.ui.small.label` → already pixel via the round-2 label
rule. Selector-level citations: element+classes verified in all 7 template instances
above; `.item` at base.css:565, popup items styled at base.css:544-556.

**2. `.repo-header` (templates/repo/header.tmpl:4, repo.css:1).** The container goes
pixel: owner/name links (header.tmpl:9) and the flex-text-block chrome inherit it.
Re-exemptions audit:
- Buttons (transfer accept/reject header.tmpl:48-53, watch button
  repo/header/watch.tmpl:8): NO rule needed — `.ui.button` declares
  `var(--fonts-regular)` at button.css:7 directly.
- Repo switcher search input (header.tmpl:15-18): NO rule needed —
  `.ui.input > input` declares the reading family at input.css:15.
- Dropdown panel (repo switcher `.menu.flex-items-menu`, header.tmpl:12-19):
  EXEMPTED — dropdown.css declares no family, so panel content would inherit pixel.
  Rule: `.repo-header .ui.dropdown .menu, .repo-header .ui.dropdown .menu .item` →
  `var(--fonts-regular)`. The `.item` arm is kept for symmetry/robustness (no current
  direct pixel rule matches these items).
- Watch-mode tippy popup (watch.tmpl:11+): rendered from a `.tippy-target` inside the
  header but MOVED into a body-level tippy box when shown — re-inherits outside the
  header, renders reading face. Judgment call: matches the panels-stay-reading
  decision; no rule needed.
- `.ui.basic.label` chips (archived/private/template, header.tmpl:27-46): stay pixel
  via the round-2 `.ui.label` rule — chips are stylized chrome, desired.

**3. Settings side nav: `.ui.fluid.vertical.menu > .item`.** Exact classes verified:
`<div class="ui fluid vertical menu">` at templates/user/settings/navbar.tmpl:2,
org/settings/navbar.tmpl:2, repo/settings/navbar.tmpl:2 (the human's phrasing was
literal). The child combinator keeps nested sub-menus out: the admin navbar
(admin/navbar.tmpl:2, same genre) nests `<details class="item">` with an inner
`.menu` — top-level summary goes pixel, sub-items inherit from the details element
(pixel) — logged: admin sub-items render pixel too, uniform with the side nav,
accepted. Other same-genre surfaces hit by the bare class selector (all left-hand
navigation, accepted and logged): repo/navbar.tmpl:2 (activity page side nav,
included at repo/activity.tmpl:6), repo/actions/sidebar.tmpl:2 (workflow list,
gt-ellipsis truncation unaffected), repo/actions/artifact_preview.tmpl:25 (file-tree
preview side nav). `.header.item` ("User Settings" caption) goes pixel — chrome,
desired. None of the three settings navbars contain dropdown/nested menus (grepped).

**4. `#navbar .item` (base/head_navbar.tmpl, styles navbar.css:1-45).** Covers the
top-level links (Issues/PRs/Milestones/Explore/Help/Sign in/Register,
head_navbar.tmpl:29-53, 136-151), the dropdown triggers (`.ui.dropdown.jump.item`,
head_navbar.tmpl:62, 90, 107) and the mobile expand toggle. Judgment calls, logged:
- Dropdown panels (user menu, create menu — head_navbar.tmpl:66-88, 93-135):
  EXEMPTED to the reading face — task menus with longer localized labels
  ("Notification subscriptions") scan better in the body face, mirroring the
  repo-header panel decision. Rule: `#navbar .ui.dropdown .menu,
  #navbar .ui.dropdown .menu .item`. The `.item` arm is REQUIRED here: panel items
  match `#navbar .item` directly, and a direct rule beats the exemption's
  inheritance.
- Search input: NONE EXISTS in the 1.27 navbar — the full template contains no
  `<input>`; the coordinator's "re-exempt the search input" is n/a (repo search lives
  in the repo header switcher, handled in item 2). Any future navbar inputs under
  `.ui.input` get input.css:15's reading family automatically.
- Mobile expand button (`.item.ui.icon.mini.button`, head_navbar.tmpl:17): matches
  `#navbar .item` (ID specificity beats button.css:7) but is icon-only — no text,
  harmless; left pixel.
- Stopwatch popup mini buttons (head_navbar.tmpl:160-180): `.ui.button` without
  `.item` — not matched, stay reading via button.css:7.
- Count badges `.notification_count` / `.header-stopwatch-dot` /
  `.navbar-admin-badge` (navbar.css:118-139): inherit the pixel face at 12px —
  exactly ark-pixel's native grid, 1:1 — but upstream sets `--font-weight-bold`
  (navbar.css:121) and synthetic bold smears the bitmap. Added an anti-smear rule
  with the selector mirrored verbatim from navbar.css:118-121 so it wins by source
  order: `font-weight: var(--font-weight-normal)`.

**Untouched by design:** font-weight normal everywhere (no synthetic bold on the
bitmap face); the `.markup` exemption from round 2 stands; body copy/inputs/code
never receive the pixel face directly. No new classes, no !important added this
round.

Verification after round-3 edits: 43 rule blocks, braces balanced, no raw hex, nine
`font-family` declarations all `var()` consumptions (--soppy-font-pixel x6,
--fonts-regular x3), 71 class names all grep-verified in the pinned tree (one
extractor false positive was "net-style" from the phrase "minecraft.net-style" in a
comment). No git ops; nothing touched outside `src/components.css` and the two task
files.

## G3 feedback round 3 (2026-09-28, human)
- Status reopened. Extend the display face (var(--soppy-font-pixel)) to navigation
  surfaces, G1-audited as always:
  1. Repo page tab strip: `.overflow-menu-items` (verify real markup in the pinned
     templates — repo header tabs)
  2. `.repo-header` — the header block; ONLY its text runs pixel: re-exempt the
     interactive controls inside (buttons, inputs, dropdown triggers/panels) back to
     the reading face at the necessary specificity
  3. Settings side nav (user/org/repo settings): the vertical menu items — the human
     phrased it as "ui fluid vertical menu > item"; grep templates/user/settings/**
     and templates/org/** for the exact classes before writing
  4. Top navbar `#navbar` — nav text in pixel; re-exempt form controls (search input)
     and dropdown panels where the body face reads better; log each judgment call
- Keep font-weight normal, keep the .markup exemption, log citations for every new
  selector.

## G3 feedback round 4 (2026-09-28, human)
- Status reopened. You own BOTH files this round (coupled change): fonts.css stack edit
  per the T-004 round-4 section, plus the cleanup below.
- With the body face becoming ark-pixel, every display-face rule you added in rounds 2
  and 3 (h1/h2, .ui.header, .ui.label, .markup exemption, overflow-menu, .repo-header,
  settings vertical menu, #navbar .item) becomes a no-op — the family is inherited
  everywhere anyway, and upstream's direct font-family declarations on buttons/inputs/
  textarea/menus point at the same vars. Remove the redundant family declarations and
  the --soppy-font-pixel token (definition + all references; grep-verify zero left).
- KEEP what is not redundant: the anti-smear `font-weight: var(--font-weight-normal)`
  pins on display positions (.ui.header, .ui.label, navbar badges) and the dropdown
  panel exemptions stay meaningful only if they still do something — re-evaluate each
  and keep only those that change the rendered result; log the reasoning per block.
- CONSEQUENCE to verify and log: code contexts must still render Fira (they consume
  --fonts-monospace; confirm no rule accidentally forces the proportional face there).
  Body stays 16px — ark-pixel is an outline woff2 at a 1.333x scale of its 12px design
  grid; note the tradeoff (12px too small, 24px too large) and log it as accepted.
- Net expected result: one font system for the page (ark-pixel), one for code (Fira).

### Round 4 acceptance
- [x] Redundant `font-family` declarations from rounds 2-3 removed; no `font-family`
  declaration remains in `src/components.css`
- [x] `--soppy-font-pixel` gone from both files — grep over `src/` returns zero
- [x] Anti-smear weight pins survive where upstream's weight still reaches the pixel
  face, each with the upstream rule cited; every removal justified in the log
- [x] Code contexts still consume `--fonts-monospace` (Fira) — consumers enumerated
- [x] Body 16px unchanged; 1.333x grid-scale tradeoff logged as accepted
- [x] No raw hex, no new classes, no git

### 2026-09-28 — agent-components — round-4 cleanup (one family for the page)

Coupled round: `src/fonts.css` (stack per the T-004 round-4 section, logged there) and
`src/components.css` (cleanup below). Only those two files plus the two task files
touched; no git actions.

**Removed — everything that became a no-op once the body face is ark-pixel.** With
`--fonts-proportional` leading ark-pixel, `--fonts-regular` (base.css:64) resolves to
ark-pixel too, so the rounds 2-3 family rules and the token no longer changed any
rendered pixel:
- `.page-content h1/h2, .ui.header` — family declaration dropped, weight pin kept
  (justified below).
- `.markup h1, .markup h2 { font-family: var(--fonts-regular) }` — dropped: it now
  resolves to the same family it was meant to exempt from. Consequence, accepted and
  logged: user-authored headings keep upstream's semibold (markup/content.css:73) and
  that weight is browser-synthesised on the single-400 pixel face. Left alone on
  purpose — stripping weight from other people's README headings is a semantic
  regression, and the fix, if G3 wants it, is one selector.
- `.ui.label` family dropped; weight pin kept (label.css:15).
- `overflow-menu.ui.menu .item` — dropped entirely. The round-3 family rule was the
  no-op; the weight half mattered less than assumed: the tab strip's loudest text is
  the ACTIVE tab, and that is base.css:791-794 (semibold) + menu.css:407 (medium) at
  (0,4,0), which the round-3 selector could never have beaten. Handled below by a
  mirrored pin instead.
- `.repo-header { … }` — dropped entirely. No upstream rule sets a weight inside the
  header block that reaches the pixel face (the repo-name anchors carry `tw-font-normal`
  or nothing), so there was nothing left to do.
- `.repo-header .ui.dropdown .menu, … .item { font-family: var(--fonts-regular) }` —
  dropped: exemption to a family that is now the same family.
- `.ui.fluid.vertical.menu > .item` — family dropped; the weight half was also
  ineffective (see the correction below).
- `#navbar .item` — dropped entirely: no upstream weight on navbar items remains to
  neutralise (navbar.css sets weight only on the badges).
- `#navbar .ui.dropdown .menu, … .item { font-family: var(--fonts-regular) }` —
  dropped: same no-op as the repo-header panel exemption.

**Kept/repaired — only what still changes the rendered result** (each mirrors the
upstream selector so it wins by source order, D-004):
- `.page-content h1, .page-content h2, .ui.header` → `font-weight: normal`:
  header.css:10 (medium) hits every `.ui.header`, including the home hero h1s
  (home.tmpl:7, 16, 24, 34, 42 are `.ui.icon.header`); the raw h1/h2 arm additionally
  cancels the UA's bold on the hero tagline (home.tmpl:10) and devtest headings.
- `.ui.label` → normal: label.css:15 (medium); 12px chips are the one surface on
  ark-pixel's native grid, so crispness there is cheap.
- **CORRECTION caught in this re-evaluation:** `.ui.menu .header.item,
  .ui.vertical.menu .header.item` → normal. The round-3 selector
  `.ui.fluid.vertical.menu > .item` is (0,3,0) and menu.css:89 (medium) is (0,4,0), so
  the side-nav captions ("User Settings", …) were never actually pinned. Mirroring the
  upstream selector fixes it; also true for the round-3 tab rule, hence the pin below.
- `.ui.tabular.menu .active.item, .ui.secondary.pointing.menu .active.item` → normal:
  base.css:791-794 (semibold) and menu.css:407 (medium) — the active tab of the
  repo/org/explore/auth strips. base.css:793 shares its block with
  `.resize-for-semibold::before`, a width-measuring helper on another element: left
  alone, it merely reserves a little slack.
- `.ui.vertical.menu .item .menu .active.item` → normal: menu.css:219 (medium), the
  active item of a nested sub-menu (admin side nav). New this round.
- `#navbar a.item .notification_count, #navbar a.item .header-stopwatch-dot,
  #navbar .item .navbar-admin-badge` → normal: navbar.css:112-121 (bold); the count
  dots render at 12px, native grid.

**Explicitly NOT pinned (logged judgment calls).** `.overflow-menu-button.active`
(base.css:583-587, medium) — the collapsed strip's "…" button, no readable text.
`.ui.button.ellipsis-button` (base.css:810-813, semibold) — a code-comment expander.
User content (`.markup` headings, `strong`, issue titles) keeps its semantic weights.

**Code face verified (required by the feedback).** `--fonts-monospace` is untouched
and leads with Fira Code, and every code context consumes it: base.css:96-101
(`pre/code/kbd/samp`, with kbd being the only near-code case), :430 (`.sha.label`
commit chips), :650-652 (`.lines-code`), :670; codeeditor.css:29 (CodeMirror content);
easymde.css:16,151 (`font: 14px var(--fonts-monospace)`); console.css:7;
markup/jupyter.css:10; repo/commit-sign.css:15. chroma.css declares no family at all,
so syntax-highlighted blocks inherit from `pre` = mono. Two near-misses checked and
accepted: codeeditor.css:59/341 use `--fonts-regular` for editor CHROME (now pixel,
not code), and base.css:707-709 gives blame metadata the proportional face (UI text,
not code). EasyMDE's Markdown textarea itself takes the mono family via the
`font:` shorthand above.

**Accepted consequences (logged, not fixed).**
- Buttons carry the pixel face now. The round-2 decision kept them off it
  (`white-space: nowrap`, button.css:21, long localized labels) — the human's "all
  text is ark-pixel" supersedes that, and since `.ui.button` declares
  `font-family: var(--fonts-regular)` (button.css:7) the face arrives by inheritance
  with no rule of ours. A pixel MONOSPACE is wider per glyph than the sans it
  replaces, so long button labels are the top thing to eyeball in G3 (fix path, if
  needed: a per-component font-size or letter-spacing pin, or exempt `.ui.button`
  from the body face).
- Body 16px over a 12px design grid = 1.333x non-integer scaling; 12px too small,
  24px too large — accepted, per the T-008 size decision. The 24px leading stays on
  the design grid (2 units).
- T-008's `pre, code, samp, .tw-font-mono { font-size: 1em }` stays, with its comment
  corrected: both faces are now monospace and equal-sized, and 0.95em × 16px = 15.2px
  is off-grid, so 1em is the defensible value. Watch-item: if Fira reads larger than
  the pixel body in G3, the knob is that rule.
- **Open question for the human (found while verifying CJK):** font_i18n.css:1-19
  sets `--fonts-override` on every element of a `ja`/`zh-CN`/`zh-TW`/`zh-HK`/`ko`
  page (`:lang()` matches descendants through inherited language), and
  `--fonts-regular` (base.css:64) puts `--fonts-override` first — so on those locale
  pages CJK text renders in the system CJK face (PingFang/Hiragino/Noto CJK/YaHei)
  rather than ark-pixel, while Latin still resolves to ark-pixel. This is upstream's
  own i18n design and was equally true with LXGW in the ladder, so nothing here broke
  it; but it does mean "all body text ark-pixel" is not what a CJK-locale user sees.
  Fixing it is one line (`:root { --fonts-override: var(--fonts-proportional) }`);
  left for a human call because it overrides upstream CJK rendering. Details in
  `tasks/T-004-pixel-fonts.md` (round-4 log).

**Verification.** `src/components.css`: 39 rule blocks, braces balanced, no raw hex,
ZERO `font-family` declarations, six `font-weight` pins, 69 class names all
grep-verified in the pinned tree. `src/fonts.css`: one `@import`, one `@font-face`,
braces balanced, no raw hex. `grep -rn 'soppy-font-pixel' src/` returns nothing.


## G3 feedback round 6 (2026-09-28, human)
1. Dashboard activity feed badge: `#activity-feed` (feeds.tmpl:1, classes
   `.flex-divided-list.items-with-main`) renders each item's `.item-trailing`
   (feeds.tmpl:125-127) as a 32px action-type octicon. Restyle that trailing slot as a
   STATIC PIXEL KEYCAP BADGE: keycap box (border + background + the --soppy-bevel-raised
   token for the key texture), content centered, square and snapped to the 12px grid,
   NO hover/active states — it is decorative, not a button.
   SCOPE STRICTLY to #activity-feed: the bare `.item-trailing` class is also used on
   settings/danger-zone and org/team pages where it wraps real buttons — do not touch
   those. Cite flex-list.css:31-37 for the item structure.
2. Signed-out home first screen: make the brand logo img BIGGER and the hero +
   landscape.png strip SMALLER ("only a small area"). Adjust your round-1 rules:
   the `.page-content.home img.logo` box (currently 360x120) grows; the hero
   background (currently background-size min(100%, 760px) auto with a 240px reserved
   ground strip and 24/12px margins) shrinks. Keep 12px-grid values, pixelated
   rendering, object-fit: contain on the logo.
G1 citations and log as always.

### Round 6 acceptance
- [x] `#activity-feed .item-trailing` renders as a static keycap badge: border +
  background + `var(--soppy-bevel-raised)`, content centred, square, on the 12px grid
- [x] Scope strictly `#activity-feed`; the bare `.item-trailing` (42 further occurrences
  across 30 templates) untouched
- [x] No hover/active states authored or inherited
- [x] Home logo bigger (576x192) and the landscape strip smaller (384px / 120px band),
  all values on the 12px grid; pixelated + object-fit: contain kept
- [x] G1 citations for every new selector; no raw hex, no new classes, no git

### 2026-09-28 — agent-components — round-6 keycap badge + home hero rescale

Only `src/components.css` and this task file touched; no git actions.

**1. Dashboard activity-feed keycap badge.**

Scope audit (G1). `#activity-feed` occurs in exactly one place in the pinned tree —
`templates/user/dashboard/feeds.tmpl:1`, the signed-in dashboard feed. The bare
`.item-trailing` class appears 42 more times across 30 other templates, where it wraps
real buttons and
must keep flex-list.css:62-69's `justify-content: end` alignment: e.g.
`org/settings/options_dangerzone.tmpl:11, 21, 31`, `org/team/members.tmpl:35, 60`,
`org/team/repositories.tmpl:45`, `repo/settings/options.tmpl:809-895`,
`user/settings/keys_ssh.tmpl:58`, `user/settings/security/webauthn.tmpl:18`,
`shared/user/access_tokens.tmpl:50`. Hence the ID-prefixed selector — nothing else can
match it. Item structure cited as instructed: `.flex-divided-list.items-with-main > .item`
= `.item-leading` + `.item-main` + `.item-trailing` (flex-list.css:31-49 = row +
`.item-leading` + `.item-main`; :62-69 the trailing slot). In the feed the slot holds exactly one decorative
octicon, `svg (printf "octicon-%s" (ActionIcon .GetOpType)) 32 "tw-text-text-light
tw-mr-1"` (feeds.tmpl:125-127; `svg` helper = `svg.RenderHTML(icon, size, class)`,
modules/svg/svg.go:82-91, size is arg 2).

The badge:
- 48x48px = 4 grid units square. `border-box` is already global (normalize.css:24-28
  `*, ::before, ::after`), so the 1px border is inside the 48px and the box stays on
  the grid — no `box-sizing` declaration needed.
- `border: 1px solid var(--soppy-border-strong)` — same strong outline as buttons.
- `background: var(--color-box-body)` — deliberately picked because it is a shade
  LIGHTER than `--color-body` (the feed's page background) in both variants: light
  #fbf7f0 vs #f6f1ea (palette-light.css:207/209), dark #1b1917 vs #171615
  (palette-dark.css:207/209), so the key reads as raised without any
  `--is-dark-theme` branch.
- `box-shadow: var(--soppy-bevel-raised)` for the key texture, per the contract.
- `align-items/justify-content: center` override flex-list.css:62-69's end alignment.
- No hard drop shadow on purpose: `--soppy-shadow-hard` belongs to floating surfaces,
  and a 4px offset repeated down every feed row would read as noise.
- `flex: 0 0 auto`: upstream sets only `flex-grow: 0`, leaving shrink at 1, and
  `.item-main` has `flex-basis: 60%` (flex-list.css:47), so the badge could squash on
  narrow viewports; this keeps the keycap square.
- `#activity-feed .item-trailing > svg { margin-right: 0 }` cancels the `tw-mr-1`
  (0.25rem = 4px at the 16px root, feeds.tmpl:126) that would otherwise sit the glyph
  2px left of centre inside the keycap.
- No `border-radius` declaration: nothing upstream sets a radius on this div (it is a
  bare `.item-trailing` div, not a `.ui.*` component), so it is square already.
- No hover/active states authored; none exist upstream for this element either —
  flex-list.css:58 styles `a:not(.label, .button):hover` and the trailing slot is a
  div holding an svg, so the badge is inert by construction.

**2. Home hero rescale (signed-out first screen).**

- Logo: 360x120 → **576x192**. Both dims stay on the 12px grid (48 x 16 units) and the
  exact 3:1 ratio of brand.png (2172/724 = 3.0) holds: the family of grid-valid 3:1
  boxes is 36m x 12m, and m=16 gives 576x192 (m=10 was the old 360x120). Neighbours if
  the human wants another step: 504x168 (m=14, smaller) / 648x216 (m=18, bigger).
- Logo margins: 24px/12px → **12px/12px** (one grid unit each side; 12px still clears
  the navbar's 1px bottom border).
- Landscape strip: `background-size: min(100%, 760px) auto` → **min(100%, 384px) auto**
  (32 grid units — "only a small area"); reserved ground band 240px → **120px** (10
  units); mobile 140px → **84px** (7 units) with the full-width art unchanged.
- Overlap model unchanged and re-checked: at 384px wide the art renders
  384 x 802/1962 ≈ 157px tall against a 120px reserved band, so ~37px of fully
  transparent sky sits behind the tagline (round 1 had ~70px of the same). On a 360px
  phone the art is ~147px against an 84px band — same proportions.
- Kept: `image-rendering: pixelated`, `object-fit: contain`, `content: url()`,
  bottom-centre placement, and the home-page-only scoping (`.page-content.home` +
  element-qualified `div.hero`).
- Interpretation logged: "hero smaller" was read as the hero's FOOTPRINT — background
  size, reserved band, margins — because the feedback's parenthetical enumerated
  exactly those. The hero's em type sizes are upstream's — desktop 5.5em / 3em
  (home.css:14-21), mobile 3.5em / 2em (home.css:5-12) — and were left alone; if the
  human also wants the type smaller, the grid-snapped pair is 60px/36px (5/3 units)
  (or 36px/24px on the mobile breakpoint) — one rule each, flagged for G3.

**Verification.** 41 rule blocks, braces balanced, no raw hex, zero `font-family`
declarations, zero `--soppy-font-pixel` references, 70 class names grep-verified in the
pinned tree, and the one new ID selector (`#activity-feed`) verified as unique to
feeds.tmpl:1. No git ops.

**Watch-items for the next G3 pass.** (1) Keycap legibility: a 32px octicon inside a
48px key is a large legend — if it reads crowded, the box grows to 60px (5 units) or
the icon shrinks (template-side, not ours). (2) Whether 384px reads as "a small area"
on a phone or still dominates. (3) Whether 576x192 is the right logo step. (4) Still
open from earlier rounds: pixel button labels at 16px (`white-space: nowrap`),
display-face line-height fit, mini/small button label wrap, brand.png downscale
crunch.


## G3 feedback round 7 (2026-09-28, human)
- Signed-out landing page only: handle the case where the hero's landscape.png
  background overlaps the hero TEXT. Context from round 6: the art renders ~157px tall
  over a 120px reserved band (84px on mobile), so at some widths part of the art sits
  behind the tagline/logo text.
  Requirement: the text must win visually. Weigh the candidates below, pick one (or a
  minimal combination), and LOG the reasoning plus the rejected alternatives:
    (a) pixel-style hard text-shadow (0 blur) built from palette vars;
    (b) a scrim layer stacked between the image and the content — e.g. a second
        background layer (gradient) above the image but below the text, using
        --color-body / --color-box-body so it adapts per variant;
    (c) more reserved space so they never overlap at all.
  Constraints: palette vars only (no raw hex), scoped to the landing-page hero
  (.page-content.home ...), must hold in light AND dark, must not regress the round-6
  sizing (384px art width / 120px band / 84px mobile), G1-audit every selector.
  PIXEL AESTHETIC IS BINDING (human follow-up): no blurred shadows and no smooth soft
  gradients — shadows are hard (0 blur), and any scrim must use hard or banded/stepped
  edges consistent with the theme; nothing that reads as a modern soft glow.

### Round 7 acceptance
- [x] Landing-page hero only: the tagline wins over landscape.png at every width
- [x] Pixel aesthetic held: hard 0-blur shadow, no blur, no gradient, no glow
- [x] Palette vars only (`--color-body`), holds in light AND dark with one declaration
- [x] Round-6 sizing untouched (384px art / 120px band / 84px mobile, art + margins
  unchanged)
- [x] Scoped to `.page-content.home div.hero` text; G1 citations logged; no raw hex,
  no new classes, no `!important`, no git

### 2026-09-28 — agent-components — round-7 hero text outline

Only `src/components.css` and this task file touched; no git actions.

**What the overlap actually is (measured, not assumed).** I decoded
`assets/landscape.png` (1962x802, RGBA) row by row: everything above y=166 (20.70% of
the height) is transparent except a few stray pixels, and solid content starts at
y=184 (22.94%). So the overlap depth is `art_height − band`, and the fraction of it
that is real artwork is everything past the first 20.7% of the art:

| viewport | art w | art h | band | overlap | of which real art |
|---|---|---|---|---|---|
| 360px  | 296 | 121 | 84  | 37px  | 12px |
| 480px  | 416 | 170 | 84  | 86px  | 51px |
| 600px  | 536 | 219 | 84  | 135px | 90px |
| 767px  | 703 | 287 | 84  | 203px | 144px |
| 768px+ | 384 | 157 | 120 | 37px  | 4px |

(art w = min(hero width, 384) at ≥768px, full width below, from the round-6 rules.)
So the round-6 desktop numbers are almost exactly at the safe boundary — the 37px
overlap sits in the transparent sky with only ~4px of the faintest cloud tips — and
the real defect is BELOW 768px, where the round-6 `background-size: 100% auto` makes
the art 121-287px tall against an 84px band. On mid widths the art is even taller than
the hero box itself, so its top is cropped by `background-clip: border-box` and the
tagline sits on artwork from its first line. (The hero box is ~130px of text + the
band, i.e. ~215px on mobile, vs a 287px art at 767px.)

The logo is NOT affected and needs no rule: a background paints only inside its own
element's border box, and the logo is a sibling above the hero (`home.tmpl:5` vs
`home.tmpl:6`), so the art can never reach it. Logged so it does not come back.

**Chosen: (a) a hard 0-blur text outline.** New rule at the end of the hero section:
`.page-content.home div.hero h1, .page-content.home div.hero h2` get an 8-direction
`text-shadow` at 4px with `0` blur, all in `var(--color-body)`.

Why this one:
- It is the classic pixel-game answer (hard outline, axis-aligned, no blur, no ramp),
  so it satisfies the binding aesthetic by construction; the human's own constraint
  list allows exactly this ("shadows are hard (0 blur)").
- It is width- and art-independent: no geometry is touched, so it cannot regress the
  round-6 numbers (384/120/84 both untouched), and it keeps working if the art is
  swapped or the sky margin changes — unlike anything anchored to the image's alpha
  profile.
- `--color-body` is exactly the colour the hero is painted on
  (`base.css:84 body { background-color: var(--color-body) }`), so the outline is
  invisible where no art is behind the text and reads as a cut-out where there is.
  It flips with the palette, so one declaration covers light and dark (light: cream
  outline around dark glyphs; dark: near-black outline around light glyphs).
- It complements the glyph fill rather than replacing it: where the art is light the
  dark text already wins, where the art is mid/dark the outline wins; the two together
  cover the whole tonal range, which is the actual requirement ("text must win").
- 4px = one third of a grid unit, i.e. one glyph pixel at the h2's 4x ark-pixel scale
  (h2 3em = 48px against a 12px design face); on the 88px h1 it is half a glyph pixel.
- No `!important` and no specificity fight: grep finds no `text-shadow` anywhere in
  `web_src/css/`, so nothing to beat. Selector specificity (0,3,2) and scope
  `div.hero` also keeps the four `h1.hero.ui.icon.header` section headers
  (home.tmpl:16, 24, 34, 42) out.

**Rejected (b), the scrim layer.** A second background layer above the image but below
the text is expressible (`background-image: linear-gradient(...), url(...)`, first
layer on top, with `background-clip: content-box` to keep it off the art band) — but
CSS cannot measure the text box, so the only edge it can use is the top of the reserved
band. That makes the scrim cover the WHOLE area above the band on every width, which
means: on desktop it would hide the 37px of transparent sky (a visual no-op that adds a
second mechanism for nothing), and on mobile it would slice through the artwork at a
hard horizontal line — at 767px that hides 203px of a 287px art, cutting the characters
off at the waist while the band below still shows the ground. A shrunken scrim is not
possible without markup or a fixed text height. Two sub-variants rejected as well:
banded/striped scrims (a dithered ramp over the text hurts the very legibility it is
meant to protect, and reads as a barcode) and an alpha ramp via `color-mix` (explicitly
forbidden — it reads as a soft modern gradient).

**Rejected (c), more reserved space.** To make the boxes never touch, the band would
have to exceed the art height: ~121px on a 360px phone (vs the binding 84px) and
~287px at 767px (vs 84px), i.e. it directly contradicts the round-6 sizing the human
told me not to regress and reverses "hero smaller". The only bounded form is capping
the MOBILE art width on the invariant `art_h − 84px ≤ 20.7% × art_h`, which solves to
art ≤ ~106px tall / ~259px wide — logged as an available follow-up, not applied,
because (i) it depends on landscape.png keeping a transparent top margin, an asset
property CSS cannot guarantee, and (ii) it would shrink the mobile art, i.e. it is a
sizing change the round asked me not to make.

**Consequence left standing (flagged).** Below 768px the art is still taller than the
hero box, so it is cropped at the hero's top edge and the tagline sits on artwork; the
outline makes the text win there, which is what round 7 asked for, but the mobile art
is still doing more cropping than the desktop one. If the human wants the underlying
geometry addressed rather than just the legibility, the two knobs are the mobile
`background-size` (round-6 value `100% auto`) and the 84px band — both deferred here on
the no-regression constraint.

**Verification.** 43 rule blocks, braces balanced, no raw hex, zero `font-family`
declarations, zero `--soppy-font-pixel` references, 69 class names (extractor now
strips comments) all grep-verified in the pinned tree. No git ops.


### Round 7 follow-up (2026-09-28, orchestrator, human request)
- The feed keycap read too large. Shrunk in place: 48px -> 36px (3 grid units), inner
  octicon 32px (template value) -> 24px (2 grid units) so the glyph keeps breathing
  room; bevel, border, no-hover/active and #activity-feed scoping unchanged. Applied
  directly by the orchestrator as a parameter tweak on the round-6 rule.
- Follow-up 2: keycap 36px -> 24px (2 grid units), inner octicon 16px; the svg now
  carries display:block + margin:0 so the inline-baseline gap and tw-mr-1 are gone and
  the flex centring yields equal space on all four sides.
- Follow-up 3: back up to 36px (3 grid units) with a 24px octicon and an EXPLICIT
  equal margin of 5px on all four sides — (36 - 2x1px border - 24) / 2 — rather than
  relying on the flex centring to derive it; display:block still kills the baseline gap.
- Follow-up 4: glyph 24px -> 16px and the equal margin 5px -> 9px inside the unchanged
  36px keycap, so the badge reads as padding around a small glyph. Arithmetic kept in
  the comment: (36 - 2x1px border - 16) / 2 = 9px.

### Follow-up 5 (2026-09-28, agent-components, round-8 pass) — keycap state reconciled
- The keycap rule as it stands on disk is NOT the 48px/`margin-right: 0` version the
  round-6 entry above describes, and there is no round-6/7 entry for the current shape,
  so recording it here: `#activity-feed .item-trailing` is a **28px square** and the
  child svg fills it (`width/height: 100%`, `padding: 4px`, `display: block`), i.e.
  glyph box `28 - 2*1px border - 2*4px padding = 18px`, 4px of air on each side. The
  hand iterations (48 -> 36 -> 24 -> 36 -> 30 -> 28, per the follow-up notes above and
  the orchestrator's note in T-008) supersede the round-6 comment, which said 30px.
- I reconciled only the two stale COMMENT figures in that block (30px -> 28px and the
  `30 - 2 - 8 = 20` arithmetic -> `28 - 2 - 8 = 18`); no behaviour was changed, since
  the box is clearly still under hand iteration.
- Open defect found while reconciling, deliberately not fixed (same reason): the
  template's `tw-mr-1` (4px, feeds.tmpl:126) is still applied, so the 100%-wide svg
  overflows the centred flex line by 4px and the glyph lands ~2px left of centre
  (2px left / 6px right). One line fixes it — `margin-right: 0` on
  `#activity-feed .item-trailing > svg` — and is noted in the CSS comment as well.
- Type scale: the scattered size rules this file used to carry (code `1em`, mini/small
  px sizes, the 24px body leading) are gone; every size now lives in the single
  documented block at the top of `src/components.css`, decided in T-008 round 8. The
  round-1/2 size entries above are historical.


