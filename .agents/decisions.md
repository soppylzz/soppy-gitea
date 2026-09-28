# Decisions — binding choices, append-only

Format: `D-###` / date / status (`accepted`, `proposed`, `superseded by D-###`) /
context → decision → consequences. Agents must follow `accepted` entries; to change one,
append a superseding entry — never edit or delete existing text. Work that would violate
an accepted decision stops and files a `proposed` entry instead.

## Accepted

### D-001 — 2026-09-28 — Target Gitea 1.27.3, pinned reference paths
Context: the theme must match a real instance; agents need one stable ground truth.
Decision: pin to `/Users/soppylzz/code/reference/gitea` (1.27.3) and
`/Users/soppylzz/code/reference/gitea-github-theme`. Re-pinning (Gitea upgrade) happens
only through a new decision entry, followed by a re-audit task.
Consequences: selectors and vars are validated against this tree only; upstream drift
invalidates past audits.

### D-002 — 2026-09-28 — AGENTS.md is the canonical harness
Context: three agent families (Claude Code, Codex, Pi) share this repo.
Decision: all conduct and workflow lives in `AGENTS.md`; `CLAUDE.md` only imports it;
Codex and Pi read `AGENTS.md` natively. No agent-specific instructions anywhere else.
Consequences: harness changes are single-commit and apply to every agent at once.

### D-003 — 2026-09-28 — Language policy
Context: multi-agent repo with an international toolchain.
Decision: docs, comments, commit messages: English. Conversation with the human: any
language the human prefers.
Consequences: reviewers can grep the repo for non-English artifacts as a lint.

### D-004 — 2026-09-28 — Deliverable shape: override-layer CSS
Context: verified mechanics (.agents/references.md): Gitea loads base `index.css` first,
then the theme file; discovery requires `theme-<name>.css` with a
`gitea-theme-meta-info` block.
Decision: our output is one override-layer CSS file per variant (light, dark at minimum),
each carrying the meta-info block; we do NOT ship a full standalone stylesheet.
Consequences: far simpler pipeline than gitea-github-theme; every rule we write relies on
cascade order, so specificity discipline matters (.agents/conduct.md).

## Open (proposed or unassigned)

- D-005 (open) — Theme final name and token prefix. Working title "soppy" /
  `--soppy-*`. Decides output filenames, meta display name, and repo branding. Owner: human.
- D-006 (open) — Source layout and build pipeline. Candidates: plain CSS files composed
  at build time (simplest, sufficient for D-004) vs a token-generation setup inspired by
  gitea-github-theme. Must produce deterministic output and a snapshot-style check.
- D-007 (open) — Pixel font selection and license (must be redistributable; WOFF2).
- D-008 (open) — This repo's license. gitea-github-theme is Apache-2.0/NOTICE; adapting
  its code would impose obligations. Original palette/design keeps us free to choose.
- D-009 (open) — Distribution: git tags + release assets vs manual copy into
  `<custom>/public/assets/css/`.

### D-010 — 2026-09-28 — Harness layout: thin AGENTS.md + `.agents/` detail (refines D-002)
Context: AGENTS.md loads into every agent session, so a 90-line file is per-session
overhead, and detail was duplicated across AGENTS.md and `docs/`.
Decision: AGENTS.md keeps only non-negotiables plus a reading-order table; all detail
lives in `.agents/` (`project.md`, `conduct.md`, `workflow.md`, `references.md`,
`decisions.md`). The former `docs/` directory is merged into `.agents/`;
`conventions.md` is renamed `conduct.md`. CLAUDE.md still imports only AGENTS.md.
Consequences: agents must follow the reading order — the non-negotiables are written so
skipping the detail files still stays safe on critical rules; repo path references point
into `.agents/` from now on.

### D-011 — 2026-09-28 — `.agents/` taxonomy: `rules/` + `references/` (supersedes D-010 layout)
Context: five flat files blur the line between normative rules and descriptive material.
Decision: `.agents/rules/` holds normative docs (`conduct.md`, `workflow.md`);
`.agents/references/` holds descriptive material (`project.md`, `ground-truth.md`);
`.agents/decisions.md` stays at the `.agents/` root as the append-only ledger — it is
neither rule nor reference and is bound via AGENTS.md non-negotiables.
Consequences: any flat `.agents/<name>.md` path written before D-011 resolves to the new
location (`conduct` → `rules/conduct`, `workflow` → `rules/workflow`, `project` →
`references/project`, `references` → `references/ground-truth`); historical entries keep
their original paths unedited.

### D-012 — 2026-09-28 — `tasks/` stays at the repo root (not inside `.agents/`)
Context: raised by the human — should the task system live under `.agents/`?
Decision: `tasks/` remains a top-level directory. `.agents/` is the low-churn harness
(normative rules + descriptive references); tasks are operational state co-owned by the
human and the agents, churned every session, and must stay visible to the human at a
glance — a dot-directory hides exactly the part that needs human attention most.
Consequences: agents must never relocate `tasks/` or nest it under `.agents/`; task
churn never pollutes harness diffs; `.agents/` stays reserved for rules, references,
the decision ledger, and possible future per-agent configuration.

### D-013 — 2026-09-28 — First implementation sprint (supersedes D-005, D-006, D-007; partial D-009)
Context: human instructed to proceed with: preview via the deployment-shape loop
(方案 1), a minecraft.net-inspired pixel design, ark-pixel-12px-monospaced-zh_cn as the
regular font, Noto Serif SC (loaded from Google Fonts) as the code font, and sub-agent
dispatch.
Decision: theme name **soppy** — outputs `theme-soppy-light.css` / `theme-soppy-dark.css`,
token prefix `--soppy-*`. Pipeline: plain CSS section files concatenated by a shell
script — no node toolchain (override-layer output per D-004 makes a bundler redundant;
revisit only if token generation becomes necessary). Distribution: copy into
`<custom>/public/assets/` of a local instance running under gitignored `gitea-root/`;
custom asset URLs use the `/assets/soppy/` namespace (repo `assets/` dir, holds the
font and `landscape.png` brand art used as the home hero background).
Fonts: `@font-face "Ark Pixel 12 Monospace SC"` for `--fonts-proportional`;
`--fonts-monospace` = "Noto Serif SC" via `@import` of Google Fonts, per explicit human
choice — the proportional (non-mono) nature of Serif SC for code is a known, accepted
tradeoff. Font sizes should snap to the pixel grid where feasible.
Consequences: `src/` holds section files (fonts, palette-light, palette-dark,
components); `scripts/build.sh` assembles `dist/`; agents working in parallel own
disjoint files; orchestrator runs gates and commits.

### D-014 — 2026-09-28 — Typography architecture v2 (supersedes D-013 typography)
Context: G3 round-2 feedback — code font is the Fira Code + Fira Mono stack; body font
is LXGW WenKai Screen; ark-pixel becomes display-only (mc.net pattern: headings and
stylized surfaces, never body/inputs/code).
Decision: `--fonts-monospace` = "Fira Code", "Fira Mono", monospace stack (Google
Fonts); `--fonts-proportional` = "LXGW WenKai Screen" (jsdelivr CDN, human-specified
@latest URL — pinned version is a logged option if reproducibility matters); display
face exposed as `--soppy-font-pixel` contract token. Noto Serif SC dropped. CDN-served
fonts redistribute nothing (no vendored licenses); ark-pixel remains vendored with
assets/OFL.txt. Consequence accepted: LXGW registers weight 400 only — 500/600 UI
text is browser-synthesized.
Consequences: D-013's font clauses are superseded; its pipeline/preview/name clauses
stand.

### D-015 — 2026-09-28 — Typography v3: ark-pixel body, Fira code (supersedes D-014)
Context: G3 round 4 — human decision: all body text back to ark-pixel; only code keeps
the Fira pair.
Decision: `--fonts-proportional` leads with "Ark Pixel 12 Monospace SC" (system stack
covers glyph gaps); the Mona Sans and LXGW WenKai Screen @imports are dropped (CDN deps
down to Google Fonts for Fira); the display-face layer and `--soppy-font-pixel` token
are removed as no-ops. Anti-smear weight pins are kept but now mirror upstream's own
selectors — two round-3 rules had insufficient specificity to win (fixed). Buttons
inherit the pixel face via upstream's own declaration (button.css:7); with nowrap plus
wider pixel glyphs, long localized button labels are the top visual watch item.
Consequences: one page face plus one code face. Supersedes D-014.

### D-016 — open — CJK locale font override
`font_i18n.css:1-19` sets `--fonts-override` on elements of ja / zh-CN / zh-TW / zh-HK /
ko pages via `:lang()`, which matches descendants through inherited language, so CJK
text on those locale pages renders in the system CJK face while Latin stays ark-pixel.
Mirroring the upstream `:root :lang(...)` selectors with
`--fonts-override: var(--fonts-proportional)` would force ark-pixel there too. Pending
the human's call because it overrides upstream i18n behaviour for CJK users, even though
ark-pixel's zh_cn variant exists precisely to cover CJK.

### D-017 — 2026-09-28 — CJK locale font override neutralized (resolves D-016)
Context: human reported ark-pixel not applying after switching the UI to Simplified
Chinese — exactly the D-016 mechanism.
Decision: mirror upstream's `:root :lang(ja|zh-CN|zh-TW|zh-HK|ko)` selectors at the
same specificity (0,2,0; our file loads later) and point `--fonts-override` back at
`var(--fonts-proportional)`, so the body face leads in every language we ship. Glyphs
ark-pixel lacks fall through the stack as before.
Consequences: upstream's per-language native-font preference is intentionally
overridden; if a locale ever needs its native face back, it is one selector entry.

### D-018 — 2026-09-28 — Release distribution and bilingual docs (resolves D-009; refines D-003)
Context: release preparation. D-009 left distribution open (tags + release assets vs manual
copy); D-003 sets docs to English; the human asked for GitHub-release delivery and a
Chinese README.
Decision: releases are cut by tag push (`v*`). `.github/workflows/release.yml` runs
`scripts/check.sh`, then `scripts/package.sh` builds `dist/soppy-<version>.zip` whose root
mirrors `<custom>/public/` (`assets/css/`, `assets/soppy/`, `assets/img/`, plus `INSTALL.md`
from `RELEASE.md`), and publishes it as a release asset; `ci.yml` runs the same checks on
push and pull request. The README is maintained in two languages — `README.md` (en,
canonical) and `README.zh.md` (zh) — kept structurally in step. Every other doc, all
comments and all commit messages stay English per D-003.
Consequences: the release archive is the supported install path and is built from `dist/`,
never hand-assembled; anything the shipped CSS references under `/assets/soppy/` must be in
the archive, which `check.sh` enforces; the English README wins on any conflict with the
translation. D-008 (this repo's own license) still blocks a *public* release: the repo has
no `LICENSE`, so the code ships all-rights-reserved until that entry lands. The bundled
font is unaffected — it is already OFL and `OFL.txt` travels in the archive.

### D-019 — 2026-09-28 — MIT license (resolves D-008)
Context: a public GitHub release cannot ship without a license; D-008 left the choice open
pending whether any gitea-github-theme code had been adapted.
Decision: the repo is **MIT** (`LICENSE`, © 2026 soppylzz). No gitea-github-theme code was
copied — it served as a structural reference only, the pipeline is plain shell (D-013) and
the CSS is written against the pinned Gitea tree — so no Apache-2.0/NOTICE obligation
applies.
Consequences: the theme CSS and artwork are freely usable, modifiable and redistributable;
the bundled font keeps its own OFL, and `assets/OFL.txt` must travel with any
redistribution (`package.sh` includes it, `check.sh` guards the asset set).

### D-020 — 2026-09-28 — Colored fills keep their hues; the text ink flips (T-010)
Context: pre-release review. Gitea paints text on every solid `.ui.<color>.label` and
`.ui.<color>.button` with a hardcoded `color: var(--color-white)`
(`modules/label.css:90-182`, `modules/button.css:216-268`, `actions.css:9-28`). The dark
ladder's named colors are bright by design, so white text measured 1.34:1 on
`--color-green` — the Open issue badge — and 2.64-3.96:1 on the rest, all below AA.
Upstream avoids this by choosing mid-tone named colors (its dark red is 4.58:1).
Decision: keep the bright hues and flip the *ink* instead. `--soppy-ink-on-color` is
`#ffffff` in the light variant (where the fills are dark, and where it matches upstream's
own behaviour) and `#0a0a0f` in the dark one; `components.css` applies it to those fills.
Rejected: muting the dark named colors to mid-tones, which would have flattened the pxlkit
palette the human signed off on.
Consequences: every colored fill in the dark variant now clears AA (worst case 4.99:1).
The ink is a `--soppy-*` token because Gitea exposes no generic "text on a colored fill"
variable — `--color-primary-contrast` covers only the primary fill. The light variant's
own bright fills (yellow, orange, red-light) remain below AA exactly as upstream's do;
fixing those needs a palette decision and is logged in T-010 as an open item.

### D-021 — 2026-09-28 — Versions come from version.txt; the workflow creates the tag (supersedes D-018's trigger)
Context: D-018 cut releases from a hand-pushed tag. The human asked for the version to be
data in the repo and for the tag to be created by the workflow, so tags exist only where
a release happened and nobody tags by hand.
Decision: `version.txt` (MAJOR.MINOR.PATCH) is the single source of truth. `release.yml`
runs on a `version.txt` change on `main` (and on manual dispatch), resolves the version
with `scripts/version.sh` against the newest `v*` tag, and — when that tag does not exist
yet — runs the G2 checks, packages the archive and creates both the tag and the release.
Resolution rule: a declared version ahead of the newest tag is the release; an equal or
older one falls back to a patch bump of the newest tag; a tag that already exists ends the
run.
Consequences: a forgotten bump yields a patch release rather than a duplicate or a
backwards move. `actions/checkout` must keep `fetch-depth: 0`, or the tag list is empty
and every run looks like a first release. `check.sh` validates the file's shape and
`package.sh` defaults to it. README carries only project information; the release
procedure, the reference trees and the way the human drives an agent live in `.agents/`.
