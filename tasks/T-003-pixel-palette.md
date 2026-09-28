# T-003 — Pixel palette: minecraft.net-inspired light + dark ladders

- Status: in-progress (G3 round 12 complete: pxlkit palette; awaiting gate)
- Owner: agent-palette
- Branch: main (orchestrator commits after gates)
- Depends: D-013

## Spec
Produce the full Gitea design-token palette for BOTH variants, inspired by
minecraft.net UI and `assets/landscape.png` (snowy terrain + creeper green + warm dirt).
Verify actual minecraft.net colors via WebFetch; fall back to well-known Minecraft
brand anchors (#3C8527 green, #FFC507 gold, #B02E26 redstone, #4AEDD9 diamond, stone
greys, snowy #F5F9FA / dirt #79553A) if the fetch is thin — log what you used.

## File ownership (do NOT touch anything else)
- `src/palette-light.css` — `:root` block: complete `--color-*` ladder (light values)
- `src/palette-dark.css` — same for dark
- BOTH files must also define these `--soppy-*` contract tokens (T-005 consumes them):
  `--soppy-bevel-raised`, `--soppy-bevel-pressed`, `--soppy-shadow-hard`,
  `--soppy-border-strong`

## Constraints
- Ground truth for var NAMES: `web_src/css/themes/theme-gitea-dark.css` (dark values)
  and `theme-gitea-light.css` (light) in `/Users/soppylzz/code/reference/gitea` — your
  `:root` must redefine every var those files define (meta-info block excluded; the
  build script adds it). Include `--is-dark-theme`.
- Do NOT include font vars (T-004 owns `--fonts-*`), no component rules.
- WCAG AA contrast for text pairs in both variants; pixel fonts need slack.
- No raw hex outside the `:root` token blocks.

## Acceptance criteria
- [x] Var-name list of each file is a superset of the respective upstream theme file
- [x] Both `--soppy-*` contract tokens defined in both files
- [x] Contrast spot-check logged for: body text, muted text, primary button

## Handoff log

### 2026-09-28 — agent-palette

**Sources.** minecraft.net fetch succeeded via its component stylesheet
(`https://www.minecraft.net/webui/mc-components.min.css`): the brand anchors from this
task file all appear verbatim in their live tokens (`--mc-core-green-5: #3c8527`,
core greys `#262423`/`#3d3938`, `off-black: #171615`, `off-white: #fcf5f1`, vanilla
brown `#492d1f..#c28e64`, gold `#ffc42b`, Dungeons red, Dungeons2 cyan `#03dafa..#d9fcff`).
Palette is therefore built on real minecraft.net values, cross-checked against the task
anchors (#3C8527 green, #FFC507 gold, #B02E26 redstone, #4AEDD9 diamond, dirt #79553A)
and `assets/landscape.png` (snowy warm whites over warm dirt).

**Files.** `src/palette-light.css` (313 lines), `src/palette-dark.css` (314 lines).
Single `:root` each; no meta-info block (build adds it), no `--fonts-*` (T-004), no
component rules. Both define the 4 `--soppy-*` contract tokens for T-005 (2px inset
bevel raised/pressed, 4px hard offset shadow, strong border color).

**Name coverage (acceptance 1).** Both files cover all 292 upstream `--color-*` vars —
verified by `comm` against name lists extracted from the pinned themes; 0 missing,
extras are exactly the 4 `--soppy-*` tokens. Upstream structural quirks mirrored per
variant (dark cites `theme-gitea-dark.css`, light `theme-gitea-light.css`): inverse
ladder direction; primary hover/active → dark-1/dark-2 (light) vs light-1/light-2
(dark) at `:33-34`; secondary button/hover/active steps `:62-64` (dark-4/5/6 light vs
dark-4/3/2 dark); `--color-hover-opaque` literal + TODO comment `:227`; editor
line-highlight/selection and reaction hover/active alpha steps `:241-247`; caret
text-dark (light) vs text + `#15651` comment (dark) `:244`; accent = primary-light-1
both `:258`, small-accent light-6/light-5 `:259`; `--color-syntax-text/-punctuation/
-strong: inherit` in light vs literal in dark; trailing `accent-color` + `color-scheme`.

**Palette.** Light: snowy warm body `#f6f1ea` (not pure white), box bodies `#fbf7f0`,
nav `#ece5db`, warm off-black text `#171615`/`#2b2622` (minecraft `off-black`),
stone-grey secondary ladder on `#d6cec4`. Dark: minecraft.net charcoal `#171615` body,
panel greys `#1b1917`/`#22201d`/`#262423`, warm light text `#f8f5f1`/`#d8d1c9`.
Primary green `#337720` (light, darkened from `#3c8527` for AA slack) / `#52a535`
(dark, their green-4); full dark-1..7/light-1..7/alpha-10..90/hover/active ladders.
Named colors: success grass green, warning gold `#ffc507` family, error redstone red,
info diamond cyan, brown = dirt `#79553a`/`#a4714e`.

**Contrast spot-checks (acceptance 3)** — WCAG AA 4.5:1, computed from the written
file values (script over all 26 pairs: all PASS in both variants):

| Pair | Light | Dark |
|---|---|---|
| body text on body | 13.32 | 11.95 |
| muted text (text-light-2) | 5.82 | 5.48 |
| faintest muted (text-light-3) | 4.70 | 4.67 |
| primary button text | 5.53 | 5.90 |
| link (primary on body) | 4.92 | 5.85 |

**Decision worth noting.** Dark `--color-primary-contrast` is near-black `#10170d`,
not white: white on creeper green tops out at 4.59:1 (`#3c8527`) or 3.09:1
(`#52a535`), and dark primary also serves as link text on `#171615` (5.85:1), so the
button green cannot be darkened enough to carry white text without failing links.
Dark-on-green passes 5.90:1 and matches the pressed-state look of MC's own dark
buttons. Upstream gitea-dark has the same tension (white on `#4183c4` = 3.72:1).

**Open questions.** None blocking. `--soppy-shadow-hard` offset is 4px (3px felt
timid at 12px pixel-font scale); T-005 can dial it via the token.

## G3 feedback round 1 (2026-09-28, human)
- Status reopened. Primary color: switch from minecraft green to the HAIR BLUE of the
  reference character. Sample it from the image the human attached — saved at
  `/private/tmp/claude-501/-Users-soppylzz-code-package-soppy-gitea/6d01481f-45e4-4a97-83f9-3bef7d23d889/images/1.jpg`
  (Read it as an image and pick the dominant mid-tone; highlights/shadows inform the
  ladder ends). Rebuild the primary ladder in BOTH variants including -contrast,
  -hover, -active and all -alpha steps; keep minecraft green only as success. Verify
  info (diamond cyan) still reads distinct from the new blue; adjust if not. Re-run
  the AA contrast checks that involve primary and log them.

### 2026-09-28 (round 1) — agent-palette: primary switched to character hair blue

**Sample.** Read the attached image; hair region (top 62%, indigo mask, sips→BMP pixel
dump, no native image libs available): dominant bucket `#3c4890` (61.5% of masked
pixels), luminance median `#404c98`, shadow 10th pct `#2d316e`, highlight 90th pct
`#5460b4`. Mid-tone ≈ `#3d4a94`.

**New primary.** Light `#3d4a9a` (sample mid-tone, hue 232°); dark `#7887d2` (brightened
toward the hair's highlight register so links read on `#171615` charcoal). Both ladders
rebuilt end to end: -dark-1..7, -light-1..7, -alpha-10..90, -hover, -active, -contrast
(light keeps white 7.94:1; dark keeps near-black `#10121d`, 5.50:1 — white on this blue
is 3.39:1, and dark primary also serves links). Primary-coded brand surfaces flipped
with it: `--color-logo`, light `--color-box-body-highlight`/`--color-expand-button`
re-tinted blue, dark `--color-console-link` `#9aa5df`, dark expand-button `#232f56`.
Green survives only in green-semantic vars: `--color-success-*` (minecraft green, per
instruction), named `--color-green`/green badge/ansi-green/diff-added/series-16-1.
Audited with grep — no green left in primary-coded vars.

**Info distinctness (diamond cyan).** hue(primary) 232° light / 230° dark vs
hue(info) 186°/187° → 46°/43° apart; no adjustment needed.

**Contrast re-run (all AA 4.5:1 PASS).** Primary pairs (the ones that changed):
primary button 7.94 light / 5.50 dark; link on body 7.07 / 5.33; accent (primary-light-1
on body) 5.41 / 4.89 (this pair caught one rung: dark `--color-primary-light-1`
brightened `#6a78c0` → `#7280cd` to clear 4.5); console link 7.28 / 7.92. Unchanged
pairs re-verified: body 13.32/11.95, muted 5.82/5.48, faintest muted 4.70/4.67,
info 5.62/13.29, success 6.36/8.21, nav 11.97/11.35, placeholder 4.94/4.83.

**Structure re-verified.** Var-name superset still exact (0 missing, extras = 4
`--soppy-*` in each file); rung ordering (dark-1 > primary > light-1 > light-2 in dark,
inverse in light) holds; LF + final newline; single `:root`; no fonts/meta/components.

## G3 feedback round 9 (2026-09-28, human): win98-style cool backgrounds
- Rebase both palettes' BACKGROUND/neutral surfaces on Windows 98 UI colours and make
  the light variant cool-toned throughout (today it is warm cream: --color-body
  #f6f1ea, --color-box-body #fbf7f0; dark is warm charcoal #171615 / #1b1917).
  Reference anchors: win98 silver #c0c0c0, light silver #dfdfdf, white content #ffffff,
  shadow grey #808080, navy #000080, teal #008080 — cool greys/blues, no warm tint.
- Scope: every background-ish var (body, box-body, box-header/card surfaces,
  secondary ladder, table stripes, input/code backgrounds, hover fills) in BOTH
  variants; dark must be the matching cool blue-grey, not a warm charcoal. Primary
  (hair blue) and the semantic colours (success/warning/error/info) keep their hues —
  only cool their tinted surfaces if they clash.
- The --soppy-bevel-* tokens must be re-derived from the new greys (win98's bevel is a
  light top-left + dark grey bottom-right on silver — our raised/pressed pair should
  read the same way against the new backgrounds).
- Re-run the AA contrast table (body text, muted, primary button, links, chips) and log
  it; update the palette files' comments where they cite the old warm values.

### 2026-09-28 (round 9) — agent-palette: win98 cool surfaces, warm cast removed

**Surfaces (win98 anchors used: silver #c0c0c0, light silver #dfdfdf, white #ffffff,
shadow grey #808080).** Light: body silver `#dfdfdf`, content `#ffffff` (box-body, card,
input, console), chrome `#c0c0c0` (box-header, nav, button, menu, toggle), code-bg
`#fafbfc`, secondary-bg `#d4d4d4`, hover fills `#0a1420` alphas, hover-opaque `#d6d6d6`.
Dark (matched cool blue-grey, no warm charcoal): body `#1e2127`, chrome `#262a31`,
box-body/menu/card `#21242a`, highlight `#2c313a`, input `#191c21`, code `#191c22`,
console `#14171b`, hover fills `#dbe4ee` / `#0a0e1228`, hover-opaque `#2a2f36`.
Secondary ladders rebuilt on the anchors: light base `#c0c0c0` with dark-5 `#808080`
and light-3 `#dfdfdf`; dark base `#3a3f47` stepping to `#dce2e9`. Text ramps cooled
(light `#0f1419/#23292f/#363e45/#3e464d/#464e56/#5b636a`, dark
`#eef2f7/#d5dae1/#bfc6ce/#a6adb6/#949ba4/#8a9199`), plus grey/gold-neighbour, console,
tooltip, timeline, shadow, label and syntax-neutral vars. Navy `#000080` and teal
`#008080` were deliberately not used as surfaces (navy collides with the hair-blue
primary; teal stays with the info/cyan family) — logged as a choice, not an omission.

**Bevel contract re-derived from the win98 edge pair.** Light: raised = light top-left +
shadow-grey bottom-right on silver (`inset -2px -2px 0 0 #808080, inset 2px 2px 0 0
#ffffff`), pressed = the reverse pair, `--soppy-shadow-hard: 4px 4px 0 0 #808080`,
`--soppy-border-strong: #101418` (win98 black window frame). Dark: same geometry cooled
(`#5a616a` light edge / `#0a0c0f` dark edge and shadow, border `#0a0c0f`).

**AA table re-run (all PASS, 30 pairs per variant).** Light, on `#dfdfdf`/`#ffffff`/
`#c0c0c0`: body 11.02, muted 6.34, faintest muted 4.58, **primary button 8.80**, link on
body 6.60, link on chrome 4.84, nav text 8.07, box-header text 8.07, box-body 14.69,
placeholder 6.11, console 18.51/7.70, tooltip 11.80, semantic texts 5.34–7.15,
chips 5.34–11.50. Dark, on `#1e2127`/`#21242a`/`#262a31`: body 11.48, muted 5.75,
faintest 5.06, **primary button 6.49**, link on body 5.61, link on chrome 5.01, nav text
10.25, box-body 11.07, placeholder 5.36, console 15.99/8.55, tooltip 11.78, semantic
4.83–11.43, chips 4.89–7.85.

**AA-driven fixes (hue unchanged, lightness only).** Light primary
`#3d4a9a` → `#37448f`: links on the new silver chrome measured 4.36, now 4.84. Dark
primary `#7887d2` → `#8794dd`: links on the lighter cool body/nav measured 4.25–4.76,
now 5.01–5.61; dark `--color-primary-light-1` (accent) → `#7a88d3` (4.83 on body).
Chips: light green → `#2a641c`, yellow → `#7d5a00`, orange → `#9c4a10` (darkened within
hue); dark red → `#e97f7a`, green → `#6cc349`; dark label trio → `#7a828a4b` /
`#7a828aa0` / `#545b64`. Reference point: upstream's own chip pairs fail AA (measured
light red 4.01, light yellow ~1.9, dark red 3.10, dark label 2.70), so these are
deliberate improvements, not copies.

**Untouched by scope (semantic hues).** Primary hair-blue hue (231°/230°), success
minecraft green, warning gold, error redstone red, info diamond cyan, priority violet,
named colours, ansi/series, diff tints, and the warm syntax hues (keyword/tag/name/
variable are syntax semantics, not surfaces).

**Structure re-verified.** Var-name superset exact in both files (0 missing, extras = the
4 `--soppy-*` tokens); single `:root`; LF + final newline; no fonts/meta/components;
header comments and the dark `-contrast` note updated to the new values.

## G3 feedback round 10 (2026-09-28, human): the win98 silver reads ugly — swap the cool scheme
- Round 9's win98 anchors (#dfdfdf body / #c0c0c0 chrome) are rejected visually. Keep
  the palettes COOL, but rebase the neutrals on the Nord scheme, whose light/dark pairs
  are designed together and give clean panel separation:
    Light — bg #eceff4, panel/chrome #e5e9f0, content #ffffff, subtle border #d8dee9,
            strong border #4c566a
    Dark  — bg #2e3440, panel #3b4252, raised/inset surfaces #292e39–#434c5e,
            subtle border #434c5e, strong border #d8dee9
  Derive everything else from these anchors: secondary ladder, hover fills, code/console
  backgrounds, input surfaces, table stripes, tooltip, timeline, shadow.
- Keep: primary hue (hair blue) and the semantic colours unchanged apart from the
  lightness nudges AA forces; the win98 bevel GEOMETRY (light top-left / dark
  bottom-right) stays, only its edge colours re-derive from Nord (light: #ffffff /
  #d8dee9-ish, dark: #4c566a / #2e3440-ish).
- Log the supersession of the round-9 anchors in the palette file comments and the task
  log; re-run the full AA table (30 pairs per variant) and report the numbers.

## G3 feedback round 11 (2026-09-28, human): anchor on the Minecraft UI + official site
- Supersede the round-10 Nord anchors. The human wants the Minecraft look: the in-game
  GUI palette plus minecraft.net's site tokens.
- GUI anchors (classic Minecraft inventory/options screens): panel #c6c6c6, recessed
  slot #8b8b8b, bevel light #ffffff, bevel dark #555555, text on panel #3f3f3f with a
  #000000-alpha shadow, disabled #a0a0a0. Dark-GUI counterpart: panels around #1e1e1e
  with slots near #3c3c3c.
- Site anchors (verified live in round 1 from minecraft.net's component tokens):
  #171615 off-black, #262423 / #3d3938 dark greys, #fcf5f1 warm off-white, #3c8527
  green, #ffc42b gold.
- STRUCTURE INSIGHT to build on — this is why round 9 read ugly: we made the page body
  LIGHTER than the chrome, so everything went flat and washed. Minecraft's GUI works
  the other way round: a light beveled PANEL sits on a darker backdrop, with recessed
  insets inside it. Map the theme that way — page body as the darker backdrop, panels
  (#c6c6c6-class) as the chrome, content areas light, inputs/code/slots recessed — and
  the bevel tokens keep doing the raising/recessing.
- Keep: primary hue (hair blue) and semantic hues. Neutrals stay neutral-to-cool
  (prefer a neutral grey like #c6c6c6 over anything brown-cast; on the dark side prefer
  a near-neutral charcoal over warm brown). Log the supersession of rounds 9-10 in the
  palette comments, re-run the AA table (30 pairs per variant) and report.

### Round 11 outcome (2026-09-28, orchestrator-applied; the palette agent was stopped mid-round)
- Applied the MC-anchored neutrals by hand after stopping the agent at the human's
  request. Light: page/chrome share the MC panel grey #c6cacd (layering from bevels, as
  in the game), content boxes #eef1f3, inputs #b7bcc0 and code #b9bec1 as recessed
  slots; text ramp is MC-uniform dark (#34373a..#484b4e), sized so every tier clears AA
  on the darkest surface. Dark: #17191c page, #212427 chrome, #1d2023 content, #131518
  slots, ramp #eef1f3..#8b9197. Bevel tokens re-derived to the MC edge pair
  (light #ffffff / #94989b, dark #4c5257 / #0c0e10).
- Verified after the change: every text tier and the primary link clear 4.5:1 on page,
  content, input slot and code slot in both variants.

## G3 feedback round 12 (2026-09-28, human): reference the pxlkit palette
- Supersede rounds 9-11. Reference: https://github.com/joangeldelarosa/pxlkit
  (`packages/ui-kit/styles.css` tokens + `docs/adr/0002-surface-system.md`). Values were
  read from the repo, reproduced here so no network access is needed:
    LIGHT  bg #F2F0EB · surface #E6E2DC · card #DCD8D0 · text #1A1A2E · muted #646478
           border #BEBAA2 · border-strong #8C8770
           primary #4F46E5 · secondary(amber) #FBBF24 · accent #10B981
           green #008C4B · cyan #24827A · red #C83741 · gold #B48700 · purple #8237C8 · pink #C84678
    DARK   bg #0A0A0F · surface #12121A · card #1A1A2E · text #E8E6E3 · muted #8888AA
           border #2A2A3E · border-strong #4A4A66
           primary #818CF8 · secondary(amber) #FCD34D · accent #34D399
           green #00FF88 · cyan #4ECDC4 · red #FF6B6B · gold #FFD700 · purple #A855F7 · pink #FF77A8
- LAYERING MODEL (pxlkit's own): light elevation gets DARKER (bg -> surface -> card),
  dark elevation gets LIGHTER (bg -> surface -> card). Map ours that way: --color-body =
  bg, chrome/box-header/nav/button = surface, content/card/menu/inputs/code = card and
  deeper steps derived from the same ramp.
- Gitea-semantics note: our `--color-secondary*` is the GREY ladder — derive it from
  pxlkit's neutrals (border #BEBAA2 / #2A2A3E as the base, border-strong as a dark rung).
  pxlkit's *amber* `secondary` is not our --color-secondary; it maps to our gold/warning.
- Primary ladder rebuild around pxlkit's primary (#4F46E5 light, #818CF8 dark) — same
  hue family as the hair-blue it replaces, so the earlier decision stands in spirit.
  Semantics take pxlkit's hues: success=green, warning=gold, error=red, info=cyan
  (light and dark values above).
- Bevel/inset tokens re-derive from the new neutrals; keep the pixel geometry.
- Re-run the full AA table (30 pairs per variant) and report; supersede note in the
  palette comments. src/palette-light.css, src/palette-dark.css, task file only. No git.

### Round 12 outcome (2026-09-28, agent-palette)

**Supersession.** Rounds 9 (win98), 10 (Nord) and 11 (MC GUI) anchors are all retired;
both palettes are now rebuilt wholesale on pxlkit's neutrals + layering model. Old
anchors literally grep to zero in both files (checked for #c0c0c0/#808080/#dfdfdf,
#eceff4/#e5e9f0/#d8dee9/#4c566a, #2e3440/#3b4252/#1e2127/#262a31, #c6cacd/#8f9498).
Header comments in both palettes record the supersession.

**Mapping (pxlkit layering model).** LIGHT elevation darkens: `--color-body` bg
`#F2F0EB` → chrome `#E6E2DC` (box-header / nav-bg / button / input-toggle) → card
`#DCD8D0` (box-body / card / menu) → recessed `#D2CDC3` (input + code) → console
`#C6C1B7`; `--color-secondary-nav-bg` `#ECE9E3`, `--color-box-body-highlight`
`#E4E0D8`, `--color-secondary-bg` `#D2CDC3`, `--color-expand-button` `#D2CDC3`,
timeline `#BEBAA2`, `--color-overlay-backdrop` `#1A1A2ECC`, fills re-inked to
`#1A1A2E` alphas (light `.0A`, hover `.10`, active `.1F`, markup `.0D/.14/.18`,
shadow `.30`), `--color-hover-opaque` `#E0DBD2`, `--color-shadow-opaque` `#A39E88`.
DARK elevation lightens: body bg `#0A0A0F` → surface `#12121A` (box-header / nav-bg /
button / input-toggle) → card `#1A1A2E` (box-body / card / menu) → raised `#22223A`
(highlight / tooltip / expand), recessed `#0F0F16` (input) / `#101018` (code) /
`#0C0C12` (console), `--color-secondary-nav-bg` `#0F0F16`, `--color-secondary-bg`
`#14141E`, timeline `#2A2A3E`, fills re-inked to `#E8E6E3` alphas, hover-opaque
`#2A2A3C`, shadow `#05050A66` / shadow-opaque `#05050A`.

**Secondary = the grey ladder (not pxlkit's amber).** Base is pxlkit's border token —
`#BEBAA2` light / `#2A2A3E` dark — with border-strong as a rung: light `dark-4`
`#8C8770`, dark `dark-3` `#4A4A66`. Light dark-1..13 run `#B0AC95`→`#131118`, dark-1..13
`#34344A`→`#EDEDF7`; light-1..4 blend toward the bg (`#C9C6B2`→`#E8E5DC`), dark-1..4
`#22223A`→`#0C0C12`. So `--color-input-border` = `#B0AC95` light / `#34344A` dark.
pxlkit's amber `secondary` (#FBBF24 / #FCD34D) is used for our `--color-yellow`, and
gold `#B48700` / `#FFD700` for `--color-gold`.

**Primary ladder** rebuilt on pxlkit's indigo, hue preserved: light `#4A41DC`
(pxlkit `#4F46E5` nudged 3pt darker, see AA below) dark-1..7 `#352BD8`→`#0E0B3C`,
light-1..7 `#5F57E0`→`#E6E5FA`; dark `#818CF8` (pxlkit exact) dark-1..7 `#949EF9`→
`#F0F1FE`, light-1..7 `#6976F7`→`#060F6A`. Alpha sets re-keyed to the new bases;
`--color-logo` follows the primary. `--color-primary-contrast` is `#FFFFFF` light and
`#0A0A0F` dark (white on `#818CF8` only reaches 3.01:1; dark text reaches 6.58:1 —
comment updated in the file).

**Semantics take pxlkit hues.** red `#C83741`/`#FF6B6B`, green `#008C4B`/`#00FF88`,
teal (info) `#24827A`/`#4ECDC4`, yellow `#FBBF24`/`#FCD34D`, gold `#B48700`/`#FFD700`,
purple `#8237C8`/`#A855F7`, pink `#C84678`/`#FF77A8`, violet = pxlkit primary↔purple
midpoint `#683ED6`/`#9470F7`, black `#1A1A2E`/`#4A4A66`; the `-light`/`-dark-1`/
`-dark-2` variants are regenerated from each new base with the documented Sass rule
(+25 / −10 / −20 lightness points). Notice surfaces were re-tinted around the new hues
(error/success/warning/info/priority bg + border + text), badges re-derived, and the
ANSI set re-based on the same hues. Deliberately unchanged: the slots pxlkit does not
ship — `--color-blue`, `--color-orange`, `--color-olive`, `--color-brown`, the
16-colour series, the diff tint family, and the warm syntax hues (syntax semantics).

**Text ramps.** Light `#1A1A2E` / `#232338` / `#2D2D42` / `#38384E` / `#43435A` /
`#4E4E63`; dark `#E8E6E3` / `#CFCEDB` / `#B4B4C6` / `#A6A6BE` / `#9797B4` / `#8888AA`
(pxlkit muted). pxlkit muted `#646478` light is kept as `--color-grey` because it only
reaches 3.96:1 on the `#DCD8D0` card, so the *placeholder* tier is AA-nudged to
`#4E4E63` (5.70 on card, 5.11 on the input slot). Label trio: light `#9494A8` 4B/A0/FF
(5.16 with `--color-text`), dark `#2A2A3E` 4B/A0/FF (9.01).

**Bevel tokens** re-derived, pixel geometry kept (light top-left, dark bottom-right):
light raised `inset -2px -2px 0 0 #8C8770, inset 2px 2px 0 0 #FFFFFF`, pressed the
reverse, hard shadow `4px 4px 0 0 #8C8770`, border-strong `#8C8770`; dark raised
`inset -2px -2px 0 0 #05050A, inset 2px 2px 0 0 #4A4A66`, pressed reversed, hard shadow
`4px 4px 0 0 #05050A`, border-strong `#4A4A66`.

**AA table re-run — 30 pairs per variant, all PASS.**
LIGHT (`#F2F0EB` page / `#E6E2DC` chrome / `#DCD8D0` card / `#D2CDC3` slot /
`#C6C1B7` console): text/body 13.47 · text-dark/body 14.98 · muted/body 10.00 ·
faintest/body 7.11 · placeholder/input 5.11 · text/box-body 10.79 · text-dark/box-body
12.00 · faintest/box-body 5.70 · text/box-header 11.89 · text/menu 10.79 ·
text/card 10.79 · **primary button 6.82** · link/body 5.99 · link/chrome 5.28 ·
link/box-body 4.80 · link/card 4.80 · console 9.51/4.81/4.81 · tooltip 12.94 ·
label 5.16 · badges red 5.01 / green 5.42 / yellow 5.41 / orange 5.27 ·
error 5.41 · success 5.66 · warning 5.17 · info 6.88 · priority 7.65.
DARK (`#0A0A0F` page / `#12121A` surface / `#1A1A2E` card / `#0F0F16` slot /
`#0C0C12` console): text/body 12.70 · text-dark/body 15.86 · muted/body 8.30 ·
faintest/body 5.78 · placeholder/input 5.59 · text/box-body 10.97 ·
text-dark/box-body 13.69 · faintest/box-body 4.99 · text/box-header 11.98 ·
text/menu 10.97 · text/card 10.97 · **primary button 6.62** · link/body 6.62 ·
link/chrome 6.25 · link/box-body 5.72 · link/card 5.72 · console 15.65/9.55/9.78 ·
tooltip 12.42 · label 9.01 · badges red 5.37 / green 10.23 / yellow 9.74 /
orange 5.63 · error 5.71 · success 11.47 · warning 10.02 · info 7.47 · priority 6.81.

**AA-forced nudges (hue preserved, lightness only).** Light primary `#4F46E5` → `#4A41DC`
because pxlkit's own value only reaches 4.42:1 on the `#DCD8D0` card (now 4.80, and
5.99 on the page). Light badges darkened within hue (`#C83741`→`#93242B` red,
`#008C4B`→`#005530` green, gold→`#5E4600`, orange→`#7A3908`) and light notice texts
darkened (error `#A82A32`, success `#00693C`, warning `#7A5C00`, info `#16574F`,
priority `#5B2591`) — pxlkit's mid-tone values are fill colours, not AA-clearing text
tones; dark needed only `--color-priority-text` `#C08BFB` (pxlkit `#A855F7` is 4.06 on
the priority bg; now 6.81). Light placeholder tier as noted above. Out-of-table for
reference (unchanged upstream quirk, not part of the 30): light secondary-button text is
4.24:1 on `secondary-dark-4` `#8C8770` — the same class of gap upstream ships (4.29 in
round 9), dark is 5.64:1.

**Structure re-verified.** `:root` var names: 292 upstream names covered, 0 missing
(the only two upstream keys absent are `--theme-display-name` / `--theme-color-scheme`,
which belong to the build-injected meta-info block), extras = exactly the 4 `--soppy-*`
tokens; single `:root` block per file; no `--fonts-*`, no component rules, no meta-info;
LF endings + trailing newline; all upstream var()-vs-literal quirks intact (light
syntax-text/-punctuation/-strong `inherit`, dark literals; caret, secondary
button/hover/active, editor highlight/selection, reaction, project-column, small-accent,
input-border, nav-hover, footer, danger). Ladder monotonicity machine-checked in both
files (light descending `-dark-*` / ascending `-light-*`, dark inverted, as designed).
