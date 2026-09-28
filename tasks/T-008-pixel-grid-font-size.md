# T-008 — Pixel grid font-size snap pass

- Status: review (G3 round 8 type-scale refactor applied 2026-09-28; awaiting human re-check; orchestrator commits)
- Owner: agent-components
- Branch: main (orchestrator commits after gates)
- Depends: T-003, T-004, G3 feedback round 1 (human, 2026-09-28)

## Spec
G3 round 1 reported fonts rendering too small in both regular and code. Revisit the
T-005 base.css:77 decision: raise the base font size (14px → 15px or 16px), audit the
fixed-px companions and button metrics first, and neutralize the 0.95em monospace
compensation at base.css:103-108 (wrong for the proportional serif code face from
T-004). Changes live in `src/components.css` (T-005's file, edited under this task's
claim per the shared-file rule).

## Acceptance criteria
- [x] Base-size decision logged with the audited desync surface (15px vs 16px)
- [x] 0.95em code compensation neutralized, selector cited
- [x] px-set type snapped to the 12px grid where it was off-grid
- [x] No raw hex, no font-family declarations, no new classes

## Handoff log

### 2026-09-28 — agent-components — base size raised, code compensation neutralized

**Decision: 16px (not 15px).** 15px is a half-measure against the stated complaint
(+7% barely reads under ark-pixel's compact x-height); 16px is the UA default (+14%)
and pairs with a 24px leading — 24 is on the 12px grid, 15px would keep odd leading
whatever the ratio. Rejections/degradations logged per audit item below.

**Changes (all in `src/components.css`, each an override-layer rule that wins by
source order over the equal-specificity upstream rule):**
- `html, body { font-size: 16px }` — upstream base.css:75-78 (14px).
- `body { line-height: 24px }` — upstream base.css:81 (20px); 1.5 leading at 16px,
  on-grid.
- `:root { --line-height-code: 24px }` — upstream base.css:16 (20px; used for code
  blocks and the editor).
- `pre, code, samp, .tw-font-mono { font-size: 1em }` — upstream base.css:103-108
  sets 0.95em "compensate for monospace fonts being usually slightly larger"; the
  T-004 code face is a proportional serif and needs no shrink.
- `.ui.ui.ui.ui.mini.button { font-size: 12px }` — upstream button.css:116-120
  (11px, off-grid).
- `.ui.small.buttons .dropdown, .ui.small.buttons .dropdown .menu > .item,
  .ui.small.buttons .button, .ui.ui.ui.ui.small.button { font-size: 12px }` —
  upstream button.css:139-145 (13px, off-grid); full selector group mirrored so
  every match path is covered.

**Audited desync surface at 16px root (1rem 14px → 16px, +14.3% on all rem lengths):**
- body `line-height: 20px` (base.css:81) — overridden to 24px (above).
- `--line-height-code: 20px` (base.css:16) — overridden to 24px (above).
- `--checkbox-size: 14px` (base.css:32) — left: control box, not copy; in the native
  range. Grid-neutral.
- Button metrics (button.css:99-148): normal min-height 38px vs 16px text + 0.57em
  vertical padding = 36.2px used ✓; compact 32px vs 6px padding = 30px ✓;
  small/tiny/mini carry px-set font sizes and are unaffected by the rem shift
  (small/mini additionally snapped to 12px above).
- Fomantic hard-coded `0.28571429rem` radii would drift 4px → 4.57px — already zeroed
  by T-005's radius pass, no action.
- `.ui.label` stays `--font-size-label: 12px` (base.css:42) — on-grid ✓.
- `--min-height-textarea: 132px` (base.css:30) — already 11×12 grid ✓.
- Hero display sizes grow with em: h1 5.5em → 88px (off-grid, upstream value, left),
  h2 3em → 48px (4×12 ✓) — noted for a future display-tuning pass, not changed.
- Editor chrome `font-size: 13px` (codeeditor.css:339) — px-set, left; log-only.

**Verification.** All class names re-audited after the edit: 67 classes, all
grep-verified in the pinned tree. No hex, no font-family, braces balanced (33 rules).
Open question: whether 11px→12px mini buttons ever wrap their labels in narrow icon
rows — check in the next G3 pass.

State: nothing else touched, no git ops.

### 2026-09-28 — agent-components — interaction note after G3 round 2

Round 2 (T-005) made the pixel face a DISPLAY face on headings/labels via the new
`--soppy-font-pixel` (T-004, lands in parallel). The 16px body / 24px leading from
this task now serves the reading face, not the pixel face — the correct pairing: the
size pass was tuned for readability, and the display face carries the style on
headings/labels only. Note for T-004: `src/fonts.css` currently still points
`--fonts-proportional` (hence `--fonts-regular`, the body family) at ark-pixel;
under the round-2 model the body family should be a reading face, with ark-pixel
exposed only through `--soppy-font-pixel` — the comment at fonts.css:20 already
sketches this. Not this task's file.

UPDATE 2026-09-28: resolved — T-004 landed exactly this. `--fonts-proportional` now
points at LXGW WenKai Screen (fonts.css:17) and ark-pixel is exposed only through
`--soppy-font-pixel` (fonts.css:24). The 16px body serves the reading face; the
conflict flagged above is closed.

SUPERSEDED 2026-09-28 (G3 round 4): the human moved the body face back to ark-pixel
(fonts.css; see the T-004 round-4 log), so the "reading face" model above no longer
describes the build — body copy and code are now the two faces, both monospace. This
task's size decision stands unchanged and is what round 4's accepted 1.333x tradeoff
refers to: 16px body over ark-pixel's 12px design grid, 24px leading (2 grid units).
The one rule from this task that needs its rationale re-read is
`pre, code, samp, .tw-font-mono { font-size: 1em }`: it was written when the code face
was a proportional serif; both faces are now monospace and equal-sized, and 0.95em of
16px (15.2px) would be off-grid, so 1em stays. Comment in components.css corrected;
if Fira reads larger than the pixel body in G3, that rule is the knob.

State: nothing else touched this round, no git ops.

### G3 follow-up (2026-09-28, human: "base font size 调大一些，参考 github")
- Base 16px -> 20px. Rationale anchored in GitHub's own ladder (Primer primitives
  base/typography: xs 12 / sm 14 = body default / md 16 = body-large / lg 20): we were
  already on body-large, so the next rung is lg = 20px.
- body line-height 24px -> 30px (GitHub's 1.5 ratio at 20px); --line-height-code
  likewise 24 -> 30px. Both are deliberately off the 12px grid — noted in the file
  comments with the grid alternative (36px) and why it was not taken.
- Stale comments corrected in the same pass: the keycap block (36px/16px/9px
  arithmetic superseded by the human's 30px box + 4px padding) and the code-size block.

## G3 feedback round 8 (2026-09-28, human): REFACTOR the whole type scale
Cause of the rework: bumping `html { font-size }` to 20px was wrong — in Gitea that
value is the REM BASIS (base.css:75-78), so the entire UI (spacing, controls, layout)
inflated, not just text. Sizes have also accumulated per-round as one-off overrides.

REQUIREMENTS
1. ONE KNOB: `html { font-size: 16px }` declared exactly once in the new type-scale
   section (Gitea ships 14px; +14% scales every rem-based dimension proportionally).
   Do not declare a body font-size unless something upstream forces it — verify first.
2. EVERY text size in rem so the root stays the only knob (this is GitHub's own
   model: Primer --base-text-size-xs is 0.75rem, not 12px). Targets at root 16px:
   | role                          | value            | ratio to body | anchor |
   | body / UI copy                | 1rem = 16px      | 1.00  | — |
   | code (pre/code/samp/.tw-font-mono) | 0.875rem = 14px | 0.875 | GitHub code:body = 12:14 = 0.857 |
   | labels / small / mini+small buttons | 0.75rem = 12px | 0.75 | ark-pixel native grid, crispest chips |
   | body line-height              | 24px (1.5)       |       | GitHub ratio, on the 12px grid |
   | --line-height-code            | 24px             |       | on the grid |
   | --checkbox-size               | 1rem = 16px      | 1.00  | control box paired to text |
   | headings / display type       | untouched        |       | upstream rem/em scales with the root |
   | pixel-face weight pins        | unchanged        |       | font-weight only, no sizes |
3. CONSOLIDATE, do not patch: one documented block near the top of components.css
   carries the table and EVERY size decision; the size rules currently scattered
   through the file (code 1em, mini/small px sizes, any label size) move into it or
   are re-derived from it. grep the file for `font-size` and `line-height` and account
   for every remaining hit in the task log — nothing size-related may live outside the
   block without a cited reason.
4. G1 citations for every upstream value touched (base.css:16/32/42/75-81,
   button.css:116-145). Light and dark unaffected. Log the final `grep -n` listing.

### Round 8 acceptance
- [x] ONE KNOB: `html { font-size: 16px }` declared once, in the type-scale block
- [x] Body size verified against upstream — it IS forced (base.css:75-78 sets 14px on
  `html, body`), so `body { font-size: 1rem }` restates it as the root, not as a size
- [x] Every text size in rem: body 1rem, code 0.875rem, labels/small+mini buttons
  0.75rem; body line-height 24px; `--line-height-code` 24px; `--checkbox-size` 1rem
- [x] Consolidated into one documented block: table + all three size tokens + html +
  body + code + the two button rules; the scattered `1em` / `12px` rules are gone
- [x] Headings and display type untouched; pixel-face weight pins unchanged
- [x] Every `font-size` / `line-height` grep hit accounted for (listing below)
- [x] G1 citations for every upstream value touched; no raw hex, no new classes, no
  `!important`, no git

### 2026-09-28 — agent-components — round-8 type-scale refactor

Only `src/components.css` (plus this file and one reconciliation note in T-005);
no git actions.

**The finding that changes requirement 1.** The spec said "do not declare a body
font-size unless something upstream forces it — verify first". Verified, and it is
forced: `web_src/css/base.css:75-78` is

```css
html, body {
  height: 100%;
  font-size: 14px;
}
```

The 14px is declared on `body` directly, not inherited, so a root-only declaration
would have left body copy at 14px while every rem-based dimension grew 14% — i.e.
exactly the mismatch that made the round-1/round-7 state incoherent. So the block
declares `body { font-size: 1rem }`: the same value, expressed against the root, so
the knob is still single. `body { line-height: 24px }` sits beside it (base.css:81 sets
20px). Nothing else in the theme declares a size: `fonts.css`, `palette-light.css` and
`palette-dark.css` have zero `font-size` / `line-height` hits (grep).

**The block as shipped** (top of `src/components.css`, derived from the spec table):

| role | declared | = at 16px | upstream it replaces |
|---|---|---|---|
| root | `html { font-size: 16px }` | 16px | base.css:75-78 (14px on html AND body) |
| body / UI copy | `body { font-size: 1rem }` | 16px | same |
| body leading | `body { line-height: 24px }` | 1.5 | base.css:81 (20px) |
| code | `pre, code, samp, .tw-font-mono { font-size: 0.875rem }` | 14px | base.css:106-108 (0.95em) |
| labels | `--font-size-label: 0.75rem` | 12px | base.css:42 (12px) |
| mini / small buttons | `0.75rem` | 12px | button.css:118 (11px), :143 (13px) |
| code leading | `--line-height-code: 24px` | — | base.css:16 (20px) |
| checkbox box | `--checkbox-size: 1rem` | 16px | base.css:32 (14px) |
| headings | untouched | — | base.css:141-159 rem/em scales with the root |
| weight pins | weight only | — | header.css:10, label.css:15, menu.css:89/219/407, base.css:791-794, navbar.css:118-121 |

**Consolidation.** The former "type scale (T-008)" section (html + body line-height +
the `1em` code rule + the two px button rules) and the `--line-height-code` token that
was squatting in the geometry `:root` block are all gone; one block now holds the three
size tokens, `html`, `body`, the code rule and the two button rules, with the table and
the per-token citations above it. The geometry `:root` keeps only the radius kills and
points at the block.

**Choices inside the table, and what they do.** The code size moved from `1em` to
`0.875rem`: `em` would compound with whatever parent it sits in (0.95em of the 16px
body = 15.2px, off-grid and not knob-driven), and a fixed rem is the GitHub ratio
(12:14 = 0.857; 0.875 is the rung that stays on the 12px grid). Mini/small buttons are
re-derived at 0.75rem, the crispest chip size on ark-pixel's native grid. `tiny` is
12px upstream already (button.css:131), i.e. at the target, so it deliberately gets no
override — logged here so the omission is not read as an oversight. `--checkbox-size`
goes 14px -> 1rem: checkbox.css:6-7, 22-23 and 34-36 size the box from it and :73-74
pairs the label's `min-height`/`line-height` to it, so the box now matches the 16px
text beside it.

**Accepted consequence of the root (unchanged from the previous decision).** The root
is Gitea's rem basis, so +14% over the shipped 14px scales every upstream rem/em
dimension with it — paddings, `--height-loading` (16rem), `.ui.header` margins
(`calc(2rem - 0.1428571em)`), Fomantic control metrics. That is exactly why the 20px
bump was wrong and why 16px is the honest rung: it is the smallest value that lifts
body copy off the compact 14px baseline. The px-fixed companions the theme owns are all
audited above; upstream's remaining px text sizes (56 declarations in `web_src/css`,
e.g. `.markup { font-size: 14px }` at markup/content.css:3 with 16px for `.file-view`,
`.lines-num/.lines-code { font-size: 12px }` at base.css:649-654, `.ui.tiny` 12px) are
NOT knob-driven. Two are worth the human's eye, both left alone as upstream's own
typographic calls rather than new one-offs: `.markup` prose renders 14px while UI copy
is 16px (so inside rendered markdown our 14px code is 1:1 with the prose, instead of
the 0.875 UI ratio), and the repo file view renders 12px text on the new 24px
`--line-height-code` (2.0 leading).

**Superseded decisions (recorded so the log is not misleading).** The earlier
"G3 follow-up" entry above raised the base to 20px and the two line-heights to 30px,
deliberately off the 12px grid; round 8 reverts all three to 16px / 24px / 24px, which
is on the grid. The `1em` code rule and the px button sizes are now `0.875rem` and
`0.75rem`. Nothing in the file is off the grid any more except the keycap box, which is
geometry rather than type (see T-005 follow-up 5).

**Final `grep -n 'font-size\|line-height' src/components.css`** — every hit accounted
for:

```
18:  /* sizes (--line-height-code, --checkbox-size, --font-size-label) live in the   <- block pointer (comment)
23:/* ONE KNOB: the root font-size. ...                                              <- block header (comment)
32:     | body line-height                    | 24px      | 1.5     | ...            <- table row
33:     | --line-height-code                  | 24px      |         | ...            <- table row
38:   Nothing else in this file declares font-size or line-height.                    <- block claim
41:  --line-height-code: 24px;                                                       <- token, block
42:  /* base.css:32 (14px): checkbox/radio box + its label's line-height ...          <- token comment
47:  --font-size-label: 0.75rem;                                                     <- token, block
52:  font-size: 16px;                                                                <- THE KNOB
56:   font-size: 14px }` — the 14px is declared on body directly, ...                <- cites base.css:75-78
59:   base.css:81 sets line-height 20px; 24px is 1.5 on the 12px grid. */           <- cites base.css:81
61:  font-size: 1rem;                                                                <- body, block
62:  line-height: 24px;                                                              <- body, block
74:  font-size: 0.875rem;                                                            <- code, block
83:  font-size: 0.75rem;                                                             <- mini, block
90:  font-size: 0.75rem;                                                             <- small, block
113:/* label.css:15 (medium): chips are sized by --font-size-label, now 0.75rem ...   <- WEIGHT pin comment
```

The only hit outside the block is line 113: a `font-weight` pin (round 4) whose comment
names the token so a reader knows the chip size comes from the block. It declares no
size; kept for exactly the reason the requirement asks for a cited reason. `grep -c
'font-size:'` on the declarations alone returns 5 (knob, body, code, mini, small) and
`line-height:` returns 1 (body) — no other rule in the file carries either property.

**Verification.** 45 rule blocks, braces balanced, no raw hex, zero `font-family`
declarations, all class names grep-verified in the pinned tree, 4 `!important` (all
pre-existing elevation/focus mirrors, none font-related). No git ops.


### G3 feedback round 9 (2026-09-28, human): bigger code-view font
- `base.css:648-654` pins `.lines-num/.lines-escape/.lines-code` to 12px and
  `base.css:668` pins `.code-inner` via a `font:` shorthand (which also sets size, so
  inheritance cannot reach it). All four are raised to the code size (0.875rem = 14px)
  inside the single type-scale block, scoped to `.file-view.code-view`. Diffs share the
  markup, so they follow suit — noted for the next G3 pass.
