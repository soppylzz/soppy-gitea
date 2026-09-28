# T-004 — Pixel fonts: ark-pixel regular + Noto Serif SC code

- Status: review (G3 round 4 applied 2026-09-28 by agent-components; awaiting human re-check)
- Owner: agent-fonts
- Branch: main (orchestrator commits after gates)
- Depends: D-013

## Spec
Typography layer per D-013. `assets/ark-pixel-12px-monospaced-zh_cn.ttf.woff2` already
exists (use that exact URL path: `/assets/soppy/ark-pixel-12px-monospaced-zh_cn.ttf.woff2`).

## File ownership (do NOT touch anything else)
- `src/fonts.css` — must contain, in this order:
  1. `@import url("https://fonts.googleapis.com/css2?family=Noto+Serif+SC:wght@400;500;600;700&display=swap");`
     (must be the first statement of the assembled file — CSS @import rule)
  2. `@font-face` for family **"Ark Pixel 12 Monospace SC"** (woff2, font-display swap)
  3. `:root` overrides: `--fonts-proportional` (ark-pixel first, sane fallbacks) and
     `--fonts-monospace` ("Noto Serif SC" first, serif fallbacks) — copy the var
     structure from `web_src/css/base.css:1-8` and keep `--fonts-emoji` intact
- `assets/OFL.txt` — fetch the ark-pixel-font license (OFL-1.1) from
  https://github.com/TakWolf/ark-pixel-font (raw LICENSE/OFL file) so the woff2 is
  legally redistributable

## Constraints
- Verify var NAMES against `web_src/css/base.css` (grep recipes in
  `.agents/references/ground-truth.md`). Note the `--fonts-override` hook (base.css:64).
- No component rules, no colors.

## Acceptance criteria
- [x] fonts.css assembles validly as the first section of a CSS file
- [x] Both `--fonts-*` overrides present, emoji stack preserved
- [x] OFL.txt present next to the font binary

## Handoff log

- 2026-09-28 agent-fonts: `src/fonts.css` and `assets/OFL.txt` written; no other files
  touched, no git actions.
  - Order: `@import` (Google Fonts, Noto Serif SC 400/500/600/700) is the first
    statement, then `@font-face "Ark Pixel 12 Monospace SC"` ->
    `/assets/soppy/ark-pixel-12px-monospaced-zh_cn.ttf.woff2` (woff2, font-display:
    swap), then `:root`, then one `body` rule. Braces balanced, final newline (LF).
  - Var names verified in pinned source: `--fonts-proportional` (base.css:3),
    `--fonts-monospace` ending in `var(--fonts-emoji)` (base.css:4),
    `--fonts-emoji: -emoji-fallback` (base.css:8, deliberately NOT redefined —
    upstream value kept). Composite/hook: base.css:63-65.
  - Stacks chosen: `--fonts-proportional: "Ark Pixel 12 Monospace SC", -apple-system,
    "Segoe UI", system-ui, Roboto, "Helvetica Neue", Arial` (no trailing generic/emoji
    of our own — base.css:64 appends "Noto Sans", sans-serif, --fonts-emoji);
    `--fonts-monospace: "Noto Serif SC", "Noto Serif CJK SC", serif,
    var(--fonts-emoji)` (serif fallbacks per the D-013 accepted tradeoff; "Noto Serif
    CJK SC" is the system-packaged name of the same family, covers offline first paint).
  - `--fonts-override` composition: hook resolves
    `var(--fonts-override, var(--fonts-proportional))` (base.css:64), so we leave
    `--fonts-override` unset and our proportional override flows through. Verified the
    only upstream setters are `:root :lang(ja|zh-CN|zh-TW|zh-HK|ko)` rules
    (font_i18n.css:1-19); `lang` is set only on `<html>` itself (head.tmpl:2), which
    `:root :lang(...)` never matches, so the hook stays unset for real content. The
    only matching elements are the footer locale-switcher links
    (footer_content.tmpl:33), where native-font-first is intentional upstream behavior
    — left alone. font_i18n.css:26-30/36-40 reference `var(--fonts-proportional)`, so
    ark-pixel becomes the fallback family inside locale overrides too.
  - Rendering stance: `body { -webkit-font-smoothing: antialiased; }` — grayscale AA
    avoids subpixel color fringing on bitmap glyph edges; `none` rejected because
    Gitea's 14px body size over a 12px pixel grid would distort and it also degrades
    fallback glyphs. `text-rendering` skipped: optimizeSpeed/geometricPrecision do not
    affect bitmap-font crispness. Upstream sets neither property anywhere
    (grep over web_src/css: no hits).
  - License: `assets/OFL.txt` is `LICENSE-OFL` from TakWolf/ark-pixel-font, fetched
    from raw.githubusercontent pinned to master head commit
    `cfe962402f4ef5f21101291083d95d99228ff6e4` (note: default branch is `master`, and
    the repo is dual-licensed OFL-1.1 + MIT `LICENSE-MIT`; GitHub's /license API
    surfaces only the MIT one — use the contents listing for OFL). Latest release at
    fetch time: `2026.09.25` (published 2026-09-25).
  - Open questions: (1) the woff2 in `assets/` was not version-verified against the
    binary (Brotli-compressed name table, no fontTools here); its drop date matches
    release 2026.09.25 — if provenance matters, re-export from that release so binary
    and OFL.txt pin agree. (2) ark-pixel is a 12px grid font under Gitea's 14px body
    size; if the preview looks unevenly scaled, the fix is a font-size snap pass —
    D-013 already directs this at component styling (T-005), not here.
- 2026-09-28 agent-fonts (G3 round 2): `src/fonts.css` rewritten to the new typography
  architecture; no other files touched, no git actions. Round-1 composition findings
  (base.css:63-65 hook, footer-locale-links-only analysis) are unchanged and still hold.
  - CDN verification (done before wiring, as instructed): fetched
    `https://cdn.jsdelivr.net/npm/lxgw-wenkai-screen-webfont@latest/style.css` — it is
    an @import chain of four sheets (`lxgwwenkaiscreen.css`, `lxgwwenkaiscreenr.css`,
    `lxgwwenkaigbscreen.css`, `lxgwwenkaigbscreenr.css`; relative URLs, resolved by the
    browser against the CDN path — valid CSS, no action needed). The main sheet
    registers font-family **'LXGW WenKai Screen'** (exact name, with quotes required),
    `font-weight: 400` ONLY, `font-style: normal`, `font-display: swap`, split into 97
    unicode-range subset woff2 files. The `-r` sheet registers a separate family
    'LXGW WenKai Screen R' (not referenced by us); the GB sheet registers the SAME
    name 'LXGW WenKai Screen' with wider GB glyph coverage — same-name union works in
    our favor. Consequence of the single 400 weight: 500/600 UI text is
    browser-synthesized — flagged for T-005.
  - Fira verification: Google Fonts css2 serves exactly the instructed weights —
    Fira Code 400/500/600 and Fira Mono 400/700 (kept 400;700 for Fira Mono per
    instruction). Verified deviation note: the "Fira Mono only ships 400;700" premise
    is outdated — Google Fonts serves a real, distinct Fira Mono 500 file (checked the
    css2 output: separate gstatic URL from the 400/700 files). Fira Code covers 500 in
    the lead family, so the instructed set is sufficient; a one-line @import change
    adds Fira Mono 500 if the human wants the fallback face to carry it.
  - New stacks: `--fonts-proportional: "LXGW WenKai Screen", -apple-system, "Segoe UI",
    system-ui, Roboto, "Helvetica Neue", Arial` (upstream base.css:3 chain as
    fallbacks); `--fonts-monospace: "Fira Code", "Fira Mono", ui-monospace,
    SFMono-Regular, "SF Mono", Menlo, Monaco, Consolas, "Liberation Mono", "Courier
    New", monospace, var(--fonts-emoji)` (full upstream base.css:4 chain as fallbacks,
    emoji tail kept); `--soppy-font-pixel: "Ark Pixel 12 Monospace SC",
    var(--fonts-proportional)` (nested var() is valid custom-property substitution and
    keeps one source of truth — expands to the full body ladder). ark-pixel
    `@font-face` byte-identical to round 1; body smoothing rule kept; Noto Serif SC
    dropped entirely.
  - Licensing: LXGW WenKai Screen is OFL-1.1 (upstream project lxgw-wenkai-screen) and
    is served entirely by the jsdelivr CDN — we redistribute nothing, so no license
    file is vendored for it. Fira Code/Fira Mono are OFL-1.1 via Google Fonts (same
    reasoning). `assets/OFL.txt` from round 1 stays: the ark-pixel woff2 IS
    redistributed by us, so its license file is still required.
  - Ledger gap (for orchestrator/human): this round-2 instruction supersedes part of
    accepted D-013 (ark-pixel as the regular/body font; Noto Serif SC as code font).
    `.agents/decisions.md` is append-only and outside my file ownership, so a
    superseding entry still needs to be appended by whoever owns the ledger.
  - Open question: LXGW WenKai Screen at `@latest` is an unpinned rolling import (per
    human instruction); if reproducibility matters later, pin the npm version in the
    @import URL — logged here, not acted on.
- 2026-09-28 agent-fonts (G3 round 3): `src/fonts.css` updated for the bilingual body
  stack; only `src/fonts.css` and this task file touched, no git actions.
  - Family verified via the Google Fonts css2 API before wiring (as instructed):
    `family=Mona+Sans` -> HTTP 200, family name **'Mona Sans'** (exact, matches
    GitHub's release name). Axis probing: `wght@200..900` -> HTTP 200 served as a true
    variable font (single `font-weight: 200 900` declaration, `font-stretch: 100%`,
    woff2 variable subsets, font-display swap — 3 unicode-range subsets);
    `wght@200..1000` and `wght@100..900` -> HTTP 400 (range rejected), so Google hosts
    wght 200-900 only. GitHub's upstream Mona Sans also has a wdth 75-125 axis, but
    the Google Fonts copy pins stretch at 100% — no width axis is served. Italic axis
    is available (`ital,wght@0,200..900;1,200..900` -> HTTP 200) and was NOT loaded —
    italic Latin text will render as synthesized oblique unless the human wants the
    real italics (one-line @import change). Preferred source worked, so the jsdelivr
    gh CDN fallback (github/mona-sans) was not needed.
  - Probe quirk worth remembering: one of the curl UA strings I tried
    (Chrome/126 Mac, no full build suffix) made Google serve static TTF instances
    (8 single-weight blocks) instead of the variable woff2; a normal full Chrome UA
    gets the variable file. Not a Google Fonts hosting difference — just their UA
    classifier.
  - Stack change: `--fonts-proportional: "Mona Sans", "LXGW WenKai Screen",
    -apple-system, "Segoe UI", system-ui, Roboto, "Helvetica Neue", Arial` — Latin
    resolves from Mona Sans, CJK falls through to LXGW (per-glyph fallback is
    per-character, so mixed-language text splits correctly). @import order is now
    Mona Sans, LXGW, Fira (body Latin, body CJK, code) — all three remain the first
    statements of the assembled file. Everything else from round 2 unchanged
    (ark-pixel face, `--soppy-font-pixel`, emoji tail, body smoothing).
  - Weight coverage note: Mona Sans 200-900 gives Latin real medium/semibold/bold;
    the round-2 synthetic-weight caveat now applies to CJK only (LXGW 400).

## G3 feedback round 2 (2026-09-28, human)
- Status reopened. Typography architecture changes:
  1. Code font: **Fira Code + Fira Mono together** replace Noto Serif SC as
     `--fonts-monospace` (proportional-serif experiment ends). Stack:
     "Fira Code", "Fira Mono", <fallbacks>. Load BOTH via Google Fonts @import
     (Fira Code weights 400;500;600 — Fira Mono only ships 400;700) unless a
     better CDN source is verified — log the choice.
  2. Body font: **LXGW WenKai Screen** becomes `--fonts-proportional` lead, loaded
     from the human-specified CDN: @import of
     `https://cdn.jsdelivr.net/npm/lxgw-wenkai-screen-webfont@latest/style.css` —
     fetch that CSS first and confirm the exact font-family name and available
     weights it registers before using it. Note in the log that the font is OFL-1.1
     and served by CDN (we redistribute nothing).
  3. Ark-pixel stays for stylized display use only — expose a new contract token
     `--soppy-font-pixel: "Ark Pixel 12 Monospace SC", <fallbacks>` in the :root so
     T-005 can apply it to headings without hardcoding family names.
  4. Keep the ark-pixel @font-face and font-display swap; keep emoji tail; keep the
     body smoothing rule.
- Order contract unchanged: @imports must be the first statements of the assembled
  file (both CDN imports at top, then @font-face, then :root).

### Round 2 acceptance
- [x] Both CDN @imports are the first statements of the assembled file (Google Fonts
  Fira Code/Fira Mono, then jsdelivr LXGW style.css)
- [x] `--fonts-monospace` leads "Fira Code", "Fira Mono"; upstream mono chain as
  fallback; emoji tail kept
- [x] `--fonts-proportional` leads "LXGW WenKai Screen" — exact family name and
  weights verified from the served CDN CSS before wiring
- [x] `--soppy-font-pixel` contract token present; ark-pixel stays display-only
- [x] ark-pixel `@font-face` + `font-display: swap` unchanged; body smoothing kept;
  no colors, no component rules

## G3 feedback round 3 (2026-09-28, human)
- Status reopened. Body text becomes bilingual by stack order: English = **Mona Sans**
  (GitHub's variable font), Chinese = **LXGW WenKai Screen** (unchanged). Latin glyphs
  resolve from the lead family; CJK falls through. So:
  `--fonts-proportional: "Mona Sans", "LXGW WenKai Screen", <existing system fallbacks>`.
- Source: prefer Google Fonts css2 @import with the variable weight range — verify the
  family exists via the css2 API and log the exact weights/axes it returns; if absent
  there, use the jsdelivr gh CDN of github/mona-sans. Variable font means real weights
  (no synthetic-bold concern for Latin). Keep everything else untouched.

### Round 3 acceptance
- [x] `--fonts-proportional: "Mona Sans", "LXGW WenKai Screen", <existing system
  fallbacks>` implemented; CJK falls through to LXGW
- [x] Mona Sans verified via Google Fonts css2 API (variable wght 200..900, stretch
  pinned 100%, swap; exact returned axes logged); jsdelivr gh fallback not needed
- [x] Everything else untouched (both round-2 imports, ark-pixel face,
  `--soppy-font-pixel`, emoji tail, body smoothing)

## G3 feedback round 4 (2026-09-28, human)
- Status reopened. "都改为 arkPixel" — the BODY face goes back to ark-pixel; only code
  keeps the Fira pair. Concretely: `--fonts-proportional: "Ark Pixel 12 Monospace SC",
  <existing system fallbacks>`; DROP the Mona Sans and LXGW WenKai Screen @imports
  (unused once body is pixel; CJK coverage comes from ark-pixel's zh_cn variant with
  the system stack as the glyph-gap fallback — log this consequence). Keep the Fira
  @import and the ark-pixel @font-face untouched. This round's edit to fonts.css is
  executed by agent-components alongside its components.css cleanup (single owner for
  the coupled token change) — see the T-005 round-4 section for the token decision.

### Round 4 acceptance
- [x] `--fonts-proportional` leads "Ark Pixel 12 Monospace SC" with the existing
  system fallbacks; no other family precedes it
- [x] Mona Sans and LXGW WenKai Screen @imports dropped; only the Fira @import remains
- [x] ark-pixel `@font-face` + `font-display: swap` and `--fonts-monospace` untouched;
  emoji tail preserved; body smoothing rule kept (comment updated for 16px)
- [x] No colors, no component rules; braces balanced, no raw hex

### 2026-09-28 — agent-components (G3 round 4) — body face back to ark-pixel

Executed by agent-components: the round-4 instruction reassigns this round's
`src/fonts.css` edit to the components owner so the coupled token change has one
owner. Only `src/fonts.css` and this task file touched; no git actions.

- `--fonts-proportional: "Ark Pixel 12 Monospace SC", -apple-system, "Segoe UI",
  system-ui, Roboto, "Helvetica Neue", Arial` (base.css:3's chain kept as fallbacks).
  The composite `--fonts-regular` (base.css:64) therefore resolves to ark-pixel +
  system stack + "Noto Sans"/"Liberation Sans"/sans-serif + `--fonts-emoji`.
- Dropped `@import` for Mona Sans (round 3) and LXGW WenKai Screen (round 2);
  `@import` order contract still satisfied (exactly one import, still the first
  statement after the header comment). Kept the Fira Code/Fira Mono import and the
  ark-pixel `@font-face` byte-identical. `--fonts-monospace` untouched: code remains
  Fira (verified consumers: base.css:96-101 `pre/code/kbd/samp`, :430 `.sha.label`,
  :652 `.lines-code`; codeeditor.css:29; easymde.css:16,151; console.css:7;
  jupyter.css:10; commit-sign.css:15 — and chroma.css declares no family, so nothing
  re-routes code to the proportional face).
- Round-3 log entries above that describe Mona Sans/LXGW as live are superseded;
  the webfont-verification findings stay as history (the licenses/CDN analysis is
  now moot since neither is loaded).
- Body size: unchanged at 16px (T-008). Accepted tradeoff, logged per instruction:
  ark-pixel is drawn on a 12px grid, so 16px is a 1.333x non-integer scale of the
  design grid (mildly uneven rasterization of the outline woff2); 12px would be
  native but too small for body copy and 24px too large. 24px leading (T-008) lands
  on 2 grid units, so the vertical rhythm stays on the design grid even though the
  glyph scale is not.

**CORRECTION to the round-2 analysis (font_i18n.css), flagged for the human.** The
round-2 log above concludes that `:root :lang(ja)` (font_i18n.css:1-19) "never
matches real content" because `lang` sits on `<html>`. That is wrong: `:lang()`
matches descendants through *inherited* language, so in a document with
`<html lang="ja|zh-CN|zh-TW|zh-HK|ko">` every body element matches, `--fonts-override`
is set on it, and `--fonts-regular` leads with the system CJK face
(`font_i18n.css:26-30`, and `:36-40` under `@supports (-moz-appearance: none)`).
The system-ui-* faces are unicode-range'd to CJK codepoints only, so within those
locale pages CJK text renders from PingFang/Hiragino/Noto CJK/YaHei rather than
ark-pixel, while Latin still resolves to ark-pixel. Consequence for round 4: the
"all body text is ark-pixel" decision holds on non-CJK-locale pages (and for CJK
content shown there, ark-pixel's zh_cn build supplies the glyphs), but a zh/ja/ko
page still prefers its system CJK face — upstream's own i18n design, not something
this change introduced, and unchanged in effect by dropping LXGW (which sat *after*
those faces in the ladder all along). Left as-is this round: neutralising it is a
one-line `:root { --fonts-override: var(--fonts-proportional) }` (or reordering via
a later `:root :lang()` rule) and it changes upstream CJK rendering, so it needs a
human call before I touch it. Flagged in the fonts.css comment too.

- Verification: exactly one `@import` and one `@font-face` (other matches are prose
  in comments), braces balanced, no raw hex, no second family declared.
